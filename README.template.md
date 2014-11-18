# AppxUtilities

Fill in functionality gaps for Windows Store AppX package PowerShell commands.

## Install

 - Extract the contents of [AppxUtilties.zip](https://david-risney.github.io/AppxUtilities/AppxUtilities.zip) into a temporary directory. 
 - Open a new PowerShell prompt, cd to the temporary directory, and run ```Unblock-File *```. 
 - Move the files to somewhere in your PATH.

Or try the new remote install script:

    (new-object Net.WebClient).DownloadString("https://david-risney.github.io/AppxUtilities/install.ps1") | iex

## Commands

AppxUtilities provides the following commands:

 - Process package info ```Get-ProcessAppxPackage wwahost```
 - Appx file to package info ```dir *appx | Get-AppxPackageFile```
 - Launch an app from a package info ```Get-AppxPackageExt *Skype* | Launch-AppxPackage```
 - Debug a package ```Get-AppxPackageExt *Cloud* | Debug-AppxPackage -OnLaunch "C:\debuggers\windbg.exe"```
 - Get more package info ```Get-AppxPackageExt.ps1```
 - Add appx package with force override and resulting package info ```Add-AppxPackageExt.ps1 *appx -Force```
 - Launch a background task for an appx package ```Get-AppxPackageExt *Skype* | Launch-AppxPackageBackgroundTask```
 - Suspend a running appx package process ```Get-AppxPackageExt *Skype* | Suspend-AppxPackage```
 - Resume a running appx package process ```Get-ProcessAppxPackage *Skype* | Resume-AppxPackage```
 - Terminate a running appx package process ```Get-ProcessAppxPackage *Skype* | Terminate-AppxPackage```

{commandHelp}

## Interacting with existing Appx commands

Because these scripts return their own types existing commands like Get-AppxPackage or Remove-AppxPackage don't work with them. To fix this you can use the ```-Merge``` on any of the AppxUtilities commands. This will add the AppxUtility properties to the original AppxPackage or Process object rather than creatings its own. In this way you can use the output of AppxUtility commands with existing Appx PowerShell commands, but the AppxUtilities properties won't be displayed.

    C:\Users\Dave> Get-AppxPackageExt.ps1 *BackgroundTask* -Merge
    
    
    Name              : Microsoft.SDKSamples.BackgroundTask.JS
    Publisher         : CN=Microsoft Corporation, O=Microsoft Corporation, L=Redmond, S=Washington, C=US
    Architecture      : Neutral
    ResourceId        :
    Version           : 1.0.0.0
    PackageFullName   : Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    InstallLocation   : C:\Program Files\WindowsApps\Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    IsFramework       : False
    PackageFamilyName : Microsoft.SDKSamples.BackgroundTask.JS_8wekyb3d8bbwe
    PublisherId       : 8wekyb3d8bbwe
    IsResourcePackage : False
    IsBundle          : False
    IsDevelopmentMode : False
    Dependencies      : {Microsoft.WinJS.2.0_1.0.9600.17018_neutral__8wekyb3d8bbwe}
    
    
    
    C:\Users\Dave> Get-AppxPackageExt.ps1 *BackgroundTask* -Merge | Remove-AppxPackage


## Combined examples

Install and launch a package under the debugger.

    Add-AppxPackageExt .\App.appx | Debug-AppxPackage -OnLaunch "C:\debuggers\windbg.exe -server tcp:port=9100 -g -G -o" | Launch-AppxPackage;

Uninstall a package based on its file.

    Get-AppxPackageFile .\App.appx -Merge | Remove-AppxPackage;

Resume all suspended apps.

    Get-ProcessAppxPackage | where State -eq suspended | Resume-AppxPackage

