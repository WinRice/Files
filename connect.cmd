@echo off
cd /d "%~dp0"
echo Uninstalling the Connect app...
CLS
install_wim_tweak.exe /o /l
install_wim_tweak.exe /o /c  Microsoft-PPIProjection-Package /r
install_wim_tweak.exe /h /o /l
echo The Connect app should be uninstalled. Please reboot Windows 10.
pause