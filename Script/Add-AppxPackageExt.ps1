<#
.SYNOPSIS
    Install Appx packages.
.DESCRIPTION
    A wrapper for Add-AppxPackage, this script additionally supports a Force 
    switch that will install the package even when a package with the same
    package full name is already installed or if the package to install has an
    untrusted signature. Additionally it has as its output the 
    Get-AppxPackageExt results of the installed packages.
.PARAMETER Paths
    The Paths to the appx packages. These can be FileInfo objects or strings
    that are the absolute paths. This is also the pipeline input.
.PARAMETER Force
    Force the install of an appx package in the following cases that would
    normally result in an error that stops the install of a package:
      -  A package with the same package full name is already installed
      -  The package to install has an untrusted signature
.PARAMETER MergeType
    Usually the results output are of a custom PSObject type that cannot be
    fed into pre-existing PowerShell Appx commands. MergeType will instead
    use the pre-existing PowerShell types and attach new properties (that
    will not be displayed by the existing type) to the existing types.
.PARAMETER InstallOnlyCertificate
    Instead of installing the specified appx package, only install its certificate.
.PARAMETER CustomAddCommand
    Install specified appx package using a custom command. If the string for this
    parameter contains a '}' then {0} is replaced with the path to the appx package.
    Otherwise a space and the package path is appended to the string to form the
    install command.
.EXAMPLE
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

.LINK
    Add-AppxPackageExt.ps1
.LINK
    Debug-AppxPackage.ps1
.LINK
    Get-AppxPackageExt.ps1
.LINK
    Get-AppxPackageFile.ps1
.LINK
    Get-ProcessAppxPackage.ps1
.LINK
    Launch-AppxPackage.ps1
.LINK
    Launch-AppxPackageBackgroundTask.ps1
.LINK
    Resume-AppxPackage.ps1
.LINK
    Suspend-AppxPackage.ps1
.LINK
    Terminate-AppxPackage.ps1
#>
param([object[]] $Paths,
    [string] $CustomAddCommand,
	[switch] $Force,
    [switch] $InstallOnlyCertificate,
	[switch] $MergeType);

$PackagesAdded = @();

$merge = !!$MergeType;

$runningElevated = ([Security.Principal.WindowsIdentity]::GetCurrent().Groups.Value -contains "S-1-5-32-544");

$scriptPath = (Get-Variable MyInvocation).Value.MyCommand.Path;
$myPath = (Split-Path -Parent ($MyInvocation.MyCommand.Path));
function ScriptDir($additional) {
	 $myPath + "\" + $additional;
}

function addPackageInternal {
    param($Path);

    if ($CustomAddCommand) {
        if ($CustomAddCommand.IndexOf("{0}") -ge 0) {
            $command = $CustomAddCommand -f $Path;
        } else {
            $command = $CustomAddCommand + " " + $Path;
        }
        .($command);
    } elseif (Test-Path -PathType Container $Path) {
        Add-AppxPackage -Register (Join-Path $Path "AppxManifest.xml");
    } elseif ((dir $Path).Name -eq "appxmanifest.xml") {
        Add-AppxPackage -Register $Path;
    } else {
        Add-AppxPackage $Path;
    }
}

function launchElevatedAndWait {
    param($cmd);

    # Launch the process and wait for it to finish
    $adminProcess = Start-Process "$PsHome\PowerShell.exe" -Verb RunAs -ArgumentList $cmd -PassThru

    # There must be a better way...
    while (!($adminProcess.HasExited)) {
        Start-Sleep -Seconds 1
    }
}

function installCert {
    param($Path);

    if ($runningElevated) {
        $cert = (Get-AuthenticodeSignature -FilePath $Path).SignerCertificate;
        $chain = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Chain;
        $chain.Build($cert);
        $certBytes = $chain.ChainElements[$chain.ChainElements.Count - 1].Certificate.Export("Cert");

        $certPath = $env:TEMP + "\Add-AppxPackageExt.tmp.cer";
        [System.IO.File]::WriteAllBytes($certPath, $certBytes);
        [void](certutil.exe -addstore TrustedPeople $certPath);
        del $certPath;
    } else {
        $elevatedArgs = '-ExecutionPolicy Unrestricted -file "' + $scriptPath + '"' +
            " -InstallOnlyCertificate " + $Path;
        launchElevatedAndWait $elevatedArgs;
    }
}

function applyDevLicense {
    # Probably a better way to do this...
    $osMajorVersion = [int](cmd /c ver | %{ if ($_ -match "Version ([0-9]*)") { $matches[1]; } });

    if ($osMajorVersion -lt 10) {
        if ($runningElevated) {
            Show-WindowsDeveloperLicenseRegistration;
        } else {
            launchElevatedAndWait "-Command Show-WindowsDeveloperLicenseRegistration";
        }
    } else {
        if ($runningElevated) {
            reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1";
        } else {
            launchElevatedAndWait '-Command reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"';
        }
    }
}

$Paths + $input | ?{ $_ } | %{
	$Path = $_;
	if ($Path.GetType() -eq "FileInfo") {
		$Path = $Path.FullName;
	}
    $Path = (gi $Path).FullName;

	$before = .(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$merge;
    $errorResolutions = @();

    do {
        if ($InstallOnlyCertificate) {
            installCert $Path;
        } else {
            $lastError = (addPackageInternal $Path 2>&1);
            $errorResolved = $false;

            if ($lastError -and $Force) {
            	if ($lastError.CategoryInfo.Category -eq "ResourceExists") {
            		$lastError.Exception.Message.Split("`n") | ?{ $_ -match "Deployment of package" } | %{ $_ -replace "Deployment of package ([^ ]*).*","`$1" } | %{
                        if (!($errorResolutions | ?{ $_ -match "remove1" })) {
            			    Remove-AppxPackage $_
            			    $before = .(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$merge;
                            $errorResolved = $true;
                            $errorResolutions += "remove1";
                        }
            		}
            	}
                elseif ($lastError.Exception -and `
                    $lastError.Exception.Message -match "Deployment failed with HRESULT: 0x80073CF9, Install failed." -and `
                    $lastError.Exception.Message -match "The current user has already installed (an unpackaged|a packaged) version of this app. (A packaged|An unpackaged) version cannot replace this." -and `
                    $lastError.Exception.Message -match "conflicting package is ([^ ]*)") {

                    if (!($errorResolutions | ?{ $_ -match "remove2" })) {
            		    Get-AppxPackage $matches[1] | Remove-AppxPackage;
            		    $before = .(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$merge;
                        $errorResolved = $true;
                        $errorResolutions += "remove2";
                    }
                }
                elseif ($lastError.Exception -and `
                    $lastError.Exception.InnerException -and `
                    (($lastError.Exception.InnerException.Message -eq "error 0x800B010A: The root certificate and all intermediate certificates of the signature in the app package or bundle must be trusted.") -or `
                     ($lastError.Exception.InnerException.Message -eq "error 0x800B0109: The root certificate of the signature in the app package or bundle must be trusted."))) {
            
                    if (!($errorResolutions | ?{ $_ -match "cert" })) {
                        installCert $Path
                        $errorResolved = $true;
                        $errorResolutions += "cert";
                    }
                }
                elseif ($lastError.Exception -and `
                    $lastError.Exception.Message -match "Deployment failed with HRESULT: 0x80073CFF, To install this application you need either a Windows developer license or a sideloading-enabled system.") {

                    if (!($errorResolutions | ?{ $_ -match "devlic" })) {
                        applyDevLicense;
                        $errorResolved = $true;
                        $errorResolutions += "devlic";
                    }
                }
            }
        }
    } while ($lastError -and $errorResolved);

    if (!$InstallOnlyCertificate) {
        if ($lastError -and !$errorResolved) {
            $lastError;
        } else {
	        $after = .(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$merge;

	        $before = @() + $before;
	        $after = @() + $after;

            $diff = diff $before $after | where SideIndicator -eq "=>" | %{ $_.InputObject };
            if (!$diff -and !$lastError) { 
                # If you readd exactly the same package, add-appxpackage gives no error and the installed package list doesn't change.
                # In that case, try to get the package info from the path we were told to install.
                $diff = .(ScriptDir("Get-AppxPackageFile.ps1")) -MergeType:$merge $Path;
            }

	        $PackagesAdded += @($diff)
        }
    }
}

$PackagesAdded;
