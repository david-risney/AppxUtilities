#include <windows.h>
#include <appmodel.h>
#include <iostream>

using namespace std;

struct ProcessInfo {
	wstring packageFullName;
	LONG status;
};

ProcessInfo processToPackageFullName(HANDLE process) {
	static const size_t packageFullNameMaxSize = 1024;
	wchar_t packageFullNameAsCStr[packageFullNameMaxSize] = L"\0";
	ProcessInfo processInfo;

	UINT32 packageFullNameAsCStrLength = ARRAYSIZE(packageFullNameAsCStr);
	LONG rc = GetPackageFamilyName(process, &packageFullNameAsCStrLength, packageFullNameAsCStr);
	processInfo.status = rc;

	if (rc == ERROR_SUCCESS) {
		processInfo.packageFullName = packageFullNameAsCStr;
	}

	return processInfo;
}

void showProcessAndPackageInfo(const UINT32 processId, HANDLE process) {
	ProcessInfo processInfo = processToPackageFullName(process);

	if (processInfo.status == ERROR_SUCCESS) {
		wcout << processId << L"\t" << processInfo.packageFullName.c_str();
	}
	else {
		wcout << L"Unable to obtain packageFullName. Error: " << processInfo.status;
	}

	wcout << endl;
}

void showPackageInfoByProcessId(const UINT32 processId) {
	HANDLE process = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, processId);
	if (process) {
		showProcessAndPackageInfo(processId, process);
		CloseHandle(process);
	}
	else {
		wcout << L"Unable to open processId " << processId << L". Error: " << GetLastError() << endl;
	}
}

void showPackageInfoByProcessId(const wchar_t *processIdAsCStr) {
	UINT32 processIdAsUInt = wcstoul(processIdAsCStr, NULL, 10);
	if (processIdAsUInt > 0) {
		showPackageInfoByProcessId(processIdAsUInt);
	}
	else {
		wcout << L"Invalid processId specified: " << processIdAsCStr << endl;
	}
}

int __cdecl wmain(__in const int argumentsSize, __in_ecount(argc) const wchar_t * arguments[]) {
	static const int argumentsSizeMinimum = 2;

	if (argumentsSize >= argumentsSizeMinimum) {
		for (int argumentIndex = 1; argumentIndex < argumentsSize; ++argumentIndex) {
			showPackageInfoByProcessId(arguments[argumentIndex]);
		}
	}
	else {
		wcout << L"ProcessIdToPackageId [Process Id] ([Process Id] ...)" << endl
			<< L"\tEvery process ID on the command line produces a line of output listing the " << endl
			<< L"\tprocess ID followed by the full package ID if the process has package identity or" << endl
			<< L"\tjust the process ID if it has no package identity." << endl;
	}
}