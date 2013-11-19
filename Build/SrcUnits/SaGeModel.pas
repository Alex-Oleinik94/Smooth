{$INCLUDE Includes\SaGe.inc}

unit SaGeModel;

interface
uses 
	  Classes
	, SaGeCommon
	, SaGeBase
	, SaGeBased
	, SaGeUtils
	, SaGeImages
	, SaGeRender
	, Crt
	, SaGeContext
	, SaGeMesh
	, SaGeGameMesh;
type
	TSGGameModel=class(TSGDrawClass)
			public
		constructor Create();override;
		destructor Destroy(); override;
		class function ClassName():String;override;
			protected
		FQuantityMeshes:LongWord;
		FMeshes:packed array of TSGGameMesh;
			public
		procedure Draw();override;
		procedure FindCollision();virtual;
		end;

implementation

procedure TSGGameModel.FindCollision();
var
	i,ii:TSGMaxEnum;
begin
if FMeshes<>nil then
	for i:=0 to FQuantityMeshes-2 do
		if FMeshes[i]<>nil then
			for ii:=i+1 to FQuantityMeshes-1 do
				if FMeshes[ii]<>nil then
					if FMeshes[ii].FDistance+FMeshes[i].FDistance>=SGAbsTwoVertex(FMeshes[ii].FPosition,FMeshes[i].FPosition) then
						begin
						//Вод тут ищем колизии
						end;
end;

procedure TSGGameModel.Draw();
var
	i:TSGMaxEnum;
begin
if FMeshes<>nil then
	for i:=0 to FQuantityMeshes-1 do
		begin
		if FMeshes[i]<>nil then
			begin
			//!Render.PushMatrix();
			FMeshes[i].TransfomMatrix();
			FMeshes[i].Draw();
			//!Render.PopMatrix();
			end;
		end;
end;

constructor TSGGameModel.Create();
begin
inherited;
FQuantityMeshes:=0;
FMeshes:=nil;
end;

destructor TSGGameModel.Destroy(); 
begin
inherited;
end;

class function TSGGameModel.ClassName():String;
begin
Result:='Game Model';
end;

end.
