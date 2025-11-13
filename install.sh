# No parameters: build both clang and gcc in that order (end setup will be for gcc)
# One parameter gcc = build gcc only (end setup will be for gcc)
# One parameter clang = build clang only (end setup will be for clang)

getname_or_rename() {
	# First parameter is package name
	# Second parameter is file pattern
	# Third parameter is whether to rename
	# Fourth optional parameter is gcc or clang
    if [ -z "$4" ]; then
		fullname=$1
    else
		fullname="${1}_${4}"
    fi
    filename=$(ls $2 2>/dev/null)
    if [ -z "$filename" ]; then
        echo "❌ No file matching $2 found."
        exit 1
    fi
    if [ "$4" ]; then
        newname="${filename/$1/$fullname}"
        if [[ "$3" == "rename" ]]; then
			mv $filename $newname
		fi
        filename=$newname
	fi

	echo "${filename}" "${fullname}"
}

install() {
	# First parameter is package name
	# Second optional parameter is gcc or clang
    echo "Installing $1 package"

	# package file eg. mingw-w64-x86_64-libobjc2-2.3-3-any.pkg.tar.zst
	read filename fullname <<< "$(getname_or_rename $1 "*$1*any.pkg.tar.zst" "get" $2)"
    if ! pacman -U $filename --noconfirm ; then
	    echo "❌ $filename install failed!"
	    exit 1
	fi
}

move_installer() {
	# First parameter is gcc or clang
	
	cd installers/win32
	read filename fullname <<< "$(getname_or_rename "OoliteInstall" "OoliteInstall-*" "rename" $1)"
	mv $filename ../../../installer/
	cd ../..
}

pacman -S dos2unix --noconfirm
pacman -S pactoys --noconfirm
pacboy -S binutils --noconfirm

cd packages
echo "Installing common libraries"
package_names=(spidermonkey pcaudiolib espeak-ng SDL)
for packagename in "${package_names[@]}"; do
	install $packagename
done
cd ..

pacman -S git --noconfirm
pacboy -S libpng --noconfirm
pacboy -S openal --noconfirm
pacboy -S libvorbis --noconfirm
pacman -S make --noconfirm
pacboy -S nsis --noconfirm

rm -rf oolite
git clone -b modern_build https://github.com/mcarans/oolite.git
cd oolite
cp .absolute_gitmodules .gitmodules
git submodule update --init
git checkout -- .gitmodules
cd ..

mkdir installer

if [[ -z "$1" || "$1" == "clang" ]]; then
	cd packages
	echo "Installing GNUStep libraries with clang"
	export cc=/mingw64/bin/clang
	export cpp=/mingw64/bin/clang++
	clang_package_names=(libobjc2 gnustep-make gnustep-base)
	for packagename in "${clang_package_names[@]}"; do
		install $packagename clang
	done
	cd ..
	pacman -Q > installer/installed-packages-clang.txt
	source /mingw64/share/GNUstep/Makefiles/GNUstep.sh

	cd oolite
	make -f Makefile clean
	make -f Makefile release$1 -j16
	move_installer clang
	make -f Makefile pkg-win$1
	move_installer clang
	cd ..
fi

if [[ -z "$1" ]]; then
	echo "Uninstalling clang GNUStep libraries"
	pacboy -R gnustep-base
	pacboy -R gnustep-make
	pacboy -R libobjc2
fi

if [[ -z "$1" || "$1" == "gcc" ]]; then
	cd packages
	echo "Installing GNUStep libraries with gcc"
	export cc=/mingw64/bin/gcc
	export cpp=/mingw64/bin/g++
	gcc_package_names=(gnustep-make gnustep-base)
	for packagename in "${gcc_package_names[@]}"; do
		install $packagename gcc
	done
	cd ..
	pacman -Q > installer/installed-packages-gcc.txt
	source /mingw64/share/GNUstep/Makefiles/GNUstep.sh

	cd oolite
	make -f Makefile clean
	make -f Makefile release$1 -j16
	move_installer gcc
	make -f Makefile pkg-win$1
	move_installer gcc
	cd ..
fi

cp /mingw64/share/GNUstep/Makefiles/GNUstep.sh /etc/profile.d/

if ! grep -q "# Custom history settings" ~/.bashrc; then
  cat >> ~/.bashrc <<'EOF'

# Custom history settings
WIN_HOME=$(cygpath "$USERPROFILE")
export HISTFILE=$WIN_HOME/.bash_history
export HISTSIZE=5000
export HISTFILESIZE=10000
shopt -s histappend
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
EOF
fi
