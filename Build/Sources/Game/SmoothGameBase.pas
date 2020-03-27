{$INCLUDE Smooth.inc}

unit SmoothGameBase;

interface

uses
	 SmoothBase
	,SmoothContextClasses
	,SmoothContextInterface
	;

type
	(******************************************************************)
	(****************************){NOD}(*******************************)
	(******************************************************************)
	TSNod = class;
	TSNodClass = class of TSNod;
	TSArNod = packed array of TSNod;
	TSNod = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
			protected
		FNods   : TSArNod;
		FParent : TSNod;
			public
		function  AddNod(const NewNodClass : TSNodClass):TSNod;virtual;overload;
		procedure AddNod(const NewNod : TSNod);virtual;overload;
		function DeleteNod(const Nod : TSNod):TSBoolean;virtual;
		procedure SetParent(const Nod : TSNod);
		procedure RemoveParent();
		procedure DestroyNods();
			private
		function GetNod(const Index : TSLongWord):TSNod;inline;
		function GetQuantityNods():TSLongWord;inline;
			public
		property Nods[Index : TSLongWord]:TSNod read GetNod;
		property QuantityNods : TSLongWord read GetQuantityNods;
		end;
type
	(******************************************************************)
	(**************************){MUTATOR}(*****************************)
	(******************************************************************)
	TSNodProperty = class(TSNod) 
		end;
	
	TSMutator = class;
	TSArMutators = packed array of TSMutator;
	TSMutatorClass = class of TSMutator;
	TSMutator = class(TSNod)
			public
		constructor Create(const VContext : ISContext);override;
			protected
		FLastNodProperty : TSNodProperty;
			public
		procedure UpDate();virtual;abstract;
		procedure Start();virtual;abstract;
		procedure AddNodProperty(const NewParentNod:TSNod);virtual;abstract;
			public
		property LastNodProperty : TSNodProperty read FLastNodProperty;
		end;

implementation

constructor TSMutator.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FLastNodProperty:=nil;
end;

(******************************************************************)
(****************************){NOD}(*******************************)
(******************************************************************)

function TSNod.GetNod(const Index : TSLongWord):TSNod;inline;
begin
if (FNods<>nil) then
	Result:=FNods[Index]
else
	Result:=nil;
end;

function TSNod.GetQuantityNods():TSLongWord;inline;
begin
if FNods=nil then
	Result:=0
else
	Result:=Length(FNods);
end;

procedure TSNod.SetParent(const Nod : TSNod );
begin
FParent:=Nod;
end;

constructor TSNod.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FNods:=nil;
FParent:=nil;
end;

procedure TSNod.RemoveParent();
begin
if FParent<>nil then
	begin
	FParent.DeleteNod(Self);
	FParent := nil;
	end;
end;

procedure TSNod.DestroyNods();
var
	i : TSInt32;
	FNod : TSNod = nil;
begin
while (FNods <> nil) and (Length(FNods) > 0) do
	begin
	FNod := FNods[High(FNods)];
	DeleteNod(FNod);
	if FNod <> nil then
		begin
		FNod.Destroy();
		FNod := nil;
		end;
	end;
end;

destructor TSNod.Destroy();
begin
RemoveParent();
DestroyNods();
inherited;
end;

class function TSNod.ClassName():TSString;
begin
Result:='TSNod';
end;

procedure TSNod.AddNod(const NewNod : TSNod);overload;
begin
if FNods=nil then
	SetLength(FNods,1)
else
	SetLength(FNods,Length(FNods)+1);
FNods[High(FNods)]:=NewNod;
NewNod.SetParent(Self);
end;

function TSNod.AddNod(const NewNodClass : TSNodClass):TSNod;overload;
begin
if FNods=nil then
	SetLength(FNods,1)
else
	SetLength(FNods,Length(FNods)+1);
Result:=NewNodClass.Create(Context);
Result.SetParent(Self);
FNods[High(FNods)]:=Result;
end;

function TSNod.DeleteNod(const Nod : TSNod):TSBoolean;
var
	i, ii: TSLongWord;
begin
Result := False;
if FNods <> nil then
	begin
	ii := Length(FNods);
	for i := 0 to High(FNods) do
		if FNods[i] = Nod then
			begin
			ii:=i;
			Break;
			end;
	if ii <> Length(FNods) then
		begin
		if ii <> High(FNods) then
			for i := ii to High(FNods) - 1 do
				FNods[i] := FNods[i + 1];
		SetLength(FNods, Length(FNods) - 1);
		if Length(FNods) = 0 then
			FNods := nil;
		Result := True;
		end;
	end;
end;

end.
