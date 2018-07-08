{$INCLUDE SaGe.inc}

unit SaGeDefinesSkiper;

interface

uses
	 Classes
	,Crt
	,SysUtils
	
	,SaGeBase
	,SaGeBaseClasses
	;

type
	TSGDefine = object
			private
		FName : TSGString;
		FValue : TSGString;
			public
		procedure Clear();
		procedure Import(const VName : TSGString; const VValue : TSGString = '');
			public
		property Name  : TSGString read FName  write FName;
		property Value : TSGString read FValue write FValue;
		end;

function SGDefineCreate(const VName : TSGString; const VValue : TSGString = '') : TSGDefine; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator =(const A, B : TSGDefine) : TSGBool; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$DEFINE INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSGDefineListHelper}
{$DEFINE DATATYPE_LIST        := TSGDefineList}
{$DEFINE DATATYPE             := TSGDefine}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF INC_PLACE_INTERFACE}

type
	TSGDefinesSkiper = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			protected
		FOutputFileName : TSGString;
		FOutput : TStream;
		FGeneralInputFileName : TSGString;
		FGeneralInputPath : TSGString;
		FDefines : TSGDefineList;
			protected
		procedure Define(const VName : TSGString; const VValue : TSGString = '');
		procedure Undef(const VName : TSGString);
		function Defined(const VName : TSGString) : TSGBool;
		function Macro(const VName : TSGString) : TSGString;
			protected
		procedure SetInput (const VInputFile  : TSGString);
		procedure SetOutput(const VOutputFile : TSGString);
		procedure KillOutput();
			protected
		procedure ProcessInput(const VInputFile : TSGString); overload;
		procedure ProcessInput(const Stream : TStream); overload;
		function ReadNextIdentifier(const Stream : TStream) : TSGString;
			public
		procedure Run();
			public
		property Output : TSGString write SetOutput;
		property Input  : TSGString write SetInput;
		end;

procedure SGDefinesSkiper(const VInputFile, VOutputFile : TSGString);

implementation

uses
	 SaGeFileUtils
	;

function TSGDefinesSkiper.ReadNextIdentifier(const Stream : TStream) : TSGString;
begin

end;

procedure TSGDefinesSkiper.ProcessInput(const Stream : TStream); overload;
begin
while Stream.Position <> Stream.Size do
	begin
	
	end;
end;

procedure TSGDefinesSkiper.Define(const VName : TSGString; const VValue : TSGString = '');
begin
if Defined(VName) then
	Undef(VName);
FDefines += SGDefineCreate(VName, VValue);
end;

procedure TSGDefinesSkiper.Undef(const VName : TSGString);
var
	i, ii : TSGUInt32;
begin
if (FDefines <> nil) and (Length(FDefines) > 0) then
	begin
	ii := Length(FDefines);
	for i := 0 to High(FDefines) do
		if FDefines[i].Name = VName then
			begin
			ii := i;
			break;
			end;
	if ii <> Length(FDefines) then
		begin
		if ii <> High(FDefines) then
			for i := ii to High(FDefines) - 1 do
				FDefines[i] := FDefines[i + 1];
		SetLength(FDefines, Length(FDefines) - 1);
		end;
	end;
end;

function TSGDefinesSkiper.Defined(const VName : TSGString) : TSGBool;
var
	i : TSGUInt32;
begin
Result := False;
if (FDefines <> nil) and (Length(FDefines) > 0) then
	for i := 0 to High(FDefines) do
		if FDefines[i].Name = VName then
			begin
			Result := True;
			break;
			end;
end;

function TSGDefinesSkiper.Macro(const VName : TSGString) : TSGString;
var
	i : TSGUInt32;
begin
Result := '';
if (FDefines <> nil) and (Length(FDefines) > 0) then
	for i := 0 to High(FDefines) do
		if FDefines[i].Name = VName then
			begin
			Result := FDefines[i].Value;
			break;
			end;
end;

procedure TSGDefinesSkiper.ProcessInput(const VInputFile : TSGString); overload;
var
	Stream : TStream = nil;
begin
Stream := TFileStream.Create(VInputFile, fmOpenRead);
ProcessInput(Stream);
Stream.Destroy();
Stream := nil;
end;

procedure TSGDefinesSkiper.Run();
begin
ProcessInput(FGeneralInputFileName);
end;

constructor TSGDefinesSkiper.Create();
begin
inherited;
FOutput := nil;
FOutputFileName := '';
FGeneralInputFileName := '';
FGeneralInputPath := '';
FDefines := nil;
end;

destructor TSGDefinesSkiper.Destroy();
begin
KillOutput();
inherited;
end;

class function TSGDefinesSkiper.ClassName() : TSGString;
begin
Result := 'TSGDefinesSkiper';
end;

procedure TSGDefinesSkiper.SetInput (const VInputFile  : TSGString);
begin
FGeneralInputFileName := VInputFile;
FGeneralInputPath := SGFilePath(FGeneralInputFileName);
end;

procedure TSGDefinesSkiper.SetOutput(const VOutputFile : TSGString);
begin
FOutputFileName := VOutputFile;
KillOutput();
FOutput := TFileStream.Create(FOutputFileName, fmCreate);
end;

procedure TSGDefinesSkiper.KillOutput();
begin
if FOutput <> nil then
	begin
	FOutput.Destroy();
	FOutput := nil;
	end;
end;

procedure SGDefinesSkiper(const VInputFile, VOutputFile : TSGString);
begin
with TSGDefinesSkiper.Create() do
	begin
	Output := VOutputFile;
	Input  := VInputFile;
	Run();
	Destroy();
	end;
end;

operator =(const A, B : TSGDefine) : TSGBool; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (A.Name = B.Name) and (A.Value = B.Value);
end;

{$DEFINE INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSGDefineListHelper}
{$DEFINE DATATYPE_LIST        := TSGDefineList}
{$DEFINE DATATYPE             := TSGDefine}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF INC_PLACE_IMPLEMENTATION}

function SGDefineCreate(const VName : TSGString; const VValue : TSGString = '') : TSGDefine; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(VName, VValue);
end;

procedure TSGDefine.Clear();
begin
Import('');
end;

procedure TSGDefine.Import(const VName : TSGString; const VValue : TSGString = '');
begin
FName := VName;
FValue := VValue;
end;

end.
