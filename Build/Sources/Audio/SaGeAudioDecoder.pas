{$INCLUDE SaGe.inc}

unit SaGeAudioDecoder;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeClasses
	,SaGeCommon

	,Classes
	;

const
	SGAudioDecoderBufferSize = 4096 * 8;
type
	TSGAudioDecoderInfo = object
			public
		FBitsPerSample : TSGByte; // 8, 16 or 32
		FChannels      : TSGByte; // 1, 2 and etc
		FFrequency     : TSGUInt32;
			public
		procedure Clear();
		end;

	TSGAudioDecoder = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			public
		procedure SetInput(const VStream : TStream); virtual; abstract; overload;
		procedure SetInput(const VFileName : TSGString); virtual; abstract; overload;
		procedure ReadInfo(); virtual; abstract;
		function Read(var VData; const VBufferSize : TSGUInt64) : TSGUInt64; virtual; abstract;
			protected
		FInfo : TSGAudioDecoderInfo;
		FInfoReaded : TSGBool;
			protected
		procedure DetermineInfo(); virtual; abstract;
		function GetSize() : TSGUInt64; virtual; abstract;
		function GetPosition() : TSGUInt64; virtual; abstract;
		procedure SetPosition(const VPosition : TSGUInt64); virtual; abstract;
			public
		property Size : TSGUInt64 read GetSize;
		property Position : TSGUInt64 read GetPosition;
		property Info : TSGAudioDecoderInfo read FInfo;
		end;

implementation

uses
	Crt
	,SaGeAudioDecoderWAV
	;

constructor TSGAudioDecoder.Create();
begin
inherited;
FInfo.Clear();
FInfoReaded := False;
end;

destructor TSGAudioDecoder.Destroy();
begin
FInfoReaded := False;
FInfo.Clear();
inherited;
end;

class function TSGAudioDecoder.ClassName() : TSGString;
begin
Result := 'TSGAudioDecoder';
end;

procedure TSGAudioDecoderInfo.Clear();
begin
FBitsPerSample := 0;
FChannels      := 0;
FFrequency     := 0;
end;

end.
