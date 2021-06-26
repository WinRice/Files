# Files
This repository contains files that CleanWin downloads while performing a task that requires internet connection (for instance: downloading Microsoft.VCLibs appx file that which is a dependency required to install WinGet).

## Description of files:   
**mach2.exe** and ***msdia140.dll** are from the [mach2](https://github.com/riverar/mach2/) project by [riverar](https://github.com/riverar).  
**Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.appxbundle**: WinGet AppInstaller bundle file.    
**Microsoft.VCLibs.140.00.UWPDesktop_14.0.29231.0_x64__8wekyb3d8bbwe.Appx**: A dependency required for WinGet to install properly.    
**ViveTool.exe**: An executable that I use to hide the "Browser settings - Restore recommended" ~suggestion~ ad from Settings.    
**Albacore.ViVe.dll**: A DLL file that ViVeTool uses.   
**connect.cmd**: A cmd script to remove Connect app bundled in Windows 10 1909 and below.   
**install_wim_tweak.exe**: An executable required by connect.cmd.  
**settings.json**: WinGet settings file with all experimental features enabled.



## Credits   
ViVeTool and its dependencies are copyrighted content of [thebookisclosed](https://github.com/thebookisclosed), licensed under the GPL v3 license.    
mach2 and its dependencies are copyrighted content of [riverar](https://github.com/riverar), licensed under the GPL v3 license.
Microsoft.DesktopAppInstaller and its dependencies are copyrighted content of Microsoft, with WinGet-CLI licensed under the MIT license

The authors of connect.cmd and install_wim_tweak.exe are unknown. If you know them, or if you are them, please mail me [here](mailto:pratyakshm@protonmail.com) with your name or online alias to get your name written here.

Takedown requests are respected.