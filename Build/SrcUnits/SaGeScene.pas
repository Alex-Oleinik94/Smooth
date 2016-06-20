{$INCLUDE Includes\SaGe.inc}
unit SaGeScene;

interface

uses
	SaGeBase
	,SaGeBased
	,SaGeCommon
	,SaGeContextInterface
	,SaGeMesh
	,SaGeModel
	,SaGeUtils
	,SaGeGameBase
	;

type
	TSGScene = class(TSGNod)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSGString;override;
			protected
		FCamera : TSGCamera;
		FMutators : TSGArMutators;
		FPlayerModel : TSGInt64;
			private
		function GetModel(const Index : TSGLongWord):TSGModel;inline;
		procedure InitCameraPosition();inline;
			public
		function AddMutator( const NewMutatorClass : TSGMutatorClass ):TSGMutator;
		procedure Start();
			public
		function AddModel(const NewModel : TSGCustomModel;const VDynamic : TSGBoolean = False):TSGModel;
		function LastModel():TSGModel;inline;
			public
		property Player : TSGInt64  read FPlayerModel;
		property Camera : TSGCamera read FCamera;
		property Models[Index : TSGLongWord]:TSGModel read GetModel;
		end;

implementation

function TSGScene.LastModel():TSGModel;inline;
begin
if FNods=nil then
	Result:=nil
else
	Result:=FNods[High(FNods)] as TSGModel;
end;

function TSGScene.AddModel(const NewModel : TSGCustomModel;const VDynamic : TSGBoolean = False):TSGModel;
var
	i : TSGLongWord;
begin
Result:=TSGModel.Create(Context);
Result.Context:=Context;
Result.Mesh := NewModel;
AddNod(Result);
for i := 0 to High(FMutators) do
	if FMutators[i] <> nil then
		begin
		FMutators[i].AddNodProperty(Result);
		end;
end;

procedure TSGScene.Start();
var
	i : TSGLongWord;
begin
if FNods<>nil then
	for i:=0 to High(FNods) do
		if (FNods[i] as TSGModel)<>nil then
			Models[i].LoadToVBO();
for i := 0 to High(FMutators) do
	if FMutators[i] <> nil then
		FMutators[i].Start();
end;

function TSGScene.GetModel(const Index : TSGLongWord):TSGModel;inline;
begin
if (FNods<>nil) and (FNods[Index]<>nil) then
	Result:=FNods[Index] as TSGModel
else
	Result:=nil;
end;

function TSGScene.AddMutator( const NewMutatorClass : TSGMutatorClass ):TSGMutator;
begin
if FMutators<> nil then
	SetLength(FMutators,Length(FMutators)+1)
else
	SetLength(FMutators,1);
Result:=NewMutatorClass.Create(Context);
FMutators[High(FMutators)]:=Result;
Result.SetParent(Self);
end;

constructor TSGScene.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FCamera := TSGCamera.Create();
FCamera.SetContext(Context);
FMutators := nil;
FPlayerModel:=-1;
end;

destructor TSGScene.Destroy();
var
	i : TSGLongWord;
begin
if FCamera<>nil then
	FCamera.Destroy();
if FMutators <> nil then
	begin
	for i := 0 to High(FMutators) do
		if FMutators[i] <> nil then
			FMutators[i].Destroy();
	SetLength(FMutators,0);
	end;
inherited;
end;

procedure TSGScene.InitCameraPosition();
begin
FCamera.InitMatrix();
end;

procedure TSGScene.Paint();
var
	i : TSGLongWord;
begin
//SGLog.Sourse('TSGScene.Draw : Processing mutators..');
if FMutators <> nil then
	for i := 0 to High ( FMutators ) do
		if FMutators[i]<>nil then
			FMutators[i].UpDate();
//SGLog.Sourse('TSGScene.Draw : Draw nods..');
InitCameraPosition();
if FNods<>nil then
	for i:=0 to High(FNods) do
		if FNods[i]<>nil then
			begin
			Render.PushMatrix();
			FNods[i].Paint();
			Render.PopMatrix()
			end;
end;

class function TSGScene.ClassName():TSGString;
begin
Result:='TSGScene';
end;

end.
