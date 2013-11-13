{$i Includes\SaGe.inc}

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
	, SaGeMesh;
type
	TSGBaseModel=class(TSGDrawClass)
			public
		constructor Create();override;
		destructor Destroy(); override;
		class function ClassName():String;override;
			protected
		FName:String;
		FQuantityMeshes:LongWord;
		FQuantityMaterials:LongWord;
		FMeshes:packed array of 
			packed record
			FMaterialIdentity:LongWord;
			FMesh:TSG3DObject;
			end;
		FMaterials:packed array of
			packed record
			FName:string;
			Ka,Kd,Ks:TSGColor3f;
			d:TSGFloat;
			end;
		
		FEnableDrawOnyWhichEnableVBO:Boolean;
		procedure LoadFromOBJ(const FFileName:string);virtual;
			public
		procedure Draw();override;
		end;

implementation

procedure TSGBaseModel.LoadFromOBJ(const FFileName:string);
begin
end;

procedure TSGBaseModel.Draw();
var
	i:LongWord;
begin
for i:=0 to FQuantityMeshes-1 do
	begin
	if FMeshes[i].FMesh <> nil then
		if (not FEnableDrawOnyWhichEnableVBO) or (FEnableDrawOnyWhichEnableVBO and FMeshes[i].FMesh.FEnableVBO) then
			FMeshes[i].FMesh.Draw();
	end;
end;

constructor TSGBaseModel.Create();
begin
inherited;
FName:='';
FQuantityMeshes:=0;
FMeshes:=nil;
FMaterials:=nil;
FQuantityMaterials:=0;
FEnableDrawOnyWhichEnableVBO:=False;
end;

destructor TSGBaseModel.Destroy(); 
begin
inherited;
end;

class function TSGBaseModel.ClassName():String;
begin
Result:='Base Model';
end;

end.
