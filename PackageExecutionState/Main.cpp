#include <Windows.h>
#include <ShObjIdl.h>
#include <AppxPackaging.h>
#include <atlbase.h>
#include <iostream>
#include <string>
#include <wrl.h>

using namespace std;
using namespace Microsoft::WRL;

enum PackageExecutionStateAction {
	Suspend,
	Resume,
	Terminate
};

enum PackageExecutionStateWait {
	ReturnImmediately,
	WaitForCompletion
};

class CWaiter : public RuntimeClass<RuntimeClassFlags<ClassicCom>, IPackageExecutionStateChangeNotification> {
public:
	CWaiter() : desiredState(PES_UNKNOWN), registrationId(0) { }

	virtual ~CWaiter() {
		if (this->packageDebugSettings) {
			this->packageDebugSettings->UnregisterForPackageStateChanges(this->registrationId);
			this->registrationId = 0;
			this->packageDebugSettings = nullptr;
		}
		if (this->eventHandle) {
			CloseHandle(this->eventHandle);
			this->eventHandle = nullptr;
		}
	};

	HRESULT Initialize(__in const wchar_t *packageFullName, __in IPackageDebugSettings *packageDebugSettingsIn, __in PACKAGE_EXECUTION_STATE desiredStateIn) {
		this->packageDebugSettings = packageDebugSettingsIn;
		this->desiredState = desiredStateIn;
		this->eventHandle = CreateEvent(nullptr, TRUE, FALSE, nullptr);
		return this->packageDebugSettings->RegisterForPackageStateChanges(packageFullName, this, &this->registrationId);
	}

	HRESULT Wait() {
		DWORD waitIndex = 0;
		HRESULT hr = CoWaitForMultipleHandles(0, 1000 * 30, 1, &this->eventHandle, &waitIndex);
		if (SUCCEEDED(hr) && waitIndex != 0) {
			hr = E_UNEXPECTED;
			wcerr << L"Unexpected wait result." << endl;
		}
		return hr;
	}

	HRESULT __stdcall OnStateChanged(__in const wchar_t *packageFullName, __in PACKAGE_EXECUTION_STATE state) {
		if (state == this->desiredState) {
			SetEvent(this->eventHandle);
		}
		return S_OK;
	}

private:
	HANDLE eventHandle;
	ComPtr<IPackageDebugSettings> packageDebugSettings;
	PACKAGE_EXECUTION_STATE desiredState;
	DWORD registrationId;
};

void setPackageExecutionState(__in const wchar_t *packageFullName, __in PackageExecutionStateAction action, __in PackageExecutionStateWait wait) {
	HRESULT hr = CoInitialize(nullptr);
	if (SUCCEEDED(hr)) {
			{
				ComPtr<IPackageDebugSettings> packageDebugSettings;
				HRESULT hr = CoCreateInstance(CLSID_PackageDebugSettings, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&packageDebugSettings));
				if (SUCCEEDED(hr)) {
					DWORD registrationId = 0;
					ComPtr<CWaiter> waiter;

					if (wait == WaitForCompletion) {
						PACKAGE_EXECUTION_STATE desiredState = PES_UNKNOWN;
						switch (action) {
						case Suspend:
							desiredState = PES_SUSPENDED;
							break;
						case Resume:
							desiredState = PES_RUNNING;
							break;
						case Terminate:
							desiredState = PES_TERMINATED;
							break;
						default:
							wcerr << L"Unexpected error 1." << endl;
							break;
						}
						waiter = Make<CWaiter>();
						hr = waiter->Initialize(packageFullName, packageDebugSettings.Get(), desiredState);
					}
					if (SUCCEEDED(hr)) {
						switch (action) {
						case Suspend:
							hr = packageDebugSettings->Suspend(packageFullName);
							break;
						case Resume:
							hr = packageDebugSettings->Resume(packageFullName);
							break;
						case Terminate:
							hr = packageDebugSettings->TerminateAllProcesses(packageFullName);
							break;
						default:
							wcerr << L"Unexpected error 2." << endl;
							break;
						}
						if (SUCCEEDED(hr)) {
							if (waiter) {
								hr = waiter->Wait();
								if (FAILED(hr)) {
									wcerr << L"Error waiting 0x" << hex << hr << endl;
								}
							}
						}
						else {
							wcerr << L"Error in Suspend/Resume/TerminateAllProcesses 0x" << hex << hr << endl;
						}
					}
					else {
						wcerr << L"Error creating waiter 0x" << hex << hr << endl;
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

void getPackageExecutionStateInner(__in IPackageDebugSettings *packageDebugSettings, __in const wchar_t *packageFullName) {
	PACKAGE_EXECUTION_STATE packageExecutionState = {};
	HRESULT hr = packageDebugSettings->GetPackageExecutionState(packageFullName, &packageExecutionState);

	if (SUCCEEDED(hr)) {
		static const wchar_t * packageExecutionStateNameMap[] = {
			L"unknown", // PES_UNKNOWN = 0
			L"running", // PES_RUNNING = 1
			L"suspending", // PES_SUSPENDING = 2
			L"suspended", // PES_SUSPENDED = 3
			L"terminated" }; // PES_TERMINATED = 4

		const wchar_t *packageExecutionStateName = L"invalid";
		if (packageExecutionState >= PES_UNKNOWN && packageExecutionState <= PES_TERMINATED) {
			packageExecutionStateName = packageExecutionStateNameMap[packageExecutionState];
		}
		wcout << packageFullName << L"\t" << packageExecutionStateName << endl;
	}
	else {
		wcerr << L"Error in GetPackageExecutionState 0x" << hex << hr << endl;
	}

}

void getPackageExecutionState(__in const wchar_t *packageFullName) {
	HRESULT hr = CoInitialize(nullptr);
	if (SUCCEEDED(hr)) {
			{
				ComPtr<IPackageDebugSettings> packageDebugSettings;
				HRESULT hr = CoCreateInstance(CLSID_PackageDebugSettings, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&packageDebugSettings));
				if (SUCCEEDED(hr)) {
					if (wcscmp(packageFullName, L"-") == 0) {
						wstring id;
						while (getline(wcin, id)) {
							getPackageExecutionStateInner(packageDebugSettings.Get(), id.c_str());
						}
					}
					else {
						getPackageExecutionStateInner(packageDebugSettings.Get(), packageFullName);
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
		const wchar_t *packageFullName = arguments[2];

		if (_wcsicmp(arguments[1], L"/get") == 0) {
			getPackageExecutionState(packageFullName);
		}
		else if (_wcsicmp(arguments[1], L"/resume") == 0) {
			setPackageExecutionState(packageFullName, Resume, ReturnImmediately);
		}
		else if (_wcsicmp(arguments[1], L"/resumeAndWait") == 0) {
			setPackageExecutionState(packageFullName, Resume, WaitForCompletion);
		}
		else if (_wcsicmp(arguments[1], L"/suspend") == 0) {
			setPackageExecutionState(packageFullName, Suspend, ReturnImmediately);
		}
		else if (_wcsicmp(arguments[1], L"/suspendAndWait") == 0) {
			setPackageExecutionState(packageFullName, Suspend, WaitForCompletion);
		}
		else if (_wcsicmp(arguments[1], L"/terminate") == 0) {
			setPackageExecutionState(packageFullName, Terminate, ReturnImmediately);
		}
		else if (_wcsicmp(arguments[1], L"/terminateAndWait") == 0) {
			setPackageExecutionState(packageFullName, Terminate, WaitForCompletion);
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
		wcout << L"Get or set the package execution state of an installed AppX package." << endl
			<< L"\tPackageExecutionState.exe /get [package full name]" << endl
			<< L"\tPackageExecutionState.exe /resume [package full name]" << endl
			<< L"\tPackageExecutionState.exe /suspend [package full name]" << endl
			<< L"\tPackageExecutionState.exe /terminate [package full name]" << endl
			<< L"\tPackageExecutionState.exe /resumeAndWait [package full name]" << endl
			<< L"\tPackageExecutionState.exe /suspendAndWait [package full name]" << endl
			<< L"\tPackageExecutionState.exe /terminateAndWait [package full name]" << endl
			;
	}
}