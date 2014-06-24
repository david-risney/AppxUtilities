param([string] $BackgroundTaskId,
	[switch] $MergeType);

$merge = !!$MergeType;

$myPath = (Split-Path -Parent ($MyInvocation.MyCommand.Path));
function ScriptDir($additional) {
	 $myPath + "\" + $additional;
}

$allInput = @($input | %{ $_; }) + @($BackgroundTaskId) | ?{ $_; };

$allInput | %{ 
	$in = $_;
	# Upgrade results from builtin Get-AppxPackage to results from AppxUtilities Get-AppxPackage.ps1
	if ($in.PackageFullName -and !($in | Get-Member BackgroundTasks)) {
		$in = Get-AppxPackage | where PackageFullName -match $in.PackageFullName | .(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType;
	}
	if ($in.PackageFullName -and ($in | Get-Member BackgroundTasks)) {
		$in = $in.BackgroundTasks[0];
	}
	if ($in.Name -and $in.Id) {
		$in = $in.Id;
	}
	if ($in.GetType().Name -eq "string" -and $in[0] -eq "{" -and $in[$in.length - 1] -eq "}") {
		$in = $in.Substring(1, $in.length - 2);
	}

	.(ScriptDir("LaunchAppxPackageBackgroundTask.exe")) /launch $in;
};
