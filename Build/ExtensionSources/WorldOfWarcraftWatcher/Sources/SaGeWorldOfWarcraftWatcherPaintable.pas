{$INCLUDE SaGe.inc}

unit SaGeWorldOfWarcraftWatcherPaintable;

interface

uses
	 SaGeBase
	,SaGeContextInterface
	,SaGeContextClasses
	,SaGeWorldOfWarcraftConnectionHandler
	,SaGeScreenClasses
	,SaGeFont
	,SaGeWorldOfWarcraftWatcherLogonConnectionsPaintable
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
		FWoWLogonConnectionsPaintable : TSGWorldOfWarcraftWatcherLogonConnectionsPaintable;
			public
		property ConnectionHandler : TSGWorldOfWarcraftConnectionHandler read FConnectionHandler write FConnectionHandler;
		end;

procedure SGKill(var WorldOfWarcraftWatcherPaintable : TSGWorldOfWarcraftWatcherPaintable); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeStringUtils
	,SaGeFileUtils
	;

class function TSGWorldOfWarcraftWatcherPaintable.ClassName() : TSGString;
begin
Result := 'World of Warcraft Watcher';
end;

procedure TSGWorldOfWarcraftWatcherPaintable.Paint();
begin
if (FWoWLogonConnectionsPaintable = nil) and (FConnectionHandler <> nil) then
	FWoWLogonConnectionsPaintable := TSGWorldOfWarcraftWatcherLogonConnectionsPaintable.Create(Context, FConnectionHandler);
if (FWoWLogonConnectionsPaintable <> nil) then
	FWoWLogonConnectionsPaintable.Paint();
end;

constructor TSGWorldOfWarcraftWatcherPaintable.Create(const _Context : ISGContext);
begin
inherited Create(_Context);
FConnectionHandler := nil;
FWoWLogonConnectionsPaintable := nil;
end;

destructor TSGWorldOfWarcraftWatcherPaintable.Destroy();
begin
FConnectionHandler := nil;
SGKill(FWoWLogonConnectionsPaintable);
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
