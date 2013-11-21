{$INCLUDE Includes\SaGe.inc}
unit SaGeGameMesh;
interface
uses 
	 SaGeBase
	,SaGeBased
	,SaGeMesh
	,SaGeContext
	,SaGeCommon
	,SaGePhisics;
type
	TSGGameMesh=class(TSGDrawClass)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		FMeshDraw:TSG3DObject;
		FCollizable:TSGCollizable;
			public
		procedure Draw();override;
		procedure TransfomMatrix();virtual;
		end;

implementation

///=============================================
///=================TSGGameMesh=================
///=============================================

procedure TSGGameMesh.TransfomMatrix();
begin
if FCollizable<>nil then
	FCollizable.TransfomMatrix();
end;

procedure TSGGameMesh.Draw();
begin
if FMeshDraw<>nil then
	FMeshDraw.Draw();
end;

constructor TSGGameMesh.Create();
begin
inherited;
FMeshDraw:=nil;
FCollizable:=nil;
end;

destructor TSGGameMesh.Destroy();
begin
if FMeshDraw<>nil then
	FMeshDraw.Destroy();
if FCollizable<>nil then
	FCollizable.Destroy();
inherited;
end;

end.
