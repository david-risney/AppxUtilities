@echo off
if "%1"=="/?" goto help
if "%1"=="/h" goto help
if "%1"=="-?" goto help
if "%1"=="-h" goto help

%systemroot%\system32\windowspowershell\v1.0\powershell.exe -ExecutionPolicy RemoteSigned -Command . %~dpn0.ps1 %*
goto end

:help
%systemroot%\system32\windowspowershell\v1.0\powershell.exe -ExecutionPolicy RemoteSigned -Command help %~dpn0.ps1 -full
goto end

:end
