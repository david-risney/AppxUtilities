param([string] $Filter,
	[switch] $ShowAll);

ps | .((Split-Path -Parent ($MyInvocation.MyCommand.Path)) + "\Get-ProcessPackageFamilyName.ps1") | ?{
	!$Filter -or $_.Name -match $Filter -or $_.PackageFamilyName -match $Filter -or $_.Id -eq $Filter; 
} | ?{
	$_.PackageFamilyName -or $ShowAll;
} | %{
	[pscustomobject]@{PackageFamilyName = $_.PackageFamilyName; Name = $_.Name; Id = $_.Id};
};