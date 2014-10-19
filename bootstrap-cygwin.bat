@echo off

set /p ARCH= What architecture (x86/x86_64)? 
set /p SSHD_PORT= Which sshd port (e.g. 53201 or 56401)? 

@echo on
set NAME=cygwin-%SSHD_PORT%
set SSHD_SERVICE=%NAME%-sshd

set DRIVE=c:
set CACHEDIR=%DRIVE%\cygwin-download
set TARGETDIR=%DRIVE%\%NAME%

set SETUPEXE=setup-%ARCH%.exe

set BASH=%TARGETDIR%\bin\bash


%SETUPEXE% -q -X -O -s http://cygwin.ternaris.com/cygwin -R %TARGETDIR% -l %CACHEDIR% -P git -P git-completion -P nix -P openssh -P wget
copy %SETUPEXE% %TARGETDIR%\
%BASH% -l -c "ln -s %SETUPEXE% /setup.exe"


%BASH% -l -c "wget https://0x2c.org/~cf1/rc-user-home-gitdir.tar.xz"
%BASH% -l -c "tar xfJ rc-user-home-gitdir.tar.xz"
%BASH% -l -c "git checkout master ."


%BASH% -l -c "./bin/ssh-host-config --yes --name %SSHD_SERVICE% --cygwin ntsec --port %SSHD_PORT% --user cyg_server"
%BASH% -l -c "sed -i /etc/sshd_config -e 's,^.*PermitUserEnvironment.*$,PermitUserEnvironment yes,'
%BASH% -l -c "cygrunsrv --start %SSHD_SERVICE%


> %TARGETDIR%\rebase.bat (
@echo.%DRIVE%
@echo.chdir %TARGETDIR%\bin
@echo.dash -c '/bin/find /nix/store -regextype posix-egrep -regex ".*\.(dll|so)" ^>/rebase.list'
@echo.dash -c '/bin/rebaseall -p -T /rebase.list'
@echo.pause
)

> %TARGETDIR%\start-sshd.bat (
@echo.%BASH% -l -c "cygrunsrv --start %SSHD_SERVICE%
)

> %TARGETDIR%\stop-sshd.bat (
@echo.%BASH% -l -c "cygrunsrv --stop %SSHD_SERVICE%
)

@echo sshd is ready on port %SSHD_PORT%
@echo Check your firewall settings!

pause