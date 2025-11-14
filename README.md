# Oolite MSYS2 MinGW64 Windows Installer

Creates release of Windows Oolite NSIS packages using versioned MSYS2 MinGW64 dependencies

You can also create an environment locally, installing pre-built dependencies, as follows:

Double click Run Me. You will be prompted for an install location. If you type c:, MSYS2 will be installed in c:\msys64. You will then be prompted for the compiler to use. Type gcc or clang as desired. Then Oolite's dependencies will be installed followed by building Oolite installers. 

Once completed, you can type the following in the shell: 

    cd oolite/oolite.app
	./oolite.exe
	
Run Me is a shortcut which runs setup.cmd. setup.cmd downloads the pre-built Oolite dependencies and installs MSYS2. It passes parameter gcc or clang to install.sh. install.sh builds Oolite's release and release-deployment installers. The GitHub Action passes no parameters which creates a clang build followed by a gcc build of release and release-deployment installers.
