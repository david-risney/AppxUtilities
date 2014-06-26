param([string] $ProcessFilter,
	[switch] $MergeType,
	[switch] $All);

$merge = !!$MergeType;

$myPath = Split-Path -Parent ($MyInvocation.MyCommand.Path);
function ScriptDir($additional) {
	$myPath + "\" + $additional;
}

$processAppxPackageType = "ProcessAppxPackageExtType";
if ((Get-TypeData $processAppxPackageType) -eq $null) { 
	Update-TypeData -TypeName $processAppxPackageType -DefaultDisplayPropertySet @("PackageFullName","State","ProcessName","Id");
}

$allInput = ($input | %{ $_; } | ?{ $_; });
if (!$allInput) {
	$allInput = (Get-Process);
}

$allInput | %{
	$pfn = (.(ScriptDir("ProcessIdToPackageId.exe")) $_.Id).Split("`t")[1];
	$package = $null;
	$packageState = $null;
	if ($pfn) {
		$package = (.(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$merge) | ?{ $_.PackageFullName -match $pfn };
		$packageState = (.(ScriptDir("PackageExecutionState.exe")) /get $pfn);
	}

	$process = $_;
	$outputObject = $_;
	if (!$merge) {
		$outputObject = New-Object PSObject `
			| Add-Member Id $process.Id -PassThru `
			| Add-Member ProcessName $process.ProcessName -PassThru `
			| Add-Member Process $process -PassThru `
		;
		$outputObject.PSTypeNames.Add($processAppxPackageType);
	}

	$outputObject `
		| Add-Member PackageFullName $pfn -PassThru `
		| Add-Member Package $package -PassThru `
		| Add-Member State $packageState `
	;

	$filterMatch = $true;
	if ($ProcessFilter) {
		$filterMatch = ($outputObject.Id -eq $ProcessFilter) -or `
			($outputObject.ProcessName -like $ProcessFilter) -or `
			($outputObject.PackageFullName -like $ProcessFilter);
	}

	if (($ProcessFilter -and $filterMatch) -or (!$ProcessFilter -and ($All -or $package))) {
		$outputObject;
	}
}
