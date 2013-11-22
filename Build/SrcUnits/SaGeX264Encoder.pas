{$INCLUDE Includes\SaGe.inc}

unit SaGeX264Encoder;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeImagesBase
	,Classes;

{$INCLUDE Includes\SaGeX264Lib.inc}

type
	TSGX264Encoder=class(TSGObject)
			public
		constructor Create;
		destructor Destroy;override;
			public
		FInputWidth,FOutputWidth,FInputHeight,FOutputHeight:TSGWord;
		FFPS:TSGByte;
		
		(* x264 *)
		//AVPicture pic_raw;                                            (* used for our "raw" input container *)
		pic_in:x264_picture_t ;
		pic_out:x264_picture_t ;
		params:x264_param_t ;
		 nals:^x264_nal_t;
		 encoder:x264_t;
		 num_nals:x264_int;
		 function Open(FileName:string;datapath:pointer):Boolean;
		end;

implementation

function TSGX264Encoder.Open(FileName:string;datapath:pointer):Boolean;
var
	r,hheader,header_size:x264_int;
	a:x264_picture_t;
begin
WriteLn(x264_picture_alloc(a,r,r,r));
end;

constructor TSGX264Encoder.Create;
begin
inherited;
end;

destructor TSGX264Encoder.Destroy;
begin
inherited;
end;


end.
