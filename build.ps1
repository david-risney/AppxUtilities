del -fo -rec bin;
mkdir bin;
Copy-Item -Force ProcessIdToPackageId/Release/ProcessIdToPackageId.exe bin;
Copy-Item -Force ProcessIdToPackageId/Release/ProcessIdToPackageId.pdb bin;
Copy-Item -Force LaunchAppxPackage/Release/LaunchAppxPackage.exe bin;
Copy-Item -Force LaunchAppxPackage/Release/LaunchAppxPackage.pdb bin;
Copy-Item -Force LaunchAppxPackageBackgroundTask/Release/LaunchAppxPackageBackgroundTask.exe bin;
Copy-Item -Force LaunchAppxPackageBackgroundTask/Release/LaunchAppxPackageBackgroundTask.pdb bin;
Copy-Item -Force ExtractFromAppx/bin/Release/ExtractFromAppx.exe bin;
Copy-Item -Force ExtractFromAppx/bin/Release/ExtractFromAppx.pdb bin;
Copy-Item -Force PackageExecutionState/Release/PackageExecutionState.exe bin;
Copy-Item -Force PackageExecutionState/Release/PackageExecutionState.pdb bin;
Copy-Item -Force Script/*.ps1 bin;
# dir bin\*.ps1 | %{ Copy-Item CmdWrapper\CmdWrapper.cmd $_.fullname.replace(".ps1", ".cmd"); };
Copy-Item -Force Redist\* bin;

pushd bin;
del ..\AppxUtilities.zip;
zip ..\AppxUtilities.zip *;
popd;

$commandHelpAsMarkdown = dir bin\*ps1 | %{
	$help = (get-help $_.FullName);
	"### " + $_.Name + " - " + $help.Synopsis;
	"";
	$help.description | ?{ $_ -and $_.Text } | %{ $_.Text.Split("`n"); };
	"";
	$help.Examples | %{
		$_.Example | %{
			"Example:";
			"";
			"    " + $_.Introduction.Text + " " + $_.Code;
			"    " + "";
			$_.Remarks | ?{ $_ -and $_.Text } | %{ $_.Text.Split("`n"); } | %{ "    " + $_; };
		};
		"";
		"";
	};
	"";
	"";
};

gc .\README.template.md | %{ $_.Replace("{commandHelp}", ($commandHelpAsMarkdown -join "`n")); } > README.md
