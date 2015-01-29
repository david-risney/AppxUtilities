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
	[switch] $Force,
	[switch] $MergeType);

$PackagesAdded = @();

$merge = !!$MergeType;

$myPath = (Split-Path -Parent ($MyInvocation.MyCommand.Path));
function ScriptDir($additional) {
	 $myPath + "\" + $additional;
}

function addPackage {
    param($Path);

    if (Test-Path -PathType Container $Path) {
        Add-AppxPackage -Register (Join-Path $Path "AppxManifest.xml");
    }
    elseif ((dir $Path).Name -eq "appxmanifest.xml") {
        Add-AppxPackage -Register $Path;
    }
    else {
        Add-AppxPackage $Path;
    }
}

$Paths + $input | ?{ $_ } | %{
	$Path = $_;
	if ($Path.GetType() -eq "FileInfo") {
		$Path = $Path.FullName;
	}

	$before = .(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$merge;

	$lastError = (addPackage $Path 2>&1);

    if ($lastError -and $Force) {
    	if ($error.CategoryInfo.Category -eq "ResourceExists") {
    		$lastError.Exception.Message.Split("`n") | ?{ $_ -match "Deployment of package" } | %{ $_ -replace "Deployment of package ([^ ]*).*","`$1" } | %{
    			Remove-AppxPackage $_
    			$before = .(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$merge;
    			addPackage $Path;
    		}
    	}
        elseif ($lastError.Exception -and `
            $lastError.Exception.Message -match "Deployment failed with HRESULT: 0x80073CF9, Install failed." -and `
            $lastError.Exception.Message -match "The current user has already installed (an unpackaged|a packaged) version of this app. (A packaged|An unpackaged) version cannot replace this." -and `
            $lastError.Exception.Message -match "conflicting package is ([^ ]*)") {

    		Get-AppxPackage $matches[1] | Remove-AppxPackage;
    		$before = .(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$merge;
    		addPackage $Path;
        }
        elseif ($lastError.Exception -and `
            $lastError.Exception.InnerException -and `
            $lastError.Exception.InnerException.Message -eq "error 0x800B0109: The root certificate of the signature in the app package or bundle must be trusted.") {
    
            $certPath = $env:TEMP + "\Add-AppxPackageExt.tmp.cer";
            [System.IO.File]::WriteAllBytes($certPath, (Get-AuthenticodeSignature ($Path)).SignerCertificate.Export("Cert"));
            [void](certutil.exe -addstore TrustedPeople $certPath);
            addPackage $Path;
            del $certPath;
        }
        elseif ($lastError.Exception -and `
            $lastError.Exception.Message -match "Deployment failed with HRESULT: 0x80073CFF, To install this application you need either a Windows developer license or a sideloading-enabled system.") {

            Show-WindowsDeveloperLicenseRegistration;

            addPackage $Path;
        }
	    elseif ($lastError) {
		    $lastError;
	    }
    }
    else {
        $lastError;
    }

	$after = .(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$merge;

	$before = @() + $before;
	$after = @() + $after;

	$PackagesAdded += @(diff $before $after | where SideIndicator -eq "=>" | %{ $_.InputObject })
}

$PackagesAdded;
