{$INCLUDE SaGe.inc}

unit SaGeBaseClasses;

interface

uses
	 Classes
	
	,SaGeBase
	;

type
	ISGInterface = interface(IInterface)
		['{2542664e-68ea-47d7-8f66-67e3143ca7ae}']
		procedure DestroyFromInterface();
		end;

	TSGObject = class(TObject)
			public
		constructor Create();virtual;
		class function ObjectName() : TSGString; virtual;
		end;

	TSGInterfacedObject = class(TSGObject, ISGInterface)
			private
		FReferenceCount : TSGLongWord;
			public
		function QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} VInterfaceIdentifier : TSGGuid; out VObject) : TSGLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};virtual;
		function _AddRef : TSGLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};virtual;
		function _Release : TSGLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};virtual;
			public
		constructor Create(); override;
		destructor Destroy(); override;
		procedure DestroyFromInterface();virtual;
		end;

	TSGNamed = class(TSGInterfacedObject)
			public
		{$IFDEF WITHLEAKSDETECTOR}
		constructor Create(); override;
		destructor Destroy(); override;
		{$ENDIF}
		class function ClassName() : TSGString; virtual;
		class function ExistedName() : TSGString; virtual;
		end;

	ISGOptionGetSeter = interface(ISGInterface)
		['{8c35573c-38fb-43ab-876f-af746af58650}']
		function GetOption(const VName : TSGString) : TSGPointer;
		procedure SetOption(const VName : TSGString; const VValue : TSGPointer);
		end;
	
	TSGOptionGetSeter = class(TSGNamed)
			public
		function GetOption(const VName : TSGString) : TSGPointer;virtual;
		procedure SetOption(const VName : TSGString; const VValue : TSGPointer);virtual;
		end;

procedure SGDestroyInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} i : IInterface);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SysUtils
	
	,SaGeLog
	{$IFDEF WITHLEAKSDETECTOR}
		,SaGeLeaksDetector
		{$ENDIF}
	;

function TSGOptionGetSeter.GetOption(const VName : TSGString) : TSGPointer;
begin
Result := nil;
end;

procedure TSGOptionGetSeter.SetOption(const VName : TSGString; const VValue : TSGPointer);
begin
end;

{$IFDEF WITHLEAKSDETECTOR}
constructor TSGNamed.Create();
begin
inherited;
if LeaksDetector = nil then
	SGInitLeaksDetector();
LeaksDetector.AddReference(ObjectName());
end;

destructor TSGNamed.Destroy();
begin
if LeaksDetector = nil then
	SGInitLeaksDetector();
LeaksDetector.ReleaseReference(ObjectName());
inherited;
end;
{$ENDIF}

procedure SGDestroyInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} i : IInterface);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
try
while i._Release() > 0 do ;
except
end;
end;

constructor TSGObject.Create();
begin
end;

constructor TSGInterfacedObject.Create();
begin
inherited;
FReferenceCount := 1;
end;

destructor TSGInterfacedObject.Destroy();
begin
inherited;
end;

procedure TSGInterfacedObject.DestroyFromInterface();
begin
if Self <> nil then
	begin
	WriteLn('Destroying from interface ' + ClassName());
	Self.Destroy();
	end;
end;

class function TSGObject.ObjectName() : TSGString;
begin
Result := ClassName;
end;

class function TSGNamed.ExistedName() : TSGString;
begin
Result := ClassName();
if Result = '' then
	Result := ObjectName();
end;

class function TSGNamed.ClassName() : TSGString;
begin
Result := 'TSGNamed';
end;

function TSGInterfacedObject.QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} VInterfaceIdentifier : TSGGuid; out VObject) : TSGLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
Result := S_OK;
if not Supports(Self, VInterfaceIdentifier, VObject) then
	if not GetInterface(VInterfaceIdentifier, VObject) then
		{$IFNDEF RELEASE}Result := TSGLongInt(E_NOINTERFACE){$ENDIF};
end;

function TSGInterfacedObject._AddRef : TSGLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
Result := InterlockedIncrement(FReferenceCount);
end;

function TSGInterfacedObject._Release : TSGLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
Result := InterlockedDecrement(FReferenceCount);
if Result = 0 then
	begin
	DestroyFromInterface();
	end;
end;

end.
