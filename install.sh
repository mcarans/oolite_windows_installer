pacman -S dos2unix --noconfirm
pacman -S pactoys --noconfirm
pacboy -S binutils --noconfirm

cd packages

package_names=(gnustep-make gnustep-base spidermonkey pcaudiolib espeak-ng SDL)

for packagename in "${package_names[@]}"; do
    echo "Installing $packagename package"
	if ! pacman -U *$packagename*any.pkg.tar.zst --noconfirm ; then
	    echo "❌ $packagename install failed!"
	    exit 1
	fi
done

cd ..

pacman -S git --noconfirm
pacboy -S libpng --noconfirm
pacboy -S openal --noconfirm
pacboy -S libvorbis --noconfirm
pacman -S make --noconfirm
pacboy -S nsis --noconfirm

mkdir installer
pacman -Q > installer/installed-packages.txt

rm -rf oolite
git clone -b modern_build https://github.com/mcarans/oolite.git
cd oolite

cp .absolute_gitmodules .gitmodules
git submodule update --init
git checkout -- .gitmodules

source /mingw64/share/GNUstep/Makefiles/GNUstep.sh

make -f Makefile clean
make -f Makefile release -j16
make -f Makefile pkg-win
cp installers/win32/OoliteInstall-* ../installer/

make -f Makefile clean
make -f Makefile release-deployment -j16
make -f Makefile pkg-win-deployment
cp installers/win32/OoliteInstall-* ../installer/

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
