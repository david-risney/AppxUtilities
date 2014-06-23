param([string] $ProcessFilter,
	[switch] $MergeType,
	[switch] $All);

$myPath = Split-Path -Parent ($MyInvocation.MyCommand.Path);
function ScriptDir($additional) {
	$myPath + "\" + $additional;
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
		$package = (.(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$MergeType) | ?{ $_.PackageFullName -match $pfn };
		$packageState = (.(ScriptDir("PackageExecutionState.exe")) /get $pfn);
	}

	$process = $_;
	$outputObject = $_;
	if (!$MergeType) {
		$outputObject = New-Object PSObject `
			| Add-Member Id $process.Id -PassThru `
			| Add-Member ProcessName $process.ProcessName -PassThru `
			| Add-Member Process $process -PassThru `
		;
	}

	$outputObject `
		| Add-Member PackageFullName $pfn -PassThru `
		| Add-Member Package $package -PassThru `
		| Add-Member State $packageState `
	;

	$filterMatch = $true;
	if ($ProcessFilter) {
		$filterMatch = ($outputObject.Id -eq $ProcessFilter) -or `
			($outputObject.ProcessName -match $ProcessFilter) -or `
			($outputObject.PackageFullName -match $ProcessFilter);
	}

	if (($All -or $package) -and $filterMatch) {
		$outputObject;
	}
}
