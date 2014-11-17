<#
.SYNOPSIS
    Get installed Appx package information.
.DESCRIPTION
    A wrapper for Get-AppxPackage, this script provides additional info beyond
    Get-AppxPackage's including:
     - DisplayName
     - Manifest parsed as XML
     - InstallLocation as file item
     - Application IDs
     - Registered background tasks
.PARAMETER Filter
    The filter passed to Get-AppxPackage.
.PARAMETER MergeType
    Usually the results output are of a custom PSObject type that cannot be
    fed into pre-existing PowerShell Appx commands. MergeType will instead
    use the pre-existing PowerShell types and attach new properties (that
    will not be displayed by the existing type) to the existing types.
.EXAMPLE
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
param([string] $Filter,
	[switch] $MergeType);

$merge = !!$MergeType;
$myPath = (Split-Path -Parent ($MyInvocation.MyCommand.Path));
function ScriptDir($additional) {
	 $myPath + "\" + $additional;
}

$appxPackageType = "AppxPackageExtType";
if ((Get-TypeData $appxPackageType) -eq $null) { 
	Update-TypeData -TypeName $appxPackageType -DefaultDisplayPropertySet @("PackageFullName","DisplayName","InstallLocationItem","Manifest","ApplicationIds","BackgroundTasks","InstallTimeUtc");
}

$packages = ($input | %{ $_; } | ?{ $_; });

if (!$packages) {
	if ($Filter) {
		$packages = Get-AppxPackage $Filter;
	}
	else {
		$packages = Get-AppxPackage;
	}
}

$packages | %{
	$appxPackage = $_;

	$installLocationItem = $null;
	$installTimeUtc = $null;
	$manifestAsXml = $null;
	$displayName = $null;
	$applicationIds = @();
	$backgroundTasks = @();

	if ($_.InstallLocation -and (Test-Path $_.InstallLocation)) {
		$installLocationItem = (gi $_.InstallLocation);
		$installTimeUtc = $installLocationItem.CreationTimeUtc;
		$manifestAsXml = Get-AppxPackageManifest -Package $_.PackageFullName;
		$displayName = (select-xml -xml $manifestAsXml -xpath "/*[local-name() = 'Package']/*[local-name() = 'Properties']/*[local-name() = 'DisplayName']").Node."#text"
		$applicationIds = (@() + (select-xml -xml $manifestAsXml -xpath "//*[local-name() = 'Application']/@Id" )) | 
			%{ $_.Node."#text" };
		$applicationIds = @() + $applicationIds; # Make sure its an array even if there's only one element.
	}

	.(ScriptDir("LaunchAppxPackageBackgroundTask.exe")) /get $appxPackage.PackageFullName | %{
		$split = $_.Split(",");
		New-Object PSObject | Add-Member Name $split[0] -PassThru | Add-Member Id $split[1] -PassThru;
	} | %{
		$backgroundTasks += @($_);
	};

	$outputObject = $_;
	if (!$merge) {
		$outputObject = New-Object PSObject `
			| Add-Member PackageFullName $appxPackage.PackageFullName -PassThru `
			| Add-Member Package $appxPackage -PassThru `
		;
		$outputObject.PSTypeNames.Add($appxPackageType);
	}

	($outputObject `
		| Add-Member DisplayName $displayName -PassThru `
		| Add-Member ApplicationIds $applicationIds -PassThru `
		| Add-Member InstallLocationItem $installLocationItem -PassThru `
		| Add-Member Manifest $manifestAsXml -PassThru `
		| Add-Member InstallTimeUtc $installTimeUtc -PassThru `
		| Add-Member BackgroundTasks $backgroundTasks -PassThru `
		);
}
