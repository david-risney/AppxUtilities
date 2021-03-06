# AppxUtilities

Fill in functionality gaps for Windows Store AppX package PowerShell commands.

## Install

 - Extract the contents of [AppxUtilties.zip](https://david-risney.github.io/AppxUtilities/AppxUtilities.zip) into a temporary directory. 
 - Open a new PowerShell prompt, cd to the temporary directory, and run ```Unblock-File *```. 
 - Move the files to somewhere in your PATH.

Or try the new remote install script from a PowerShell prompt. It will install or update the tools in ~\bin and add that path to your user PATH.

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

### Add-AppxPackageExt.ps1 - Install Appx packages.

A wrapper for Add-AppxPackage, this script additionally supports a Force 
switch that will install the package even when a package with the same
package full name is already installed or if the package to install has an
untrusted signature. Additionally it has as its output the 
Get-AppxPackageExt results of the installed packages.

Example:

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




### Debug-AppxPackage.ps1 - Debug appx packages.

A wrapper for plmdebug.exe, this script makes it easy to use plmdebug.exe
in PowerShell with other AppxPackage commands. Returns the 
Get-AppxPackageExt results of the packages to which this command applied.

Example:

    PS C:\Users\Dave> Get-AppxPackageExt *BackgroundTask* | Debug-AppxPackage -OnLaunch "C:\debuggers\windbg.exe -server tcp:port=9100"
    
    PackageFullName     : Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    DisplayName         : BackgroundTask JS sample
    InstallLocationItem : C:\Program
                          Files\WindowsApps\Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    Manifest            : #document
    ApplicationIds      : {App}
    BackgroundTasks     : {}
    InstallTimeUtc      : 6/26/2014 3:14:11 PM
    
    # Attach a debugger to a package the next time it is run using Debug-AppxPackage.
Example:

    PS C:\Users\Dave> Get-ProcessAppxPackage *backgroundtask* | Debug-AppxPackage.ps1 -On C:\debuggers\windbg.exe
    
    PackageFullName     : Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    DisplayName         : BackgroundTask JS sample
    InstallLocationItem : C:\Program
                          Files\WindowsApps\Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    Manifest            : #document
    ApplicationIds      : {App}
    BackgroundTasks     : {}
    InstallTimeUtc      : 6/26/2014 3:14:11 PM
    
    # Attach a debugger to a currently running package
Example:

    PS C:\Users\Dave> Get-AppxPackageExt *backgroundtask* | Debug-AppxPackage.ps1 -Off
    
    PackageFullName     : Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    DisplayName         : BackgroundTask JS sample
    InstallLocationItem : C:\Program
                          Files\WindowsApps\Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    Manifest            : #document
    ApplicationIds      : {App}
    BackgroundTasks     : {}
    InstallTimeUtc      : 6/26/2014 3:14:11 PM
    
    # Turn off debugging a package.




### Get-AppxPackageExt.ps1 - Get installed Appx package information.

A wrapper for Get-AppxPackage, this script provides additional info beyond
Get-AppxPackage's including:
 - DisplayName
 - Manifest parsed as XML
 - InstallLocation as file item
 - Application IDs
 - Registered background tasks

Example:

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




### Get-AppxPackageFile.ps1 - Get Appx package info from an Appx package file.

Given an Appx package file, Get-AppxPackageFile extracts the manifest from
the file (using ExtractFromAppx.exe) and outputs the results of 
Get-AppxPackageExt filtered to packages with the same name as that in the
manifest, or if none exist outputs information from the manifest.

Example:

    PS C:\Users\Dave> Get-AppxPackageFile.ps1 .\BackgroundTask.Windows_1.0.0.0_AnyCPU_Debug.appx
    
    Name                  : Microsoft.SDKSamples.BackgroundTask.JS
    DisplayName           : BackgroundTask JS sample
    Version               : 1.0.0.0
    Publisher             : CN=Microsoft Corporation, O=Microsoft Corporation, L=Redmond, S=Washington, C=US
    ProcessorArchitecture : neutral
    ApplicationIds        : {App}
    Manifest              : #document
    
    
    Results of calling for a package not installed
Example:

    PS C:\Users\Dave> Get-AppxPackageFile.ps1 .\BackgroundTask.Windows_1.0.0.0_AnyCPU_Debug.appx
    
    PackageFullName     : Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    DisplayName         : BackgroundTask JS sample
    InstallLocationItem : C:\Program
                          Files\WindowsApps\Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    Manifest            : #document
    ApplicationIds      : {App}
    BackgroundTasks     : {}
    InstallTimeUtc      : 6/26/2014 2:53:15 PM
    
    Results of calling for a package installed




### Get-ProcessAppxPackage.ps1 - Get Appx package info for running processes.

A wrapper for Get-Process, this script provides information about the 
running processes package identity and package execution state.

Example:

    PS C:\Users\Dave> Get-ProcessAppxPackage
    
    PackageFullName               State                         ProcessName                                              Id
    ---------------               -----                         -----------                                              --
    microsoft.windowscommunica... suspended                     livecomm                                              11516
    Microsoft.SkypeApp_2.8.0.1... suspended                     WWAHost                                               16796
Example:

    PS C:\Users\Dave> Get-ProcessAppxPackage Skype
    
    PackageFullName               State                         ProcessName                                              Id
    ---------------               -----                         -----------                                              --
    Microsoft.SkypeApp_2.8.0.1... suspended                     WWAHost




### Launch-AppxPackage.ps1 - Launch an installed Appx package's application.

Given an AppxPackage or PackageFamilyName and ApplicationId Launch-AppxPackage
launches the application and provides as output the Get-ProcessAppxPackage
result of the launched process.

Example:

    PS C:\Users\Dave> Get-AppxPackageExt *BackgroundTask* | Launch-AppxPackage
    
    PackageFullName               State       ProcessName             Id
    ---------------               -----       -----------             --
    Microsoft.SDKSamples.Backg... running     WWAHost              10604




### Launch-AppxPackageBackgroundTask.ps1 - Launch an Appx package's registered background task.

Given a background task id, launch the corresponding registered background
task.

Example:

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




### Resume-AppxPackage.ps1 - Resume all suspended processes for a particular Appx package.

Resume all suspended processes for a particular Appx package.

Example:

    PS C:\Users\Dave> Get-ProcessAppxPackage livecomm
    
    PackageFullName               State               ProcessName                Id
    ---------------               -----               -----------                --
    microsoft.windowscommunica... suspended           livecomm                11516
    
    
    PS C:\Users\Dave> Get-ProcessAppxPackage livecomm | Resume-AppxPackage
    
    PackageFullName               State               ProcessName                Id
    ---------------               -----               -----------                --
    microsoft.windowscommunica... running             livecomm                11516




### Suspend-AppxPackage.ps1 - Suspend all running processes for a particular Appx package.

Suspend all running processes for a particular Appx package.

Example:

    PS C:\Users\Dave> Get-ProcessAppxPackage livecomm
    
    PackageFullName               State               ProcessName                Id
    ---------------               -----               -----------                --
    microsoft.windowscommunica... suspended           livecomm                11516
    
    
    PS C:\Users\Dave> Get-ProcessAppxPackage livecomm | Resume-AppxPackage
    
    PackageFullName               State               ProcessName                Id
    ---------------               -----               -----------                --
    microsoft.windowscommunica... running             livecomm                11516
    
    
    PS C:\Users\Dave> Get-ProcessAppxPackage livecomm | Suspend-AppxPackage
    
    PackageFullName               State               ProcessName                Id
    ---------------               -----               -----------                --
    microsoft.windowscommunica... suspended           livecomm                11516




### Terminate-AppxPackage.ps1 - Terminate all processes for a particular Appx package.

Terminate all processes for a particular Appx package.

Example:

     
    





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

