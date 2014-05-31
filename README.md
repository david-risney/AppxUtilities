# AppxUtilities

Fill in functionality gaps for Windows Store AppX package PowerShell commands.

## Query running process package info

Unforunately there's no builtin cmdlet or command line executable that can tell you the PackageFamilyName of a process. AppxUtilities makes a ProcessIdToPackageId.exe, Get-ProcessPackageFamilyName.ps1, and pspfn.ps1.

    PS C:\Users\Dave> ps | Get-ProcessPackageFamilyName.ps1 | where PackageFamilyName -match Bing
    
    Handles  NPM(K)    PM(K)      WS(K) VM(M)   CPU(s)     Id ProcessName                                                  
    -------  ------    -----      ----- -----   ------     -- -----------                                                  
       1426     126   123852     200024   914     2.61  25968 WWAHost                                                      


    PS C:\Users\Dave> pspfn.ps1
    
    PackageFamilyName                       Name                             Id
    -----------------                       ----                             --
    microsoft.windowscommunicationsapps_... livecomm                       4692
    Microsoft.BingWeather_8wekyb3d8bbwe     WWAHost                       23076

## Query installed package info

The AppxUtilities Get-AppxPackage.ps1 has the following abilities beyond the builtin cmdlet:

 - Provides the manifest as parsed XML.
 - Provides the InstallLocation as a file item.
 - Provides the list of contained Applications.

For example:

    PS C:\Users\Dave> Get-AppxPackage.ps1


## Query package file package info

    PS C:\Users\Dave> dir Test.appx | Get-AppxPackageFile.ps1
    

## Launch a package

There's also no builtin cmdlet or executable to launch from the command line a Windows Store app by package name. AppxUtilities makes Launch-AppxPackage.

    PS C:\Users\Dave> Get-AppxPackage | where name -match Weather | Launch-AppxPackage.ps1


## Add a package

The AppxUtilities Add-AppxPackage.ps1 has the following abilities beyond what the builtin Add-AppxPackage performs:

 - Install a package with the exact same package identity using the -Force switch.
 - Know the package info of what was just installed using the -PassThru switch.

For example:

    PS C:\Users\Dave> dir bing*.appx | Add-AppxPackage.ps1 -Force -PassThru

## Debug a package

This depends on [PLMDebug](http://msdn.microsoft.com/en-us/library/windows/hardware/jj680085(v=vs.85).aspx) which is available in the debugging tools of the [Windows SDK for Windows 8.1](http://msdn.microsoft.com/en-US/windows/desktop/bg162891).

Attach a debugger to a package the next time it is run:

    PS C:\Users\Dave> Get-AppxPackage | where name -match Bing | Debug-AppxPackage.ps1 -OnLaunch "C:\Debuggers\cdb -server tcp:port=9090 "

Attach a debugger to a currently running package:

    PS C:\Users\Dave> pspfn | where PackageFamilyName -match Bing | Debug-AppxPackage.ps1 C:\Debuggers\windbg.exe

Turn off debugging a package:

    PS C:\Users\Dave> Get-AppxPackage | where name -match Bing | Debug-AppxPackage.ps1 -Off
