# AppxUtilities

Fill in functionality gaps for Windows Store AppX package PowerShell commands.

## Install

 - Extract the contents of the [AppxUtilties.zip](https://david-risney.github.io/AppxUtilities/AppxUtilities.zip) file into a temporary directory. 
 - Open a new PowerShell prompt, cd to the temporary directory, and run ```Unblock-File *```. 
 - Move the files to somewhere in your PATH.

## Commands

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

### Query running process package info

AppxUtilities makes Get-ProcessAppxPackage.ps1 which tells you the PackageFullName and package execution state (suspended, running, terminated) in addition to the normal process name and process ID.

    PS C:\Users\Dave> Get-ProcessAppxPackage
    
    PackageFullName               State                         ProcessName                                              Id
    ---------------               -----                         -----------                                              --
    microsoft.windowscommunica... suspended                     livecomm                                              11516
    Microsoft.SkypeApp_2.8.0.1... suspended                     WWAHost                                               16796
    
    
    PS C:\Users\Dave> Get-ProcessAppxPackage Skype
    
    PackageFullName               State                         ProcessName                                              Id
    ---------------               -----                         -----------                                              --
    Microsoft.SkypeApp_2.8.0.1... suspended                     WWAHost                                               16796


For use in scripts there are also hidden properties Package and Process that get you the full Get-AppxPackageExt package object and the full Get-Process process object respectively.

### Query installed package info

The AppxUtilities Get-AppxPackageExt.ps1 provides a few more properties for each AppxPackage object over Get-AppxPackage including the following:

 - Display name.
 - Manifest as parsed XML.
 - InstallLocation as a file item.
 - Contained Application IDs.
 - Registered background tasks.

    PS C:\Users\Dave> Get-AppxPackageExt.ps1 *Skype*
    
    
    PackageFullName     : Microsoft.SkypeApp_2.8.0.1001_x86__kzf8qxf38zg5c
    DisplayName         : Skype
    InstallLocationItem : C:\Program Files\WindowsApps\Microsoft.SkypeApp_2.8.0.1001_x86__kzf8qxf38zg5c
    Manifest            : #document
    ApplicationIds      : {App}
    BackgroundTasks     : {@{Name=userAccountStateChangedBackgroundTask; Id={516560FE-4EEE-4FDE-9017-7B7742D656C4}},
                          @{Name=keepAliveTimerTriggerBackgroundTask; Id={47B17C4A-0953-416A-8EF0-EDFF9415E080}},
                          @{Name=refreshChannelUriBackgroundTask; Id={BC523B83-5B2F-4F37-972C-50877A49DE7A}}}
    InstallTimeUtc      : 5/7/2014 10:14:32 AM


For use in scripts there is also a hidden Package property that will give the original Get-AppxPackage package object.

### Query package file package info

Get the package info from an appx file. If the package contained in the appx file is installed, it returns the installed Get-AppxPackageExt package info and otherwise returns similar data found in the manifest.

    PS C:\Users\Dave> Get-AppxPackageFile.ps1 .\BackgroundTask.Windows_1.0.0.0_AnyCPU_Debug.appx
    
    
    Name                  : Microsoft.SDKSamples.BackgroundTask.JS
    DisplayName           : BackgroundTask JS sample
    Version               : 1.0.0.0
    Publisher             : CN=Microsoft Corporation, O=Microsoft Corporation, L=Redmond, S=Washington, C=US
    ProcessorArchitecture : neutral
    ApplicationIds        : {App}
    Manifest              : #document
    
    
    
    PS C:\Users\Dave> Add-AppxPackage .\BackgroundTask.Windows_1.0.0.0_AnyCPU_Debug.appx
    PS C:\Users\Dave> Get-AppxPackageFile.ps1 .\BackgroundTask.Windows_1.0.0.0_AnyCPU_Debug.appx
    
    
    PackageFullName     : Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    DisplayName         : BackgroundTask JS sample
    InstallLocationItem : C:\Program
                          Files\WindowsApps\Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    Manifest            : #document
    ApplicationIds      : {App}
    BackgroundTasks     : {}
    InstallTimeUtc      : 6/26/2014 2:53:15 PM


### Launch a packaged application

AppxUtilities makes Launch-AppxPackage.ps1 which launches Appx packaged applications. Provided with a package it will launch the first application in the package. Provided with a PackageFamilyName and ApplicationId it will launch that specific application. After launching it returns the Get-ProcessAppxPackage result for the launched process.

    PS C:\Users\Dave> Get-AppxPackageExt *BackgroundTask* | Launch-AppxPackage
    
    PackageFullName               State                         ProcessName                                              Id
    ---------------               -----                         -----------                                              --
    Microsoft.SDKSamples.Backg... running                       WWAHost                                               10604


### Launch a packaged application's background task

AppxUtilities lets you enumerate and launch the registered background tasks of an Appx application. Use the BackgroundTasks property of the Get-AppxPackageExt results to see available registered background tasks per Appx package. And use Launch-AppxPackageBackgroundTask to start a background task. Launch-AppxPackageBackgroundTask takes as input a package in which case it runs the first registered background task, or a background task property from a Get-AppxPackageExt result, or a GUID string that is the registered background task property.

    PS C:\Users\Dave> Get-AppxPackageExt *BackgroundTask*
    
    
    PackageFullName     : Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    DisplayName         : BackgroundTask JS sample
    InstallLocationItem : C:\Program
                          Files\WindowsApps\Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    Manifest            : #document
    ApplicationIds      : {App}
    BackgroundTasks     : {@{Name=SampleJavaScriptBackgroundTask; Id={A2D67B9C-80A3-4C0D-877D-10AE2915E597}}}
    InstallTimeUtc      : 6/26/2014 4:27:12 PM
    
    
    
    PS C:\Users\Dave> Get-AppxPackageExt *BackgroundTask* | Launch-AppxPackageBackgroundTask


### Add a package

The AppxUtilities Add-AppxPackageExt.ps1 has the following abilities beyond what the builtin Add-AppxPackage performs:

 - Install a package with the exact same package identity using the -Force switch.
 - Return the Get-AppxPackageExt package objects of what was just installed.


    PS C:\Users\Dave> Add-AppxPackageExt .\BackgroundTask2.appx
    Add-AppxPackage : Deployment failed with HRESULT: 0x80073CFB, The provided package is already installed, and
    reinstallation of the package was blocked. Check the AppXDeployment-Server event log for details.
    Deployment of package Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe was blocked because the
    provided package has the same identity as an already-installed package but the contents are different. Increment the
    version number of the package to be installed, or remove the old package for every user on the system before
    installing this package.
    NOTE: For additional information, look for [ActivityId] 765451bb-88b0-0001-8afa-5876b088cf01 in the Event Log or use
    the command line Get-AppxLog -ActivityID 765451bb-88b0-0001-8afa-5876b088cf01
    At C:\users\dave\bin\Add-AppxPackageExt.ps1:22 char:16
    +     $lastError = (Add-AppxPackage $Path 2>&1);
    +                   ~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : ResourceExists: (C:\Users\Dave\BackgroundTask2.appx:String) [Add-AppxPackage], PSInvalid
       OperationException
        + FullyQualifiedErrorId : DeploymentError,Microsoft.Windows.Appx.PackageManager.Commands.AddAppxPackageCommand
    
    PS C:\Users\Dave> Add-AppxPackageExt .\BackgroundTask2.appx -Force
    
    
    PackageFullName     : Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    DisplayName         : BackgroundTask JS sample
    InstallLocationItem : C:\Program
                          Files\WindowsApps\Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    Manifest            : #document
    ApplicationIds      : {App}
    BackgroundTasks     : {}
    InstallTimeUtc      : 6/26/2014 3:14:11 PM


### Debug a package

Debug-AppxPackage takes as input the result of Get-AppxPackageExt, Get-AppxPackage, or Get-ProcessAppxPackage and with the parameters ```-OnLaunch```, ```-On```, or ```-Off``` allows you to attach a debugger the next and subsequent times the package is launched, attach a debugger immediately, or turn off debugging of the package. It returns the Get-AppxPackageExt result of the package(s) to which the command applied.

Attach a debugger to a package the next time it is run using Debug-AppxPackage:

    PS C:\Users\Dave> Get-AppxPackageExt *BackgroundTask* | Debug-AppxPackage -OnLaunch "C:\debuggers\windbg.exe -server tcp:port=9100"
    
    
    PackageFullName     : Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    DisplayName         : BackgroundTask JS sample
    InstallLocationItem : C:\Program
                          Files\WindowsApps\Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    Manifest            : #document
    ApplicationIds      : {App}
    BackgroundTasks     : {}
    InstallTimeUtc      : 6/26/2014 3:14:11 PM
    

Attach a debugger to a currently running package:

    PS C:\Users\Dave> Get-ProcessAppxPackage *backgroundtask* | Debug-AppxPackage.ps1 -On C:\debuggers\windbg.exe
    
    
    PackageFullName     : Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    DisplayName         : BackgroundTask JS sample
    InstallLocationItem : C:\Program
                          Files\WindowsApps\Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    Manifest            : #document
    ApplicationIds      : {App}
    BackgroundTasks     : {}
    InstallTimeUtc      : 6/26/2014 3:14:11 PM


Turn off debugging a package:

    PS C:\Users\Dave> Get-AppxPackageExt *backgroundtask* | Debug-AppxPackage.ps1 -Off
    
    
    PackageFullName     : Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    DisplayName         : BackgroundTask JS sample
    InstallLocationItem : C:\Program
                          Files\WindowsApps\Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    Manifest            : #document
    ApplicationIds      : {App}
    BackgroundTasks     : {}
    InstallTimeUtc      : 6/26/2014 3:14:11 PM


### Suspend, Resume, and Terminate

Use the Suspend-AppxPackage, Resume-AppxPackage, and Terminate-AppxPackage to suspend, resume, and terminate respectively running appx package processes. 
Takes as input the result of Get-AppxPackageExt or Get-ProcessAppxPackage and provides as output the Get-ProcessAppxPackage result of the targetted processes.

    PS C:\Users\Dave> Get-ProcessAppxPackage livecomm
    
    PackageFullName               State                         ProcessName                                              Id
    ---------------               -----                         -----------                                              --
    microsoft.windowscommunica... suspended                     livecomm                                              11516
    
    
    PS C:\Users\Dave> Get-ProcessAppxPackage livecomm | Resume-AppxPackage
    
    PackageFullName               State                         ProcessName                                              Id
    ---------------               -----                         -----------                                              --
    microsoft.windowscommunica... running                       livecomm                                              11516
    
    
    PS C:\Users\Dave> Get-ProcessAppxPackage livecomm | Suspend-AppxPackage
    
    PackageFullName               State                         ProcessName                                              Id
    ---------------               -----                         -----------                                              --
    microsoft.windowscommunica... suspended                     livecomm                                              11516


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

    Add-AppxPackageExt.ps1 .\App.appx | Debug-AppxPackage.ps1 -OnLaunch "C:\debuggers\windbg.exe" | Launch-AppxPackage;

Uninstall a package based on its file.

    (Get-AppxPackageFile.ps1 .\App.appx).AppxPackage | Remove-AppxPackage;

