# Files
This repository contains files that CleanWin downloads while performing a task that requires internet connection (for instance: downloading Microsoft.VCLibs appx file that which is a dependency required to install WinGet).

Description of files:   
**NetTestFile**: Used to test internet connection of users because I'm not yet aware of any other way to do that  
**Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.appxbundle**: WinGet-CLI AppInstaller bundle file  
**Microsoft.VCLibs.140.00.UWPDesktop_14.0.29231.0_x64__8wekyb3d8bbwe.Appx**: A dependency required for WinGet to install properly  
**ViveTool.exe**: An executable that I use to hide the "Browser settings - Restore recommended" ~suggestion~ ad from Settings  
**Albacore.ViVe.dll**: A DLL file that ViVeTool uses  
**connect.cmd**: A cmd script to remove Connect app bundled in Windows 10 1909 and below  
**install_wim_tweak.exe**: An executable required by connect.cmd  
**settings.json**: WinGet settings file with all experimental features enabled, though this is specifically used to enable the "uninstall" feature that is currently used to uninstall 64-bit versions of OneDrive



# Credits   
ViVeTool and its dependencies are copyrighted content of https://github.com/thebookisclosed, licensed under the GPL v3 license.    
Microsoft.DesktopAppInstaller and its dependencies are copyrighted content of Microsoft, with WinGet-CLI licensed under the MIT license

The authors of connect.cmd and install_wim_tweak.exe are unknown. If you know them, or if you are them, please mail me [here](mailto:pratyakshm@protonmail.com) with your name or online alias to get your name written here.
