#include <Windows.h>
#include <ShObjIdl.h>
#include <AppxPackaging.h>
#include <atlbase.h>
#include <iostream>
#include <wrl.h>

using namespace std;
using namespace Microsoft::WRL;

void launchPackageBackgroundTask(__in const wchar_t *backgroundTaskIdAsString) {
	HRESULT hr = CoInitialize(nullptr);
	if (SUCCEEDED(hr)) {
			{
				ComPtr<IPackageDebugSettings> packageDebugSettings;
				HRESULT hr = CoCreateInstance(CLSID_PackageDebugSettings, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&packageDebugSettings));
				if (SUCCEEDED(hr)) {
					UUID backgroundTaskIdAsUuid;
					UuidFromStringW((RPC_WSTR)(backgroundTaskIdAsString), &backgroundTaskIdAsUuid);
					hr = packageDebugSettings->ActivateBackgroundTask(&backgroundTaskIdAsUuid);

					if (FAILED(hr)) {
						wcerr << L"Error in ActivateBackgroundTask 0x" << hex << hr << endl;
					}
				}
				else {
					wcerr << L"Error in CoCreateInstance 0x" << hex << hr << endl;
				}
			}

		CoUninitialize();
	}
	else {
		wcerr << L"Error in CoInitialize 0x" << hex << hr << endl;
	}
}

void getPackageBackgroundTasks(__in const wchar_t *packageFullName) {
	HRESULT hr = CoInitialize(nullptr);
	if (SUCCEEDED(hr)) {
			{
				ComPtr<IPackageDebugSettings> packageDebugSettings;
				HRESULT hr = CoCreateInstance(CLSID_PackageDebugSettings, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&packageDebugSettings));
				if (SUCCEEDED(hr)) {
					ULONG taskCount = 0;
					const GUID *guids = nullptr;
					const wchar_t **names = nullptr;

					// Documentation doesn't say to release the guid or names.
					hr = packageDebugSettings->EnumerateBackgroundTasks(packageFullName, &taskCount, &guids, &names);

					if (SUCCEEDED(hr)) {
						for (ULONG idx = 0; idx < taskCount; ++idx) {
							OLECHAR guidAsString[40] = L"invalid guid.";
							StringFromGUID2(guids[idx], guidAsString, ARRAYSIZE(guidAsString));
							wcout << names[idx] << L"," << guidAsString << endl;
						}
					}
					else {
						wcerr << L"Error in EnumerateBackgroundTasks2 0x" << hex << hr << endl;
					}
				}
				else {
					wcerr << L"Error in CoCreateInstance 0x" << hex << hr << endl;
				}
			}

		CoUninitialize();
	}
	else {
		wcerr << L"Error in CoInitialize 0x" << hex << hr << endl;
	}
}

int __cdecl wmain(__in const int argumentsSize, __in_ecount(argc) const wchar_t * arguments[]) {
	bool validCommandLine = true;

	if (argumentsSize == 3) {
		if (_wcsicmp(arguments[1], L"/get") == 0) {
			getPackageBackgroundTasks(arguments[2]);
		}
		else if (_wcsicmp(arguments[1], L"/launch") == 0) {
			launchPackageBackgroundTask(arguments[2]);
		}
		else {
			wcerr << L"Unknown switch: " << arguments[1] << endl;
			validCommandLine = false;
		}
	}
	else {
		wcerr << L"Incorrect number of arguments." << endl;
		validCommandLine = false;
	}

	if (!validCommandLine) {
		wcout << L"Get or launch an installed AppX package's background task." << endl
			<< L"\tLaunchAppxPackageBackgroundTask.exe /get [package full name]" << endl
			<< L"\tLaunchAppxPackageBackgroundTask.exe /launch [background task id]" << endl
			;
	}
}