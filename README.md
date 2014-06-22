# AppxUtilities

Fill in functionality gaps for Windows Store AppX package PowerShell commands.

New commands:
 - Query running process package info ```pspfn.ps1```
 - Query appx package file info ```Get-AppxPackageFile.ps1```
 - Launch an app from a package ```Get-AppxPackageExt *Weather* | Launch-AppxPackage.ps1```
 - Debug a package ```Get-AppxPackageExt *Cloud* | Debug-AppxPackage -OnLaunch "C:\debuggers\windbg.exe"```

Updates to builtin commands:
 - Additional properties on ```Get-AppxPackageExt.ps1``` results
 - Force install of existing packages and get package object results from ```Add-AppxPackageExt.ps1```

## Install

Extract the contents of the [AppxUtilties.zip](https://david-risney.github.io/AppxUtilities/AppxUtilities.zip) file into a temporary directory. Open a new PowerShell prompt, cd to the temporary directory, and run ```Unblock-File *```. Move the files to somewhere in your PATH.

## Commands

### Query running process package info

Unforunately there's no builtin cmdlet or command line executable that can tell you the PackageFamilyName of a process. AppxUtilities makes a ProcessIdToPackageId.exe, Get-ProcessAppxPackage.ps1, and pspfn.ps1.

    PS C:\Users\Dave> ps | Get-ProcessAppxPackage.ps1 | where PackageFamilyName -match Bing
    
    Handles  NPM(K)    PM(K)      WS(K) VM(M)   CPU(s)     Id ProcessName                                                  
    -------  ------    -----      ----- -----   ------     -- -----------                                                  
       1426     126   123852     200024   914     2.61  25968 WWAHost                                                      
    
    PS C:\Users\Dave> pspfn.ps1
    
    PackageFullName                                                              Id Name
    ---------------                                                              -- ----
    microsoft.windowscommunicationsapps_...                                    4692 livecomm
    58823DavidRisney.CloudShare_1.1.0.3_...                                   27176 WWAHost
    
    PS C:\Users\Dave> pspfn.ps1 Cloud
    
    PackageFullName                                                              Id Name
    ---------------                                                              -- ----
    58823DavidRisney.CloudShare_1.1.0.3_...                                   27176 WWAHost

### Query installed package info

The AppxUtilities Get-AppxPackageExt.ps1 provides a few more properties for each AppxPackage object including the following:

 - Provides the manifest as parsed XML.
 - Provides the InstallLocation as a file item.
 - Provides the list of contained Applications.

For example:

    PS C:\Users\Dave> Get-AppxPackageExt.ps1 *Cloud*
    
    
    Name                : 58823DavidRisney.CloudShare
    DisplayName         : Cloud Share
    PackageFullName     : 58823DavidRisney.CloudShare_1.1.0.3_neutral__xv340bf98g09e
    ApplicationIds      : {App}
    InstallLocationItem : C:\Program Files\WindowsApps\58823DavidRisney.CloudShare_1.1.0.3_neutral__xv340bf98g09e
    InstallTimeUtc      : 5/21/2014 3:12:56 PM


### Query package file package info

Obtain package info from an appx file. If its installed it returns the installed package info and otherwise returns similar data found in the manifest in the package.

    PS C:\Users\Dave> Get-AppxPackageFile.ps1 .\App.appx


    Name                  : f0c4e9e7-162f-4c33-a9b1-4faf67cf68a6
    DisplayName           : App1
    Version               : 1.0.0.0
    Publisher             : CN=Dave
    ProcessorArchitecture : neutral
    ApplicationIds        : {App}
    Manifest              : #document



    PS C:\Users\Dave> Add-AppxPackage .\App.appx
    PS C:\Users\Dave> Get-AppxPackageFile.ps1 .\App.appx


    AppxPackage         : f0c4e9e7-162f-4c33-a9b1-4faf67cf68a6_1.0.0.0_neutral__tbz3402trp7yy
    Name                : f0c4e9e7-162f-4c33-a9b1-4faf67cf68a6
    DisplayName         : App1
    PackageFullName     : f0c4e9e7-162f-4c33-a9b1-4faf67cf68a6_1.0.0.0_neutral__tbz3402trp7yy
    ApplicationIds      : {App}
    Manifest            : #document
    InstallLocationItem : C:\Program Files\WindowsApps\f0c4e9e7-162f-4c33-a9b1-4faf67cf68a6_1.0.0.0_neutral__tbz3402trp7yy
    InstallTimeUtc      : 6/2/2014 3:42:56 AM

    

### Launch a package

There's also no builtin cmdlet or executable to launch from the command line a Windows Store app by package name. AppxUtilities makes Launch-AppxPackage.

    PS C:\Users\Dave> Get-AppxPackageExt *Cloud* | Launch-AppxPackage.ps1
    
    PackageFullName                                                              Id Name
    ---------------                                                              -- ----
    58823DavidRisney.CloudShare_1.1.0.3_...                                   27176 WWAHost

### Add a package

The AppxUtilities Add-AppxPackageExt.ps1 has the following abilities beyond what the builtin Add-AppxPackage performs:

 - Install a package with the exact same package identity using the -Force switch.
 - Know the package info of what was just installed using the -PassThru switch.

For example:

    PS C:\Users\Dave> Add-AppxPackageExt.ps1 .\App.appx
    add-appxpackage : Deployment failed with HRESULT: 0x80073CFB, The provided package is already installed, and
    reinstallation of the package was blocked. Check the AppXDeployment-Server event log for details.
    Deployment of package f0c4e9e7-162f-4c33-a9b1-4faf67cf68a6_1.0.0.0_neutral__tbz3402trp7yy was blocked because the
    provided package has the same identity as an already-installed package but the contents are different. Increment the
    version number of the package to be installed, or remove the old package for every user on the system before
    installing this package.
    NOTE: For additional information, look for [ActivityId] 431a2ff7-7193-0001-d850-1f439371cf01 in the Event Log or use
    the command line Get-AppxLog -ActivityID 431a2ff7-7193-0001-d850-1f439371cf01
    At C:\users\dave\development\appxutilities\bin\Add-AppxPackageExt.ps1:15 char:16
    +     $lastError = (add-appxpackage $Path 2>&1);
    +                   ~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : ResourceExists: (C:\Users\Dave\App.appx:String) [Add-AppxPackage], PSInvalidOperationExc
       eption
        + FullyQualifiedErrorId : DeploymentError,Microsoft.Windows.Appx.PackageManager.Commands.AddAppxPackageCommand
    
    PS C:\Users\Dave> Add-AppxPackageExt.ps1 .\App.appx -Force -PassThru
    
    
    Name              : f0c4e9e7-162f-4c33-a9b1-4faf67cf68a6
    Publisher         : CN=Dave
    Architecture      : Neutral
    ResourceId        :
    Version           : 1.0.0.0
    PackageFullName   : f0c4e9e7-162f-4c33-a9b1-4faf67cf68a6_1.0.0.0_neutral__tbz3402trp7yy
    InstallLocation   : C:\Program Files\WindowsApps\f0c4e9e7-162f-4c33-a9b1-4faf67cf68a6_1.0.0.0_neutral__tbz3402trp7yy
    IsFramework       : False
    PackageFamilyName : f0c4e9e7-162f-4c33-a9b1-4faf67cf68a6_tbz3402trp7yy
    PublisherId       : tbz3402trp7yy
    IsResourcePackage : False
    IsBundle          : False
    IsDevelopmentMode : False
    Dependencies      : {Microsoft.WinJS.2.0_1.0.9600.17018_neutral__8wekyb3d8bbwe}

### Debug a package

This depends on [PLMDebug.exe](http://msdn.microsoft.com/en-us/library/windows/hardware/jj680085(v=vs.85).aspx) which is available in the debugging tools of the [Windows SDK for Windows 8.1](http://msdn.microsoft.com/en-US/windows/desktop/bg162891).

Attach a debugger to a package the next time it is run:

    PS C:\Users\Dave> Get-AppxPackageExt *Cloud* | Debug-AppxPackage.ps1 -OnLaunch "C:\debuggers\windbg.exe -server tcp:port=9090"
    
    
    Name                : 58823DavidRisney.CloudShare
    DisplayName         : Cloud Share
    PackageFullName     : 58823DavidRisney.CloudShare_1.1.0.3_neutral__xv340bf98g09e
    ApplicationIds      : {App}
    InstallLocationItem : C:\Program Files\WindowsApps\58823DavidRisney.CloudShare_1.1.0.3_neutral__xv340bf98g09e
    InstallTimeUtc      : 5/21/2014 3:12:56 PM


Attach a debugger to a currently running package:

    PS C:\Users\Dave> pspfn Cloud | Debug-AppxPackage.ps1 -On C:\debuggers\windbg.exe


    Name                : 58823DavidRisney.CloudShare
    DisplayName         : Cloud Share
    PackageFullName     : 58823DavidRisney.CloudShare_1.1.0.3_neutral__xv340bf98g09e
    ApplicationIds      : {App}
    InstallLocationItem : C:\Program Files\WindowsApps\58823DavidRisney.CloudShare_1.1.0.3_neutral__xv340bf98g09e
    InstallTimeUtc      : 5/21/2014 3:12:56 PM

Turn off debugging a package:

    PS C:\Users\Dave> Get-AppxPackageExt *BingF* | Debug-AppxPackage.ps1 -Off


    Name                : Microsoft.BingFinance
    DisplayName         : ms-resource:BrandedAppTitle
    PackageFullName     : Microsoft.BingFinance_3.0.2.258_x64__8wekyb3d8bbwe
    ApplicationIds      : {AppexFinance}
    InstallLocationItem : C:\Program Files\WindowsApps\Microsoft.BingFinance_3.0.2.258_x64__8wekyb3d8bbwe
    InstallTimeUtc      : 5/7/2014 10:14:56 AM

    Name                : Microsoft.BingFoodAndDrink
    DisplayName         : ms-resource:AppTitleWithBranding
    PackageFullName     : Microsoft.BingFoodAndDrink_3.0.2.258_x64__8wekyb3d8bbwe
    ApplicationIds      : {AppexFoodAndDrink}
    InstallLocationItem : C:\Program Files\WindowsApps\Microsoft.BingFoodAndDrink_3.0.2.258_x64__8wekyb3d8bbwe
    InstallTimeUtc      : 5/10/2014 2:37:32 AM

## Combined examples

Install and launch a package under the debugger.

    Add-AppxPackageExt.ps1 .\App.appx -PassThru | Debug-AppxPackage.ps1 -OnLaunch "C:\debuggers\windbg.exe" | Launch-AppxPackage;

Uninstall a package based on its file.

    (Get-AppxPackageFile.ps1 .\App.appx).AppxPackage | Remove-AppxPackage;

