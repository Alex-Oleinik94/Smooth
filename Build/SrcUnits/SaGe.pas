
{$IFDEF MSWINDOWS}
	{$R .\..\SaGe.res}
	{$ENDIF}

{$i Includes\SaGe.inc}

unit SaGe;

interface

uses 
	crt
	,gl
	,glu
	,glext
	,Classes
	,SysUtils
	{$IFDEF GLUT}
		,glut 
		{$ENDIF}
	,dos
	{$IFDEF MSWINDOWS}
		,windows
		{$ENDIF}
	{$IFDEF UNIX}
		,unix
		,Dl
		,x
		,xlib
		,xutil
		,glx
		{$ENDIF}
	,SaGeImages
	,SaGeBase
	,DynLibs
	;
const
	{$IFDEF GLUT}
		SGGLUTDLL = 
		{$IFDEF MSWINDOWS}
			'glut32.dll';
		{$ELSE}
			{$IFDEF darwin}
				'/System/Library/Frameworks/GLUT.framework/GLUT';
			{$ELSE}
				{$IFDEF MORPHOS}
					'libglut.so.3';
				{$ELSE}
					'';
					{$ENDIF}
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
	SGFrameButtonsType0f =               $000003;
	SGFrameButtonsTypeCleared = SGFrameButtonsType0f;
	SGFrameButtonsType1f =               $000004;
	SGFrameButtonsType3f =               $000005;
	
	SGObjectTimerConst : real = 0.02;
	
	SGFrameAnimationConst = 200;
	SGFrameFObject = 5;
	SGFrameFNObject = 1;
	
	SGAlignNone =                        $000006;
	SGAlignLeft =                        $000007;
	SGAlignRight =                       $000008;
	SGAlignTop =                         $000009;
	SGAlignBottom =                      $00000A;
	SGAlignClient =                      $00000B;
	
	SGAnchorRight =                      $00000D;
	SGAnchorLeft =                       $00000E;
	SGAnchorTop =                        $00000F;
	SGAnchorBottom =                     $000010;
	
	SG_2D =                              $000011;
	SG_3D =                              $000012;
	
	SG_VERTEX_FOR_CHILDREN =             $000013;
	SG_VERTEX_FOR_PARENT =               $000014;
	
	SG_LEFT =                            $000015;
	SG_TOP =                             $000016;
	SG_HEIGHT =                          $000017;
	SG_WIDTH =                           $000018;
	SG_RIGHT =                           $000019;
	SG_BOTTOM =                          $00001A;
	
	SG_VARIABLE =                        $00001B;
	SG_CONST =                           $00001C;
	SG_OPERATOR =                        $00001D;
	SG_BOOLEAN =                         $00001E;
	SG_REAL =                            $00001F;
	SG_NUMERIC =                         $000020;
	SG_OBJECT =                          $000021;
	SG_NONE =                            $000022;
	SG_NOTHINC = SG_NONE;
	SG_NOTHINK = SG_NONE;
	SG_FUNCTION =                        $000023;
	
	SG_ERROR =                           $000024;
	SG_WARNING =                         $000025;
	SG_NOTE =                            $000026;
	
	SG_3D_ORTHO =                        $000027;
	
	SG_GLSL_3_0 =                          $000028;
	SG_GLSL_ARB =                          $000029;
	
type
	{$IFDEF SGDebuging}
		(*$NOTE type*)
		{$ENDIF}
	
	TSGPoint2f=object
		x,y:longint;
		procedure Import(const x1:longint = 0; const y1:longint = 0);
		procedure Write;
		procedure Vertex;
		end;
	TSGPoint = TSGPoint2f;
	SGPoint = TSGPoint2f;
	SGPoint2f = TSGPoint2f;
	PSGPoint = ^ SGPoint;
	
	TSGPoint3f=object(SGPoint)
			public
		z:longint;
			public
		procedure Import(const x1:LongInt = 0;const x2:LongInt = 0;const x3:LongInt = 0);inline;
		procedure Vertex;
		end;
	SGPoint3f = TSGPoint3f;
	PSGPoint3f = ^ SGPoint3f;
	
	TSGVertexType = type single;
	
	TSGVertex2f=object
		x,y:TSGVertexType;
		procedure Vertex;
		procedure TexCoord;
		procedure SetVariables(const x1:real = 0; const y1:real = 0);
		procedure Import(const x1:real = 0;const y1:real = 0);
		procedure Write;
		procedure WriteLn;
		procedure Round;overload;
		procedure Translate;
		end;
	PTSGVertex2f=^TSGVertex2f;
	TArTSGVertex2f = type packed array of TSGVertex2f;
	PTArTSGVertex2f = ^TArTSGVertex2f;
	SGVertex2f = TSGVertex2f;
	Vertex2f = TSGVertex2f;
	
	TSGComplexNumber = object(TSGVertex2f)
		end;
	
	TSGVertex3f=object(TSGVertex2f)
		z:TSGVertexType;
		procedure Vertex;inline;
		procedure SetVariables(const x1:real = 0; const y1:real = 0; const z1:real = 0);inline;
		procedure Import(const x1:real = 0; const y1:real = 0; const z1:real = 0);inline;
		procedure Normal;
		procedure LightPosition(const Ligth:LongInt = GL_LIGHT0);inline;
		procedure VertexPoint;
		procedure Write;inline;
		procedure WriteLn;inline;
		procedure Vertex(Const P:Pointer);inline;
		procedure Normalize;
		procedure ReadFromTextFile(const Fail:PTextFile);
		procedure ReadLnFromTextFile(const Fail:PTextFile);
		procedure Translate;inline;
		end;
	SGVertex3f=TSGVertex3f;
	SGVertex=SGVertex3f;
	TSGVertex=SGVertex;
	PTSGVertex3f=^TSGVertex3f;
	PSGVertex = PTSGVertex3f;
	PSGVertex3f = PTSGVertex3f;
	TArTSGVertex3f = type packed array of TSGVertex3f;
	ArrayOfTSGVertex3f = TArTSGVertex3f;
	TArTSGVertex = TArTSGVertex3f;
	TArSGVertex = TArTSGVertex3f;
	ArSGVertex = TArTSGVertex3f;
	TSGArTSGVertex = TArTSGVertex3f;
	TSGArSGVertex = TArTSGVertex3f;
	SGArTSGVertex = TArTSGVertex3f;
	SGArSGVertex = TArTSGVertex3f;
	SGArVertex = TArTSGVertex3f;
	ArVertex = TArTSGVertex3f;
	PTArTSGVertex3f = ^TArTSGVertex3f;
	TSGVertexFunction = function (a:SGVertex):SGVertex;
	TSGArLongWord = type packed array of LongWord;
	TSGScreenVertexes=object
		Vertexes:array[0..1] of TSGVertex2f;
		procedure Import(const x1:real = 0;const y1:real = 0;const x2:real = 0;const y2:real = 0);
		procedure Write;
		procedure ProcSumX(r:Real);
		procedure ProcSumY(r:Real);
		property SumX:real write ProcSumX;
		property SumY:real write ProcSumY;
		property X1:TSGVertexType read Vertexes[0].x write Vertexes[0].x;
		property Y1:TSGVertexType read Vertexes[0].y write Vertexes[0].y;
		property X2:TSGVertexType read Vertexes[1].x write Vertexes[1].x;
		property Y2:TSGVertexType read Vertexes[1].y write Vertexes[1].y;
		function VertexInView(const Vertex:TSGVertex2f):Boolean;inline;
		function AbsX:SGReal;inline;
		function AbsY:SGReal;inline;
		end;
	
	TSGVisibleVertex=object(TSGVertex3f)
		Visible:Boolean;
		end;
	SGVisibleVertex = TSGVisibleVertex;
	PSGVisibleVertex = ^SGVisibleVertex;
	TArSGVisibleVertex = type packed array of TSGVisibleVertex;
	TArTSGVisibleVertex = TArSGVisibleVertex;
	TSGVisibleVertexFunction = function (a:TSGVisibleVertex;CONST b:Pointer):TSGVisibleVertex;
	TSGPointerProcedure = procedure (a:Pointer);
	TSGProcedure = procedure;
	
	PTSGColor3f=^TSGColor3f;

{ TSGColor3f }

TSGColor3f=object
		r,g,b:single;
		procedure Color;inline;
		procedure SetColor;inline;
		procedure Import(const r1:single = 0; const g1:single = 0; const b1:single = 0);
		procedure ReadFromStream(const Stream:TStream);inline;
		procedure WriteToStream(const Stream:TStream);inline;
		end;
	PTArTSGColor3f = ^TArTSGColor3f;
	TArTSGColor3f = array of TSGColor3f;
	
	PTSGColor4f = ^ TSGColor4f;
	TSGColor4f=object(TSGColor3f)
		a:single;
		procedure SetColor;
		procedure Color;
		procedure SetVariables(const r1:real = 0; const g1:real = 0; const b1:real = 0; const a1:real = 1);
		function AddAlpha(const NewAlpha:real = 1):TSGColor4f;
		function WithAlpha(const NewAlpha:real = 1):TSGColor4f;
		procedure Import(const r1:real = 0; const g1:real = 0; const b1:real = 0;const a1:real = 1);
		procedure ReadFromStream(const Stream:TStream);inline;
		procedure WriteToStream(const Stream:TStream);inline;
		end;
	SGColor4f = TSGColor4f;
	SGColor = TSGColor4f;
	PTArTSGColor4f = ^TArTSGColor4f;
	TArTSGColor4f =type packed array of TSGColor4f;
	TArSGColor4f = TArTSGColor4f;
	TArSGColor = TArTSGColor4f;
	TArColor = TArTSGColor4f;
	ArColor = TArTSGColor4f;
	ArSGColor = TArTSGColor4f;
	ArSGColor4f = TArSGColor4f;
	
	PTSGPlane = ^ TSGPlane;
	TSGPlane=object
		a,b,c,d:real;
		procedure Import(const a1:real = 0; const b1:real = 0; const c1:real = 0; const d1:real = 0);
		procedure Write;
		end;
	PSGPlane = PTSGPlane;
	SGPlane = TSGPlane;
	
	TSGThreadProcedure = SaGeBase.TSGThreadProcedure;
	TSGThread = SaGeBase.TSGThread;
	SGThread = SaGeBase.TSGThread;

	TSGBezierCurve =object
		StartArray : TArTSGVertex3f;
		EndArray : TArTSGVertex3f;
		Detalization:dword;
		procedure Clear;
		procedure InitVertex(const k:TSGVertex3f);
		procedure Calculate;
		procedure Init(const p:Pointer = nil);
		procedure SetArray(const a:TArTSGVertex3f);
		function SetDetalization(const l:dword):boolean;
		function GetDetalization:longword;
		procedure CalculateRandom(Detalization1,KolVertex,Diapazon:longint);
		end;
	SGBezierCurve = TSGBezierCurve;
	
	TSGArFor0To255OfBoolean = type packed array [0..255] of boolean;
	TSGArFor0To2OfBoolean = type packed array [0..2] of boolean;
	TSGArFor0To3OfSGPoint = type packed array [0..3]of SGPoint;
	TSGArFor1To4OfSGVertex = type packed array [1..4] of SGVertex;
	PTSGArFor1To4OfSGVertex = ^TSGArFor1To4OfSGVertex;
	PSGArFor1To4OfSGVertex = PTSGArFor1To4OfSGVertex;
	TSGArTObject = type packed array of TObject;
	
	TSGGLMatrixArray = array [0..3,0..3] of GLFloat;
	TSGGLMatrix = object
			public
		constructor Create;
			public
		FMatrix:TSGGLMatrixArray;
		procedure Clear;
		procedure Add(const x:Int = 0; const y:Int = 0;const Param:GLFloat = 0);
		procedure LoadFromPlane(Plane:TSGPlane);
		procedure Init;
		procedure Load;
		procedure Write;
		end;

	SGGLMatrix = TSGGLMatrix;
	TSGMatrix = TSGGLMatrix;
	
	TSGSkin=class;
	TSGSkin=class(TObject)
		
		end;
	
	TSGShodowVertexProcedure=procedure (Param1,Param2,Param3:GLFloat);cdecl;
var
	{$IFDEF SGDebuging}
		(*$NOTE var*)
		{$ENDIF}
	
	SGCLPaintProcedure : SGProcedure = nil;
	SGCLForReSizeScreenProcedure : SGProcedure = nil;
	SGCLLoadProcedure : SGProcedure = nil;
	
	SGContextResized:Boolean = False;
	
	Nan:real;
	Inf:real;
const
	NilVertex:SGVertex = (x:0;y:0;z:0);
var
	NilColor:SGColor = (r:0;g:0;b:0;a:0);
	
	SGIsSuppored_GL_version_1_2:Boolean = False;
	SGIsSuppored_GL_version_1_3:Boolean = False;
	SGIsSuppored_GL_ARB_imaging:Boolean = False;
	SGIsSuppored_GL_ARB_multitexture:Boolean = False;
	SGIsSuppored_GL_ARB_transpose_matrix:Boolean = False;
	SGIsSuppored_GL_ARB_multisample:Boolean = False;
	SGIsSuppored_GL_ARB_texture_env_add:Boolean = False;
	SGIsSuppored_WGL_ARB_extensions_string:Boolean = False;
	SGIsSuppored_WGL_ARB_buffer_region:Boolean = False;
	SGIsSuppored_GL_ARB_texture_cube_map:Boolean = False;
	SGIsSuppored_GL_ARB_depth_texture:Boolean = False;
	SGIsSuppored_GL_ARB_point_parameters:Boolean = False;
	SGIsSuppored_GL_ARB_shadow:Boolean = False;
	SGIsSuppored_GL_ARB_shadow_ambient:Boolean = False;
	SGIsSuppored_GL_ARB_texture_border_clamp:Boolean = False;
	SGIsSuppored_GL_ARB_texture_compression:Boolean = False;
	SGIsSuppored_GL_ARB_texture_env_combine:Boolean = False;
	SGIsSuppored_GL_ARB_texture_env_crossbar:Boolean = False;
	SGIsSuppored_GL_ARB_texture_env_dot3:Boolean = False;
	SGIsSuppored_GL_ARB_texture_mirrored_repeat:Boolean = False;
	SGIsSuppored_GL_ARB_vertex_blend:Boolean = False;
	SGIsSuppored_GL_ARB_vertex_program:Boolean = False;
	SGIsSuppored_GL_ARB_window_pos:Boolean = False;
	SGIsSuppored_GL_EXT_422_pixels:Boolean = False;
	SGIsSuppored_GL_EXT_bgra:Boolean = False;
	SGIsSuppored_GL_EXT_blend_color:Boolean = False;
	SGIsSuppored_GL_EXT_blend_func_separate:Boolean = False;
	SGIsSuppored_GL_EXT_blend_logic_op:Boolean = False;
	SGIsSuppored_GL_EXT_blend_minmax:Boolean = False;
	SGIsSuppored_GL_EXT_blend_subtract:Boolean = False;
	SGIsSuppored_GL_EXT_clip_volume_hint:Boolean = False;
	SGIsSuppored_GL_EXT_color_subtable:Boolean = False;
	SGIsSuppored_GL_EXT_compiled_vertex_array:Boolean = False;
	SGIsSuppored_GL_EXT_convolution:Boolean = False;
	SGIsSuppored_GL_EXT_fog_coord:Boolean = False;
	SGIsSuppored_GL_EXT_histogram:Boolean = False;
	SGIsSuppored_GL_EXT_multi_draw_arrays:Boolean = False;
	SGIsSuppored_GL_EXT_packed_depth_stencil:Boolean = False;
	SGIsSuppored_GL_EXT_packed_pixels:Boolean = False;
	SGIsSuppored_GL_EXT_paletted_texture:Boolean = False;
	SGIsSuppored_GL_EXT_point_parameters:Boolean = False;
	SGIsSuppored_GL_EXT_polygon_offset:Boolean = False;
	SGIsSuppored_GL_EXT_secondary_color:Boolean = False;
	SGIsSuppored_GL_EXT_separate_specular_color:Boolean = False;
	SGIsSuppored_GL_EXT_shadow_funcs:Boolean = False;
	SGIsSuppored_GL_EXT_shared_texture_palette:Boolean = False;
	SGIsSuppored_GL_EXT_stencil_two_side:Boolean = False;
	SGIsSuppored_GL_EXT_stencil_wrap:Boolean = False;
	SGIsSuppored_GL_EXT_subtexture:Boolean = False;
	SGIsSuppored_GL_EXT_texture3D:Boolean = False;
	SGIsSuppored_GL_EXT_texture_compression_s3tc:Boolean = False;
	SGIsSuppored_GL_EXT_texture_env_add:Boolean = False;
	SGIsSuppored_GL_EXT_texture_env_combine:Boolean = False;
	SGIsSuppored_GL_EXT_texture_env_dot3:Boolean = False;
	SGIsSuppored_GL_EXT_texture_filter_anisotropic:Boolean = False;
	SGIsSuppored_GL_EXT_texture_lod_bias:Boolean = False;
	SGIsSuppored_GL_EXT_texture_object:Boolean = False;
	SGIsSuppored_GL_EXT_vertex_array:Boolean = False;
	SGIsSuppored_GL_EXT_vertex_shader:Boolean = False;
	SGIsSuppored_GL_EXT_vertex_weighting:Boolean = False;
	SGIsSuppored_GL_HP_occlusion_test:Boolean = False;
	SGIsSuppored_GL_NV_blend_square:Boolean = False;
	SGIsSuppored_GL_NV_copy_depth_to_color:Boolean = False;
	SGIsSuppored_GL_NV_depth_clamp:Boolean = False;
	SGIsSuppored_GL_NV_evaluators:Boolean = False;
	SGIsSuppored_GL_NV_fence:Boolean = False;
	SGIsSuppored_GL_NV_fog_distance:Boolean = False;
	SGIsSuppored_GL_NV_light_max_exponent:Boolean = False;
	SGIsSuppored_GL_NV_multisample_filter_hint:Boolean = False;
	SGIsSuppored_GL_NV_occlusion_query:Boolean = False;
	SGIsSuppored_GL_NV_packed_depth_stencil:Boolean = False;
	SGIsSuppored_GL_NV_point_sprite:Boolean = False;
	SGIsSuppored_GL_NV_register_combiners:Boolean = False;
	SGIsSuppored_GL_NV_register_combiners2:Boolean = False;
	SGIsSuppored_GL_NV_texgen_emboss:Boolean = False;
	SGIsSuppored_GL_NV_texgen_reflection:Boolean = False;
	SGIsSuppored_GL_NV_texture_compression_vtc:Boolean = False;
	SGIsSuppored_GL_NV_texture_env_combine4:Boolean = False;
	SGIsSuppored_GL_NV_texture_rectangle:Boolean = False;
	SGIsSuppored_GL_NV_texture_shader:Boolean = False;
	SGIsSuppored_GL_NV_texture_shader2:Boolean = False;
	SGIsSuppored_GL_NV_texture_shader3:Boolean = False;
	SGIsSuppored_GL_NV_vertex_array_range:Boolean = False;
	SGIsSuppored_GL_NV_vertex_array_range2:Boolean = False;
	SGIsSuppored_GL_NV_vertex_program:Boolean = False;
	SGIsSuppored_GL_NV_vertex_program1_1:Boolean = False;
	SGIsSuppored_GL_ATI_element_array:Boolean = False;
	SGIsSuppored_GL_ATI_envmap_bumpmap:Boolean = False;
	SGIsSuppored_GL_ATI_fragment_shader:Boolean = False;
	SGIsSuppored_GL_ATI_pn_triangles:Boolean = False;
	SGIsSuppored_GL_ATI_texture_mirror_once:Boolean = False;
	SGIsSuppored_GL_ATI_vertex_array_object:Boolean = False;
	SGIsSuppored_GL_ATI_vertex_streams:Boolean = False;
	SGIsSuppored_WGL_I3D_image_buffer:Boolean = False;
	SGIsSuppored_WGL_I3D_swap_frame_lock:Boolean = False;
	SGIsSuppored_WGL_I3D_swap_frame_usage:Boolean = False;
	SGIsSuppored_GL_3DFX_texture_compression_FXT1:Boolean = False;
	SGIsSuppored_GL_IBM_cull_vertex:Boolean = False;
	SGIsSuppored_GL_IBM_multimode_draw_arrays:Boolean = False;
	SGIsSuppored_GL_IBM_raster_pos_clip:Boolean = False;
	SGIsSuppored_GL_IBM_texture_mirrored_repeat:Boolean = False;
	SGIsSuppored_GL_IBM_vertex_array_lists:Boolean = False;
	SGIsSuppored_GL_MESA_resize_buffers:Boolean = False;
	SGIsSuppored_GL_MESA_window_pos:Boolean = False;
	SGIsSuppored_GL_OML_interlace:Boolean = False;
	SGIsSuppored_GL_OML_resample:Boolean = False;
	SGIsSuppored_GL_OML_subsample:Boolean = False;
	SGIsSuppored_GL_SGIS_generate_mipmap:Boolean = False;
	SGIsSuppored_GL_SGIS_multisample:Boolean = False;
	SGIsSuppored_GL_SGIS_pixel_texture:Boolean = False;
	SGIsSuppored_GL_SGIS_texture_border_clamp:Boolean = False;
	SGIsSuppored_GL_SGIS_texture_color_mask:Boolean = False;
	SGIsSuppored_GL_SGIS_texture_edge_clamp:Boolean = False;
	SGIsSuppored_GL_SGIS_texture_lod:Boolean = False;
	SGIsSuppored_GL_SGIS_depth_texture:Boolean = False;
	SGIsSuppored_GL_SGIX_fog_offset:Boolean = False;
	SGIsSuppored_GL_SGIX_interlace:Boolean = False;
	SGIsSuppored_GL_SGIX_shadow_ambient:Boolean = False;
	SGIsSuppored_GL_SGI_color_matrix:Boolean = False;
	SGIsSuppored_GL_SGI_color_table:Boolean = False;
	SGIsSuppored_GL_SGI_texture_color_table:Boolean = False;
	SGIsSuppored_GL_SUN_vertex:Boolean = False;
	SGIsSuppored_GL_ARB_fragment_program:Boolean = False;
	SGIsSuppored_GL_ATI_text_fragment_shader:Boolean = False;
	SGIsSuppored_GL_ARB_vertex_buffer_object:Boolean = False;
	SGIsSuppored_GL_APPLE_client_storage:Boolean = False;
	SGIsSuppored_GL_APPLE_element_array:Boolean = False;
	SGIsSuppored_GL_APPLE_fence:Boolean = False;
	SGIsSuppored_GL_APPLE_vertex_array_object:Boolean = False;
	SGIsSuppored_GL_APPLE_vertex_array_range:Boolean = False;
	SGIsSuppored_WGL_ARB_pixel_format:Boolean = False;
	SGIsSuppored_WGL_ARB_make_current_read:Boolean = False;
	SGIsSuppored_WGL_ARB_pbuffer:Boolean = False;
	SGIsSuppored_WGL_EXT_swap_control:Boolean = False;
	SGIsSuppored_WGL_ARB_render_texture:Boolean = False;
	SGIsSuppored_WGL_EXT_extensions_string:Boolean = False;
	SGIsSuppored_WGL_EXT_make_current_read:Boolean = False;
	SGIsSuppored_WGL_EXT_pbuffer:Boolean = False;
	SGIsSuppored_WGL_EXT_pixel_format:Boolean = False;
	SGIsSuppored_WGL_I3D_digital_video_control:Boolean = False;
	SGIsSuppored_WGL_I3D_gamma:Boolean = False;
	SGIsSuppored_WGL_I3D_genlock:Boolean = False;
	SGIsSuppored_GL_ARB_matrix_palette:Boolean = False;
	SGIsSuppored_GL_NV_element_array:Boolean = False;
	SGIsSuppored_GL_NV_float_buffer:Boolean = False;
	SGIsSuppored_GL_NV_fragment_program:Boolean = False;
	SGIsSuppored_GL_NV_primitive_restart:Boolean = False;
	SGIsSuppored_GL_NV_vertex_program2:Boolean = False;
	SGIsSuppored_WGL_NV_render_texture_rectangle:Boolean = False;
	SGIsSuppored_GL_NV_pixel_data_range:Boolean = False;
	SGIsSuppored_GL_EXT_texture_rectangle:Boolean = False;
	SGIsSuppored_GL_S3_s3tc:Boolean = False;
	SGIsSuppored_GL_ATI_draw_buffers:Boolean = False;
	SGIsSuppored_WGL_ATI_pixel_format_float:Boolean = False;
	SGIsSuppored_GL_ATI_texture_env_combine3:Boolean = False;
	SGIsSuppored_GL_ATI_texture_float:Boolean = False;
	SGIsSuppored_GL_NV_texture_expand_normal:Boolean = False;
	SGIsSuppored_GL_NV_half_float:Boolean = False;
	SGIsSuppored_GL_ATI_map_object_buffer:Boolean = False;
	SGIsSuppored_GL_ATI_separate_stencil:Boolean = False;
	SGIsSuppored_GL_ATI_vertex_attrib_array_object:Boolean = False;
	SGIsSuppored_GL_ARB_occlusion_query:Boolean = False;
	SGIsSuppored_GL_ARB_shader_objects:Boolean = False;
	SGIsSuppored_GL_ARB_vertex_shader:Boolean = False;
	SGIsSuppored_GL_ARB_fragment_shader:Boolean = False;
	SGIsSuppored_GL_ARB_shading_language_100:Boolean = False;
	SGIsSuppored_GL_ARB_texture_non_power_of_two:Boolean = False;
	SGIsSuppored_GL_ARB_point_sprite:Boolean = False;
	SGIsSuppored_GL_EXT_depth_bounds_test:Boolean = False;
	SGIsSuppored_GL_EXT_texture_mirror_clamp:Boolean = False;
	SGIsSuppored_GL_EXT_blend_equation_separate:Boolean = False;
	SGIsSuppored_GL_MESA_pack_invert:Boolean = False;
	SGIsSuppored_GL_MESA_ycbcr_texture:Boolean = False;
	SGIsSuppored_GL_ARB_fragment_program_shadow:Boolean = False;
	SGIsSuppored_GL_NV_fragment_program_option:Boolean = False;
	SGIsSuppored_GL_EXT_pixel_buffer_object:Boolean = False;
	SGIsSuppored_GL_NV_fragment_program2:Boolean = False;
	SGIsSuppored_GL_NV_vertex_program2_option:Boolean = False;
	SGIsSuppored_GL_NV_vertex_program3:Boolean = False;
	SGIsSuppored_GL_ARB_draw_buffers:Boolean = False;
	SGIsSuppored_GL_ARB_texture_rectangle:Boolean = False;
	SGIsSuppored_GL_ARB_color_buffer_float:Boolean = False;
	SGIsSuppored_GL_ARB_half_float_pixel:Boolean = False;
	SGIsSuppored_GL_ARB_texture_float:Boolean = False;
	SGIsSuppored_GL_EXT_texture_compression_dxt1:Boolean = False;
	SGIsSuppored_GL_ARB_pixel_buffer_object:Boolean = False;
	SGIsSuppored_GL_EXT_framebuffer_object:Boolean = False;
	SGIsSuppored_GL_ARB_framebuffer_object:Boolean = False;
	SGIsSuppored_GL_ARB_map_buffer_range:Boolean = False;
	SGIsSuppored_GL_ARB_vertex_array_object:Boolean = False;
	SGIsSuppored_GL_ARB_copy_buffer:Boolean = False;
	SGIsSuppored_GL_ARB_uniform_buffer_object:Boolean = False;
	SGIsSuppored_GL_ARB_draw_elements_base_vertex:Boolean = False;
	SGIsSuppored_GL_ARB_provoking_vertex:Boolean = False;
	SGIsSuppored_GL_ARB_sync:Boolean = False;
	SGIsSuppored_GL_ARB_texture_multisample:Boolean = False;
	SGIsSuppored_GL_ARB_blend_func_extended:Boolean = False;
	SGIsSuppored_GL_ARB_sampler_objects:Boolean = False;
	SGIsSuppored_GL_ARB_timer_query:Boolean = False;
	SGIsSuppored_GL_ARB_vertex_type_2_10_10_10_rev:Boolean = False;
	SGIsSuppored_GL_ARB_gpu_shader_fp64:Boolean = False;
	SGIsSuppored_GL_ARB_shader_subroutine:Boolean = False;
	SGIsSuppored_GL_ARB_tessellation_shader:Boolean = False;
	SGIsSuppored_GL_ARB_transform_feedback2:Boolean = False;
	SGIsSuppored_GL_ARB_transform_feedback3:Boolean = False;
	SGIsSuppored_GL_version_1_4:Boolean = False;
	SGIsSuppored_GL_version_1_5:Boolean = False;
	SGIsSuppored_GL_version_2_0:Boolean = False;
	SGIsSuppored_GL_VERSION_2_1:Boolean = False;
	SGIsSuppored_GL_VERSION_3_0:Boolean = False;
	SGIsSuppored_GL_VERSION_3_1:Boolean = False;
	SGIsSuppored_GL_VERSION_3_2:Boolean = False;
	SGIsSuppored_GL_VERSION_3_3:Boolean = False;
	SGIsSuppored_GL_VERSION_4_0:Boolean = False;

var
	SGIsOpenGLInit:Boolean = False;

operator + (const a,b:TSGComplexNumber):TSGComplexNumber;overload;inline;
operator * (const a,b:TSGComplexNumber):TSGComplexNumber;inline;overload;
operator - (const a,b:TSGComplexNumber):TSGComplexNumber;overload;inline;
operator / (const a,b:TSGComplexNumber):TSGComplexNumber;inline;overload;
operator ** (const a:TSGComplexNumber;const b:LongInt):TSGComplexNumber;inline;overload;
operator = (const a,b:TSGComplexNumber):Boolean;overload;inline;

operator * (const a:SGColor;const b:real):SGColor;inline;overload;
operator * (const b:extended;const a:SGColor):SGColor;inline;overload;
operator * (const a:SGColor;const b:byte):SGColor;inline;overload;
operator * (const a:SGColor;const b:longint):SGColor;inline;overload;
operator * (const a:SGColor;const b:int64):SGColor;inline;overload;
operator * (const b:int64;const a:SGColor):SGColor;inline;overload;
operator * (const b:longint;const a:SGColor):SGColor;inline;overload;
operator * (const b:byte;const a:SGColor):SGColor;inline;overload;
operator + (const a,b:SGColor):SGColor;inline;overload;
operator - (const a,b:SGColor):SGColor;inline;overload;
operator / (const a:SGColor;const b:real):SGColor;inline;overload;

operator + (const a,b:SGVertex):SGVertex;inline;overload;
operator - (const a,b:SGVertex):SGVertex;inline;overload;
operator / (const a:SGVertex;const b:real):SGVertex;inline;overload;
operator * (const a:SGVertex;const b:real):SGVertex;inline;overload;
operator * (const b:real;const a:SGVertex):SGVertex;inline;overload;
operator + (const a:SGVertex;const b:SGVertex2f):SGVertex;inline;overload;
operator + (const a:SGVertex2f;const b:SGVertex):SGVertex;inline;overload;
operator + (const a,b:SGVertex2f):SGVertex2f;overload;inline;overload;
operator + (const a,b:SGVertex2f):SGVertex;inline;overload;
operator - (const a:TSGVertex):TSGVertex;overload;inline;
operator * (const a:SGVertex2f;const b:real):SGVertex2f;overload;inline;
operator / (const a:SGVertex2f;const b:real):SGVertex2f;overload;inline;
operator * (const b:real;const a:SGVertex2f):SGVertex2f;overload;inline;
operator / (const b:real;const a:SGVertex2f):SGVertex2f;overload;inline;
operator = (const a,b:TSGVertex3f):Boolean;overload;inline;
operator - (const a,b:TSGVertex2f):TSGVertex2f;overload;inline;
operator - (const a:TSGVertex2f):TSGVertex2f;overload;inline;
operator * (const a,b:TSGVertex2f):TSGVertex2f;overload;inline;
operator + (const a:SGVertex2f;const b:TSGVertexType):SGVertex2f;overload;inline;
operator - (const a:SGVertex2f;const b:TSGVertexType):SGVertex2f;overload;inline;

operator ** (const a:Real;const b:LongInt):Real;inline;overload;
operator ** (const a:single;const b:LongInt):single;overload;inline;
operator ** (const a:LongInt;const b:LongInt):LongInt;overload;inline;

operator * (const a:TSGScreenVertexes;const b:real):TSGScreenVertexes;inline;overload;

operator + (const a,b:SGPoint):SGPoint;inline;overload;
operator - (const a,b:SGPoint):SGPoint;inline;overload;
operator / (const a:SGPoint;const b:Int64):SGPoint;overload;inline;
operator div (const a:SGPoint;const b:Int64):SGPoint;overload;inline;
operator = (const a,b:TSGPoint2f):Boolean;overload;inline;
operator * (const a:TSGPoint2f;const b:real):TSGVertex2f;overload;inline;
operator + (const a:TSGPoint2f;const b:integer):TSGPoint2f;overload;inline;

operator + (const a:TSGVertex2f;const b:TSGPoint2f):TSGVertex2f;overload;inline;
operator := (const a:TSGPoint2f):TSGVertex2f;overload;inline;

procedure SGCrearOpenGL;
function SGGetVertexInAttitude(const t1,t2:TSGVertex3f; const r:real = 0.5):TSGVertex3f;
function SGTSGVertex3fImport(const x:real = 0;const y:real = 0;const z:real = 0):TSGVertex3f;
procedure SGInitOpenGL;
function SGVertexImport(const x:real = 0;const y:real = 0;const z:real = 0):TSGVertex3f;
function SGPointImport(const NewX:Real = 0; const NewY:Real = 0 ):SGPoint;
function SGPointImport(const NewX:LongInt = 0; const NewY:LongInt = 0 ):SGPoint;	
procedure SGQuad(const Vertex1:SGVertex;const Vertex2:SGVertex;const Vertex3:SGVertex;const Vertex4:SGVertex);
procedure SGLoadFrameIdentity;
function SGVertexOnQuad(const Vertex:SGVertex; const QuadVertex1:SGVertex;const QuadVertex2:SGVertex;const QuadVertex3:SGVertex;const QuadVertex4:SGVertex):boolean;
function SGAbsTwoVertex(const Vertex1:SGVertex;const Vertex2:SGVertex):real;inline;
function SGTreugPlosh(const a1,a2,a3:SGVertex):real;
function SGVertexOnQuad(const Vertex:SGVertex; const QuadVertex1:SGVertex;const QuadVertex3:SGVertex):boolean;
procedure SGQuad(ArVertex:TSGArFor1To4OfSGVertex);
function SGGetMatrix2x2(a1,a2,a3,a4:real):real;
function SGGetMatrix3x3(a1,a2,a3,a4,a5,a6,a7,a8,a9:real):real;
function SGGetVertexOnIntersectionOfThreePlane(p1,p2,p3:SGPlane):SGVertex;
function SGGetVertexWhichNormalFromThreeVertex(const p1,p2,p3:SGVertex):SGVertex;
function SGGetPlaneFromThreeVertex(const a1,a2,a3:SGVertex):SGPlane;
function SGGetPlaneFromNineReals(const x1,y1,z1,x2,y2,z2,x0,y0,z0:real):SGPlane;
function SGGetVertexOnIntersectionOfTwoLinesFromFourVertex(const q1,q2,w1,w2:SGVertex):SGVertex;
procedure SGRoundQuad(const Vertex1,Vertex3:SGVertex; const Radius:real; const Interval:LongInt;const QuadColor:SGColor; const LinesColor:SGColor4f; const WithLines:boolean = False;const WithQuad:boolean = True);
function SGColorImport(const r1:real = 0;const g1:real = 0;const b1:real = 0;const a1:real = 1):SGColor;
function SGPoint2fToVertex2f(const Point:SGPoint):SGVertex2f;inline;
function SGPoint2fToVertex3f(const Point:SGPoint):SGVertex3f;inline;
function SGGetArrayOfRoundQuad(const Vertex1,Vertex3:SGVertex; const Radius:real; const Interval:LongInt):SGArVertex;
procedure SGRoundWindowQuad(const Vertex11,Vertex13:SGVertex;const Vertex21,Vertex23:SGVertex; 
	const Radius1:real;const Radius2:real; const Interval:LongInt;const QuadColor1:SGColor;const QuadColor2:SGColor;
	const WithLines:boolean; const LinesColor1:SGColor4f; const LinesColor2:SGColor4f);
procedure SGConstructRoundQuad(const ArVertex:SGArSGVertex;const Interval:LongInt;const QuadColor:SGColor; const LinesColor:SGColor4f; const WithLines:boolean = False;const WithQuad:boolean = True);
procedure SGSomeQuad(a,b,c,d:SGVertex;vl,np:SGPoint);
procedure SGWndSomeQuad(a,c:SGVertex);
procedure SGWriteTime;
function SGPCharAddSimbol(var VPChar:PChar; const VChar:Char):PChar;
function SGPCharsEqual(const PChar1,PChar2:PChar):Boolean;
function SGPCharHigh(const VPChar:PChar):LongInt;
function SGPCharLength(const VPChar:PChar):LongWord;
function SGPCharDecFromEnd(var VPChar:PChar; const Number:LongWord = 1):PChar;
function SGPCharUpCase(const VPChar:PChar):PChar;
function SGPCharRead:PChar;
function SGCharRead:Char;
function SGPCharDeleteSpaces(const VPChar:PCHAR):PChar;
function SGPCharTotal(const VPChar1,VPChar2:PChar):PChar;
function SGAbsTwoVertex2f(const Vertex1,Vertex2:SGVertex2f):real;inline;
function SGRealExists(const r:real):Boolean;
function SGRealsEqual(const r1,r2:real):Boolean;
procedure SGQuickRePlaceReals(var Real1,Real2:Real);
procedure SGQuickRePlaceLongInt(var LongInt1,LongInt2:LongInt);
procedure SGQuickRePlaceVertexType(var LongInt1,LongInt2:TSGVertexType); 
function SGVertex2fToPoint2f(const Vertex:TSGVertex2f):TSGPoint2f;
function SGVertex2fImport(const x:real = 0;const y:real = 0):TSGVertex2f;inline;
function SGComplexNumberImport(const x:real = 0;const y:real = 0):TSGComplexNumber;inline;
function SGRandomMinus:Int;
procedure SGSetCLProcedure(const p:Pointer = nil);
procedure SCSetCLScreenBounds(const p:Pointer = nil);
function SGReadLnString:String;
function SGReadLnByte:Byte;
procedure SGSetCLLoadProcedure(p:Pointer);
function SGGetFreeFileName(const Name:string):string;inline;
function SGGetFileNameWithoutExpansion(const FileName:string):string;inline;
function SGFloatToString(const R:Extended;const Zeros:LongInt = 0):string;inline;
function SGGetQuantitySimbolsInNumber(l:LongInt):LongInt;inline;
function SGPCharGetPart(const VPChar:PChar;const Position1,Position2:LongInt):PChar;
function SGPoint2fImport(const x1:int64 = 0; const y1:int64 = 0):TSGPoint2f;overload;inline;
function SGPoint2fImport(const x1:extended = 0; const y1:extended = 0):TSGPoint2f;overload;inline;
function SGGetColor4fFromLongWord(const LongWordColor:LongWord;const WithAlpha:Boolean = False):SGColor4f;inline;
procedure SGLookAt(Mesh,Camera,CameraTop:SGVertex3f);
function SGX(const v:Single):TSGVertex3f;inline;
function SGY(const v:Single):TSGVertex3f;inline;
function SGZ(const v:Single):TSGVertex3f;inline;
procedure SGColor3f(const a,b,c:Single);inline;
function Abs(const a:TSGVertex2f):extended;inline;overload;
function Random(const lx,ly:LongWord):TSGPoint2f;overload;inline;
function SGGetPointsCirclePoints(const FPoints:TArTSGVertex2f):TSGArLongWord;

implementation
{$IFDEF SGDebuging}
	(*$NOTE implementation*)
	{$ENDIF}

operator * (const b:real;const a:SGVertex2f):SGVertex2f;overload;inline;
begin
Result.Import(a.x*b,a.y*b);
end;

operator / (const b:real;const a:SGVertex2f):SGVertex2f;overload;inline;
begin
Result.Import(b/a.x,b/a.y);
end;

operator * (const b:extended;const a:SGColor):SGColor;inline;overload;
begin
Result.Import(a.r*b,a.g*b,a.b*b,a.a*b);
end;

operator * (const a:SGColor;const b:byte):SGColor;inline;overload;
begin
Result.Import(a.r*b,a.g*b,a.b*b,a.a*b);
end;

operator * (const a:SGColor;const b:longint):SGColor;inline;overload;
begin
Result.Import(a.r*b,a.g*b,a.b*b,a.a*b);
end;

operator * (const a:SGColor;const b:int64):SGColor;inline;overload;
begin
Result.Import(a.r*b,a.g*b,a.b*b,a.a*b);
end;

operator * (const b:byte;const a:SGColor):SGColor;inline;overload;
begin
Result.Import(a.r*b,a.g*b,a.b*b,a.a*b);
end;

operator * (const b:longint;const a:SGColor):SGColor;inline;overload;
begin
Result.Import(a.r*b,a.g*b,a.b*b,a.a*b);
end;

operator * (const b:int64;const a:SGColor):SGColor;inline;overload;
begin
Result.Import(a.r*b,a.g*b,a.b*b,a.a*b);
end;

procedure TSGPoint3f.Vertex;
begin
glVertex3f(x,y,z);
end;
procedure TSGPoint3f.Import(const x1:LongInt = 0;const x2:LongInt = 0;const x3:LongInt = 0);inline;
begin
x:=x1;
y:=x2;
z:=x3;
end;

function SGGetPointsCirclePoints(const FPoints:TArTSGVertex2f):TSGArLongWord;

function GetNext(const p1,p2:LongWord):LongWord;
var
	a2,// квадрат альфа
	b2,//квадрат бетта
	TemCos,//Косиеус сейчас
	MinCos,//Охуенный косинус, который нада найти
	a:single;
	i:LongWord;

begin
MinCos:=1;
Result:=Length(FPoints);
a2:=(sqr(FPoints[p1].x-FPoints[p2].x)+sqr(FPoints[p1].y-FPoints[p2].y));
a:=sqrt(a2);
for i:=0 to High(FPoints) do
	if (i<>p1) and (i<>p2) then
		begin
		b2:=(sqr(FPoints[i].x-FPoints[p2].x)+sqr(FPoints[i].y-FPoints[p2].y));
		TemCos:=((sqr(FPoints[i].x-FPoints[p1].x)+sqr(FPoints[i].y-FPoints[p1].y))-a2-b2)/(-2*a*sqrt(b2));
		if (TemCos<MinCos) then
			begin
			Result:=i;
			MinCos:=TemCos;
			end;
		end;
if Result=Length(FPoints) then
	raise  Exception.Create('Ebat ti loh!!!');
end;
vAR
	I,ii:LongWord;
	s:string;
begin
SetLength(Result,2);
Result[0]:=0;
Result[1]:=1;
repeat
ii:=GetNext(Result[High(Result)-1],Result[High(Result)]);
SetLength(Result,Length(Result)+1);
Result[High(Result)]:=ii;
ii:=0;
for i:=1 to High(Result)-2 do
	begin
	if (Result[i]=Result[High(Result)])  and (Result[i-1]=Result[High(Result)-1])then
		begin
		ii:=1;
		break;
		end;
	end;
until (ii=1);
for ii:=i+1 to High(Result) do
	begin
	Result[ii-i-1]:=Result[ii];
	end;
SetLength(Result,Length(Result)-i-1);
end;


operator + (const a:SGVertex2f;const b:TSGVertexType):SGVertex2f;overload;inline;
begin
Result.Import(a.x+b,a.y+b);
end;

operator - (const a:SGVertex2f;const b:TSGVertexType):SGVertex2f;overload;inline;
begin
Result.Import(a.x-b,a.y-b);
end;

function Random(const lx,ly:LongWord):TSGPoint2f;overload;inline;
begin
Result.Import(Random(lx),Random(ly));
end;

function Abs(const a:TSGVertex2f):extended;inline;overload;
begin
Result:=//Abs();
Abs(a.x)+Abs(a.y);
end;

procedure SGColor3f(const a,b,c:Single);inline;
begin
glColor4f(a,b,c,1);
end;

operator := (const a:TSGPoint2f):TSGVertex2f;overload;inline;
begin
Result.Import(a.x,a.y); 
end;

operator * (const a,b:TSGVertex2f):TSGVertex2f;overload;inline;
begin
Result.Import(a.x*b.x,a.y*b.y);
end;

operator * (const a:TSGPoint2f;const b:real):TSGVertex2f;overload;inline;
begin
Result.x:=a.x*b;
Result.y:=a.y*b;
end;

operator + (const a:TSGPoint2f;const b:integer):TSGPoint2f;overload;inline;
begin
Result.Import(a.x+b,a.y+b);
end;

operator + (const a:TSGVertex2f;const b:TSGPoint2f):TSGVertex2f;overload;inline;
begin
Result.Import(a.x+b.x,a.y+b.y);
end;

operator - (const a,b:TSGVertex2f):TSGVertex2f;overload;inline;
begin
Result.x:=a.x-b.x;
Result.y:=a.y-b.y;
end;

operator - (const a:TSGVertex2f):TSGVertex2f;overload;inline;
begin
Result.x:=-a.x;
Result.y:=-a.y;
end;

operator * (const a:SGVertex2f;const b:real):SGVertex2f;overload;inline;
begin
Result.Import(a.x*b,a.y*b);
end;

operator / (const a:SGVertex2f;const b:real):SGVertex2f;overload;inline;
begin
Result.Import(a.x/b,a.y/b);
end;

operator = (const a,b:TSGPoint2f):Boolean;overload;inline;
begin
Result:=(a.x=b.x) and (a.y=b.y);
end;

operator = (const a,b:TSGVertex3f):Boolean;overload;inline;
begin
Result:=(Abs(a.x-b.x)+Abs(a.y-b.y)+Abs(a.z-b.z))<SGZero;
end;

procedure TSGPlane.Write;
begin
System.Write(a:0:10,' ',b:0:10,' ',c:0:10,' ',d:0:10);
end;

operator / (const a:SGPoint;const b:Int64):SGPoint;overload;inline;
begin
Result:=a div b;
end;

operator div (const a:SGPoint;const b:Int64):SGPoint;overload;inline;
begin
Result.x:=a.x div b;
Result.y:=a.y div b;
end;

procedure TSGColor3f.ReadFromStream(const Stream:TStream);inline;
begin
Stream.ReadBuffer(Self,SizeOf(r)*3);
end;

procedure TSGColor3f.WriteToStream(const Stream:TStream);inline;
begin
Stream.WriteBuffer(Self,SizeOf(r)*3);
end;

procedure TSGColor4f.ReadFromStream(const Stream:TStream);inline;
begin
Stream.ReadBuffer(Self,SizeOf(r)*4);
end;

procedure TSGColor4f.WriteToStream(const Stream:TStream);inline;
begin
Stream.WriteBuffer(Self,SizeOf(r)*4);
end;

operator - (const a:TSGVertex):TSGVertex;overload;inline;
begin
Result.x:=-a.x;
Result.y:=-a.y;
Result.z:=-a.z;
end;

operator * (const b:real;const a:SGVertex):SGVertex;inline;overload;
begin
Result:=a*b;
end;

function SGX(const v:Single):TSGVertex3f;inline;
begin
Result.Import(v,0,0);
end;

function SGY(const v:Single):TSGVertex3f;inline;
begin
Result.Import(0,v,0);
end;

function SGZ(const v:Single):TSGVertex3f;inline;
begin
Result.Import(0,0,v);
end;

procedure TSGVertex3f.Translate;
begin
glTranslatef(x,y,z);
end;

procedure TSGVertex2f.Translate;
begin
glTranslatef(x,y,0);
end;

procedure SGLookAt(Mesh,Camera,CameraTop:SGVertex3f);
begin
gluLookAt(Mesh.x,Mesh.y,Mesh.z,Camera.x,Camera.y,Camera.z,CameraTop.x,CameraTop.y,CameraTop.z);
end;

procedure TSGVertex3f.ReadFromTextFile(const Fail:PTextFile);
begin
Read(Fail^,x,y,z);
end;

procedure TSGVertex3f.ReadLnFromTextFile(const Fail:PTextFile);
begin
ReadFromTextFile(Fail);
ReadLn(Fail^);
end;

operator = (const a,b:TSGComplexNumber):Boolean;overload;inline;
begin
Result:=(a.x=b.x) and (b.y=a.y);
end;

function TSGScreenVertexes.AbsX:SGReal;inline;
begin
Result:=Abs(X1-X2);
end;

function TSGScreenVertexes.AbsY:SGReal;inline;
begin
Result:=Abs(Y1-Y2);
end;

function TSGScreenVertexes.VertexInView(const Vertex:TSGVertex2f):Boolean;inline;
begin
Result:=(Vertex.x<SGMax(X1,X2)) and 
	(Vertex.y<SGMax(Y1,Y2)) and 
	(Vertex.x>SGMin(X1,X2)) and 
	(Vertex.y>SGMin(Y1,Y2));
end;

operator + (const a,b:SGColor):SGColor;inline;
begin
Result.r:=a.r+b.r;
Result.g:=a.g+b.g;
Result.b:=a.b+b.b;
Result.a:=a.a+b.a;
end;

operator - (const a,b:SGColor):SGColor;inline;
begin
Result.r:=a.r-b.r;
Result.g:=a.g-b.g;
Result.b:=a.b-b.b;
Result.a:=a.a-b.a;
end;

operator / (const a:SGColor;const b:real):SGColor;inline;
begin
Result.r:=a.r/b;
Result.g:=a.g/b;
Result.b:=a.b/b;
Result.a:=a.a/b;
end;

function SGGetColor4fFromLongWord(const LongWordColor:LongWord;const WithAlpha:Boolean = False):SGColor4f;inline;
type
	LongWordByteArray = packed array [0..3] of byte;
begin
if WithAlpha then
	begin
	Result.Import(
		LongWordByteArray(LongWordColor)[3]/255,
		LongWordByteArray(LongWordColor)[2]/255,
		LongWordByteArray(LongWordColor)[1]/255,
		LongWordByteArray(LongWordColor)[0]/255);
	
	end
else
	begin
	Result.Import(
		LongWordByteArray(LongWordColor)[2]/255,
		LongWordByteArray(LongWordColor)[1]/255,
		LongWordByteArray(LongWordColor)[0]/255,
		1);
	end;
end;

function SGPoint2fImport(const x1:extended = 0; const y1:extended = 0):TSGPoint2f;overload;inline;
begin
Result.x:=Round(x1);
Result.y:=Round(y1);
end;

function SGPoint2fImport(const x1:int64 = 0; const y1:int64 = 0):TSGPoint2f;overload;inline;
begin
Result.x:=x1;
Result.y:=y1;
end;

procedure TSGVertex2f.Round;overload;
begin
x:=System.Round(x);
y:=System.Round(y);
end;

procedure TSGColor4f.Import(const r1:real = 0; const g1:real = 0; const b1:real = 0;const a1:real = 1);
begin
r:=r1;
b:=b1;
g:=g1;
a:=a1;
end;

function TSGColor4f.WithAlpha(const NewAlpha:real = 1):TSGColor4f;
begin
Result:=Self;
Result.a*=NewAlpha;
end;

function SGPCharGetPart(const VPChar:PChar;const Position1,Position2:LongInt):PChar;
var
	i:LongInt;
begin
Result:='';
i:=Position1;
while (VPChar[i]<>#0) and (i<>Position2+1) do
	begin
	SGPCharAddSimbol(Result,VPChar[i]);
	i+=1;
	end;
end;

function SGGetQuantitySimbolsInNumber(l:LongInt):LongInt;inline;
begin
Result:=0;
while l<>0 do
	begin
	Result+=1;
	l:=l div 10;
	end;
end;

function SGFloatToString(const R:Extended;const Zeros:LongInt = 0):string;inline;
var
	i:LongInt;
begin
Result:='';
if Trunc(R)=0 then
	begin
	if R<0 then
		Result+='-';
	Result+='0';
	end
else
	Result+=SGStr(Trunc(R));
if Zeros<>0 then
	begin
	if Abs(R-Trunc(R))*10**Zeros<>0 then
		begin
		i:=Zeros-SGGetQuantitySimbolsInNumber(Trunc(Abs(R-Trunc(R))*(10**Zeros)));
		Result+='.';
		while i>0 do
			begin
			i-=1;
			Result+='0';
			end;
		Result+=SGStr(Trunc(Abs(R-Trunc(R))*(10**Zeros)));
		while Result[Length(Result)]='0' do
			SetLength(Result,Length(Result)-1);//Byte(Result[0])-=1;
		if Result[Length(Result)]='.' then
			SetLength(Result,Length(Result)-1);//Byte(Result[0])-=1;
		end;
	end;
end;

function SGGetFileNameWithoutExpansion(const FileName:string):string;inline;
var
	i:LongInt;
	PointPosition:LongInt = 0;
begin
for i:=1 to Length(FileName) do
	begin
	if FileName[i]='.' then
		begin
		PointPosition:=i;
		end;
	end;
if (PointPosition=0) then
	Result:=FileName
else
	begin
	Result:='';
	for i:=1 to PointPosition-1 do
		Result+=FileName[i];
	end;
end;

function SGGetFreeFileName(const Name:string):string;inline;
var
	FileExpansion:String = '';
	FileName:string = '';
	Number:LongInt = 1;

begin
if FileExists(Name) then
	begin
	FileExpansion:=SGGetFileExpansion(Name);
	FileName:=SGGetFileNameWithoutExpansion(Name);
	while FileExists(FileName+' (Copy '+SGStr(Number)+').'+FileExpansion) do
		Number+=1;
	Result:=FileName+' (Copy '+SGStr(Number)+').'+FileExpansion;
	end
else
	Result:=Name;
end;

operator ** (const a:TSGComplexNumber;const b:LongInt):TSGComplexNumber;inline;
var
	i:LongInt;
begin
Result.Import(1,0);
for i:=1 to b do
	Result*=a;
end;

procedure TSGGLMatrix.Load;
begin
glMatrixMode(GL_PROJECTION);
glLoadMatrixf(@Self);
glMatrixMode(GL_MODELVIEW);
end;

procedure TSGGLMatrix.Init;
begin
glMatrixMode(GL_PROJECTION);
glMultMatrixf(@Self);
glMatrixMode(GL_MODELVIEW);
end;

procedure TSGGLMatrix.Write;
var
	i,ii:longint;
begin
for i:=0 to 3 do
	begin
	for ii:=0 to 3 do
		System.Write(FMatrix[i][ii]:0:4,' ');
	System.WriteLn;
	end;
WriteLn;
end;

procedure TSGGLMatrix.LoadFromPlane(Plane:TSGPlane);
begin
Clear;
Add(0,0,-Plane.d);
Add(1,1,-Plane.d);
Add(2,2,-Plane.d);
Add(0,3,Plane.a);
Add(1,3,Plane.b);
Add(2,3,Plane.c);
end;

procedure SGQuickRePlaceVertexType(var LongInt1,LongInt2:TSGVertexType);
var
	a:TSGVertexType;
begin
a:=LongInt1;
LongInt1:=LongInt2;
LongInt2:=a;
end;

procedure SGSetCLLoadProcedure(p:Pointer);
begin
SGCLLoadProcedure:=SGProcedure(p);
end;

function SGReadLnByte:Byte;
begin 
Readln(Result);
end;

function SGReadLnString:String;
begin
Readln(Result);
end;

procedure TSGVertex3f.Normalize;
var
	vabs:real;
begin
vabs:=SGAbsTwoVertex(Self,NilVertex);
x/=vabs;
y/=vabs;
z/=vabs;
end;

procedure TSGVertex3f.Vertex(Const P:Pointer);
begin
if p=nil then
	gl.glVertex3f(x,y,z)
else
	TSGShodowVertexProcedure(p)(x,y,z);
end;

procedure SGSetCLProcedure(const p:Pointer = nil);
begin
SGCLPaintProcedure:=SGProcedure(p);
end;

procedure SCSetCLScreenBounds(const p:Pointer = nil);
begin
SGCLForReSizeScreenProcedure:=SGProcedure(p);
end;

function SGRandomMinus:Int;
begin
if random(2)=0 then
	Result:=-1
else
	Result:=1;
end;

procedure TSGGLMatrix.Clear;
begin
FMatrix[0,0]:=0;FMatrix[0,1]:=0;FMatrix[0,2]:=0;FMatrix[0,3]:=0;
FMatrix[1,0]:=0;FMatrix[1,1]:=0;FMatrix[1,2]:=0;FMatrix[1,3]:=0;
FMatrix[2,0]:=0;FMatrix[2,1]:=0;FMatrix[2,2]:=0;FMatrix[2,3]:=0;
FMatrix[3,0]:=0;FMatrix[3,1]:=0;FMatrix[3,2]:=0;FMatrix[3,3]:=0;
end;

constructor TSGGLMatrix.Create;
begin
Clear;
end;

procedure TSGGLMatrix.Add(const x:Int = 0; const y:Int = 0;const Param:GLFloat = 0);
begin
if (x>=0) and (x<=3) and (y>=0) and (y<=3) then
	FMatrix[x,y]:=Param;
end;


function TSGColor4f.AddAlpha(const NewAlpha:real = 1):TSGColor4f;
begin
a*=NewAlpha;
Result:=Self;
end;

function SGComplexNumberImport(const x:real = 0;const y:real = 0):TSGComplexNumber;inline;
begin
Result.Import(x,y);
end;

function SGVertex2fImport(const x:real = 0;const y:real = 0):TSGVertex2f;inline;
begin
Result.Import(x,y);
end;

operator - (const a,b:TSGComplexNumber):TSGComplexNumber;inline;
begin
Result.Import(a.x-b.x,a.y-b.y);
end;

operator / (const a,b:TSGComplexNumber):TSGComplexNumber;inline;
begin
Result.Import(
	(a.x*b.x+a.y*b.y)/(b.x*b.x-b.y*b.y),
	(a.y*b.x-a.x*b.y)/(b.x*b.x-b.y*b.y));
end;

operator * (const a,b:TSGComplexNumber):TSGComplexNumber;inline;
begin
result.Import(a.x*b.x-a.y*b.y,a.x*b.y+b.x*a.y);
end;

operator + (const a,b:TSGComplexNumber):TSGComplexNumber;inline;
begin
Result.Import(a.x+b.x,a.y+b.y);
end;

function SGVertex2fToPoint2f(const Vertex:TSGVertex2f):TSGPoint2f;
begin
Result.Import(
	Round(Vertex.X),
	Round(Vertex.Y));
end;

procedure SGQuickRePlaceLongInt(var LongInt1,LongInt2:LongInt);
var
	LongInt3:LongInt;
begin
LongInt3:=LongInt1;
LongInt1:=LongInt2;
LongInt2:=LongInt3;
end;

procedure SGQuickRePlaceReals(var Real1,Real2:Real);
var
	Real3:Real;
begin
Real3:=Real1;
Real1:=Real2;
Real2:=Real3;
end;

procedure TSGScreenVertexes.ProcSumX(r:Real);
begin
Vertexes[0].x+=r;
Vertexes[1].x+=r;
end;

procedure TSGScreenVertexes.ProcSumY(r:Real);
begin
Vertexes[0].y+=r;
Vertexes[1].y+=r;
end;

procedure TSGVertex3f.WriteLn;
begin
Write;
System.WriteLn()
end;

procedure TSGVertex3f.Write;
begin
inherited Write;
System.Write(' ',z:0:10)
end;

procedure TSGVertex2f.Write;
begin
System.Write(x:0:10,' ',y:0:10);
end;

procedure TSGVertex2f.WriteLn;
begin
Write;
System.Writeln;
end;

procedure TSGScreenVertexes.Write;
begin
Vertexes[0].Write;
System.Write(' ');
Vertexes[1].WriteLn;
end;

operator * (const a:TSGScreenVertexes;const b:real):TSGScreenVertexes;inline;
var
	x,y,x1,y1:real;
begin
x:=(a.x1+a.x2)/2;
y:=(a.y1+a.y2)/2;
x1:=abs(a.x1-x);
y1:=abs(a.y1-y);
x1*=b;
y1*=b;
Result.Import(
	x-x1,
	y-y1,
	x+x1,
	y+y1);
end;

procedure TSGScreenVertexes.Import(const x1:real = 0;const y1:real = 0;const x2:real = 0;const y2:real = 0);
begin
Vertexes[0].x:=x1;
Vertexes[0].y:=y1;
Vertexes[1].x:=x2;
Vertexes[1].y:=y2;
end;

function SGRealsEqual(const r1,r2:real):Boolean;
begin
Result:=abs(r1-r2)<=SGZero;
end;

function SGRealExists(const r:real):Boolean;
begin
Result:={(r<>Nan) and} (r<>Inf) and (r<>-Inf);
end;

function SGAbsTwoVertex2f(const Vertex1,Vertex2:SGVertex2f):real;inline;
begin
Result:=sqrt(sqr(Vertex1.x-Vertex2.x)+sqr(Vertex1.y-Vertex2.y));
end;

function SGPCharTotal(const VPChar1,VPChar2:PChar):PChar;
var
	Length1:LongInt = 0;
	Length2:LongInt = 0;
	I:LongInt = 0;
begin
Length1:=SGPCharLength(VPChar1);
Length2:=SGPCharLength(VPChar2);
Result:=nil;
GetMem(Result,Length1+Length2+1);
Result[Length1+Length2]:=#0;
for I:=0 to Length1-1 do
	Result[I]:=VPChar1[i];
for i:=Length1 to Length1+Length2-1 do
	Result[I]:=VPChar2[I-Length1];
end;

procedure TSGVertex3f.VertexPoint;
begin
glBegin(GL_POINTS);
Vertex;
glEnd();
end;

operator ** (const a:LongInt;const b:LongInt):LongInt;overload;inline;
var
	I:LongInt = 0;
begin
Result:=1;
for i:=1 to b do
	Result*=a;
end;


operator ** (const a:Single;const b:LongInt):Single;inline;overload;
var
	I:LongWord = 0;
begin
Result:=1;
if b>0 then
	for i:=1 to b do
		Result*=a
else
	for i:=1 to abs(b) do
		Result/=a
end;

operator ** (const a:Real;const b:LongInt):Real;inline;overload;
var
	I:LongWord = 0;
begin
Result:=1;
if b>0 then
	for i:=1 to b do
		Result*=a
else
	for i:=1 to abs(b) do
		Result/=a
end;

procedure TSGVertex3f.LightPosition(const Ligth:LongInt = GL_LIGHT0);
var
	Light:array[0..3] of glFloat;
	AmbientLight : array[0..3] of glFloat = (0.5,0.5,0.5,1.0);
	DiffuseLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
	SpecularLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
begin
Light[0]:=x;
Light[1]:=y;
Light[2]:=z;
Light[3]:=2;
glEnable(Ligth);
glLightfv(Ligth,GL_POSITION,@Light);
glLightfv(Ligth,GL_AMBIENT, @AmbientLight);
glLightfv(Ligth,GL_DIFFUSE, @DiffuseLight);
glLightfv(Ligth,GL_SPECULAR, @SpecularLight);
end;

procedure TSGVertex3f.Normal;
begin
glNormal3f(x,y,z);
end;

function SGPCharDeleteSpaces(const VPChar:PCHAR):PChar;
var
	I:Longint = 0;
begin
GetMem(Result,1);
Result^:=#0;
while VPChar[i]<>#0 do
	begin
	if VPChar[i]<>' ' then
		SGPCharAddSimbol(Result,VPChar[i]);
	I+=1;
	end;
end;

function SGCharRead:Char;
begin
Read(Result);
end;

function SGPCharRead:PChar;
begin
GetMem(Result,1);
Result[0]:=#0;
while not eoln do
	begin
	SGPCharAddSimbol(Result,SGCharRead);
	end;
end;

function SGPCharUpCase(const VPChar:PChar):PChar;
var
	i:LongWord = 0;
begin
Result:=nil;
if (VPChar<>nil) then
	begin
	I:=SGPCharLength(VPChar);
	GetMem(Result,I+1);
	Result[I]:=#0;
	I:=0;
	while VPChar[i]<>#0 do
		begin
		Result[i]:=UpCase(VPChar[i]);
		I+=1;
		end;
	end;
end;

function SGPCharDecFromEnd(var VPChar:PChar; const Number:LongWord = 1):PChar;
var
	NewVPChar:PChar = nil;
	LengthOld:LongWord = 0;
	I:LongInt = 0;
begin
LengthOld:=SGPCharLength(VPChar);
GetMem(NewVPChar,LengthOld-Number+1);
for I:=0 to LengthOld-Number-1 do
	NewVPChar[i]:=VPChar[i];
NewVPChar[LengthOld-Number]:=#0;
VPChar:=NewVPChar;
Result:=NewVPChar;
end;

function SGPCharLength(const VPChar:PChar):LongWord;
begin
Result:=SGPCharHigh(VPChar)+1;
end;

function SGPCharHigh(const VPChar:PChar):LongInt;
begin
if (VPChar = nil) or (VPChar[0] = #0) then
	Result:=-1
else
	begin
	Result:=0;
	while VPChar[Result]<>#0 do
		Result+=1;
	Result-=1;
	end;
end;

function SGPCharsEqual(const PChar1,PChar2:PChar):Boolean;
var
	I:LongInt = 0;
	VExit:Boolean = False;
begin
Result:=True;
if not ((PChar1=nil) and (PChar2=nil)) then
	while Result and (not VExit) do
		begin
		if (PChar1=nil) or (PChar2=nil) or (PChar1[i]=#0) or (PChar2[i]=#0) then
			VExit:=True;
		if  ((PChar1=nil) and (PChar2<>nil) and (PChar2[i]<>#0)) or
			((PChar2=nil) and (PChar1<>nil) and (PChar1[i]<>#0))then
				Result:=False
		else
			if (PChar1<>nil) and (PChar2<>nil) and 
				(((PChar1[i]=#0) and (PChar2[i]<>#0)) or 
				 ((PChar2[i]=#0) and (PChar1[i]<>#0))) then
					Result:=False
			else
				if (PChar1<>nil) and (PChar2<>nil) and 
					(PChar1[i]<>#0) and (PChar2[i]<>#0) and 
					(PChar1[i]<>PChar2[i]) then
						Result:=False;					
		I+=1;
		end;
end;

function SGPCharAddSimbol(var VPChar:PChar; const VChar:Char):PChar;
var
	NewVPChar:PChar = nil;
	LengthOld:LongInt = 0;
	I:LongInt = 0;
begin
if VPChar<>nil then
	begin
	while (VPChar[LengthOld]<>#0) do
		LengthOld+=1;
	end;
GetMem(NewVPChar,LengthOld+2);
for I:=0 to LengthOld-1 do
	NewVPChar[i]:=VPChar[i];
NewVPChar[LengthOld]:=VChar;
NewVPChar[LengthOld+1]:=#0;
VPChar:=NewVPChar;
Result:=NewVPChar;
end;

procedure SGWriteTime;
var
	h,m,s,sec100:word;
begin
GetTime(h,m,s,sec100);
writeln(h,':Hours; ',m,':Minits; ',s,':Seconds; ',sec100,':Sec100.');
end;

procedure SGWndSomeQuad(a,c:SGVertex);
var
	b,d:SGVertex;
begin
b.Import(c.x,a.y,a.z);
d.Import(a.x,c.y,a.z);
glBegin(GL_QUADS);
glTexCoord2f(0,1);a.Vertex;
glTexCoord2f(1,1);b.Vertex;
glTexCoord2f(1,0);c.Vertex;
glTexCoord2f(0,0);d.Vertex;
glEnd;
end;

operator + (const a:SGVertex;const b:SGVertex2f):SGVertex;inline;
begin
Result.Import(a.x+b.x,a.y+b.y,a.z);
end;

operator + (const a:SGVertex2f;const b:SGVertex):SGVertex;inline;
begin
Result.Import(a.x+b.x,a.y+b.y,b.z);
end;

operator + (const a,b:SGVertex2f):SGVertex2f;inline;
begin
Result.Import(a.x+b.x,a.y+b.y);
end;

operator + (const a,b:SGVertex2f):SGVertex;inline;
begin
Result.Import(a.x+b.x,a.y+b.y);
end;

procedure SGSomeQuad(a,b,c,d:SGVertex;vl,np:SGPoint);
begin
glBegin(GL_QUADS);
glTexCoord2f(vl.x, vl.y);a.Vertex;
glTexCoord2f(np.x, vl.y);b.Vertex;
glTexCoord2f(np.x, np.y);c.Vertex;
glTexCoord2f(vl.x, np.y);d.Vertex;
glEnd;
end;

procedure SGRoundWindowQuad(const Vertex11,Vertex13:SGVertex;const Vertex21,Vertex23:SGVertex; 
	const Radius1:real;const Radius2:real; const Interval:LongInt;const QuadColor1:SGColor;const QuadColor2:SGColor;
	const WithLines:boolean; const LinesColor1:SGColor4f; const LinesColor2:SGColor4f);
begin
SGRoundQuad(Vertex11,Vertex13,Radius1,Interval,QuadColor1,LinesColor1,WithLines);
SGRoundQuad(Vertex21,Vertex23,Radius2,Interval,QuadColor2,LinesColor2,WithLines);
end;

procedure SGRoundQuad(
	const Vertex1,Vertex3:SGVertex; 
	const Radius:real; 
	const Interval:LongInt;
	const QuadColor:SGColor; 
	const LinesColor:SGColor4f; 
	const WithLines:boolean = False;
	const WithQuad:boolean = True);
var
	ArVertex:TSGArTSGVertex = nil;
begin
ArVertex:=SGGetArrayOfRoundQuad(Vertex1,Vertex3,Radius,Interval);
SGConstructRoundQuad(ArVertex,Interval,QuadColor,LinesColor,WithLines,WithQuad);
SetLength(ArVertex,0);
end;

function SGGetArrayOfRoundQuad(const Vertex1,Vertex3:SGVertex; const Radius:real; const Interval:LongInt):SGArVertex;
var
	Vertex2,Vertex4:SGVertex;
	VertexR1,VertexR2,VertexR3,VertexR4:SGVertex;
	I,ii:LongInt;
begin
Result:=nil;
Vertex2.Import(Vertex3.x,Vertex1.y,(Vertex1.z+Vertex3.z)/2);
Vertex4.Import(Vertex1.x,Vertex3.y,(Vertex1.z+Vertex3.z)/2);
VertexR1.Import(Vertex1.x+Radius,Vertex1.y-Radius,Vertex1.z);
VertexR2.Import(Vertex2.x-Radius,Vertex2.y-Radius,Vertex2.z);
VertexR3.Import(Vertex3.x-Radius,Vertex3.y+Radius,Vertex3.z);
VertexR4.Import(Vertex4.x+Radius,Vertex4.y+Radius,Vertex4.z);
SetLength(Result,Interval*4+4);
ii:=0;
For i:=0 to Interval do
	begin
	Result[ii].Import(VertexR2.x+cos((Pi/2)/(Interval)*i)*Radius,VertexR2.y+sin((Pi/2)/(Interval)*i+Pi)*Radius+2*Radius,VertexR2.z); 
	ii+=1;
	end;
For i:=0 to Interval do
	begin
	Result[ii].Import(VertexR1.x+cos((Pi/2)*i/(Interval)+Pi/2)*Radius,VertexR1.y+sin((Pi/2)*i/(Interval)+3*Pi/2)*Radius+2*Radius,VertexR1.z); 
	ii+=1;
	end;
For i:=0 to Interval do
	begin 
	Result[ii].Import(VertexR4.x+cos((Pi/2)*i/Interval+Pi)*Radius,VertexR4.y+sin((Pi/2)*i/(Interval))*Radius-2*Radius,VertexR4.z); 
	ii+=1;
	end;
For i:=0 to Interval do
	begin 
	Result[ii].Import(VertexR3.x+cos((Pi/2)*i/(Interval)+3*Pi/2)*Radius,VertexR3.y+sin((Pi/2)*i/(Interval)+Pi/2)*Radius-2*Radius,VertexR3.z); 
	ii+=1;
	end;
end;

procedure SGConstructRoundQuad(
	const ArVertex:SGArSGVertex;
	const Interval:LongInt;
	const QuadColor:SGColor; 
	const LinesColor:SGColor4f; 
	const WithLines:boolean = False;
	const WithQuad:boolean = True);
var
	I:LongInt;
begin
if WithQuad then
	begin
	(QuadColor).Color;
	glBegin(GL_QUADS);
	for i:=0 to Interval-1 do
		begin
		ArVertex[Interval-i].Vertex;
		ArVertex[Interval+1+i].Vertex;
		ArVertex[Interval+2+i].Vertex;
		ArVertex[Interval-i-1].Vertex;
		end;
	ArVertex[0].Vertex;
	ArVertex[2*Interval+1].Vertex;
	ArVertex[2*Interval+2].Vertex;
	ArVertex[4*(Interval+1)-1].Vertex;
	for i:=0 to Interval-1 do
		begin
		ArVertex[(Interval+1)*2+i].Vertex;
		ArVertex[(Interval+1)*2+i+1].Vertex;
		ArVertex[(Interval+1)*4-2-i].Vertex;
		ArVertex[(Interval+1)*4-1-i].Vertex;
		end;
	glEnd();
	end;
if WithLines then
	begin
	LinesColor.Color;
	glBegin(GL_LINE_LOOP);
	for i:=Low(ArVertex) to High(ArVertex) do
		ArVertex[i].Vertex;
	glEnd();
	end;
end;

function SGPoint2fToVertex3f(const Point:SGPoint):SGVertex3f;inline;
begin
Result.Import(Point.x,Point.y,0);
end;

operator * (const a:SGColor;const b:real):SGColor;inline;
begin
Result.SetVariables(a.r*b,a.g*b,a.b*b,a.a*b);
end;

function SGColorImport(const r1:real = 0;const g1:real = 0;const b1:real = 0;const a1:real = 1):SGColor;inline;
begin
Result.SetVariables(r1,g1,b1,a1);
end;

function SGPoint2fToVertex2f(const Point:SGPoint):SGVertex2f;inline;
begin
Result.Import(Point.x,Point.y);
end;

procedure TSGVertex2f.Import(const x1:real = 0;const y1:real = 0);inline;
begin
x:=x1;
y:=y1;
end;

procedure TSGPoint2f.Vertex;inline;
begin
glVertex2f(x,y);
end;

function SGGetVertexOnIntersectionOfTwoLinesFromFourVertex(const q1,q2,w1,w2:SGVertex):SGVertex;inline;
var
	q3:SGVertex;
begin
q3:=q2;
q3+=SGGetVertexWhichNormalFromThreeVertex(q1,q2,w1);
Result:=SGGetVertexOnIntersectionOfThreePlane(
	SGGetPlaneFromThreeVertex(q1,q2,q3),
	SGGetPlaneFromThreeVertex(SGGetVertexInAttitude(q1,q2),w1,w2),
	SGGetPlaneFromThreeVertex(SGGetVertexInAttitude(q1,q3),w1,w2));
end;

function SGGetPlaneFromNineReals(const x1,y1,z1,x2,y2,z2,x0,y0,z0:real):SGPlane;
begin
Result.Import(
	+SGGetMatrix2x2(y1-y0,z1-z0,y2-y0,z2-z0),
	-SGGetMatrix2x2(x1-x0,z1-z0,x2-x0,z2-z0),
	+SGGetMatrix2x2(x1-x0,y1-y0,x2-x0,y2-y0),
	-x0*SGGetMatrix2x2(y1-y0,z1-z0,y2-y0,z2-z0)
	+y0*SGGetMatrix2x2(x1-x0,z1-z0,x2-x0,z2-z0)
	-z0*SGGetMatrix2x2(x1-x0,y1-y0,x2-x0,y2-y0))
end;

function SGGetPlaneFromThreeVertex(const a1,a2,a3:SGVertex):SGPlane;
begin
Result:=SGGetPlaneFromNineReals(a1.x,a1.y,a1.z,a2.x,a2.y,a2.z,a3.x,a3.y,a3.z);
end;

function SGGetVertexWhichNormalFromThreeVertex(const p1,p2,p3:SGVertex):SGVertex;
var a,b,c:real;
begin
a:=p1.y*(p2.z-p3.z)+p2.y*(p3.z-p1.z)+p3.y*(p1.z-p2.z);
b:=p1.z*(p2.x-p3.x)+p2.z*(p3.x-p1.x)+p3.z*(p1.x-p2.x);
c:=p1.x*(p2.y-p3.y)+p2.x*(p3.y-p1.y)+p3.x*(p1.y-p2.y);
Result.Import(a/(sqrt(a*a+b*b+c*c)),b/(sqrt(a*a+b*b+c*c)),c/(sqrt(a*a+b*b+c*c)));
end;

function SGGetVertexOnIntersectionOfThreePlane(p1,p2,p3:SGPlane):SGVertex;
var de,de1,de2,de3:real;
begin
p1.d:=-1*(p1.d);
p2.d:=-1*(p2.d);
p3.d:=-1*(p3.d);
de:=SGGetMatrix3x3(p1.a,p1.b,p1.c,p2.a,p2.b,p2.c,p3.a,p3.b,p3.c);
de1:=SGGetMatrix3x3(p1.d,p1.b,p1.c,p2.d,p2.b,p2.c,p3.d,p3.b,p3.c);
de2:=SGGetMatrix3x3(p1.a,p1.d,p1.c,p2.a,p2.d,p2.c,p3.a,p3.d,p3.c);
de3:=SGGetMatrix3x3(p1.a,p1.b,p1.d,p2.a,p2.b,p2.d,p3.a,p3.b,p3.d);
Result.Import(de1/de,de2/de,de3/de);
end;

function SGGetMatrix3x3(a1,a2,a3,a4,a5,a6,a7,a8,a9:real):real;
begin
Result:=a1*SGGetMatrix2x2(a5,a6,a8,a9)-a2*SGGetMatrix2x2(a4,a6,a7,a9)+a3*SGGetMatrix2x2(a4,a5,a7,a8);
end;

function SGGetMatrix2x2(a1,a2,a3,a4:real):real;
begin
Result:=a1*a4-a2*a3;
end;

procedure TSGPlane.Import(const a1:real = 0; const b1:real = 0; const c1:real = 0; const d1:real = 0);
begin
a:=a1;
b:=b1;
c:=c1;
d:=d1;
end;

procedure TSGColor3f.Color;
begin
SetColor();
end;

procedure TSGColor3f.SetColor;
begin
glColor3f(r,g,b);
end;

procedure TSGColor3f.Import(const r1: single; const g1: single; const b1: single
  );
begin
  r:=r1;
  g:=g1;
  b:=b1;
end;

procedure SGQuad(ArVertex:TSGArFor1To4OfSGVertex);
begin
SGQuad(ArVertex[1],ArVertex[2],ArVertex[3],ArVertex[4])
end;

procedure TSGPoint2f.Write;
begin
writeln(x,' ',y);
end;



function SGVertexOnQuad(const Vertex:SGVertex; const QuadVertex1:SGVertex;const QuadVertex3:SGVertex):boolean;
begin
Result:=SGVertexOnQuad(
	Vertex,
	QuadVertex1,
	SGVertexImport(
		QuadVertex1.x,
		QuadVertex3.y,
		QuadVertex1.z),
	QuadVertex3,
	SGVertexImport(
		QuadVertex3.x,
		QuadVertex1.y,
		QuadVertex3.z));
end;

function SGVertexOnQuad(const Vertex:SGVertex; const QuadVertex1:SGVertex;const QuadVertex2:SGVertex;const QuadVertex3:SGVertex;const QuadVertex4:SGVertex):boolean;
begin
if abs(
	(SGAbsTwoVertex(QuadVertex1,QuadVertex2)*SGAbsTwoVertex(QuadVertex2,QuadVertex3))
	-
	(
		SGTreugPlosh(Vertex,QuadVertex1,QuadVertex2)+
		SGTreugPlosh(Vertex,QuadVertex2,QuadVertex3)+
		SGTreugPlosh(Vertex,QuadVertex3,QuadVertex4)+
		SGTreugPlosh(Vertex,QuadVertex4,QuadVertex1))
	)>SGZero then
	Result:=False
else
	Result:=True;
end;

function SGTreugPlosh(const a1,a2,a3:SGVertex):real;
var
	p:real;
begin
p:=(SGAbsTwoVertex(a1,a2)+SGAbsTwoVertex(a1,a3)+SGAbsTwoVertex(a3,a2))/2;
SGTreugPlosh:=sqrt(p*(p-SGAbsTwoVertex(a1,a2))*(p-SGAbsTwoVertex(a3,a2))*(p-SGAbsTwoVertex(a1,a3)));
end;

function SGAbsTwoVertex(const Vertex1:SGVertex;const Vertex2:SGVertex):real;inline;
begin
Result:=sqrt(sqr(Vertex1.x-Vertex2.x)+sqr(Vertex1.y-Vertex2.y)+sqr(Vertex1.z-Vertex2.z));
end;

procedure SGLoadFrameIdentity;
begin
glLoadIdentity;
glTranslatef(0,0,-6);
end;

procedure SGQuad(const Vertex1:SGVertex;const Vertex2:SGVertex;const Vertex3:SGVertex;const Vertex4:SGVertex);
begin
glBegin(GL_QUADS);
Vertex1.Vertex;
Vertex2.Vertex;
Vertex3.Vertex;
Vertex4.Vertex;
glEnd();
end;

function SGPointImport(const NewX:LongInt = 0; const NewY:LongInt = 0 ):SGPoint;
begin
Result.x:=NewX;
Result.y:=NewY;
end;

function SGPointImport(const NewX:Real = 0; const NewY:Real = 0 ):SGPoint;
begin
Result.x:=Round(NewX);
Result.y:=Round(NewY);
end;

procedure TSGVertex3f.Import(const x1:real = 0; const y1:real = 0; const z1:real = 0);
begin
x:=x1;
y:=y1;
z:=z1;
end;

function SGVertexImport(const x:real = 0;const y:real = 0;const z:real = 0):TSGVertex3f;
begin
Result.x:=x;
Result.y:=y;
Result.z:=z;
end;

operator / (const a:SGVertex;const b:real):SGVertex;inline;
begin
Result.x:=a.x/b;
Result.y:=a.y/b;
Result.z:=a.z/b;
end;

operator * (const a:SGVertex;const b:real):SGVertex;inline;
begin
Result.x:=a.x*b;
Result.y:=a.y*b;
Result.z:=a.z*b;
end;



operator - (const a,b:SGVertex):SGVertex;inline;
begin
Result.x:=a.x-b.x;
Result.y:=a.y-b.y;
Result.z:=a.z-b.z;
end;

operator + (const a,b:SGVertex):SGVertex;inline;
begin
Result.x:=a.x+b.x;
Result.y:=a.y+b.y;
Result.z:=a.z+b.z;
end;

procedure TSGBezierCurve.CalculateRandom(Detalization1,KolVertex,Diapazon:longint);
var
	i:longint;
begin
Clear;
SetDetalization(Detalization1);
for i:=1 to KolVertex do
	InitVertex(SGTSGVertex3fImport(
		SGRandomMinus*random(Diapazon)/(random(Diapazon)+1),
		SGRandomMinus*random(Diapazon)/(random(Diapazon)+1),
		SGRandomMinus*random(Diapazon)/(random(Diapazon)+1)));
Calculate;
end;
procedure SGPoint.Import(const x1:longint = 0; const y1:longint = 0);
begin
x:=x1;
y:=y1;
end;

operator + (const a,b:SGPoint):SGPoint;inline;
begin
Result.x:=a.x+b.x;
Result.y:=a.y+b.y;
end;

operator - (const a,b:SGPoint):SGPoint;inline;
begin
Result.x:=a.x-b.x;
Result.y:=a.y-b.y;
end;

procedure SGInitOpenGL;
var
	AmbientLight : array[0..3] of glFloat = (0.5,0.5,0.5,1.0);
	DiffuseLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
	SpecularLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
	SpecularReflection : array[0..3] of glFloat = (0.4,0.4,0.4,1.0);
	LightPosition : array[0..3] of glFloat = (0,1,0,2);
	fogColor:SGColor4f = (r:0;g:0;b:0;a:1);
var
	Extendeds:packed array of string;
	i,ii:LongWord;
begin
if SGIsOpenGLInit then
	Exit;

glEnable(GL_FOG);
glFogi(GL_FOG_MODE, GL_LINEAR);
glHint (GL_FOG_HINT, GL_NICEST);
//glHint(GL_FOG_HINT, GL_DONT_CARE);
glFogf (GL_FOG_START, 300);
glFogf (GL_FOG_END, 400);
glFogfv(GL_FOG_COLOR, @fogColor);
glFogf(GL_FOG_DENSITY, 0.55);

glClearColor(0,0,0,0);
glEnable(GL_DEPTH_TEST);
glClearDepth(1.0);
glDepthFunc(GL_LEQUAL);

glEnable(GL_LINE_SMOOTH);
glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
glLineWidth (1.5);

glShadeModel(GL_SMOOTH);
glEnable(GL_TEXTURE_1D);
glEnable(GL_TEXTURE_2D);
glEnable(GL_TEXTURE);
glEnable (GL_BLEND);
glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA) ;
glEnable (GL_LINE_SMOOTH);
//glEnable (GL_POLYGON_SMOOTH);


glEnable(GL_LIGHTING);
glLightfv(GL_LIGHT0,GL_AMBIENT, @AmbientLight);
glLightfv(GL_LIGHT0,GL_DIFFUSE, @DiffuseLight);
glLightfv(GL_LIGHT0,GL_SPECULAR, @SpecularLight);
glEnable(GL_LIGHT0);

glLightfv(GL_LIGHT0,GL_POSITION,@LightPosition);

glEnable(GL_COLOR_MATERIAL);
glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
glMaterialfv(GL_FRONT, GL_SPECULAR, @SpecularReflection);
glMateriali(GL_FRONT,GL_SHININESS,100);

glDisable(GL_LIGHTING);

SetLength(Extendeds,0);
i:=0;

SGLog.Sourse('SGOpenGLInit : Supported is next extendeds {');

SGIsSuppored_GL_version_1_2:=Load_GL_version_1_2;
if SGIsSuppored_GL_version_1_2 then
	begin
	SGLog.Sourse('GL_version_1_2');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_version_1_2';
	end;
SGIsSuppored_GL_version_1_3:=Load_GL_version_1_3;
if SGIsSuppored_GL_version_1_3 then
	begin
	SGLog.Sourse('GL_version_1_3');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_version_1_3';
	end;
SGIsSuppored_GL_ARB_imaging:=Load_GL_ARB_imaging;
if SGIsSuppored_GL_ARB_imaging then
	begin
	SGLog.Sourse('GL_ARB_imaging');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_imaging';
	end;
SGIsSuppored_GL_ARB_multitexture:=Load_GL_ARB_multitexture;
if SGIsSuppored_GL_ARB_multitexture then
	begin
	SGLog.Sourse('GL_ARB_multitexture');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_multitexture';
	end;
SGIsSuppored_GL_ARB_transpose_matrix:=Load_GL_ARB_transpose_matrix;
if SGIsSuppored_GL_ARB_transpose_matrix then
	begin
	SGLog.Sourse('GL_ARB_transpose_matrix');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_transpose_matrix';
	end;
SGIsSuppored_GL_ARB_multisample:=Load_GL_ARB_multisample;
if SGIsSuppored_GL_ARB_multisample then
	begin
	SGLog.Sourse('GL_ARB_multisample');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_multisample';
	end;
SGIsSuppored_GL_ARB_texture_env_add:=Load_GL_ARB_texture_env_add;
if SGIsSuppored_GL_ARB_texture_env_add then
	begin
	SGLog.Sourse('GL_ARB_texture_env_add');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_texture_env_add';
	end;
SGIsSuppored_WGL_ARB_extensions_string:=Load_WGL_ARB_extensions_string;
if SGIsSuppored_WGL_ARB_extensions_string then
	begin
	SGLog.Sourse('WGL_ARB_extensions_string');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_ARB_extensions_string';
	end;
SGIsSuppored_WGL_ARB_buffer_region:=Load_WGL_ARB_buffer_region;
if SGIsSuppored_WGL_ARB_buffer_region then
	begin
	SGLog.Sourse('WGL_ARB_buffer_region');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_ARB_buffer_region';
	end;
SGIsSuppored_GL_ARB_texture_cube_map:=Load_GL_ARB_texture_cube_map;
if SGIsSuppored_GL_ARB_texture_cube_map then
	begin
	SGLog.Sourse('GL_ARB_texture_cube_map');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_texture_cube_map';
	end;
SGIsSuppored_GL_ARB_depth_texture:=Load_GL_ARB_depth_texture;
if SGIsSuppored_GL_ARB_depth_texture then
	begin
	SGLog.Sourse('GL_ARB_depth_texture');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_depth_texture';
	end;
SGIsSuppored_GL_ARB_point_parameters:=Load_GL_ARB_point_parameters;
if SGIsSuppored_GL_ARB_point_parameters then
	begin
	SGLog.Sourse('GL_ARB_point_parameters');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_point_parameters';
	end;
SGIsSuppored_GL_ARB_shadow:=Load_GL_ARB_shadow;
if SGIsSuppored_GL_ARB_shadow then
	begin
	SGLog.Sourse('GL_ARB_shadow');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_shadow';
	end;
SGIsSuppored_GL_ARB_shadow_ambient:=Load_GL_ARB_shadow_ambient;
if SGIsSuppored_GL_ARB_shadow_ambient then
	begin
	SGLog.Sourse('GL_ARB_shadow_ambient');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_shadow_ambient';
	end;
SGIsSuppored_GL_ARB_texture_border_clamp:=Load_GL_ARB_texture_border_clamp;
if SGIsSuppored_GL_ARB_texture_border_clamp then
	begin
	SGLog.Sourse('GL_ARB_texture_border_clamp');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_texture_border_clamp';
	end;
SGIsSuppored_GL_ARB_texture_compression:=Load_GL_ARB_texture_compression;
if SGIsSuppored_GL_ARB_texture_compression then
	begin
	SGLog.Sourse('GL_ARB_texture_compression');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_texture_compression';
	end;
SGIsSuppored_GL_ARB_texture_env_combine:=Load_GL_ARB_texture_env_combine;
if SGIsSuppored_GL_ARB_texture_env_combine then
	begin
	SGLog.Sourse('GL_ARB_texture_env_combine');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_texture_env_combine';
	end;
SGIsSuppored_GL_ARB_texture_env_crossbar:=Load_GL_ARB_texture_env_crossbar;
if SGIsSuppored_GL_ARB_texture_env_crossbar then
	begin
	SGLog.Sourse('GL_ARB_texture_env_crossbar');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_texture_env_crossbar';
	end;
SGIsSuppored_GL_ARB_texture_env_dot3:=Load_GL_ARB_texture_env_dot3;
if SGIsSuppored_GL_ARB_texture_env_dot3 then
	begin
	SGLog.Sourse('GL_ARB_texture_env_dot3');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_texture_env_dot3';
	end;
SGIsSuppored_GL_ARB_texture_mirrored_repeat:=Load_GL_ARB_texture_mirrored_repeat;
if SGIsSuppored_GL_ARB_texture_mirrored_repeat then
	begin
	SGLog.Sourse('GL_ARB_texture_mirrored_repeat');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_texture_mirrored_repeat';
	end;
SGIsSuppored_GL_ARB_vertex_blend:=Load_GL_ARB_vertex_blend;
if SGIsSuppored_GL_ARB_vertex_blend then
	begin
	SGLog.Sourse('GL_ARB_vertex_blend');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_vertex_blend';
	end;
SGIsSuppored_GL_ARB_vertex_program:=Load_GL_ARB_vertex_program;
if SGIsSuppored_GL_ARB_vertex_program then
	begin
	SGLog.Sourse('GL_ARB_vertex_program');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_vertex_program';
	end;
SGIsSuppored_GL_ARB_window_pos:=Load_GL_ARB_window_pos;
if SGIsSuppored_GL_ARB_window_pos then
	begin
	SGLog.Sourse('GL_ARB_window_pos');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_window_pos';
	end;
SGIsSuppored_GL_EXT_422_pixels:=Load_GL_EXT_422_pixels;
if SGIsSuppored_GL_EXT_422_pixels then
	begin
	SGLog.Sourse('GL_EXT_422_pixels');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_422_pixels';
	end;
SGIsSuppored_GL_EXT_bgra:=Load_GL_EXT_bgra;
if SGIsSuppored_GL_EXT_bgra then
	begin
	SGLog.Sourse('GL_EXT_bgra');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_bgra';
	end;
SGIsSuppored_GL_EXT_blend_color:=Load_GL_EXT_blend_color;
if SGIsSuppored_GL_EXT_blend_color then
	begin
	SGLog.Sourse('GL_EXT_blend_color');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_blend_color';
	end;
SGIsSuppored_GL_EXT_blend_func_separate:=Load_GL_EXT_blend_func_separate;
if SGIsSuppored_GL_EXT_blend_func_separate then
	begin
	SGLog.Sourse('GL_EXT_blend_func_separate');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_blend_func_separate';
	end;
SGIsSuppored_GL_EXT_blend_logic_op:=Load_GL_EXT_blend_logic_op;
if SGIsSuppored_GL_EXT_blend_logic_op then
	begin
	SGLog.Sourse('GL_EXT_blend_logic_op');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_blend_logic_op';
	end;
SGIsSuppored_GL_EXT_blend_minmax:=Load_GL_EXT_blend_minmax;
if SGIsSuppored_GL_EXT_blend_minmax then
	begin
	SGLog.Sourse('GL_EXT_blend_minmax');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_blend_minmax';
	end;
SGIsSuppored_GL_EXT_blend_subtract:=Load_GL_EXT_blend_subtract;
if SGIsSuppored_GL_EXT_blend_subtract then
	begin
	SGLog.Sourse('GL_EXT_blend_subtract');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_blend_subtract';
	end;
SGIsSuppored_GL_EXT_clip_volume_hint:=Load_GL_EXT_clip_volume_hint;
if SGIsSuppored_GL_EXT_clip_volume_hint then
	begin
	SGLog.Sourse('GL_EXT_clip_volume_hint');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_clip_volume_hint';
	end;
SGIsSuppored_GL_EXT_color_subtable:=Load_GL_EXT_color_subtable;
if SGIsSuppored_GL_EXT_color_subtable then
	begin
	SGLog.Sourse('GL_EXT_color_subtable');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_color_subtable';
	end;
SGIsSuppored_GL_EXT_compiled_vertex_array:=Load_GL_EXT_compiled_vertex_array;
if SGIsSuppored_GL_EXT_compiled_vertex_array then
	begin
	SGLog.Sourse('GL_EXT_compiled_vertex_array');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_compiled_vertex_array';
	end;
SGIsSuppored_GL_EXT_convolution:=Load_GL_EXT_convolution;
if SGIsSuppored_GL_EXT_convolution then
	begin
	SGLog.Sourse('GL_EXT_convolution');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_convolution';
	end;
SGIsSuppored_GL_EXT_fog_coord:=Load_GL_EXT_fog_coord;
if SGIsSuppored_GL_EXT_fog_coord then
	begin
	SGLog.Sourse('GL_EXT_fog_coord');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_fog_coord';
	end;
SGIsSuppored_GL_EXT_histogram:=Load_GL_EXT_histogram;
if SGIsSuppored_GL_EXT_histogram then
	begin
	SGLog.Sourse('GL_EXT_histogram');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_histogram';
	end;
SGIsSuppored_GL_EXT_multi_draw_arrays:=Load_GL_EXT_multi_draw_arrays;
if SGIsSuppored_GL_EXT_multi_draw_arrays then
	begin
	SGLog.Sourse('GL_EXT_multi_draw_arrays');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_multi_draw_arrays';
	end;
SGIsSuppored_GL_EXT_packed_depth_stencil:=Load_GL_EXT_packed_depth_stencil;
if SGIsSuppored_GL_EXT_packed_depth_stencil then
	begin
	SGLog.Sourse('GL_EXT_packed_depth_stencil');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_packed_depth_stencil';
	end;
SGIsSuppored_GL_EXT_packed_pixels:=Load_GL_EXT_packed_pixels;
if SGIsSuppored_GL_EXT_packed_pixels then
	begin
	SGLog.Sourse('GL_EXT_packed_pixels');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_packed_pixels';
	end;
SGIsSuppored_GL_EXT_paletted_texture:=Load_GL_EXT_paletted_texture;
if SGIsSuppored_GL_EXT_paletted_texture then
	begin
	SGLog.Sourse('GL_EXT_paletted_texture');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_paletted_texture';
	end;
SGIsSuppored_GL_EXT_point_parameters:=Load_GL_EXT_point_parameters;
if SGIsSuppored_GL_EXT_point_parameters then
	begin
	SGLog.Sourse('GL_EXT_point_parameters');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_point_parameters';
	end;
SGIsSuppored_GL_EXT_polygon_offset:=Load_GL_EXT_polygon_offset;
if SGIsSuppored_GL_EXT_polygon_offset then
	begin
	SGLog.Sourse('GL_EXT_polygon_offset');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_polygon_offset';
	end;
SGIsSuppored_GL_EXT_secondary_color:=Load_GL_EXT_secondary_color;
if SGIsSuppored_GL_EXT_secondary_color then
	begin
	SGLog.Sourse('GL_EXT_secondary_color');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_secondary_color';
	end;
SGIsSuppored_GL_EXT_separate_specular_color:=Load_GL_EXT_separate_specular_color;
if SGIsSuppored_GL_EXT_separate_specular_color then
	begin
	SGLog.Sourse('GL_EXT_separate_specular_color');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_separate_specular_color';
	end;
SGIsSuppored_GL_EXT_shadow_funcs:=Load_GL_EXT_shadow_funcs;
if SGIsSuppored_GL_EXT_shadow_funcs then
	begin
	SGLog.Sourse('GL_EXT_shadow_funcs');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_shadow_funcs';
	end;
SGIsSuppored_GL_EXT_shared_texture_palette:=Load_GL_EXT_shared_texture_palette;
if SGIsSuppored_GL_EXT_shared_texture_palette then
	begin
	SGLog.Sourse('GL_EXT_shared_texture_palette');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_shared_texture_palette';
	end;
SGIsSuppored_GL_EXT_stencil_two_side:=Load_GL_EXT_stencil_two_side;
if SGIsSuppored_GL_EXT_stencil_two_side then
	begin
	SGLog.Sourse('GL_EXT_stencil_two_side');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_stencil_two_side';
	end;
SGIsSuppored_GL_EXT_stencil_wrap:=Load_GL_EXT_stencil_wrap;
if SGIsSuppored_GL_EXT_stencil_wrap then
	begin
	SGLog.Sourse('GL_EXT_stencil_wrap');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_stencil_wrap';
	end;
SGIsSuppored_GL_EXT_subtexture:=Load_GL_EXT_subtexture;
if SGIsSuppored_GL_EXT_subtexture then
	begin
	SGLog.Sourse('GL_EXT_subtexture');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_subtexture';
	end;
SGIsSuppored_GL_EXT_texture3D:=Load_GL_EXT_texture3D;
if SGIsSuppored_GL_EXT_texture3D then
	begin
	SGLog.Sourse('GL_EXT_texture3D');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_texture3D';
	end;
SGIsSuppored_GL_EXT_texture_compression_s3tc:=Load_GL_EXT_texture_compression_s3tc;
if SGIsSuppored_GL_EXT_texture_compression_s3tc then
	begin
	SGLog.Sourse('GL_EXT_texture_compression_s3tc');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_texture_compression_s3tc';
	end;
SGIsSuppored_GL_EXT_texture_env_add:=Load_GL_EXT_texture_env_add;
if SGIsSuppored_GL_EXT_texture_env_add then
	begin
	SGLog.Sourse('GL_EXT_texture_env_add');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_texture_env_add';
	end;
SGIsSuppored_GL_EXT_texture_env_combine:=Load_GL_EXT_texture_env_combine;
if SGIsSuppored_GL_EXT_texture_env_combine then
	begin
	SGLog.Sourse('GL_EXT_texture_env_combine');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_texture_env_combine';
	end;
SGIsSuppored_GL_EXT_texture_env_dot3:=Load_GL_EXT_texture_env_dot3;
if SGIsSuppored_GL_EXT_texture_env_dot3 then
	begin
	SGLog.Sourse('GL_EXT_texture_env_dot3');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_texture_env_dot3';
	end;
SGIsSuppored_GL_EXT_texture_filter_anisotropic:=Load_GL_EXT_texture_filter_anisotropic;
if SGIsSuppored_GL_EXT_texture_filter_anisotropic then
	begin
	SGLog.Sourse('GL_EXT_texture_filter_anisotropic');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_texture_filter_anisotropic';
	end;
SGIsSuppored_GL_EXT_texture_lod_bias:=Load_GL_EXT_texture_lod_bias;
if SGIsSuppored_GL_EXT_texture_lod_bias then
	begin
	SGLog.Sourse('GL_EXT_texture_lod_bias');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_texture_lod_bias';
	end;
SGIsSuppored_GL_EXT_texture_object:=Load_GL_EXT_texture_object;
if SGIsSuppored_GL_EXT_texture_object then
	begin
	SGLog.Sourse('GL_EXT_texture_object');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_texture_object';
	end;
SGIsSuppored_GL_EXT_vertex_array:=Load_GL_EXT_vertex_array;
if SGIsSuppored_GL_EXT_vertex_array then
	begin
	SGLog.Sourse('GL_EXT_vertex_array');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_vertex_array';
	end;
SGIsSuppored_GL_EXT_vertex_shader:=Load_GL_EXT_vertex_shader;
if SGIsSuppored_GL_EXT_vertex_shader then
	begin
	SGLog.Sourse('GL_EXT_vertex_shader');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_vertex_shader';
	end;
SGIsSuppored_GL_EXT_vertex_weighting:=Load_GL_EXT_vertex_weighting;
if SGIsSuppored_GL_EXT_vertex_weighting then
	begin
	SGLog.Sourse('GL_EXT_vertex_weighting');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_vertex_weighting';
	end;
SGIsSuppored_GL_HP_occlusion_test:=Load_GL_HP_occlusion_test;
if SGIsSuppored_GL_HP_occlusion_test then
	begin
	SGLog.Sourse('GL_HP_occlusion_test');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_HP_occlusion_test';
	end;
SGIsSuppored_GL_NV_blend_square:=Load_GL_NV_blend_square;
if SGIsSuppored_GL_NV_blend_square then
	begin
	SGLog.Sourse('GL_NV_blend_square');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_blend_square';
	end;
SGIsSuppored_GL_NV_copy_depth_to_color:=Load_GL_NV_copy_depth_to_color;
if SGIsSuppored_GL_NV_copy_depth_to_color then
	begin
	SGLog.Sourse('GL_NV_copy_depth_to_color');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_copy_depth_to_color';
	end;
SGIsSuppored_GL_NV_depth_clamp:=Load_GL_NV_depth_clamp;
if SGIsSuppored_GL_NV_depth_clamp then
	begin
	SGLog.Sourse('GL_NV_depth_clamp');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_depth_clamp';
	end;
SGIsSuppored_GL_NV_evaluators:=Load_GL_NV_evaluators;
if SGIsSuppored_GL_NV_evaluators then
	begin
	SGLog.Sourse('GL_NV_evaluators');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_evaluators';
	end;
SGIsSuppored_GL_NV_fence:=Load_GL_NV_fence;
if SGIsSuppored_GL_NV_fence then
	begin
	SGLog.Sourse('GL_NV_fence');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_fence';
	end;
SGIsSuppored_GL_NV_fog_distance:=Load_GL_NV_fog_distance;
if SGIsSuppored_GL_NV_fog_distance then
	begin
	SGLog.Sourse('GL_NV_fog_distance');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_fog_distance';
	end;
SGIsSuppored_GL_NV_light_max_exponent:=Load_GL_NV_light_max_exponent;
if SGIsSuppored_GL_NV_light_max_exponent then
	begin
	SGLog.Sourse('GL_NV_light_max_exponent');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_light_max_exponent';
	end;
SGIsSuppored_GL_NV_multisample_filter_hint:=Load_GL_NV_multisample_filter_hint;
if SGIsSuppored_GL_NV_multisample_filter_hint then
	begin
	SGLog.Sourse('GL_NV_multisample_filter_hint');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_multisample_filter_hint';
	end;
SGIsSuppored_GL_NV_occlusion_query:=Load_GL_NV_occlusion_query;
if SGIsSuppored_GL_NV_occlusion_query then
	begin
	SGLog.Sourse('GL_NV_occlusion_query');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_occlusion_query';
	end;
SGIsSuppored_GL_NV_packed_depth_stencil:=Load_GL_NV_packed_depth_stencil;
if SGIsSuppored_GL_NV_packed_depth_stencil then
	begin
	SGLog.Sourse('GL_NV_packed_depth_stencil');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_packed_depth_stencil';
	end;
SGIsSuppored_GL_NV_point_sprite:=Load_GL_NV_point_sprite;
if SGIsSuppored_GL_NV_point_sprite then
	begin
	SGLog.Sourse('GL_NV_point_sprite');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_point_sprite';
	end;
SGIsSuppored_GL_NV_register_combiners:=Load_GL_NV_register_combiners;
if SGIsSuppored_GL_NV_register_combiners then
	begin
	SGLog.Sourse('GL_NV_register_combiners');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_register_combiners';
	end;
SGIsSuppored_GL_NV_register_combiners2:=Load_GL_NV_register_combiners2;
if SGIsSuppored_GL_NV_register_combiners2 then
	begin
	SGLog.Sourse('GL_NV_register_combiners2');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_register_combiners2';
	end;
SGIsSuppored_GL_NV_texgen_emboss:=Load_GL_NV_texgen_emboss;
if SGIsSuppored_GL_NV_texgen_emboss then
	begin
	SGLog.Sourse('GL_NV_texgen_emboss');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_texgen_emboss';
	end;
SGIsSuppored_GL_NV_texgen_reflection:=Load_GL_NV_texgen_reflection;
if SGIsSuppored_GL_NV_texgen_reflection then
	begin
	SGLog.Sourse('GL_NV_texgen_reflection');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_texgen_reflection';
	end;
SGIsSuppored_GL_NV_texture_compression_vtc:=Load_GL_NV_texture_compression_vtc;
if SGIsSuppored_GL_NV_texture_compression_vtc then
	begin
	SGLog.Sourse('GL_NV_texture_compression_vtc');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_texture_compression_vtc';
	end;
SGIsSuppored_GL_NV_texture_env_combine4:=Load_GL_NV_texture_env_combine4;
if SGIsSuppored_GL_NV_texture_env_combine4 then
	begin
	SGLog.Sourse('GL_NV_texture_env_combine4');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_texture_env_combine4';
	end;
SGIsSuppored_GL_NV_texture_rectangle:=Load_GL_NV_texture_rectangle;
if SGIsSuppored_GL_NV_texture_rectangle then
	begin
	SGLog.Sourse('GL_NV_texture_rectangle');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_texture_rectangle';
	end;
SGIsSuppored_GL_NV_texture_shader:=Load_GL_NV_texture_shader;
if SGIsSuppored_GL_NV_texture_shader then
	begin
	SGLog.Sourse('GL_NV_texture_shader');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_texture_shader';
	end;
SGIsSuppored_GL_NV_texture_shader2:=Load_GL_NV_texture_shader2;
if SGIsSuppored_GL_NV_texture_shader2 then
	begin
	SGLog.Sourse('GL_NV_texture_shader2');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_texture_shader2';
	end;
SGIsSuppored_GL_NV_texture_shader3:=Load_GL_NV_texture_shader3;
if SGIsSuppored_GL_NV_texture_shader3 then
	begin
	SGLog.Sourse('GL_NV_texture_shader3');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_texture_shader3';
	end;
SGIsSuppored_GL_NV_vertex_array_range:=Load_GL_NV_vertex_array_range;
if SGIsSuppored_GL_NV_vertex_array_range then
	begin
	SGLog.Sourse('GL_NV_vertex_array_range');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_vertex_array_range';
	end;
SGIsSuppored_GL_NV_vertex_array_range2:=Load_GL_NV_vertex_array_range2;
if SGIsSuppored_GL_NV_vertex_array_range2 then
	begin
	SGLog.Sourse('GL_NV_vertex_array_range2');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_vertex_array_range2';
	end;
SGIsSuppored_GL_NV_vertex_program:=Load_GL_NV_vertex_program;
if SGIsSuppored_GL_NV_vertex_program then
	begin
	SGLog.Sourse('GL_NV_vertex_program');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_vertex_program';
	end;
SGIsSuppored_GL_NV_vertex_program1_1:=Load_GL_NV_vertex_program1_1;
if SGIsSuppored_GL_NV_vertex_program1_1 then
	begin
	SGLog.Sourse('GL_NV_vertex_program1_1');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_vertex_program1_1';
	end;
SGIsSuppored_GL_ATI_element_array:=Load_GL_ATI_element_array;
if SGIsSuppored_GL_ATI_element_array then
	begin
	SGLog.Sourse('GL_ATI_element_array');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ATI_element_array';
	end;
SGIsSuppored_GL_ATI_envmap_bumpmap:=Load_GL_ATI_envmap_bumpmap;
if SGIsSuppored_GL_ATI_envmap_bumpmap then
	begin
	SGLog.Sourse('GL_ATI_envmap_bumpmap');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ATI_envmap_bumpmap';
	end;
SGIsSuppored_GL_ATI_fragment_shader:=Load_GL_ATI_fragment_shader;
if SGIsSuppored_GL_ATI_fragment_shader then
	begin
	SGLog.Sourse('GL_ATI_fragment_shader');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ATI_fragment_shader';
	end;
SGIsSuppored_GL_ATI_pn_triangles:=Load_GL_ATI_pn_triangles;
if SGIsSuppored_GL_ATI_pn_triangles then
	begin
	SGLog.Sourse('GL_ATI_pn_triangles');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ATI_pn_triangles';
	end;
SGIsSuppored_GL_ATI_texture_mirror_once:=Load_GL_ATI_texture_mirror_once;
if SGIsSuppored_GL_ATI_texture_mirror_once then
	begin
	SGLog.Sourse('GL_ATI_texture_mirror_once');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ATI_texture_mirror_once';
	end;
SGIsSuppored_GL_ATI_vertex_array_object:=Load_GL_ATI_vertex_array_object;
if SGIsSuppored_GL_ATI_vertex_array_object then
	begin
	SGLog.Sourse('GL_ATI_vertex_array_object');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ATI_vertex_array_object';
	end;
SGIsSuppored_GL_ATI_vertex_streams:=Load_GL_ATI_vertex_streams;
if SGIsSuppored_GL_ATI_vertex_streams then
	begin
	SGLog.Sourse('GL_ATI_vertex_streams');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ATI_vertex_streams';
	end;
SGIsSuppored_WGL_I3D_image_buffer:=Load_WGL_I3D_image_buffer;
if SGIsSuppored_WGL_I3D_image_buffer then
	begin
	SGLog.Sourse('WGL_I3D_image_buffer');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_I3D_image_buffer';
	end;
SGIsSuppored_WGL_I3D_swap_frame_lock:=Load_WGL_I3D_swap_frame_lock;
if SGIsSuppored_WGL_I3D_swap_frame_lock then
	begin
	SGLog.Sourse('WGL_I3D_swap_frame_lock');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_I3D_swap_frame_lock';
	end;
SGIsSuppored_WGL_I3D_swap_frame_usage:=Load_WGL_I3D_swap_frame_usage;
if SGIsSuppored_WGL_I3D_swap_frame_usage then
	begin
	SGLog.Sourse('WGL_I3D_swap_frame_usage');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_I3D_swap_frame_usage';
	end;
SGIsSuppored_GL_3DFX_texture_compression_FXT1:=Load_GL_3DFX_texture_compression_FXT1;
if SGIsSuppored_GL_3DFX_texture_compression_FXT1 then
	begin
	SGLog.Sourse('GL_3DFX_texture_compression_FXT1');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_3DFX_texture_compression_FXT1';
	end;
SGIsSuppored_GL_IBM_cull_vertex:=Load_GL_IBM_cull_vertex;
if SGIsSuppored_GL_IBM_cull_vertex then
	begin
	SGLog.Sourse('GL_IBM_cull_vertex');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_IBM_cull_vertex';
	end;
SGIsSuppored_GL_IBM_multimode_draw_arrays:=Load_GL_IBM_multimode_draw_arrays;
if SGIsSuppored_GL_IBM_multimode_draw_arrays then
	begin
	SGLog.Sourse('GL_IBM_multimode_draw_arrays');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_IBM_multimode_draw_arrays';
	end;
SGIsSuppored_GL_IBM_raster_pos_clip:=Load_GL_IBM_raster_pos_clip;
if SGIsSuppored_GL_IBM_raster_pos_clip then
	begin
	SGLog.Sourse('GL_IBM_raster_pos_clip');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_IBM_raster_pos_clip';
	end;
SGIsSuppored_GL_IBM_texture_mirrored_repeat:=Load_GL_IBM_texture_mirrored_repeat;
if SGIsSuppored_GL_IBM_texture_mirrored_repeat then
	begin
	SGLog.Sourse('GL_IBM_texture_mirrored_repeat');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_IBM_texture_mirrored_repeat';
	end;
SGIsSuppored_GL_IBM_vertex_array_lists:=Load_GL_IBM_vertex_array_lists;
if SGIsSuppored_GL_IBM_vertex_array_lists then
	begin
	SGLog.Sourse('GL_IBM_vertex_array_lists');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_IBM_vertex_array_lists';
	end;
SGIsSuppored_GL_MESA_resize_buffers:=Load_GL_MESA_resize_buffers;
if SGIsSuppored_GL_MESA_resize_buffers then
	begin
	SGLog.Sourse('GL_MESA_resize_buffers');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_MESA_resize_buffers';
	end;
SGIsSuppored_GL_MESA_window_pos:=Load_GL_MESA_window_pos;
if SGIsSuppored_GL_MESA_window_pos then
	begin
	SGLog.Sourse('GL_MESA_window_pos');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_MESA_window_pos';
	end;
SGIsSuppored_GL_OML_interlace:=Load_GL_OML_interlace;
if SGIsSuppored_GL_OML_interlace then
	begin
	SGLog.Sourse('GL_OML_interlace');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_OML_interlace';
	end;
SGIsSuppored_GL_OML_resample:=Load_GL_OML_resample;
if SGIsSuppored_GL_OML_resample then
	begin
	SGLog.Sourse('GL_OML_resample');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_OML_resample';
	end;
SGIsSuppored_GL_OML_subsample:=Load_GL_OML_subsample;
if SGIsSuppored_GL_OML_subsample then
	begin
	SGLog.Sourse('GL_OML_subsample');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_OML_subsample';
	end;
SGIsSuppored_GL_SGIS_generate_mipmap:=Load_GL_SGIS_generate_mipmap;
if SGIsSuppored_GL_SGIS_generate_mipmap then
	begin
	SGLog.Sourse('GL_SGIS_generate_mipmap');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_SGIS_generate_mipmap';
	end;
SGIsSuppored_GL_SGIS_multisample:=Load_GL_SGIS_multisample;
if SGIsSuppored_GL_SGIS_multisample then
	begin
	SGLog.Sourse('GL_SGIS_multisample');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_SGIS_multisample';
	end;
SGIsSuppored_GL_SGIS_pixel_texture:=Load_GL_SGIS_pixel_texture;
if SGIsSuppored_GL_SGIS_pixel_texture then
	begin
	SGLog.Sourse('GL_SGIS_pixel_texture');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_SGIS_pixel_texture';
	end;
SGIsSuppored_GL_SGIS_texture_border_clamp:=Load_GL_SGIS_texture_border_clamp;
if SGIsSuppored_GL_SGIS_texture_border_clamp then
	begin
	SGLog.Sourse('GL_SGIS_texture_border_clamp');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_SGIS_texture_border_clamp';
	end;
SGIsSuppored_GL_SGIS_texture_color_mask:=Load_GL_SGIS_texture_color_mask;
if SGIsSuppored_GL_SGIS_texture_color_mask then
	begin
	SGLog.Sourse('GL_SGIS_texture_color_mask');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_SGIS_texture_color_mask';
	end;
SGIsSuppored_GL_SGIS_texture_edge_clamp:=Load_GL_SGIS_texture_edge_clamp;
if SGIsSuppored_GL_SGIS_texture_edge_clamp then
	begin
	SGLog.Sourse('GL_SGIS_texture_edge_clamp');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_SGIS_texture_edge_clamp';
	end;
SGIsSuppored_GL_SGIS_texture_lod:=Load_GL_SGIS_texture_lod;
if SGIsSuppored_GL_SGIS_texture_lod then
	begin
	SGLog.Sourse('GL_SGIS_texture_lod');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_SGIS_texture_lod';
	end;
SGIsSuppored_GL_SGIS_depth_texture:=Load_GL_SGIS_depth_texture;
if SGIsSuppored_GL_SGIS_depth_texture then
	begin
	SGLog.Sourse('GL_SGIS_depth_texture');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_SGIS_depth_texture';
	end;
SGIsSuppored_GL_SGIX_fog_offset:=Load_GL_SGIX_fog_offset;
if SGIsSuppored_GL_SGIX_fog_offset then
	begin
	SGLog.Sourse('GL_SGIX_fog_offset');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_SGIX_fog_offset';
	end;
SGIsSuppored_GL_SGIX_interlace:=Load_GL_SGIX_interlace;
if SGIsSuppored_GL_SGIX_interlace then
	begin
	SGLog.Sourse('GL_SGIX_interlace');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_SGIX_interlace';
	end;
SGIsSuppored_GL_SGIX_shadow_ambient:=Load_GL_SGIX_shadow_ambient;
if SGIsSuppored_GL_SGIX_shadow_ambient then
	begin
	SGLog.Sourse('GL_SGIX_shadow_ambient');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_SGIX_shadow_ambient';
	end;
SGIsSuppored_GL_SGI_color_matrix:=Load_GL_SGI_color_matrix;
if SGIsSuppored_GL_SGI_color_matrix then
	begin
	SGLog.Sourse('GL_SGI_color_matrix');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_SGI_color_matrix';
	end;
SGIsSuppored_GL_SGI_color_table:=Load_GL_SGI_color_table;
if SGIsSuppored_GL_SGI_color_table then
	begin
	SGLog.Sourse('GL_SGI_color_table');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_SGI_color_table';
	end;
SGIsSuppored_GL_SGI_texture_color_table:=Load_GL_SGI_texture_color_table;
if SGIsSuppored_GL_SGI_texture_color_table then
	begin
	SGLog.Sourse('GL_SGI_texture_color_table');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_SGI_texture_color_table';
	end;
SGIsSuppored_GL_SUN_vertex:=Load_GL_SUN_vertex;
if SGIsSuppored_GL_SUN_vertex then
	begin
	SGLog.Sourse('GL_SUN_vertex');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_SUN_vertex';
	end;
SGIsSuppored_GL_ARB_fragment_program:=Load_GL_ARB_fragment_program;
if SGIsSuppored_GL_ARB_fragment_program then
	begin
	SGLog.Sourse('GL_ARB_fragment_program');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_fragment_program';
	end;
SGIsSuppored_GL_ATI_text_fragment_shader:=Load_GL_ATI_text_fragment_shader;
if SGIsSuppored_GL_ATI_text_fragment_shader then
	begin
	SGLog.Sourse('GL_ATI_text_fragment_shader');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ATI_text_fragment_shader';
	end;
SGIsSuppored_GL_ARB_vertex_buffer_object:=Load_GL_ARB_vertex_buffer_object;
if SGIsSuppored_GL_ARB_vertex_buffer_object then
	begin
	SGLog.Sourse('GL_ARB_vertex_buffer_object');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_vertex_buffer_object';
	end;
SGIsSuppored_GL_APPLE_client_storage:=Load_GL_APPLE_client_storage;
if SGIsSuppored_GL_APPLE_client_storage then
	begin
	SGLog.Sourse('GL_APPLE_client_storage');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_APPLE_client_storage';
	end;
SGIsSuppored_GL_APPLE_element_array:=Load_GL_APPLE_element_array;
if SGIsSuppored_GL_APPLE_element_array then
	begin
	SGLog.Sourse('GL_APPLE_element_array');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_APPLE_element_array';
	end;
SGIsSuppored_GL_APPLE_fence:=Load_GL_APPLE_fence;
if SGIsSuppored_GL_APPLE_fence then
	begin
	SGLog.Sourse('GL_APPLE_fence');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_APPLE_fence';
	end;
SGIsSuppored_GL_APPLE_vertex_array_object:=Load_GL_APPLE_vertex_array_object;
if SGIsSuppored_GL_APPLE_vertex_array_object then
	begin
	SGLog.Sourse('GL_APPLE_vertex_array_object');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_APPLE_vertex_array_object';
	end;
SGIsSuppored_GL_APPLE_vertex_array_range:=Load_GL_APPLE_vertex_array_range;
if SGIsSuppored_GL_APPLE_vertex_array_range then
	begin
	SGLog.Sourse('GL_APPLE_vertex_array_range');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_APPLE_vertex_array_range';
	end;
SGIsSuppored_WGL_ARB_pixel_format:=Load_WGL_ARB_pixel_format;
if SGIsSuppored_WGL_ARB_pixel_format then
	begin
	SGLog.Sourse('WGL_ARB_pixel_format');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_ARB_pixel_format';
	end;
SGIsSuppored_WGL_ARB_make_current_read:=Load_WGL_ARB_make_current_read;
if SGIsSuppored_WGL_ARB_make_current_read then
	begin
	SGLog.Sourse('WGL_ARB_make_current_read');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_ARB_make_current_read';
	end;
SGIsSuppored_WGL_ARB_pbuffer:=Load_WGL_ARB_pbuffer;
if SGIsSuppored_WGL_ARB_pbuffer then
	begin
	SGLog.Sourse('WGL_ARB_pbuffer');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_ARB_pbuffer';
	end;
SGIsSuppored_WGL_EXT_swap_control:=Load_WGL_EXT_swap_control;
if SGIsSuppored_WGL_EXT_swap_control then
	begin
	SGLog.Sourse('WGL_EXT_swap_control');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_EXT_swap_control';
	end;
SGIsSuppored_WGL_ARB_render_texture:=Load_WGL_ARB_render_texture;
if SGIsSuppored_WGL_ARB_render_texture then
	begin
	SGLog.Sourse('WGL_ARB_render_texture');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_ARB_render_texture';
	end;
SGIsSuppored_WGL_EXT_extensions_string:=Load_WGL_EXT_extensions_string;
if SGIsSuppored_WGL_EXT_extensions_string then
	begin
	SGLog.Sourse('WGL_EXT_extensions_string');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_EXT_extensions_string';
	end;
SGIsSuppored_WGL_EXT_make_current_read:=Load_WGL_EXT_make_current_read;
if SGIsSuppored_WGL_EXT_make_current_read then
	begin
	SGLog.Sourse('WGL_EXT_make_current_read');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_EXT_make_current_read';
	end;
SGIsSuppored_WGL_EXT_pbuffer:=Load_WGL_EXT_pbuffer;
if SGIsSuppored_WGL_EXT_pbuffer then
	begin
	SGLog.Sourse('WGL_EXT_pbuffer');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_EXT_pbuffer';
	end;
SGIsSuppored_WGL_EXT_pixel_format:=Load_WGL_EXT_pixel_format;
if SGIsSuppored_WGL_EXT_pixel_format then
	begin
	SGLog.Sourse('WGL_EXT_pixel_format');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_EXT_pixel_format';
	end;
SGIsSuppored_WGL_I3D_digital_video_control:=Load_WGL_I3D_digital_video_control;
if SGIsSuppored_WGL_I3D_digital_video_control then
	begin
	SGLog.Sourse('WGL_I3D_digital_video_control');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_I3D_digital_video_control';
	end;
SGIsSuppored_WGL_I3D_gamma:=Load_WGL_I3D_gamma;
if SGIsSuppored_WGL_I3D_gamma then
	begin
	SGLog.Sourse('WGL_I3D_gamma');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_I3D_gamma';
	end;
SGIsSuppored_WGL_I3D_genlock:=Load_WGL_I3D_genlock;
if SGIsSuppored_WGL_I3D_genlock then
	begin
	SGLog.Sourse('WGL_I3D_genlock');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_I3D_genlock';
	end;
SGIsSuppored_GL_ARB_matrix_palette:=Load_GL_ARB_matrix_palette;
if SGIsSuppored_GL_ARB_matrix_palette then
	begin
	SGLog.Sourse('GL_ARB_matrix_palette');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_matrix_palette';
	end;
SGIsSuppored_GL_NV_element_array:=Load_GL_NV_element_array;
if SGIsSuppored_GL_NV_element_array then
	begin
	SGLog.Sourse('GL_NV_element_array');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_element_array';
	end;
SGIsSuppored_GL_NV_float_buffer:=Load_GL_NV_float_buffer;
if SGIsSuppored_GL_NV_float_buffer then
	begin
	SGLog.Sourse('GL_NV_float_buffer');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_float_buffer';
	end;
SGIsSuppored_GL_NV_fragment_program:=Load_GL_NV_fragment_program;
if SGIsSuppored_GL_NV_fragment_program then
	begin
	SGLog.Sourse('GL_NV_fragment_program');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_fragment_program';
	end;
SGIsSuppored_GL_NV_primitive_restart:=Load_GL_NV_primitive_restart;
if SGIsSuppored_GL_NV_primitive_restart then
	begin
	SGLog.Sourse('GL_NV_primitive_restart');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_primitive_restart';
	end;
SGIsSuppored_GL_NV_vertex_program2:=Load_GL_NV_vertex_program2;
if SGIsSuppored_GL_NV_vertex_program2 then
	begin
	SGLog.Sourse('GL_NV_vertex_program2');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_vertex_program2';
	end;
SGIsSuppored_WGL_NV_render_texture_rectangle:=Load_WGL_NV_render_texture_rectangle;
if SGIsSuppored_WGL_NV_render_texture_rectangle then
	begin
	SGLog.Sourse('WGL_NV_render_texture_rectangle');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_NV_render_texture_rectangle';
	end;
SGIsSuppored_GL_NV_pixel_data_range:=Load_GL_NV_pixel_data_range;
if SGIsSuppored_GL_NV_pixel_data_range then
	begin
	SGLog.Sourse('GL_NV_pixel_data_range');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_pixel_data_range';
	end;
SGIsSuppored_GL_EXT_texture_rectangle:=Load_GL_EXT_texture_rectangle;
if SGIsSuppored_GL_EXT_texture_rectangle then
	begin
	SGLog.Sourse('GL_EXT_texture_rectangle');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_texture_rectangle';
	end;
SGIsSuppored_GL_S3_s3tc:=Load_GL_S3_s3tc;
if SGIsSuppored_GL_S3_s3tc then
	begin
	SGLog.Sourse('GL_S3_s3tc');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_S3_s3tc';
	end;
SGIsSuppored_GL_ATI_draw_buffers:=Load_GL_ATI_draw_buffers;
if SGIsSuppored_GL_ATI_draw_buffers then
	begin
	SGLog.Sourse('GL_ATI_draw_buffers');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ATI_draw_buffers';
	end;
SGIsSuppored_WGL_ATI_pixel_format_float:=Load_WGL_ATI_pixel_format_float;
if SGIsSuppored_WGL_ATI_pixel_format_float then
	begin
	SGLog.Sourse('WGL_ATI_pixel_format_float');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='WGL_ATI_pixel_format_float';
	end;
SGIsSuppored_GL_ATI_texture_env_combine3:=Load_GL_ATI_texture_env_combine3;
if SGIsSuppored_GL_ATI_texture_env_combine3 then
	begin
	SGLog.Sourse('GL_ATI_texture_env_combine3');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ATI_texture_env_combine3';
	end;
SGIsSuppored_GL_ATI_texture_float:=Load_GL_ATI_texture_float;
if SGIsSuppored_GL_ATI_texture_float then
	begin
	SGLog.Sourse('GL_ATI_texture_float');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ATI_texture_float';
	end;
SGIsSuppored_GL_NV_texture_expand_normal:=Load_GL_NV_texture_expand_normal;
if SGIsSuppored_GL_NV_texture_expand_normal then
	begin
	SGLog.Sourse('GL_NV_texture_expand_normal');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_texture_expand_normal';
	end;
SGIsSuppored_GL_NV_half_float:=Load_GL_NV_half_float;
if SGIsSuppored_GL_NV_half_float then
	begin
	SGLog.Sourse('GL_NV_half_float');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_half_float';
	end;
SGIsSuppored_GL_ATI_map_object_buffer:=Load_GL_ATI_map_object_buffer;
if SGIsSuppored_GL_ATI_map_object_buffer then
	begin
	SGLog.Sourse('GL_ATI_map_object_buffer');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ATI_map_object_buffer';
	end;
SGIsSuppored_GL_ATI_separate_stencil:=Load_GL_ATI_separate_stencil;
if SGIsSuppored_GL_ATI_separate_stencil then
	begin
	SGLog.Sourse('GL_ATI_separate_stencil');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ATI_separate_stencil';
	end;
SGIsSuppored_GL_ATI_vertex_attrib_array_object:=Load_GL_ATI_vertex_attrib_array_object;
if SGIsSuppored_GL_ATI_vertex_attrib_array_object then
	begin
	SGLog.Sourse('GL_ATI_vertex_attrib_array_object');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ATI_vertex_attrib_array_object';
	end;
SGIsSuppored_GL_ARB_occlusion_query:=Load_GL_ARB_occlusion_query;
if SGIsSuppored_GL_ARB_occlusion_query then
	begin
	SGLog.Sourse('GL_ARB_occlusion_query');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_occlusion_query';
	end;
SGIsSuppored_GL_ARB_shader_objects:=Load_GL_ARB_shader_objects;
if SGIsSuppored_GL_ARB_shader_objects then
	begin
	SGLog.Sourse('GL_ARB_shader_objects');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_shader_objects';
	end;
SGIsSuppored_GL_ARB_vertex_shader:=Load_GL_ARB_vertex_shader;
if SGIsSuppored_GL_ARB_vertex_shader then
	begin
	SGLog.Sourse('GL_ARB_vertex_shader');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_vertex_shader';
	end;
SGIsSuppored_GL_ARB_fragment_shader:=Load_GL_ARB_fragment_shader;
if SGIsSuppored_GL_ARB_fragment_shader then
	begin
	SGLog.Sourse('GL_ARB_fragment_shader');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_fragment_shader';
	end;
SGIsSuppored_GL_ARB_shading_language_100:=Load_GL_ARB_shading_language_100;
if SGIsSuppored_GL_ARB_shading_language_100 then
	begin
	SGLog.Sourse('GL_ARB_shading_language_100');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_shading_language_100';
	end;
SGIsSuppored_GL_ARB_texture_non_power_of_two:=Load_GL_ARB_texture_non_power_of_two;
if SGIsSuppored_GL_ARB_texture_non_power_of_two then
	begin
	SGLog.Sourse('GL_ARB_texture_non_power_of_two');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_texture_non_power_of_two';
	end;
SGIsSuppored_GL_ARB_point_sprite:=Load_GL_ARB_point_sprite;
if SGIsSuppored_GL_ARB_point_sprite then
	begin
	SGLog.Sourse('GL_ARB_point_sprite');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_point_sprite';
	end;
SGIsSuppored_GL_EXT_depth_bounds_test:=Load_GL_EXT_depth_bounds_test;
if SGIsSuppored_GL_EXT_depth_bounds_test then
	begin
	SGLog.Sourse('GL_EXT_depth_bounds_test');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_depth_bounds_test';
	end;
SGIsSuppored_GL_EXT_texture_mirror_clamp:=Load_GL_EXT_texture_mirror_clamp;
if SGIsSuppored_GL_EXT_texture_mirror_clamp then
	begin
	SGLog.Sourse('GL_EXT_texture_mirror_clamp');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_texture_mirror_clamp';
	end;
SGIsSuppored_GL_EXT_blend_equation_separate:=Load_GL_EXT_blend_equation_separate;
if SGIsSuppored_GL_EXT_blend_equation_separate then
	begin
	SGLog.Sourse('GL_EXT_blend_equation_separate');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_blend_equation_separate';
	end;
SGIsSuppored_GL_MESA_pack_invert:=Load_GL_MESA_pack_invert;
if SGIsSuppored_GL_MESA_pack_invert then
	begin
	SGLog.Sourse('GL_MESA_pack_invert');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_MESA_pack_invert';
	end;
SGIsSuppored_GL_MESA_ycbcr_texture:=Load_GL_MESA_ycbcr_texture;
if SGIsSuppored_GL_MESA_ycbcr_texture then
	begin
	SGLog.Sourse('GL_MESA_ycbcr_texture');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_MESA_ycbcr_texture';
	end;
SGIsSuppored_GL_ARB_fragment_program_shadow:=Load_GL_ARB_fragment_program_shadow;
if SGIsSuppored_GL_ARB_fragment_program_shadow then
	begin
	SGLog.Sourse('GL_ARB_fragment_program_shadow');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_fragment_program_shadow';
	end;
SGIsSuppored_GL_NV_fragment_program_option:=Load_GL_NV_fragment_program_option;
if SGIsSuppored_GL_NV_fragment_program_option then
	begin
	SGLog.Sourse('GL_NV_fragment_program_option');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_fragment_program_option';
	end;
SGIsSuppored_GL_EXT_pixel_buffer_object:=Load_GL_EXT_pixel_buffer_object;
if SGIsSuppored_GL_EXT_pixel_buffer_object then
	begin
	SGLog.Sourse('GL_EXT_pixel_buffer_object');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_pixel_buffer_object';
	end;
SGIsSuppored_GL_NV_fragment_program2:=Load_GL_NV_fragment_program2;
if SGIsSuppored_GL_NV_fragment_program2 then
	begin
	SGLog.Sourse('GL_NV_fragment_program2');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_fragment_program2';
	end;
SGIsSuppored_GL_NV_vertex_program2_option:=Load_GL_NV_vertex_program2_option;
if SGIsSuppored_GL_NV_vertex_program2_option then
	begin
	SGLog.Sourse('GL_NV_vertex_program2_option');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_vertex_program2_option';
	end;
SGIsSuppored_GL_NV_vertex_program3:=Load_GL_NV_vertex_program3;
if SGIsSuppored_GL_NV_vertex_program3 then
	begin
	SGLog.Sourse('GL_NV_vertex_program3');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_NV_vertex_program3';
	end;
SGIsSuppored_GL_ARB_draw_buffers:=Load_GL_ARB_draw_buffers;
if SGIsSuppored_GL_ARB_draw_buffers then
	begin
	SGLog.Sourse('GL_ARB_draw_buffers');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_draw_buffers';
	end;
SGIsSuppored_GL_ARB_texture_rectangle:=Load_GL_ARB_texture_rectangle;
if SGIsSuppored_GL_ARB_texture_rectangle then
	begin
	SGLog.Sourse('GL_ARB_texture_rectangle');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_texture_rectangle';
	end;
SGIsSuppored_GL_ARB_color_buffer_float:=Load_GL_ARB_color_buffer_float;
if SGIsSuppored_GL_ARB_color_buffer_float then
	begin
	SGLog.Sourse('GL_ARB_color_buffer_float');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_color_buffer_float';
	end;
SGIsSuppored_GL_ARB_half_float_pixel:=Load_GL_ARB_half_float_pixel;
if SGIsSuppored_GL_ARB_half_float_pixel then
	begin
	SGLog.Sourse('GL_ARB_half_float_pixel');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_half_float_pixel';
	end;
SGIsSuppored_GL_ARB_texture_float:=Load_GL_ARB_texture_float;
if SGIsSuppored_GL_ARB_texture_float then
	begin
	SGLog.Sourse('GL_ARB_texture_float');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_texture_float';
	end;
SGIsSuppored_GL_EXT_texture_compression_dxt1:=Load_GL_EXT_texture_compression_dxt1;
if SGIsSuppored_GL_EXT_texture_compression_dxt1 then
	begin
	SGLog.Sourse('GL_EXT_texture_compression_dxt1');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_texture_compression_dxt1';
	end;
SGIsSuppored_GL_ARB_pixel_buffer_object:=Load_GL_ARB_pixel_buffer_object;
if SGIsSuppored_GL_ARB_pixel_buffer_object then
	begin
	SGLog.Sourse('GL_ARB_pixel_buffer_object');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_pixel_buffer_object';
	end;
SGIsSuppored_GL_EXT_framebuffer_object:=Load_GL_EXT_framebuffer_object;
if SGIsSuppored_GL_EXT_framebuffer_object then
	begin
	SGLog.Sourse('GL_EXT_framebuffer_object');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_EXT_framebuffer_object';
	end;
SGIsSuppored_GL_ARB_framebuffer_object:=Load_GL_ARB_framebuffer_object;
if SGIsSuppored_GL_ARB_framebuffer_object then
	begin
	SGLog.Sourse('GL_ARB_framebuffer_object');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_framebuffer_object';
	end;
SGIsSuppored_GL_ARB_map_buffer_range:=Load_GL_ARB_map_buffer_range;
if SGIsSuppored_GL_ARB_map_buffer_range then
	begin
	SGLog.Sourse('GL_ARB_map_buffer_range');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_map_buffer_range';
	end;
SGIsSuppored_GL_ARB_vertex_array_object:=Load_GL_ARB_vertex_array_object;
if SGIsSuppored_GL_ARB_vertex_array_object then
	begin
	SGLog.Sourse('GL_ARB_vertex_array_object');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_vertex_array_object';
	end;
SGIsSuppored_GL_ARB_copy_buffer:=Load_GL_ARB_copy_buffer;
if SGIsSuppored_GL_ARB_copy_buffer then
	begin
	SGLog.Sourse('GL_ARB_copy_buffer');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_copy_buffer';
	end;
SGIsSuppored_GL_ARB_uniform_buffer_object:=Load_GL_ARB_uniform_buffer_object;
if SGIsSuppored_GL_ARB_uniform_buffer_object then
	begin
	SGLog.Sourse('GL_ARB_uniform_buffer_object');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_uniform_buffer_object';
	end;
SGIsSuppored_GL_ARB_draw_elements_base_vertex:=Load_GL_ARB_draw_elements_base_vertex;
if SGIsSuppored_GL_ARB_draw_elements_base_vertex then
	begin
	SGLog.Sourse('GL_ARB_draw_elements_base_vertex');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_draw_elements_base_vertex';
	end;
SGIsSuppored_GL_ARB_provoking_vertex:=Load_GL_ARB_provoking_vertex;
if SGIsSuppored_GL_ARB_provoking_vertex then
	begin
	SGLog.Sourse('GL_ARB_provoking_vertex');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_provoking_vertex';
	end;
SGIsSuppored_GL_ARB_sync:=Load_GL_ARB_sync;
if SGIsSuppored_GL_ARB_sync then
	begin
	SGLog.Sourse('GL_ARB_sync');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_sync';
	end;
SGIsSuppored_GL_ARB_texture_multisample:=Load_GL_ARB_texture_multisample;
if SGIsSuppored_GL_ARB_texture_multisample then
	begin
	SGLog.Sourse('GL_ARB_texture_multisample');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_texture_multisample';
	end;
SGIsSuppored_GL_ARB_blend_func_extended:=Load_GL_ARB_blend_func_extended;
if SGIsSuppored_GL_ARB_blend_func_extended then
	begin
	SGLog.Sourse('GL_ARB_blend_func_extended');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_blend_func_extended';
	end;
SGIsSuppored_GL_ARB_sampler_objects:=Load_GL_ARB_sampler_objects;
if SGIsSuppored_GL_ARB_sampler_objects then
	begin
	SGLog.Sourse('GL_ARB_sampler_objects');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_sampler_objects';
	end;
SGIsSuppored_GL_ARB_timer_query:=Load_GL_ARB_timer_query;
if SGIsSuppored_GL_ARB_timer_query then
	begin
	SGLog.Sourse('GL_ARB_timer_query');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_timer_query';
	end;
SGIsSuppored_GL_ARB_vertex_type_2_10_10_10_rev:=Load_GL_ARB_vertex_type_2_10_10_10_rev;
if SGIsSuppored_GL_ARB_vertex_type_2_10_10_10_rev then
	begin
	SGLog.Sourse('GL_ARB_vertex_type_2_10_10_10_rev');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_vertex_type_2_10_10_10_rev';
	end;
SGIsSuppored_GL_ARB_gpu_shader_fp64:=Load_GL_ARB_gpu_shader_fp64;
if SGIsSuppored_GL_ARB_gpu_shader_fp64 then
	begin
	SGLog.Sourse('GL_ARB_gpu_shader_fp64');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_gpu_shader_fp64';
	end;
SGIsSuppored_GL_ARB_shader_subroutine:=Load_GL_ARB_shader_subroutine;
if SGIsSuppored_GL_ARB_shader_subroutine then
	begin
	SGLog.Sourse('GL_ARB_shader_subroutine');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_shader_subroutine';
	end;
SGIsSuppored_GL_ARB_tessellation_shader:=Load_GL_ARB_tessellation_shader;
if SGIsSuppored_GL_ARB_tessellation_shader then
	begin
	SGLog.Sourse('GL_ARB_tessellation_shader');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_tessellation_shader';
	end;
SGIsSuppored_GL_ARB_transform_feedback2:=Load_GL_ARB_transform_feedback2;
if SGIsSuppored_GL_ARB_transform_feedback2 then
	begin
	SGLog.Sourse('GL_ARB_transform_feedback2');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_transform_feedback2';
	end;
SGIsSuppored_GL_ARB_transform_feedback3:=Load_GL_ARB_transform_feedback3;
if SGIsSuppored_GL_ARB_transform_feedback3 then
	begin
	SGLog.Sourse('GL_ARB_transform_feedback3');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_ARB_transform_feedback3';
	end;
SGIsSuppored_GL_version_1_4:=Load_GL_version_1_4;
if SGIsSuppored_GL_version_1_4 then
	begin
	SGLog.Sourse('GL_version_1_4');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_version_1_4';
	end;
SGIsSuppored_GL_version_1_5:=Load_GL_version_1_5;
if SGIsSuppored_GL_version_1_5 then
	begin
	SGLog.Sourse('GL_version_1_5');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_version_1_5';
	end;
SGIsSuppored_GL_version_2_0:=Load_GL_version_2_0;
if SGIsSuppored_GL_version_2_0 then
	begin
	SGLog.Sourse('GL_version_2_0');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_version_2_0';
	end;
SGIsSuppored_GL_VERSION_2_1:=Load_GL_VERSION_2_1;
if SGIsSuppored_GL_VERSION_2_1 then
	begin
	SGLog.Sourse('GL_VERSION_2_1');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_VERSION_2_1';
	end;
SGIsSuppored_GL_VERSION_3_0:=Load_GL_VERSION_3_0;
if SGIsSuppored_GL_VERSION_3_0 then
	begin
	SGLog.Sourse('GL_VERSION_3_0');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_VERSION_3_0';
	end;
SGIsSuppored_GL_VERSION_3_1:=Load_GL_VERSION_3_1;
if SGIsSuppored_GL_VERSION_3_1 then
	begin
	SGLog.Sourse('GL_VERSION_3_1');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_VERSION_3_1';
	end;
SGIsSuppored_GL_VERSION_3_2:=Load_GL_VERSION_3_2;
if SGIsSuppored_GL_VERSION_3_2 then
	begin
	SGLog.Sourse('GL_VERSION_3_2');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_VERSION_3_2';
	end;
SGIsSuppored_GL_VERSION_3_3:=Load_GL_VERSION_3_3;
if SGIsSuppored_GL_VERSION_3_3 then
	begin
	SGLog.Sourse('GL_VERSION_3_3');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_VERSION_3_3';
	end;
SGIsSuppored_GL_VERSION_4_0:=Load_GL_VERSION_4_0;
if SGIsSuppored_GL_VERSION_4_0 then
	begin
	SGLog.Sourse('GL_VERSION_4_0');
	i+=1;
	end
else
	begin
	SetLength(Extendeds,Length(Extendeds)+1);
	Extendeds[High(Extendeds)]:='GL_VERSION_4_0';
	end;


SGLog.Sourse('} Suppored is '+SGStr(i)+' extendeds...');
SGLog.Sourse('SGOpenGLInit : Not supported is next extendeds ('+SGStr(Length(Extendeds))+') {');

for ii:=0 to High(Extendeds) do
	SGLog.Sourse(Extendeds[ii]);

SGLog.Sourse('}');
SGLog.Sourse('SGOpenGLInit : Total : Suppored '+SGStr(i)+' extendeds, not supppored '+SGStr(Length(Extendeds))+' extendeds...');

SetLength(Extendeds,0);

if SGCLLoadProcedure<>nil then
	SGCLLoadProcedure;

SGIsOpenGLInit:=True;
end;

function SGTSGVertex3fImport(const x:real = 0;const y:real = 0;const z:real = 0):TSGVertex3f;
begin
Result.x:=x;
Result.y:=y;
Result.z:=z;
end;

procedure SGCrearOpenGL;
begin
glClear(GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT);
glLoadIdentity();
glTranslatef(0,0,0);
glRotatef( 0,0,1,0);
end;

function TSGBezierCurve.GetDetalization:longword;
begin
GetDetalization:=Detalization;
end;

procedure TSGBezierCurve.SetArray(const a:TArTSGVertex3f);
begin
SetLength(StartArray,0);
StartArray:=a;
end;

function TSGBezierCurve.SetDetalization(const l:dword):boolean;
begin
if l>0 then
	begin
	SetDetalization:=true;
	Detalization:=l;
	end
else
	SetDetalization:=false;
end;

procedure TSGBezierCurve.Init(const p:Pointer = nil);
var	
	i:longint;
begin
GlBegin(GL_LINE_STRIP);
for i:=Low(EndArray) to High(EndArray) do
	begin
	EndArray[i].Vertex(p);
	end;
GlEnd();
end;

function SGGetVertexInAttitude(const t1,t2:TSGVertex3f; const r:real = 0.5):TSGVertex3f;
begin
Result.SetVariables(
	-r*(t1.x-t2.x)+t1.x,
	-r*(t1.y-t2.y)+t1.y,
	-r*(t1.z-t2.z)+t1.z);
end;

procedure TSGBezierCurve.Calculate;
var
	i:longword;

function GetKoor(const R:real;const A:TArTSGVertex3f):TSGVertex3f;
var
	A2:TArTSGVertex3f;
	i:longint;
begin
if Length(a)=2 then
	begin
	GetKoor:=SGGetVertexInAttitude(A[Low(A)],A[High(A)],r);
	end
else
	begin
	SetLength(A2,Length(A)-1);
	for i:=Low(A2) to High(A2) do
		A2[i]:=SGGetVertexInAttitude(A[i],A[i+1],r);
	GetKoor:=GetKoor(R,A2);
	SetLength(A2,0);
	end;
end;

begin
SetLength(EndArray,Detalization+1);
for i:=Low(EndArray) to High(EndArray) do
	begin
	EndArray[i]:=GetKoor(i/Detalization,StartArray);
	end;
end;

procedure TSGBezierCurve.InitVertex(const k:TSGVertex3f);
begin
SetLength(StartArray,Length(StartArray)+1);
StartArray[High(StartArray)]:=k;
end;

procedure TSGBezierCurve.Clear;
begin
SetLength(StartArray,0);
SetLength(EndArray,0);
SetDetalization(40);
end;


procedure TSGVertex2f.SetVariables(const x1:real = 0; const y1:real = 0);
begin
x:=x1;
y:=y1;
end;

procedure TSGVertex3f.SetVariables(const x1:real = 0; const y1:real = 0; const z1:real = 0);
begin
x:=x1;
y:=y1;
z:=z1;
end;

procedure TSGColor4f.SetVariables(const r1:real = 0; const g1:real = 0; const b1:real = 0; const a1:real = 1);
begin
r:=r1;
g:=g1;
b:=b1;
a:=a1;
end;

procedure TSGVertex2f.TexCoord;
begin
glTexCoord2f(x,y);
end;

procedure TSGColor4f.SetColor;
begin
Color;
end;

procedure TSGColor4f.Color;
begin
glColor4f(r,g,b,a);
end;

procedure TSGVertex2f.Vertex;
begin
glVertex2f(x,y);
end;

procedure TSGVertex3f.Vertex;
begin
glVertex3f(x,y,z);
end;

initialization

begin
Nan:=sqrt(-1);
Inf:=1/0;
RandomIze;
end;

end.
