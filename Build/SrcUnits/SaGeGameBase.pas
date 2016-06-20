{$INCLUDE Includes\SaGe.inc}

unit SaGeGameBase;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeContextInterface
	;

type
	(******************************************************************)
	(****************************){NOD}(*******************************)
	(******************************************************************)
	TSGNod = class;
	TSGNodClass = class of TSGNod;
	TSGArNod = packed array of TSGNod;
	TSGNod = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
			protected
		FNods   : TSGArNod;
		FParent : TSGNod;
			public
		function  AddNod(const NewNodClass : TSGNodClass):TSGNod;virtual;overload;
		procedure AddNod(const NewNod : TSGNod);virtual;overload;
		function DeleteNod(const Nod : TSGNod):TSGBoolean;virtual;
		procedure SetParent(const Nod : TSGNod );
			private
		function GetNod(const Index : TSGLongWord):TSGNod;inline;
		function GetQuantityNods():TSGLongWord;inline;
			public
		property Nods[Index : TSGLongWord]:TSGNod read GetNod;
		property QuantityNods : TSGLongWord read GetQuantityNods;
		end;
type
	(******************************************************************)
	(**************************){MUTATOR}(*****************************)
	(******************************************************************)
	TSGNodProperty = class(TSGNod) 
		end;
	
	TSGMutator = class;
	TSGArMutators = packed array of TSGMutator;
	TSGMutatorClass = class of TSGMutator;
	TSGMutator = class(TSGNod)
			public
		constructor Create(const VContext : ISGContext);override;
			protected
		FLastNodProperty : TSGNodProperty;
			public
		procedure UpDate();virtual;abstract;
		procedure Start();virtual;abstract;
		procedure AddNodProperty(const NewParentNod:TSGNod);virtual;abstract;
			public
		property LastNodProperty : TSGNodProperty read FLastNodProperty;
		end;

implementation

constructor TSGMutator.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FLastNodProperty:=nil;
end;

(******************************************************************)
(****************************){NOD}(*******************************)
(******************************************************************)

function TSGNod.GetNod(const Index : TSGLongWord):TSGNod;inline;
begin
if (FNods<>nil) then
	Result:=FNods[Index]
else
	Result:=nil;
end;

function TSGNod.GetQuantityNods():TSGLongWord;inline;
begin
if FNods=nil then
	Result:=0
else
	Result:=Length(FNods);
end;

procedure TSGNod.SetParent(const Nod : TSGNod );
begin
FParent:=Nod;
end;

constructor TSGNod.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FNods:=nil;
FParent:=nil;
end;

destructor TSGNod.Destroy();
var
	i : TSGLongWord;
begin
if FNods<>nil then
	begin
	for i:=0 to High(FNods) do
		if FNods[i]<>nil then
			FNods[i].Destroy();
	SetLength(FNods,0);
	end;
if FParent<>nil then
	FParent.DeleteNod(Self);
inherited;
end;

class function TSGNod.ClassName():TSGString;
begin
Result:='TSGNod';
end;

procedure TSGNod.AddNod(const NewNod : TSGNod);overload;
begin
if FNods=nil then
	SetLength(FNods,1)
else
	SetLength(FNods,Length(FNods)+1);
FNods[High(FNods)]:=NewNod;
NewNod.SetParent(Self);
end;

function TSGNod.AddNod(const NewNodClass : TSGNodClass):TSGNod;overload;
begin
if FNods=nil then
	SetLength(FNods,1)
else
	SetLength(FNods,Length(FNods)+1);
Result:=NewNodClass.Create(Context);
Result.SetParent(Self);
FNods[High(FNods)]:=Result;
end;

function TSGNod.DeleteNod(const Nod : TSGNod):TSGBoolean;
var
	i, ii: TSGLongWord;
begin
Result:=False;
if FNods<>nil then
	begin
	ii := Length(FNods);
	for i:=0 to High(FNods) do
		if FNods[i] = Nod then
			begin
			ii:=i;
			Break;
			end;
	if ii <> Length(FNods) then
		begin
		for i := ii to Length(FNods)-1 do
			FNods[i]:=FNods[i+1];
		SetLength(FNods,Length(FNods)-1);
		Result:=True;
		end;
	end;
end;

end.
