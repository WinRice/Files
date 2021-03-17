@echo off
cd /d "%~dp0"
CLS
install_wim_tweak.exe /o /l
install_wim_tweak.exe /o /c  Microsoft-PPIProjection-Package /r
install_wim_tweak.exe /h /o /l
exit
