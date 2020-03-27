{$INCLUDE Smooth.inc}

unit Smooth3dObjectLoader;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,Smooth3dObject
	
	,Classes
	;
	// Manipulator
type
	TS3dObjectLoader = class;
	TS3dObjectLoaderClass = class of TS3dObjectLoader;
	TS3dObjectLoaderProgress = TSModelLoadProgress;
	TS3dObjectLoader = class(TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
		function Load() : TSBoolean; virtual;
			protected
		FFileName  : TSString;
		FModel     : TSCustomModel;
		FProgress  : TS3dObjectLoaderProgress;
			public
		procedure SetFileName(const VFileName : TSString); virtual;
		procedure SetModel(const VModel : TSCustomModel); virtual;
			public
		property Model    : TSCustomModel        read FModel    write SetModel;
		property FileName : TSString             read FFileName write SetFileName;
		property Progress : TS3dObjectLoaderProgress read FProgress write FProgress;
			protected
		procedure SetProgress(const ProgressNow : TSFloat32); virtual;
		end;

function SLoad3dObject(const LoadModel : TSCustomModel; const LoadClass : TS3dObjectLoaderClass; const LoadFileName : TSString; const LoadProgress : TS3dObjectLoaderProgress = nil) : TSBoolean; overload;
function SLoad3dObject3DS(const LoadModel : TSCustomModel; const LoadFileName : TSString; const LoadProgress : TS3dObjectLoaderProgress = nil) : TSBoolean; overload;
function SLoad3dObject3DS(const LoadModel : TSCustomModel; const LoadStream : TStream; const LoadFileName : TSString = ''; const LoadProgress : TS3dObjectLoaderProgress = nil) : TSBoolean; overload;
function SLoad3dObjectOBJ(const LoadModel : TSCustomModel; const LoadFileName : TSString; const LoadProgress : TS3dObjectLoaderProgress = nil) : TSBoolean; overload;
function SLoad3dObjectS3DM(const LoadModel : TSCustomModel; const LoadFileName : TSString; const LoadProgress : TS3dObjectLoaderProgress = nil) : TSBoolean; overload;

implementation

uses
	 SmoothLog
	,SmoothSysUtils
	
	,SysUtils
	
	// Formats
	,Smooth3dObject3ds
	,Smooth3dObjectObj
	,Smooth3dObjectS3dm
	;

function SLoad3dObjectS3DM(const LoadModel : TSCustomModel; const LoadFileName : TSString; const LoadProgress : TS3dObjectLoaderProgress = nil) : TSBoolean; overload;
begin
Result := SLoad3dObject(LoadModel, TS3dObjectS3DMLoader, LoadFileName, LoadProgress);
end;

function SLoad3dObjectOBJ(const LoadModel : TSCustomModel; const LoadFileName : TSString; const LoadProgress : TS3dObjectLoaderProgress = nil) : TSBoolean; overload;
begin
Result := SLoad3dObject(LoadModel, TS3dObjectOBJLoader, LoadFileName, LoadProgress);
end;

function SLoad3dObject3DS(const LoadModel : TSCustomModel; const LoadStream : TStream; const LoadFileName : TSString = ''; const LoadProgress : TS3dObjectLoaderProgress = nil) : TSBoolean; overload;
begin
Result := False;
with TS3dObject3DSLoader.Create() do
	begin
	try
		Progress := LoadProgress;
		SetStream(LoadStream);
		FileName := LoadFileName;
		Import3DS(LoadModel, Result);
	except on e : Exception do
		SLogException('SLoad3dObject3DS<Stream>(...). Raised exception', e);
	end;
	Destroy();
	end;
end;

function SLoad3dObject3DS(const LoadModel : TSCustomModel; const LoadFileName : TSString; const LoadProgress : TS3dObjectLoaderProgress = nil) : TSBoolean; overload;
begin
Result := SLoad3dObject(LoadModel, TS3dObject3DSLoader, LoadFileName, LoadProgress);
end;

function SLoad3dObject(const LoadModel : TSCustomModel; const LoadClass : TS3dObjectLoaderClass; const LoadFileName : TSString; const LoadProgress : TS3dObjectLoaderProgress = nil) : TSBoolean; overload;
begin
Result := False;
if LoadClass <> nil then
	with LoadClass.Create() do
		begin
		Model    := LoadModel;
		FileName := LoadFileName;
		Progress := LoadProgress;
		try
			Result   := Load();
		except on e : Exception do
			SLogException('SLoad3dObject(' + LoadClass.ClassName() + ', "' + LoadFileName + '"). Raised exception', e);
		end;
		Destroy();
		end;
end;

procedure TS3dObjectLoader.SetFileName(const VFileName : TSString);
begin
FFileName := VFileName;
end;

procedure TS3dObjectLoader.SetModel(const VModel : TSCustomModel);
begin
FModel := VModel;
end;

procedure TS3dObjectLoader.SetProgress(const ProgressNow : TSFloat32);
begin
if FProgress <> nil then
	FProgress^ := ProgressNow;
end;

function TS3dObjectLoader.Load() : TSBoolean;
begin
Result := False;
end;

constructor TS3dObjectLoader.Create();
begin
inherited;
FFileName := '';
FModel := nil;
FProgress := nil;
end;

destructor TS3dObjectLoader.Destroy();
begin
if FModel <> nil then
	FModel := nil;
inherited;
end;

class function TS3dObjectLoader.ClassName() : TSString;
begin
Result := 'TS3dObjectLoader';
end;

end.
