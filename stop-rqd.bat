@echo off
:: OpenCue RQD Client Stop Batch Wrapper

:: Launch the PowerShell script with the same arguments
powershell -ExecutionPolicy Bypass -File "%~dp0stop-rqd.ps1" %*

:: If the script returns with an error, pause to let the user read the message
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Press any key to exit...
    pause >nul
) 