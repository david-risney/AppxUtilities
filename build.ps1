del -fo -rec bin
mkdir bin
Copy-Item -Force ProcessIdToPackageId/Release/ProcessIdToPackageId.exe bin
Copy-Item -Force ProcessIdToPackageId/Release/ProcessIdToPackageId.pdb bin
Copy-Item -Force LaunchAppxPackage/Release/LaunchAppxPackage.exe bin
Copy-Item -Force LaunchAppxPackage/Release/LaunchAppxPackage.pdb bin
Copy-Item -Force ExtractFromAppx/bin/Release/ExtractFromAppx.exe bin
Copy-Item -Force ExtractFromAppx/bin/Release/ExtractFromAppx.pdb bin
Copy-Item -Force PackageExecutionState/Release/PackageExecutionState.exe bin
Copy-Item -Force PackageExecutionState/Release/PackageExecutionState.pdb bin
Copy-Item -Force Script/*.ps1 bin
dir bin\*.ps1 | %{ Copy-Item CmdWrapper\CmdWrapper.cmd $_.fullname.replace(".ps1", ".cmd"); }
Copy-Item -Force Redist\* bin
pushd bin
zip ..\AppxUtilities.zip *
popd
