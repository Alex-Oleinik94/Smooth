{$INCLUDE Smooth.inc}

//{$DEFINE S_SCENE_DEBUG}

unit SmoothScene;

interface

uses
	 SmoothBase
	,SmoothCommonStructs
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothMesh
	,SmoothModel
	,SmoothGameBase
	,SmoothCamera
	,SmoothCasesOfPrint
	;

type
	TSScene = class(TSNod)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
			protected
		FCamera : TSCamera;
		FMutators : TSArMutators;
		FPlayerModel : TSInt64;
			private
		function GetModel(const Index : TSLongWord):TSModel;inline;
		procedure InitCameraPosition();inline;
			public
		function AddMutator( const NewMutatorClass : TSMutatorClass ):TSMutator;
		procedure Start();
			public
		function AddModel(const NewModel : TSCustomModel;const VDynamic : TSBoolean = False):TSModel;
		function LastModel():TSModel;inline;
			public
		property Player : TSInt64  read FPlayerModel;
		property Camera : TSCamera read FCamera;
		property Models[Index : TSLongWord]:TSModel read GetModel;
			public
		procedure ViewInfo(const PredString : TSString = ''; const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]);
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothLog
	;

procedure TSScene.ViewInfo(const PredString : TSString = ''; const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]);
var
	i : TSUInt32;
begin
SHint([PredString, 'TSScene__ViewInfo(..)'], CasesOfPrint);
SHint([PredString, '  Camera   = ', SAddrStr(FCamera)], CasesOfPrint);
if (FNods <> nil) and (Length(FNods) > 0) then
	for i := 0 to High(FNods) do
		if FNods[i] is TSModel then
			if (FNods[i] as TSModel).Mesh <> nil then
				(FNods[i] as TSModel).Mesh.WriteInfo(PredString + '  ' + SStr(i + 1) + ') ', CasesOfPrint);
end;

function TSScene.LastModel():TSModel;inline;
begin
if FNods = nil then
	Result := nil
else
	Result := FNods[High(FNods)] as TSModel;
end;

function TSScene.AddModel(const NewModel : TSCustomModel;const VDynamic : TSBoolean = False):TSModel;
var
	i : TSLongWord;
begin
Result := TSModel.Create(Context);
Result.Context:=Context;
Result.Mesh := NewModel;
AddNod(Result);
for i := 0 to High(FMutators) do
	if FMutators[i] <> nil then
		begin
		FMutators[i].AddNodProperty(Result);
		end;
end;

procedure TSScene.Start();
var
	i : TSLongWord;
begin
if FNods<>nil then
	for i:=0 to High(FNods) do
		if FNods[i] is TSModel then
			Models[i].LoadToVBO();

for i := 0 to High(FMutators) do
	if FMutators[i] <> nil then
		FMutators[i].Start();
end;

function TSScene.GetModel(const Index : TSLongWord):TSModel;inline;
begin
if (FNods <> nil) and (Index >= 0) and (Index <= High(FNods)) and (FNods[Index] <> nil) then
	Result := FNods[Index] as TSModel
else
	Result := nil;
end;

function TSScene.AddMutator( const NewMutatorClass : TSMutatorClass ):TSMutator;
begin
if FMutators<> nil then
	SetLength(FMutators, Length(FMutators) + 1)
else
	SetLength(FMutators, 1);
Result:=NewMutatorClass.Create(Context);
FMutators[High(FMutators)]:=Result;
Result.SetParent(Self);
end;

constructor TSScene.Create(const VContext : ISContext);
begin
inherited Create(VContext);

FCamera := TSCamera.Create();
FCamera.SetContext(Context);

FMutators    := nil;
FPlayerModel := -1;
end;

destructor TSScene.Destroy();
var
	i : TSLongWord;
begin
if FCamera<>nil then
	begin
	FCamera.Destroy();
	FCamera := nil;
	end;
if FMutators <> nil then
	begin
	for i := 0 to High(FMutators) do
		if FMutators[i] <> nil then
			FMutators[i].Destroy();
	SetLength(FMutators, 0);
	end;
inherited;
end;

procedure TSScene.InitCameraPosition();
begin
if FCamera <> nil then
	//FCamera.InitMatrix();
	FCamera.CallAction();
end;

procedure TSScene.Paint();
var
	i : TSLongWord;
begin
{$IF defined(S_SCENE_DEBUG)}
SLog.Source('TSScene__Paint(). Processing mutators...');
{$ENDIF}
if FMutators <> nil then
	for i := 0 to High ( FMutators ) do
		if FMutators[i]<>nil then
			FMutators[i].UpDate();
{$IF defined(S_SCENE_DEBUG)}
SLog.Source('TSScene__Paint(). : Paint nods...');
{$ENDIF}
InitCameraPosition();
Render.Color3f(1, 1, 1);
if FNods <> nil then
	for i:=0 to High(FNods) do
		if FNods[i] <> nil then
			FNods[i].Paint();
end;

class function TSScene.ClassName():TSString;
begin
Result := 'TSScene';
end;

end.
