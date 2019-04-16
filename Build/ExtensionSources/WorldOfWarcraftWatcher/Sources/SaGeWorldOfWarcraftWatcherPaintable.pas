{$INCLUDE SaGe.inc}

//{$DEFINE WOWW_CD} //Console Debug

unit SaGeWorldOfWarcraftWatcherPaintable;

interface

uses
	 SaGeBase
	,SaGeContextInterface
	,SaGeContextClasses
	,SaGeWorldOfWarcraftConnectionHandler
	,SaGeScreenClasses
	,SaGeFont
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
		FFont : TSGFont;
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
{$IFDEF WOWW_CD}Write('P');{$ENDIF} //Paint
if (ConnectionHandler <> nil) then
	begin
	//WriteLn(FConnectionHandler.AllDataSize);
	FSizeLabel.Caption := SGStr(FConnectionHandler.AllDataSize);
	end;
end;

constructor TSGWorldOfWarcraftWatcherPaintable.Create(const _Context : ISGContext);
begin
inherited Create(_Context);
FConnectionHandler := nil;

FFont := TSGFont.Create(SGFontDirectory + DirectorySeparator + 'Times New Roman.sgf');
FFont.SetContext(Context);
FFont.Loading();
FFont.ToTexture();

FSizeLabel := SGCreateLabel(Screen, '0', 100, 100, 500, 40, FFont, True, True);
{$IFDEF WOWW_CD}Write('C');{$ENDIF} //Create
end;

destructor TSGWorldOfWarcraftWatcherPaintable.Destroy();
begin
{$IFDEF WOWW_CD}WriteLn('D');{$ENDIF} //Destroy
FConnectionHandler := nil;
SGKill(FSizeLabel);
SGKill(FFont);
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
