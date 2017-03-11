{$INCLUDE SaGe.inc}

unit SaGeMeshLoader;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeMesh
	
	,Classes
	;
	// Manipulator
type
	TSGMeshLoader = class;
	TSGMeshLoaderClass = class of TSGMeshLoader;
	TSGMeshLoaderProgress = TSGModelLoadProgress;
	TSGMeshLoader = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
		function Load() : TSGBoolean; virtual;
			protected
		FFileName  : TSGString;
		FModel     : TSGCustomModel;
		FProgress  : TSGMeshLoaderProgress;
			public
		procedure SetFileName(const VFileName : TSGString); virtual;
		procedure SetModel(const VModel : TSGCustomModel); virtual;
			public
		property Model    : TSGCustomModel        read FModel    write SetModel;
		property FileName : TSGString             read FFileName write SetFileName;
		property Progress : TSGMeshLoaderProgress read FProgress write FProgress;
			protected
		procedure SetProgress(const ProgressNow : TSGFloat32); virtual;
		end;

function SGLoadMesh(const LoadModel : TSGCustomModel; const LoadClass : TSGMeshLoaderClass; const LoadFileName : TSGString; const LoadProgress : TSGMeshLoaderProgress = nil) : TSGBoolean; overload;
function SGLoadMesh3DS(const LoadModel : TSGCustomModel; const LoadFileName : TSGString; const LoadProgress : TSGMeshLoaderProgress = nil) : TSGBoolean; overload;
function SGLoadMesh3DS(const LoadModel : TSGCustomModel; const LoadStream : TStream; const LoadFileName : TSGString = ''; const LoadProgress : TSGMeshLoaderProgress = nil) : TSGBoolean; overload;
function SGLoadMeshOBJ(const LoadModel : TSGCustomModel; const LoadFileName : TSGString; const LoadProgress : TSGMeshLoaderProgress = nil) : TSGBoolean; overload;
function SGLoadMeshSG3DM(const LoadModel : TSGCustomModel; const LoadFileName : TSGString; const LoadProgress : TSGMeshLoaderProgress = nil) : TSGBoolean; overload;

implementation

uses
	 SaGeLog
	,SaGeSysUtils
	
	,SysUtils
	
	// Formats
	,SaGeMesh3ds
	,SaGeMeshObj
	,SaGeMeshSg3dm
	;

function SGLoadMeshSG3DM(const LoadModel : TSGCustomModel; const LoadFileName : TSGString; const LoadProgress : TSGMeshLoaderProgress = nil) : TSGBoolean; overload;
begin
Result := SGLoadMesh(LoadModel, TSGMeshSG3DMLoader, LoadFileName, LoadProgress);
end;

function SGLoadMeshOBJ(const LoadModel : TSGCustomModel; const LoadFileName : TSGString; const LoadProgress : TSGMeshLoaderProgress = nil) : TSGBoolean; overload;
begin
Result := SGLoadMesh(LoadModel, TSGMeshOBJLoader, LoadFileName, LoadProgress);
end;

function SGLoadMesh3DS(const LoadModel : TSGCustomModel; const LoadStream : TStream; const LoadFileName : TSGString = ''; const LoadProgress : TSGMeshLoaderProgress = nil) : TSGBoolean; overload;
begin
Result := False;
with TSGMesh3DSLoader.Create() do
	begin
	try
		Progress := LoadProgress;
		SetStream(LoadStream);
		FileName := LoadFileName;
		Import3DS(LoadModel, Result);
	except on e : Exception do
		SGLogException('SGLoadMesh3DS<Stream>(...). Raised exception', e);
	end;
	Destroy();
	end;
end;

function SGLoadMesh3DS(const LoadModel : TSGCustomModel; const LoadFileName : TSGString; const LoadProgress : TSGMeshLoaderProgress = nil) : TSGBoolean; overload;
begin
Result := SGLoadMesh(LoadModel, TSGMesh3DSLoader, LoadFileName, LoadProgress);
end;

function SGLoadMesh(const LoadModel : TSGCustomModel; const LoadClass : TSGMeshLoaderClass; const LoadFileName : TSGString; const LoadProgress : TSGMeshLoaderProgress = nil) : TSGBoolean; overload;
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
			SGLogException('SGLoadMesh(' + LoadClass.ClassName() + ', "' + LoadFileName + '"). Raised exception', e);
		end;
		Destroy();
		end;
end;

procedure TSGMeshLoader.SetFileName(const VFileName : TSGString);
begin
FFileName := VFileName;
end;

procedure TSGMeshLoader.SetModel(const VModel : TSGCustomModel);
begin
FModel := VModel;
end;

procedure TSGMeshLoader.SetProgress(const ProgressNow : TSGFloat32);
begin
if FProgress <> nil then
	FProgress^ := ProgressNow;
end;

function TSGMeshLoader.Load() : TSGBoolean;
begin
Result := False;
end;

constructor TSGMeshLoader.Create();
begin
inherited;
FFileName := '';
FModel := nil;
FProgress := nil;
end;

destructor TSGMeshLoader.Destroy();
begin
if FModel <> nil then
	FModel := nil;
inherited;
end;

class function TSGMeshLoader.ClassName() : TSGString;
begin
Result := 'TSGMeshLoader';
end;

end.
