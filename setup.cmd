@echo off
setlocal

:: Change directory to the folder containing this script
cd /D "%~dp0"
echo Running in: %CD%

:: Prompt the user for a path
set /p INSTALL_PATH=Enter the installation path: 

:: Prompt the user for whether to install gcc or clang
set /p GCC_OR_CLANG=Enter compiler to use - gcc or clang: 

:: Where to download Oolite dependencies
set OOLITE_DEPS_URL=https://api.github.com/repos/mcarans/oolite_mingw64_environment/releases/latest
mkdir packages

echo === Download Oolite dependencies ===
powershell -NoLogo -NoProfile -Command "$release=Invoke-RestMethod %OOLITE_DEPS_URL%; foreach ($asset in $release.assets) {Invoke-WebRequest $asset.browser_download_url -OutFile (Join-Path packages $asset.name)}"

:: Where to download installer
set MSYS2_URL=https://github.com/msys2/msys2-installer/releases/latest/download/msys2-base-x86_64-latest.sfx.exe
set INSTALLER=%TEMP%\msys2-base.sfx.exe

echo === Download MSYS2 base archive ===
powershell -Command "Invoke-WebRequest -Uri %MSYS2_URL% -OutFile '%INSTALLER%'"

echo === Extract MSYS2 to %MSYS2_ROOT% ===
:: -y = assume Yes, -o = output dir
"%INSTALLER%" -y -o%INSTALL_PATH%

:: Run a login shell once to initialize keyrings and base setup
echo === Initialise MSYS2 ===
:: Where MSYS2 is installed
set MSYS2_ROOT=%INSTALL_PATH%\msys64

%MSYS2_ROOT%\usr\bin\bash -lc "pacman-key --init"
%MSYS2_ROOT%\usr\bin\bash -lc "pacman-key --populate msys2"
%MSYS2_ROOT%\usr\bin\bash -lc "pacman -Sy --noconfirm pacman"
%MSYS2_ROOT%\usr\bin\bash -lc "pacman -Syu --noconfirm"

echo === Launch MinGW64 shell, install Oolite dependencies and install Oolite  ===
%MSYS2_ROOT%\msys2_shell.cmd -mingw64 -defterm -here -no-start -c "./install.sh %GCC_OR_CLANG%; exec bash"

endlocal
