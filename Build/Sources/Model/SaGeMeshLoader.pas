{$INCLUDE SaGe.inc}

unit SaGeMeshLoader;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeMesh
	
	,Classes
	;
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
		property Model    : TSGCustomModel        read FModel    write FModel;
		property FileName : TSGString             read FFileName write FFileName;
		property Progress : TSGMeshLoaderProgress read FProgress write FProgress;
			protected
		procedure SetProgress(const ProgressNow : TSGFloat32); virtual;
		end;

function SGLoadMesh(const LoadClass : TSGMeshLoaderClass; const LoadModel : TSGCustomModel; const LoadFileName : TSGString; const LoadProgress : TSGMeshLoaderProgress = nil) : TSGBoolean;

implementation

uses
	 SaGeLog
	,SaGeSysUtils
	
	,SysUtils
	;

function SGLoadMesh(const LoadClass : TSGMeshLoaderClass; const LoadModel : TSGCustomModel; const LoadFileName : TSGString; const LoadProgress : TSGMeshLoaderProgress = nil) : TSGBoolean;
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
