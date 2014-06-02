Copy-Item -Force ProcessIdToPackageId/Release/ProcessIdToPackageId.exe bin
Copy-Item -Force ProcessIdToPackageId/Release/ProcessIdToPackageId.pdb bin
Copy-Item -Force LaunchAppxPackage/Release/LaunchAppxPackage.exe bin
Copy-Item -Force LaunchAppxPackage/Release/LaunchAppxPackage.pdb bin
Copy-Item -Force ExtractFromAppx/bin/Release/ExtractFromAppx.exe bin
Copy-Item -Force ExtractFromAppx/bin/Release/ExtractFromAppx.pdb bin
Copy-Item -Force Script/*.ps1 bin
pushd bin
zip ..\AppxUtilities.zip *
popd
