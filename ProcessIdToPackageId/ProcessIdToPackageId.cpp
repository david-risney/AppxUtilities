#include <windows.h>
#include <appmodel.h>
#include <iostream>

using namespace std;

wstring processToPackageFullName(HANDLE process) {
	static const size_t packageFullNameMaxSize = 1024;
	wchar_t packageFullNameAsCStr[packageFullNameMaxSize] = L"\0";
	wstring packageFullNameAsString;

	UINT32 packageFullNameAsCStrLength = ARRAYSIZE(packageFullNameAsCStr);
	LONG rc = GetPackageFamilyName(process, &packageFullNameAsCStrLength, packageFullNameAsCStr);
	if (rc != APPMODEL_ERROR_NO_PACKAGE) {
		packageFullNameAsString = packageFullNameAsCStr;
	}
	else {
		wcerr << L" error reading packageFullName: " << rc;
	}

	return packageFullNameAsString;
}

void showProcessAndPackageInfo(const UINT32 processId, HANDLE process) {
	wstring packageFullName = processToPackageFullName(process);
	wcout << processId;

	if (!packageFullName.empty()) {
		wcout << L"\t" << packageFullName.c_str();
	}

	wcout << endl;
}

void handleProcessId(const UINT32 processId) {
	HANDLE process = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, processId);
	if (process) {
		showProcessAndPackageInfo(processId, process);
		CloseHandle(process);
	}
	else {
		wcerr << L"Unable to open processId " << processId << ". Error: " << GetLastError() << endl;
	}
}

void handleProcessId(const wchar_t *processIdAsCStr) {
	UINT32 processIdAsUInt = wcstoul(processIdAsCStr, NULL, 10);
	if (processIdAsUInt > 0) {
		handleProcessId(processIdAsUInt);
	}
	else {
		wcerr << L"Invalid processId specified: " << processIdAsCStr << endl;
	}
}

int __cdecl wmain(__in const int argumentsSize, __in_ecount(argc) const wchar_t * arguments[]) {
	static const int argumentsSizeMinimum = 2;

	if (argumentsSize >= argumentsSizeMinimum) {
		for (int argumentIndex = 1; argumentIndex < argumentsSize; ++argumentIndex) {
			handleProcessId(arguments[argumentIndex]);
		}
	}
	else {
		wcerr << L"ProcessIdToPackageId [Process Id] ([Process Id] ...)" << endl
			<< L"\tEvery process ID on the command line produces a line of output listing the " << endl
			<< L"\tprocess ID followed by the full package ID if the process has package identity or" << endl
			<< L"\tjust the process ID if it has no package identity." << endl;
	}
}