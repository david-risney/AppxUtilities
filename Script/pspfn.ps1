param([string] $Filter,
	[switch] $ShowAll);

$myPath = (Split-Path -Parent ($MyInvocation.MyCommand.Path));
function ScriptDir($additional) {
	 $myPath + "\" + $additional;
}


ps | .(ScriptDir("\Get-ProcessAppxPackage.ps1")) | ?{
	!$Filter -or $_.Name -match $Filter -or $_.PackageFullName -match $Filter -or $_.Id -eq $Filter; 
} | ?{
	$_.PackageFullName -or $ShowAll;
} | %{
	$_ | select PackageFullName,Id,Name;
};
