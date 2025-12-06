# Oolite MSYS2 Windows Installer Builder and Quick Local Setup

Creates release of Windows Oolite NSIS packages using versioned MSYS2 UCRT64 Clang or MinGW64 GCC dependencies. The GitHub Action creates a UCRT64 Clang build followed by a MinGW64 GCC build of release and release-deployment installers. The installers are then put into the release on GitHub.

You can also create an environment locally, installing pre-built dependencies, as follows:

Double click Run Me. The Run Me shortcut runs setup.cmd. setup.cmd installs MSYS2. You will be prompted for an install location. If you type c:, MSYS2 will be installed in c:\msys64. You can choose the MSYS2 environment and compiler combination - 1 for UCRT64 Clang or 2 for MinGW64 GCC. setup.cmd launches the aprropriate MSYS2 shell corresponding to the chosen environment and passes gcc or clang as a parameter to install.sh. install.sh builds Oolite's release and release-deployment installers.

Once completed, you can type the following in the shell: 

    cd oolite/oolite.app
	./oolite.exe

If you subsequently wish to try the other environment/compiler combination, open the environment's shell and then run install.sh passing parameter gcc or clang as appropriate.
