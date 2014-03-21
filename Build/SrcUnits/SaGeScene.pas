{$INCLUDE Includes\SaGe.inc}
unit SaGeScene;

interface

uses
	SaGeBase
	,SaGeBased
	,SaGeCommon
	,SaGeContext
	,SaGeMesh
	,SaGeModel
	,SaGeUtils
	,SaGeGameBase
	;

type
	TSGScene = class(TSGNod)
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
			protected
		FCamera : TSGCamera;
		FMutators : TSGArMutators;
		FPlayerModel : TSGInt64;
			private
		function GetModel(const Index : TSGLongWord):TSGModel;inline;
			public
		function AddMutator( const NewMutatorClass : TSGMutatorClass ):TSGMutator;
			public
		property Player : TSGInt64  read FPlayerModel;
		property Camera : TSGCamera read FCamera;
		property Models[Index : TSGLongWord]:TSGModel read GetModel;
		end;

implementation

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

constructor TSGScene.Create(const VContext:TSGContext);
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

procedure TSGScene.Draw();
var
	i : TSGLongWord;
begin
//SGLog.Sourse('TSGScene.Draw : Processing mutators..');
if FMutators <> nil then
	for i := 0 to High ( FMutators ) do
		if FMutators[i]<>nil then
			FMutators[i].UpDate();
//SGLog.Sourse('TSGScene.Draw : Draw nods..');
FCamera.InitMatrix();
if FNods<>nil then
	for i:=0 to High(FNods) do
		if FNods[i]<>nil then
			begin
			Render.PushMatrix();
			FNods[i].Draw();
			Render.PopMatrix()
			end;
end;

class function TSGScene.ClassName():TSGString;
begin
Result:='TSGScene';
end;

end.
