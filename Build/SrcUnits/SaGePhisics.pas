{$INCLUDE Includes\SaGe.inc}

unit SaGePhisics;

interface

uses
	SaGeBase
	,SaGeBased
	,SaGeCommon
	,SaGeMesh
	,SaGeModel
	,SaGeGameBase
	,SaGeScene
	;

type
	TSGCollidableModel=class(TSGNod)
			protected
		FColidableMesh  : TSG3DObject;
		FWeight         : TSGSingle;   // Масса 
		FFriction       : TSGSingle;   // Трение
		FPositionShift  : TSGPosition; // Изменение позиции с течением времени (скорость с ее направлением)
		FPhysicDistance : TSGSingle;   // Для не напрягания физики
			public
		property PhysicDistance : TSGSingle read FPhysicDistance;
		end;
type
	TSGPCollidableMember = packed record
		RIncluded : TSGBoolean;
		RCollidableModel    : TSGCollidableModel;
		RModel : TSGModel;
		end;
type
	TSGPCollidableGroup = packed array of TSGPCollidableMember;
type
	TSGCustomPhisics = class(TSGMutator)
			private
		procedure ProcessingCollidableGroup(const Player,QuantityCollidables:TSGLongWord;var CollidableGroup : TSGPCollidableGroup);virtual;abstract;
			public
		procedure UpDate();override;
type
		end;
	TSGPhisics2D = class(TSGCustomPhisics)
			private
		procedure ProcessingCollidableGroup(const Player,QuantityCollidables:TSGLongWord;var CollidableGroup : TSGPCollidableGroup);override;
		end;

implementation

// Processing CollidableGroup which indexes of collidable models of scene
procedure TSGPhisics2D.ProcessingCollidableGroup(const Player,QuantityCollidables:TSGLongWord;var CollidableGroup : TSGPCollidableGroup);
begin

end;

procedure TSGCustomPhisics.UpDate();
var
	Scene:TSGScene = nil;
	Index : TSGLongWord;
	CollidableGroup : TSGPCollidableGroup = nil;
	PlayerCollidableModel, IndexCollidableModel : TSGCollidableModel;
	QuantityCollidables : TSGLongWord = 0;
begin
Scene := FParent as TSGScene;
if (Scene <> nil) and (Scene.Player <> -1) then
	begin
	PlayerCollidableModel := Scene.Models[Scene.Player].FindProperty(TSGCollidableModel) as TSGCollidableModel;
	if PlayerCollidableModel <>nil then
		begin
		SetLength(CollidableGroup,Scene.QuantityNods);
		FillChar(CollidableGroup[0],Scene.QuantityNods*SizeOf(CollidableGroup[0]),0);
		for Index := 0 to Scene.QuantityNods-1 do
			if (Scene.Models[Index] <> nil) and (Scene.Player <> Index) then
				begin
				IndexCollidableModel := Scene.Models[Index].FindProperty(TSGCollidableModel) as TSGCollidableModel;
				if IndexCollidableModel <> nil then
					begin
					if SGAbsTwoVertex(Scene.Models[Index].Position.Location, Scene.Models[Scene.Player].Position.Location) < 
						PlayerCollidableModel.PhysicDistance+IndexCollidableModel.PhysicDistance then
							begin
							CollidableGroup[Index].RIncluded := True;
							CollidableGroup[Index].RCollidableModel := IndexCollidableModel;
							CollidableGroup[Index].RModel := Scene.Models[Index];
							QuantityCollidables +=1;
							end;
					end;
				end;
		if QuantityCollidables<>0 then
			begin
			CollidableGroup[Scene.Player].RIncluded := False;
			CollidableGroup[Scene.Player].RCollidableModel := PlayerCollidableModel;
			CollidableGroup[Scene.Player].RModel := Scene.Models[Scene.Player];
			ProcessingCollidableGroup(Scene.Player,QuantityCollidables,CollidableGroup);
			end;
		SetLength(CollidableGroup,0);
		end;
	end;
end;

end.
