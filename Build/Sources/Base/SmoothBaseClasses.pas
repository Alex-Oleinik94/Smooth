{$INCLUDE Smooth.inc}

unit SmoothBaseClasses;

interface

uses
	 Classes
	
	,SmoothBase
	;

type
	ISInterface = interface(IInterface)
		['{2542664e-68ea-47d7-8f66-67e3143ca7ae}']
		procedure DestroyFromInterface();
		end;

	TSObject = class(TObject)
			public
		constructor Create();virtual;
		class function ObjectName() : TSString; virtual;
		end;

	TSInterfacedObject = class(TSObject, ISInterface)
			private
		FReferenceCount : TSLongWord;
			public
		function QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} VInterfaceIdentifier : TSGuid; out VObject) : TSLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};virtual;
		function _AddRef : TSLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};virtual;
		function _Release : TSLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};virtual;
			public
		constructor Create(); override;
		destructor Destroy(); override;
		procedure DestroyFromInterface();virtual;
		end;
	
	TSNamed = class(TSInterfacedObject)
			public
		{$IFDEF WITHLEAKSDETECTOR}
		constructor Create(); override;
		destructor Destroy(); override;
		{$ENDIF}
		class function ClassName() : TSString; virtual;
		class function ExistedName() : TSString; virtual;
		end;
	TSNamedClass = class of TSNamed;
	
	ISOptionGetSeter = interface(ISInterface)
		['{8c35573c-38fb-43ab-876f-af746af58650}']
		function GetOption(const VName : TSString) : TSPointer;
		procedure SetOption(const VName : TSString; const VValue : TSPointer);
		end;
	
	TSOptionGetSeter = class(TSNamed)
			public
		function GetOption(const VName : TSString) : TSPointer;virtual;
		procedure SetOption(const VName : TSString; const VValue : TSPointer);virtual;
		end;

procedure SDestroyInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} i : IInterface);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator = (const Guid1, Guid2 : TSGuid) : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SysUtils
	
	,SmoothLog
	{$IFDEF WITHLEAKSDETECTOR}
		,SmoothLeaksDetector
		{$ENDIF}
	;

operator = (const Guid1, Guid2 : TSGuid) : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
var
	Index : TSUInt8;
begin
Result := 
	(Guid1.Data1 = Guid2.Data1) and
	(Guid1.Data2 = Guid2.Data2) and
	(Guid1.Data3 = Guid2.Data3);
if Result then
	for Index := 0 to 7 do
		if (Guid1.Data4[Index] <> Guid2.Data4[Index]) then
			begin
			Result := False;
			break;
			end;
end;

function TSOptionGetSeter.GetOption(const VName : TSString) : TSPointer;
begin
Result := nil;
end;

procedure TSOptionGetSeter.SetOption(const VName : TSString; const VValue : TSPointer);
begin
end;

{$IFDEF WITHLEAKSDETECTOR}
constructor TSNamed.Create();
begin
inherited;
if LeaksDetector = nil then
	SInitLeaksDetector();
LeaksDetector.AddReference(ObjectName());
end;

destructor TSNamed.Destroy();
begin
if LeaksDetector = nil then
	SInitLeaksDetector();
LeaksDetector.ReleaseReference(ObjectName());
inherited;
end;
{$ENDIF}

procedure SDestroyInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} i : IInterface);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
try
while i._Release() > 0 do ;
except
end;
end;

constructor TSObject.Create();
begin
end;

constructor TSInterfacedObject.Create();
begin
inherited;
FReferenceCount := 1;
end;

destructor TSInterfacedObject.Destroy();
begin
inherited;
end;

procedure TSInterfacedObject.DestroyFromInterface();
begin
if Self <> nil then
	begin
	WriteLn('Destroying from interface ' + ClassName());
	Self.Destroy();
	end;
end;

class function TSObject.ObjectName() : TSString;
begin
Result := ClassName;
end;

class function TSNamed.ExistedName() : TSString;
begin
Result := ClassName();
if Result = '' then
	Result := ObjectName();
end;

class function TSNamed.ClassName() : TSString;
begin
Result := 'TSNamed';
end;

function TSInterfacedObject.QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} VInterfaceIdentifier : TSGuid; out VObject) : TSLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
Result := S_OK;
if not Supports(Self, VInterfaceIdentifier, VObject) then
	if not GetInterface(VInterfaceIdentifier, VObject) then
		{$IFNDEF RELEASE}Result := TSLongInt(E_NOINTERFACE){$ENDIF};
end;

function TSInterfacedObject._AddRef : TSLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
Result := InterlockedIncrement(FReferenceCount);
end;

function TSInterfacedObject._Release : TSLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
Result := InterlockedDecrement(FReferenceCount);
if Result = 0 then
	begin
	DestroyFromInterface();
	end;
end;

end.
