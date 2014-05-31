#include <Windows.h>
#include <ShObjIdl.h>
#include <AppxPackaging.h>
#include <atlbase.h>
#include <iostream>

using namespace std;

void launchAppxPackage(__in const wchar_t *applicationUserModelId) {
	HRESULT hr = CoInitialize(nullptr);
	if (SUCCEEDED(hr)) {
		{
			CComPtr<IApplicationActivationManager> applicationActivationManager;
			HRESULT hr = CoCreateInstance(CLSID_ApplicationActivationManager, NULL, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&applicationActivationManager));
			if (SUCCEEDED(hr)) {
				DWORD processId = 0;
				hr = applicationActivationManager->ActivateApplication(applicationUserModelId, nullptr, AO_NONE, &processId);
				if (SUCCEEDED(hr)) {
					wcout << processId << endl;
				}
				else {
					wcerr << L"Error in ActivateApplication 0x" << hex << hr << endl;
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

void launchAppxPackage(__in const wchar_t *packageFullName, __in const wchar_t *applicationId) {
	wstring applicationUserModelId;
	
	applicationUserModelId += packageFullName;
	applicationUserModelId += L"!";
	applicationUserModelId += applicationId;

	launchAppxPackage(applicationUserModelId.c_str());
}

int __cdecl wmain(__in const int argumentsSize, __in_ecount(argc) const wchar_t * arguments[]) {
	static const int packageFullNameArgumentIndex = 1,
		applicationUserModelIdArgumentIndex = 1,
		applicationIdArgumentIndex = 2,
		minimumArgumentsSize = 2,
		maximumArgumentsSize = 3;

	if (argumentsSize == minimumArgumentsSize) {
		launchAppxPackage(arguments[applicationUserModelIdArgumentIndex]);
	}
	else if (argumentsSize == maximumArgumentsSize) {
		launchAppxPackage(arguments[packageFullNameArgumentIndex], arguments[applicationIdArgumentIndex]);
	}
	else {
		wcout << L"Launch an installed Appx app" << endl
			<< L"\tLaunchAppxPackage.exe [Package full name] [Application ID]" << endl
			<< L"\tLaunchAppxPackage.exe [Application user model ID]" << endl;
	}
}