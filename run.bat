::set 8:43:22 to 08:43:22
if "%time:~0,2%" lss "10" (set H=0%time:~1,1%) else (set H=%time:~0,2%)

::format date
set DF=%DATE:~0,4%-%DATE:~5,2%-%DATE:~8,2%

::format time
set TF=%H%-%TIME:~3,2%-%TIME:~6,2%

set SIM=%~dp0/runtime/win32/LuaFlJoy.exe
set WORKDIR=%~dp0
set POS=685,50

set LOGNAME=%DF%-%TF%.log
set LOGDIR=%WORKDIR%log\
if not exist %LOGDIR% md %LOGDIR%
::remain 9 add cur 1
set LOGNUM=9
pushd %LOGDIR%
for /f "skip=%LOGNUM% tokens=*" %%i in ('dir/b/o-d *.log') do del %%i
::run
start %SIM% -workdir %WORKDIR% -position %POS% -write-debug-log %LOGDIR%%LOGNAME% -scale 0.75
::pause