{$INCLUDE SaGe.inc}

unit SaGeWorldOfWarcraftWatcherPaintable;

interface

uses
	 SaGeBase
	,SaGeContextInterface
	,SaGeContextClasses
	,SaGeWorldOfWarcraftConnectionHandler
	,SaGeScreenClasses
	;

type
	TSGWorldOfWarcraftWatcherPaintable = class(TSGPaintableObject)
			public
		constructor Create(const _Context : ISGContext); override;
		destructor Destroy(); override;
		procedure Paint(); override;
		class function ClassName() : TSGString; override;
			protected
		FConnectionHandler : TSGWorldOfWarcraftConnectionHandler;
		FSizeLabel : TSGScreenLabel;
			public
		property ConnectionHandler : TSGWorldOfWarcraftConnectionHandler read FConnectionHandler write FConnectionHandler;
		end;

procedure SGKill(var WorldOfWarcraftWatcherPaintable : TSGWorldOfWarcraftWatcherPaintable); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeStringUtils
	;

class function TSGWorldOfWarcraftWatcherPaintable.ClassName() : TSGString;
begin
Result := 'Maz1g Wizard';
end;

procedure TSGWorldOfWarcraftWatcherPaintable.Paint();
begin
Write('Paint');
if (ConnectionHandler <> nil) then
	FSizeLabel.Caption := SGStr(FConnectionHandler.AllDataSize);
end;

constructor TSGWorldOfWarcraftWatcherPaintable.Create(const _Context : ISGContext);
begin
inherited Create(_Context);
FConnectionHandler := nil;
FSizeLabel := SGCreateLabel(Screen, '0', 100, 100, 500, 40, True, True);
WriteLn('Create');
end;

destructor TSGWorldOfWarcraftWatcherPaintable.Destroy();
begin
WriteLn('Destroy');
FConnectionHandler := nil;
if (FSizeLabel <> nil) then
	begin
	FSizeLabel.Destroy();
	FSizeLabel := nil;
	end;
inherited;
end;

procedure SGKill(var WorldOfWarcraftWatcherPaintable : TSGWorldOfWarcraftWatcherPaintable); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if WorldOfWarcraftWatcherPaintable <> nil then
	begin
	WorldOfWarcraftWatcherPaintable.Destroy();
	WorldOfWarcraftWatcherPaintable := nil;
	end;
end;

end.
