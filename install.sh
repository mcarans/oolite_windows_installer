pacman -S dos2unix --noconfirm
pacman -S pactoys --noconfirm
pacboy -S binutils --noconfirm

cd packages

package_names=(pcaudiolib espeak-ng nspr spidermonkey gnustep-make gnustep-base SDL)

for packagename in "${package_names[@]}"; do
    echo "Installing $packagename package"
	pacman -U *$packagename*any.pkg.tar.zst --noconfirm
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
make -f Makefile release$1 -j16
make -f Makefile pkg-win$1
cp installers/win32/OoliteInstall* ../installer/
