//DEPRECATED

{$INCLUDE Smooth.inc}

unit SmoothWorldOfWarcraftWatcherPaintable;

interface

uses
	 SmoothBase
	,SmoothContextInterface
	,SmoothContextClasses
	,SmoothWorldOfWarcraftConnectionHandler
	,SmoothScreenClasses
	,SmoothFont
	,SmoothWorldOfWarcraftWatcherLogonConnectionsPaintable
	;

type
	TSWorldOfWarcraftWatcherPaintable = class(TSPaintableObject)
			public
		constructor Create(const _Context : ISContext); override;
		destructor Destroy(); override;
		procedure Paint(); override;
		class function ClassName() : TSString; override;
			protected
		FConnectionHandler : TSWorldOfWarcraftConnectionHandler;
		FWoWLogonConnectionsPaintable : TSWorldOfWarcraftWatcherLogonConnectionsPaintable;
			public
		property ConnectionHandler : TSWorldOfWarcraftConnectionHandler read FConnectionHandler write FConnectionHandler;
		end;

procedure SKill(var WorldOfWarcraftWatcherPaintable : TSWorldOfWarcraftWatcherPaintable); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothStringUtils
	,SmoothFileUtils
	;

class function TSWorldOfWarcraftWatcherPaintable.ClassName() : TSString;
begin
Result := 'World of Warcraft Watcher';
end;

procedure TSWorldOfWarcraftWatcherPaintable.Paint();
begin
if (FWoWLogonConnectionsPaintable = nil) and (FConnectionHandler <> nil) then
	FWoWLogonConnectionsPaintable := TSWorldOfWarcraftWatcherLogonConnectionsPaintable.Create(Context, FConnectionHandler);
if (FWoWLogonConnectionsPaintable <> nil) then
	FWoWLogonConnectionsPaintable.Paint();
end;

constructor TSWorldOfWarcraftWatcherPaintable.Create(const _Context : ISContext);
begin
inherited Create(_Context);
FConnectionHandler := nil;
FWoWLogonConnectionsPaintable := nil;
end;

destructor TSWorldOfWarcraftWatcherPaintable.Destroy();
begin
FConnectionHandler := nil;
SKill(FWoWLogonConnectionsPaintable);
inherited;
end;

procedure SKill(var WorldOfWarcraftWatcherPaintable : TSWorldOfWarcraftWatcherPaintable); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if WorldOfWarcraftWatcherPaintable <> nil then
	begin
	WorldOfWarcraftWatcherPaintable.Destroy();
	WorldOfWarcraftWatcherPaintable := nil;
	end;
end;

end.
