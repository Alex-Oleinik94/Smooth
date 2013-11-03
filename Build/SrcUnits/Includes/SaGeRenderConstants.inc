const
  SGR_ACCUM                          = $0100;
  SGR_LOAD                           = $0101;
  SGR_RETURN                         = $0102;
  SGR_MULT                           = $0103;
  SGR_ADD                            = $0104;

  // AlphaFunction
  SGR_NEVER                          = $0200;
  SGR_LESS                           = $0201;
  SGR_EQUAL                          = $0202;
  SGR_LEQUAL                         = $0203;
  SGR_GREATER                        = $0204;
  SGR_NOTEQUAL                       = $0205;
  SGR_GEQUAL                         = $0206;
  SGR_ALWAYS                         = $0207;

  // AttribMask
  SGR_CURRENT_BIT                    = $00000001;
  SGR_POINT_BIT                      = $00000002;
  SGR_LINE_BIT                       = $00000004;
  SGR_POLYGON_BIT                    = $00000008;
  SGR_POLYGON_STIPPLE_BIT            = $00000010;
  SGR_PIXEL_MODE_BIT                 = $00000020;
  SGR_LIGHTING_BIT                   = $00000040;
  SGR_FOG_BIT                        = $00000080;
  SGR_DEPTH_BUFFER_BIT               = $00000100;
  SGR_ACCUM_BUFFER_BIT               = $00000200;
  SGR_STENCIL_BUFFER_BIT             = $00000400;
  SGR_VIEWPORT_BIT                   = $00000800;
  SGR_TRANSFORM_BIT                  = $00001000;
  SGR_ENABLE_BIT                     = $00002000;
  SGR_COLOR_BUFFER_BIT               = $00004000;
  SGR_HINT_BIT                       = $00008000;
  SGR_EVAL_BIT                       = $00010000;
  SGR_LIST_BIT                       = $00020000;
  SGR_TEXTURE_BIT                    = $00040000;
  SGR_SCISSOR_BIT                    = $00080000;
  SGR_ALL_ATTRIB_BITS                = $000FFFFF;

  // BeginMode
  SGR_POINTS                         = $0000;
  SGR_LINES                          = $0001;
  SGR_LINE_LOOP                      = $0002;
  SGR_LINE_STRIP                     = $0003;
  SGR_TRIANGLES                      = $0004;
  SGR_TRIANGLE_STRIP                 = $0005;
  SGR_TRIANGLE_FAN                   = $0006;
  SGR_QUADS                          = $0007;
  SGR_QUAD_STRIP                     = $0008;
  SGR_POLYGON                        = $0009;

  // BlendingFactorDest
  SGR_ZERO                           = 0;
  SGR_ONE                            = 1;
  SGR_SRC_COLOR                      = $0300;
  SGR_ONE_MINUS_SRC_COLOR            = $0301;
  SGR_SRC_ALPHA                      = $0302;
  SGR_ONE_MINUS_SRC_ALPHA            = $0303;
  SGR_DST_ALPHA                      = $0304;
  SGR_ONE_MINUS_DST_ALPHA            = $0305;

  // BlendingFactorSrc
  //      SGR_ZERO
  //      SGR_ONE
  SGR_DST_COLOR                      = $0306;
  SGR_ONE_MINUS_DST_COLOR            = $0307;
  SGR_SRC_ALPHA_SATURATE             = $0308;
  //      SGR_SRC_ALPHA
  //      SGR_ONE_MINUS_SRC_ALPHA
  //      SGR_DST_ALPHA
  //      SGR_ONE_MINUS_DST_ALPHA

  // Boolean
  SGR_TRUE                           = 1;
  SGR_FALSE                          = 0;

  // ClearBufferMask
  //      SGR_COLOR_BUFFER_BIT
  //      SGR_ACCUM_BUFFER_BIT
  //      SGR_STENCIL_BUFFER_BIT
  //      SGR_DEPTH_BUFFER_BIT

  // ClientArrayType
  //      SGR_VERTEX_ARRAY
  //      SGR_NORMAL_ARRAY
  //      SGR_COLOR_ARRAY
  //      SGR_INDEX_ARRAY
  //      SGR_TEXTURE_COORD_ARRAY
  //      SGR_EDGE_FLAG_ARRAY

  // ClipPlaneName
  SGR_CLIP_PLANE0                    = $3000;
  SGR_CLIP_PLANE1                    = $3001;
  SGR_CLIP_PLANE2                    = $3002;
  SGR_CLIP_PLANE3                    = $3003;
  SGR_CLIP_PLANE4                    = $3004;
  SGR_CLIP_PLANE5                    = $3005;

  // ColorMaterialFace
  //      SGR_FRONT
  //      SGR_BACK
  //      SGR_FRONT_AND_BACK

  // ColorMaterialParameter
  //      SGR_AMBIENT
  //      SGR_DIFFUSE
  //      SGR_SPECULAR
  //      SGR_EMISSION
  //      SGR_AMBIENT_AND_DIFFUSE

  // ColorPointerType
  //      SGR_BYTE
  //      SGR_UNSIGNED_BYTE
  //      SGR_SHORT
  //      SGR_UNSIGNED_SHORT
  //      SGR_INT
  //      SGR_UNSIGNED_INT
  //      SGR_FLOAT
  //      SGR_DOUBLE

  // CullFaceMode
  //      SGR_FRONT
  //      SGR_BACK
  //      SGR_FRONT_AND_BACK

  // DataType
  SGR_BYTE                           = $1400;
  SGR_UNSIGNED_BYTE                  = $1401;
  SGR_SHORT                          = $1402;
  SGR_UNSIGNED_SHORT                 = $1403;
  SGR_INT                            = $1404;
  SGR_UNSIGNED_INT                   = $1405;
  SGR_FLOAT                          = $1406;
  SGR_2_BYTES                        = $1407;
  SGR_3_BYTES                        = $1408;
  SGR_4_BYTES                        = $1409;
  SGR_DOUBLE                         = $140A;

  // DepthFunction
  //      SGR_NEVER
  //      SGR_LESS
  //      SGR_EQUAL
  //      SGR_LEQUAL
  //      SGR_GREATER
  //      SGR_NOTEQUAL
  //      SGR_GEQUAL
  //      SGR_ALWAYS

  // DrawBufferMode
  SGR_NONE                           = 0;
  SGR_FRONT_LEFT                     = $0400;
  SGR_FRONT_RIGHT                    = $0401;
  SGR_BACK_LEFT                      = $0402;
  SGR_BACK_RIGHT                     = $0403;
  SGR_FRONT                          = $0404;
  SGR_BACK                           = $0405;
  SGR_LEFT                           = $0406;
  SGR_RIGHT                          = $0407;
  SGR_FRONT_AND_BACK                 = $0408;
  SGR_AUX0                           = $0409;
  SGR_AUX1                           = $040A;
  SGR_AUX2                           = $040B;
  SGR_AUX3                           = $040C;

  // Enable
  //      SGR_FOG
  //      SGR_LIGHTING
  //      SGR_TEXTURE_1D
  //      SGR_TEXTURE_2D
  //      SGR_LINE_STIPPLE
  //      SGR_POLYGON_STIPPLE
  //      SGR_CULL_FACE
  //      SGR_ALPHA_TEST
  //      SGR_BLEND
  //      SGR_INDEX_LOGIC_OP
  //      SGR_COLOR_LOGIC_OP
  //      SGR_DITHER
  //      SGR_STENCIL_TEST
  //      SGR_DEPTH_TEST
  //      SGR_CLIP_PLANE0
  //      SGR_CLIP_PLANE1
  //      SGR_CLIP_PLANE2
  //      SGR_CLIP_PLANE3
  //      SGR_CLIP_PLANE4
  //      SGR_CLIP_PLANE5
  //      SGR_LIGHT0
  //      SGR_LIGHT1
  //      SGR_LIGHT2
  //      SGR_LIGHT3
  //      SGR_LIGHT4
  //      SGR_LIGHT5
  //      SGR_LIGHT6
  //      SGR_LIGHT7
  //      SGR_TEXTURE_GEN_S
  //      SGR_TEXTURE_GEN_T
  //      SGR_TEXTURE_GEN_R
  //      SGR_TEXTURE_GEN_Q
  //      SGR_MAP1_VERTEX_3
  //      SGR_MAP1_VERTEX_4
  //      SGR_MAP1_COLOR_4
  //      SGR_MAP1_INDEX
  //      SGR_MAP1_NORMAL
  //      SGR_MAP1_TEXTURE_COORD_1
  //      SGR_MAP1_TEXTURE_COORD_2
  //      SGR_MAP1_TEXTURE_COORD_3
  //      SGR_MAP1_TEXTURE_COORD_4
  //      SGR_MAP2_VERTEX_3
  //      SGR_MAP2_VERTEX_4
  //      SGR_MAP2_COLOR_4
  //      SGR_MAP2_INDEX
  //      SGR_MAP2_NORMAL
  //      SGR_MAP2_TEXTURE_COORD_1
  //      SGR_MAP2_TEXTURE_COORD_2
  //      SGR_MAP2_TEXTURE_COORD_3
  //      SGR_MAP2_TEXTURE_COORD_4
  //      SGR_POINT_SMOOTH
  //      SGR_LINE_SMOOTH
  //      SGR_POLYGON_SMOOTH
  //      SGR_SCISSOR_TEST
  //      SGR_COLOR_MATERIAL
  //      SGR_NORMALIZE
  //      SGR_AUTO_NORMAL
  //      SGR_VERTEX_ARRAY
  //      SGR_NORMAL_ARRAY
  //      SGR_COLOR_ARRAY
  //      SGR_INDEX_ARRAY
  //      SGR_TEXTURE_COORD_ARRAY
  //      SGR_EDGE_FLAG_ARRAY
  //      SGR_POLYGON_OFFSET_POINT
  //      SGR_POLYGON_OFFSET_LINE
  //      SGR_POLYGON_OFFSET_FILL

  // ErrorCode
  SGR_NO_ERROR                       = 0;
  SGR_INVALID_ENUM                   = $0500;
  SGR_INVALID_VALUE                  = $0501;
  SGR_INVALID_OPERATION              = $0502;
  SGR_STACK_OVERFLOW                 = $0503;
  SGR_STACK_UNDERFLOW                = $0504;
  SGR_OUT_OF_MEMORY                  = $0505;

  // FeedBackMode
  SGR_2D                             = $0600;
  SGR_3D                             = $0601;
  SGR_3D_COLOR                       = $0602;
  SGR_3D_COLOR_TEXTURE               = $0603;
  SGR_4D_COLOR_TEXTURE               = $0604;
  SGR_3D_ORTHO 						= $0605;
  
  // FeedBackToken
  SGR_PASS_THROUGH_TOKEN             = $0700;
  SGR_POINT_TOKEN                    = $0701;
  SGR_LINE_TOKEN                     = $0702;
  SGR_POLYGON_TOKEN                  = $0703;
  SGR_BITMAP_TOKEN                   = $0704;
  SGR_DRAW_PIXEL_TOKEN               = $0705;
  SGR_COPY_PIXEL_TOKEN               = $0706;
  SGR_LINE_RESET_TOKEN               = $0707;

  // FogMode
  //      SGR_LINEAR
  SGR_EXP                            = $0800;
  SGR_EXP2                           = $0801;

  // FogParameter
  //      SGR_FOG_COLOR
  //      SGR_FOG_DENSITY
  //      SGR_FOG_END
  //      SGR_FOG_INDEX
  //      SGR_FOG_MODE
  //      SGR_FOG_START

  // FrontFaceDirection
  SGR_CW                             = $0900;
  SGR_CCW                            = $0901;

  // GetMapTarget
  SGR_COEFF                          = $0A00;
  SGR_ORDER                          = $0A01;
  SGR_DOMAIN                         = $0A02;

  // GetPixelMap
  //      SGR_PIXEL_MAP_I_TO_I
  //      SGR_PIXEL_MAP_S_TO_S
  //      SGR_PIXEL_MAP_I_TO_R
  //      SGR_PIXEL_MAP_I_TO_G
  //      SGR_PIXEL_MAP_I_TO_B
  //      SGR_PIXEL_MAP_I_TO_A
  //      SGR_PIXEL_MAP_R_TO_R
  //      SGR_PIXEL_MAP_G_TO_G
  //      SGR_PIXEL_MAP_B_TO_B
  //      SGR_PIXEL_MAP_A_TO_A

  // GetPointerTarget
  //      SGR_VERTEX_ARRAY_POINTER
  //      SGR_NORMAL_ARRAY_POINTER
  //      SGR_COLOR_ARRAY_POINTER
  //      SGR_INDEX_ARRAY_POINTER
  //      SGR_TEXTURE_COORD_ARRAY_POINTER
  //      SGR_EDGE_FLAG_ARRAY_POINTER

  // GetTarget
  SGR_CURRENT_COLOR                  = $0B00;
  SGR_CURRENT_INDEX                  = $0B01;
  SGR_CURRENT_NORMAL                 = $0B02;
  SGR_CURRENT_TEXTURE_COORDS         = $0B03;
  SGR_CURRENT_RASTER_COLOR           = $0B04;
  SGR_CURRENT_RASTER_INDEX           = $0B05;
  SGR_CURRENT_RASTER_TEXTURE_COORDS  = $0B06;
  SGR_CURRENT_RASTER_POSITION        = $0B07;
  SGR_CURRENT_RASTER_POSITION_VALID  = $0B08;
  SGR_CURRENT_RASTER_DISTANCE        = $0B09;
  SGR_POINT_SMOOTH                   = $0B10;
  SGR_POINT_SIZE                     = $0B11;
  SGR_POINT_SIZE_RANGE               = $0B12;
  SGR_POINT_SIZE_GRANULARITY         = $0B13;
  SGR_LINE_SMOOTH                    = $0B20;
  SGR_LINE_WIDTH                     = $0B21;
  SGR_LINE_WIDTH_RANGE               = $0B22;
  SGR_LINE_WIDTH_GRANULARITY         = $0B23;
  SGR_LINE_STIPPLE                   = $0B24;
  SGR_LINE_STIPPLE_PATTERN           = $0B25;
  SGR_LINE_STIPPLE_REPEAT            = $0B26;
  SGR_LIST_MODE                      = $0B30;
  SGR_MAX_LIST_NESTING               = $0B31;
  SGR_LIST_BASE                      = $0B32;
  SGR_LIST_INDEX                     = $0B33;
  SGR_POLYGON_MODE                   = $0B40;
  SGR_POLYGON_SMOOTH                 = $0B41;
  SGR_POLYGON_STIPPLE                = $0B42;
  SGR_EDGE_FLAG                      = $0B43;
  SGR_CULL_FACE                      = $0B44;
  SGR_CULL_FACE_MODE                 = $0B45;
  SGR_FRONT_FACE                     = $0B46;
  SGR_LIGHTING                       = $0B50;
  SGR_LIGHT_MODEL_LOCAL_VIEWER       = $0B51;
  SGR_LIGHT_MODEL_TWO_SIDE           = $0B52;
  SGR_LIGHT_MODEL_AMBIENT            = $0B53;
  SGR_SHADE_MODEL                    = $0B54;
  SGR_COLOR_MATERIAL_FACE            = $0B55;
  SGR_COLOR_MATERIAL_PARAMETER       = $0B56;
  SGR_COLOR_MATERIAL                 = $0B57;
  SGR_FOG                            = $0B60;
  SGR_FOG_INDEX                      = $0B61;
  SGR_FOG_DENSITY                    = $0B62;
  SGR_FOG_START                      = $0B63;
  SGR_FOG_END                        = $0B64;
  SGR_FOG_MODE                       = $0B65;
  SGR_FOG_COLOR                      = $0B66;
  SGR_DEPTH_RANGE                    = $0B70;
  SGR_DEPTH_TEST                     = $0B71;
  SGR_DEPTH_WRITEMASK                = $0B72;
  SGR_DEPTH_CLEAR_VALUE              = $0B73;
  SGR_DEPTH_FUNC                     = $0B74;
  SGR_ACCUM_CLEAR_VALUE              = $0B80;
  SGR_STENCIL_TEST                   = $0B90;
  SGR_STENCIL_CLEAR_VALUE            = $0B91;
  SGR_STENCIL_FUNC                   = $0B92;
  SGR_STENCIL_VALUE_MASK             = $0B93;
  SGR_STENCIL_FAIL                   = $0B94;
  SGR_STENCIL_PASS_DEPTH_FAIL        = $0B95;
  SGR_STENCIL_PASS_DEPTH_PASS        = $0B96;
  SGR_STENCIL_REF                    = $0B97;
  SGR_STENCIL_WRITEMASK              = $0B98;
  SGR_MATRIX_MODE                    = $0BA0;
  SGR_NORMALIZE                      = $0BA1;
  SGR_VIEWPORT                       = $0BA2;
  SGR_MODELVIEW_STACK_DEPTH          = $0BA3;
  SGR_PROJECTION_STACK_DEPTH         = $0BA4;
  SGR_TEXTURE_STACK_DEPTH            = $0BA5;
  SGR_MODELVIEW_MATRIX               = $0BA6;
  SGR_PROJECTION_MATRIX              = $0BA7;
  SGR_TEXTURE_MATRIX                 = $0BA8;
  SGR_ATTRIB_STACK_DEPTH             = $0BB0;
  SGR_CLIENT_ATTRIB_STACK_DEPTH      = $0BB1;
  SGR_ALPHA_TEST                     = $0BC0;
  SGR_ALPHA_TEST_FUNC                = $0BC1;
  SGR_ALPHA_TEST_REF                 = $0BC2;
  SGR_DITHER                         = $0BD0;
  SGR_BLEND_DST                      = $0BE0;
  SGR_BLEND_SRC                      = $0BE1;
  SGR_BLEND                          = $0BE2;
  SGR_LOGIC_OP_MODE                  = $0BF0;
  SGR_INDEX_LOGIC_OP                 = $0BF1;
  SGR_COLOR_LOGIC_OP                 = $0BF2;
  SGR_AUX_BUFFERS                    = $0C00;
  SGR_DRAW_BUFFER                    = $0C01;
  SGR_READ_BUFFER                    = $0C02;
  SGR_SCISSOR_BOX                    = $0C10;
  SGR_SCISSOR_TEST                   = $0C11;
  SGR_INDEX_CLEAR_VALUE              = $0C20;
  SGR_INDEX_WRITEMASK                = $0C21;
  SGR_COLOR_CLEAR_VALUE              = $0C22;
  SGR_COLOR_WRITEMASK                = $0C23;
  SGR_INDEX_MODE                     = $0C30;
  SGR_RGBA_MODE                      = $0C31;
  SGR_DOUBLEBUFFER                   = $0C32;
  SGR_STEREO                         = $0C33;
  SGR_RENDER_MODE                    = $0C40;
  SGR_PERSPECTIVE_CORRECTION_HINT    = $0C50;
  SGR_POINT_SMOOTH_HINT              = $0C51;
  SGR_LINE_SMOOTH_HINT               = $0C52;
  SGR_POLYGON_SMOOTH_HINT            = $0C53;
  SGR_FOG_HINT                       = $0C54;
  SGR_TEXTURE_GEN_S                  = $0C60;
  SGR_TEXTURE_GEN_T                  = $0C61;
  SGR_TEXTURE_GEN_R                  = $0C62;
  SGR_TEXTURE_GEN_Q                  = $0C63;
  SGR_PIXEL_MAP_I_TO_I               = $0C70;
  SGR_PIXEL_MAP_S_TO_S               = $0C71;
  SGR_PIXEL_MAP_I_TO_R               = $0C72;
  SGR_PIXEL_MAP_I_TO_G               = $0C73;
  SGR_PIXEL_MAP_I_TO_B               = $0C74;
  SGR_PIXEL_MAP_I_TO_A               = $0C75;
  SGR_PIXEL_MAP_R_TO_R               = $0C76;
  SGR_PIXEL_MAP_G_TO_G               = $0C77;
  SGR_PIXEL_MAP_B_TO_B               = $0C78;
  SGR_PIXEL_MAP_A_TO_A               = $0C79;
  SGR_PIXEL_MAP_I_TO_I_SIZE          = $0CB0;
  SGR_PIXEL_MAP_S_TO_S_SIZE          = $0CB1;
  SGR_PIXEL_MAP_I_TO_R_SIZE          = $0CB2;
  SGR_PIXEL_MAP_I_TO_G_SIZE          = $0CB3;
  SGR_PIXEL_MAP_I_TO_B_SIZE          = $0CB4;
  SGR_PIXEL_MAP_I_TO_A_SIZE          = $0CB5;
  SGR_PIXEL_MAP_R_TO_R_SIZE          = $0CB6;
  SGR_PIXEL_MAP_G_TO_G_SIZE          = $0CB7;
  SGR_PIXEL_MAP_B_TO_B_SIZE          = $0CB8;
  SGR_PIXEL_MAP_A_TO_A_SIZE          = $0CB9;
  SGR_UNPACK_SWAP_BYTES              = $0CF0;
  SGR_UNPACK_LSB_FIRST               = $0CF1;
  SGR_UNPACK_ROW_LENGTH              = $0CF2;
  SGR_UNPACK_SKIP_ROWS               = $0CF3;
  SGR_UNPACK_SKIP_PIXELS             = $0CF4;
  SGR_UNPACK_ALIGNMENT               = $0CF5;
  SGR_PACK_SWAP_BYTES                = $0D00;
  SGR_PACK_LSB_FIRST                 = $0D01;
  SGR_PACK_ROW_LENGTH                = $0D02;
  SGR_PACK_SKIP_ROWS                 = $0D03;
  SGR_PACK_SKIP_PIXELS               = $0D04;
  SGR_PACK_ALIGNMENT                 = $0D05;
  SGR_MAP_COLOR                      = $0D10;
  SGR_MAP_STENCIL                    = $0D11;
  SGR_INDEX_SHIFT                    = $0D12;
  SGR_INDEX_OFFSET                   = $0D13;
  SGR_RED_SCALE                      = $0D14;
  SGR_RED_BIAS                       = $0D15;
  SGR_ZOOM_X                         = $0D16;
  SGR_ZOOM_Y                         = $0D17;
  SGR_GREEN_SCALE                    = $0D18;
  SGR_GREEN_BIAS                     = $0D19;
  SGR_BLUE_SCALE                     = $0D1A;
  SGR_BLUE_BIAS                      = $0D1B;
  SGR_ALPHA_SCALE                    = $0D1C;
  SGR_ALPHA_BIAS                     = $0D1D;
  SGR_DEPTH_SCALE                    = $0D1E;
  SGR_DEPTH_BIAS                     = $0D1F;
  SGR_MAX_EVAL_ORDER                 = $0D30;
  SGR_MAX_LIGHTS                     = $0D31;
  SGR_MAX_CLIP_PLANES                = $0D32;
  SGR_MAX_TEXTURE_SIZE               = $0D33;
  SGR_MAX_PIXEL_MAP_TABLE            = $0D34;
  SGR_MAX_ATTRIB_STACK_DEPTH         = $0D35;
  SGR_MAX_MODELVIEW_STACK_DEPTH      = $0D36;
  SGR_MAX_NAME_STACK_DEPTH           = $0D37;
  SGR_MAX_PROJECTION_STACK_DEPTH     = $0D38;
  SGR_MAX_TEXTURE_STACK_DEPTH        = $0D39;
  SGR_MAX_VIEWPORT_DIMS              = $0D3A;
  SGR_MAX_CLIENT_ATTRIB_STACK_DEPTH  = $0D3B;
  SGR_SUBPIXEL_BITS                  = $0D50;
  SGR_INDEX_BITS                     = $0D51;
  SGR_RED_BITS                       = $0D52;
  SGR_GREEN_BITS                     = $0D53;
  SGR_BLUE_BITS                      = $0D54;
  SGR_ALPHA_BITS                     = $0D55;
  SGR_DEPTH_BITS                     = $0D56;
  SGR_STENCIL_BITS                   = $0D57;
  SGR_ACCUM_RED_BITS                 = $0D58;
  SGR_ACCUM_GREEN_BITS               = $0D59;
  SGR_ACCUM_BLUE_BITS                = $0D5A;
  SGR_ACCUM_ALPHA_BITS               = $0D5B;
  SGR_NAME_STACK_DEPTH               = $0D70;
  SGR_AUTO_NORMAL                    = $0D80;
  SGR_MAP1_COLOR_4                   = $0D90;
  SGR_MAP1_INDEX                     = $0D91;
  SGR_MAP1_NORMAL                    = $0D92;
  SGR_MAP1_TEXTURE_COORD_1           = $0D93;
  SGR_MAP1_TEXTURE_COORD_2           = $0D94;
  SGR_MAP1_TEXTURE_COORD_3           = $0D95;
  SGR_MAP1_TEXTURE_COORD_4           = $0D96;
  SGR_MAP1_VERTEX_3                  = $0D97;
  SGR_MAP1_VERTEX_4                  = $0D98;
  SGR_MAP2_COLOR_4                   = $0DB0;
  SGR_MAP2_INDEX                     = $0DB1;
  SGR_MAP2_NORMAL                    = $0DB2;
  SGR_MAP2_TEXTURE_COORD_1           = $0DB3;
  SGR_MAP2_TEXTURE_COORD_2           = $0DB4;
  SGR_MAP2_TEXTURE_COORD_3           = $0DB5;
  SGR_MAP2_TEXTURE_COORD_4           = $0DB6;
  SGR_MAP2_VERTEX_3                  = $0DB7;
  SGR_MAP2_VERTEX_4                  = $0DB8;
  SGR_MAP1_GRID_DOMAIN               = $0DD0;
  SGR_MAP1_GRID_SEGMENTS             = $0DD1;
  SGR_MAP2_GRID_DOMAIN               = $0DD2;
  SGR_MAP2_GRID_SEGMENTS             = $0DD3;
  SGR_TEXTURE_1D                     = $0DE0;
  SGR_TEXTURE_2D                     = $0DE1;
  SGR_FEEDBACK_BUFFER_POINTER        = $0DF0;
  SGR_FEEDBACK_BUFFER_SIZE           = $0DF1;
  SGR_FEEDBACK_BUFFER_TYPE           = $0DF2;
  SGR_SELECTION_BUFFER_POINTER       = $0DF3;
  SGR_SELECTION_BUFFER_SIZE          = $0DF4;
  //      SGR_TEXTURE_BINDING_1D
  //      SGR_TEXTURE_BINDING_2D
  //      SGR_VERTEX_ARRAY
  //      SGR_NORMAL_ARRAY
  //      SGR_COLOR_ARRAY
  //      SGR_INDEX_ARRAY
  //      SGR_TEXTURE_COORD_ARRAY
  //      SGR_EDGE_FLAG_ARRAY
  //      SGR_VERTEX_ARRAY_SIZE
  //      SGR_VERTEX_ARRAY_TYPE
  //      SGR_VERTEX_ARRAY_STRIDE
  //      SGR_NORMAL_ARRAY_TYPE
  //      SGR_NORMAL_ARRAY_STRIDE
  //      SGR_COLOR_ARRAY_SIZE
  //      SGR_COLOR_ARRAY_TYPE
  //      SGR_COLOR_ARRAY_STRIDE
  //      SGR_INDEX_ARRAY_TYPE
  //      SGR_INDEX_ARRAY_STRIDE
  //      SGR_TEXTURE_COORD_ARRAY_SIZE
  //      SGR_TEXTURE_COORD_ARRAY_TYPE
  //      SGR_TEXTURE_COORD_ARRAY_STRIDE
  //      SGR_EDGE_FLAG_ARRAY_STRIDE
  //      SGR_POLYGON_OFFSET_FACTOR
  //      SGR_POLYGON_OFFSET_UNITS

  // GetTextureParameter
  //      SGR_TEXTURE_MAG_FILTER
  //      SGR_TEXTURE_MIN_FILTER
  //      SGR_TEXTURE_WRAP_S
  //      SGR_TEXTURE_WRAP_T
  SGR_TEXTURE_WIDTH                  = $1000;
  SGR_TEXTURE_HEIGHT                 = $1001;
  SGR_TEXTURE_INTERNAL_FORMAT        = $1003;
  SGR_TEXTURE_BORDER_COLOR           = $1004;
  SGR_TEXTURE_BORDER                 = $1005;
  //      SGR_TEXTURE_RED_SIZE
  //      SGR_TEXTURE_GREEN_SIZE
  //      SGR_TEXTURE_BLUE_SIZE
  //      SGR_TEXTURE_ALPHA_SIZE
  //      SGR_TEXTURE_LUMINANCE_SIZE
  //      SGR_TEXTURE_INTENSITY_SIZE
  //      SGR_TEXTURE_PRIORITY
  //      SGR_TEXTURE_RESIDENT

  // HintMode
  SGR_DONT_CARE                      = $1100;
  SGR_FASTEST                        = $1101;
  SGR_NICEST                         = $1102;

  // HintTarget
  //      SGR_PERSPECTIVE_CORRECTION_HINT
  //      SGR_POINT_SMOOTH_HINT
  //      SGR_LINE_SMOOTH_HINT
  //      SGR_POLYGON_SMOOTH_HINT
  //      SGR_FOG_HINT

  // IndexPointerType
  //      SGR_SHORT
  //      SGR_INT
  //      SGR_FLOAT
  //      SGR_DOUBLE

  // LightModelParameter
  //      SGR_LIGHT_MODEL_AMBIENT
  //      SGR_LIGHT_MODEL_LOCAL_VIEWER
  //      SGR_LIGHT_MODEL_TWO_SIDE

  // LightName
  SGR_LIGHT0                         = $4000;
  SGR_LIGHT1                         = $4001;
  SGR_LIGHT2                         = $4002;
  SGR_LIGHT3                         = $4003;
  SGR_LIGHT4                         = $4004;
  SGR_LIGHT5                         = $4005;
  SGR_LIGHT6                         = $4006;
  SGR_LIGHT7                         = $4007;

  // LightParameter
  SGR_AMBIENT                        = $1200;
  SGR_DIFFUSE                        = $1201;
  SGR_SPECULAR                       = $1202;
  SGR_POSITION                       = $1203;
  SGR_SPOT_DIRECTION                 = $1204;
  SGR_SPOT_EXPONENT                  = $1205;
  SGR_SPOT_CUTOFF                    = $1206;
  SGR_CONSTANT_ATTENUATION           = $1207;
  SGR_LINEAR_ATTENUATION             = $1208;
  SGR_QUADRATIC_ATTENUATION          = $1209;

  // InterleavedArrays
  //      SGR_V2F
  //      SGR_V3F
  //      SGR_C4UB_V2F
  //      SGR_C4UB_V3F
  //      SGR_C3F_V3F
  //      SGR_N3F_V3F
  //      SGR_C4F_N3F_V3F
  //      SGR_T2F_V3F
  //      SGR_T4F_V4F
  //      SGR_T2F_C4UB_V3F
  //      SGR_T2F_C3F_V3F
  //      SGR_T2F_N3F_V3F
  //      SGR_T2F_C4F_N3F_V3F
  //      SGR_T4F_C4F_N3F_V4F

  // ListMode
  SGR_COMPILE                        = $1300;
  SGR_COMPILE_AND_EXECUTE            = $1301;

  // ListNameType
  //      SGR_BYTE
  //      SGR_UNSIGNED_BYTE
  //      SGR_SHORT
  //      SGR_UNSIGNED_SHORT
  //      SGR_INT
  //      SGR_UNSIGNED_INT
  //      SGR_FLOAT
  //      SGR_2_BYTES
  //      SGR_3_BYTES
  //      SGR_4_BYTES

  // LogicOp
  SGR_CLEAR                          = $1500;
  SGR_AND                            = $1501;
  SGR_AND_REVERSE                    = $1502;
  SGR_COPY                           = $1503;
  SGR_AND_INVERTED                   = $1504;
  SGR_NOOP                           = $1505;
  SGR_XOR                            = $1506;
  SGR_OR                             = $1507;
  SGR_NOR                            = $1508;
  SGR_EQUIV                          = $1509;
  SGR_INVERT                         = $150A;
  SGR_OR_REVERSE                     = $150B;
  SGR_COPY_INVERTED                  = $150C;
  SGR_OR_INVERTED                    = $150D;
  SGR_NAND                           = $150E;
  SGR_SET                            = $150F;

  // MapTarget
  //      SGR_MAP1_COLOR_4
  //      SGR_MAP1_INDEX
  //      SGR_MAP1_NORMAL
  //      SGR_MAP1_TEXTURE_COORD_1
  //      SGR_MAP1_TEXTURE_COORD_2
  //      SGR_MAP1_TEXTURE_COORD_3
  //      SGR_MAP1_TEXTURE_COORD_4
  //      SGR_MAP1_VERTEX_3
  //      SGR_MAP1_VERTEX_4
  //      SGR_MAP2_COLOR_4
  //      SGR_MAP2_INDEX
  //      SGR_MAP2_NORMAL
  //      SGR_MAP2_TEXTURE_COORD_1
  //      SGR_MAP2_TEXTURE_COORD_2
  //      SGR_MAP2_TEXTURE_COORD_3
  //      SGR_MAP2_TEXTURE_COORD_4
  //      SGR_MAP2_VERTEX_3
  //      SGR_MAP2_VERTEX_4

  // MaterialFace
  //      SGR_FRONT
  //      SGR_BACK
  //      SGR_FRONT_AND_BACK

  // MaterialParameter
  SGR_EMISSION                       = $1600;
  SGR_SHININESS                      = $1601;
  SGR_AMBIENT_AND_DIFFUSE            = $1602;
  SGR_COLOR_INDEXES                  = $1603;
  //      SGR_AMBIENT
  //      SGR_DIFFUSE
  //      SGR_SPECULAR

  // MatrixMode
  SGR_MODELVIEW                      = $1700;
  SGR_PROJECTION                     = $1701;
  SGR_TEXTURE                        = $1702;

  // MeshMode1
  //      SGR_POINT
  //      SGR_LINE

  // MeshMode2
  //      SGR_POINT
  //      SGR_LINE
  //      SGR_FILL

  // NormalPointerType
  //      SGR_BYTE
  //      SGR_SHORT
  //      SGR_INT
  //      SGR_FLOAT
  //      SGR_DOUBLE

  // PixelCopyType
  SGR_COLOR                          = $1800;
  SGR_DEPTH                          = $1801;
  SGR_STENCIL                        = $1802;

  // PixelFormat
  SGR_COLOR_INDEX                    = $1900;
  SGR_STENCIL_INDEX                  = $1901;
  SGR_DEPTH_COMPONENT                = $1902;
  SGR_RED                            = $1903;
  SGR_GREEN                          = $1904;
  SGR_BLUE                           = $1905;
  SGR_ALPHA                          = $1906;
  SGR_RGB                            = $1907;
  SGR_RGBA                           = $1908;
  SGR_LUMINANCE                      = $1909;
  SGR_LUMINANCE_ALPHA                = $190A;

  // PixelMap
  //      SGR_PIXEL_MAP_I_TO_I
  //      SGR_PIXEL_MAP_S_TO_S
  //      SGR_PIXEL_MAP_I_TO_R
  //      SGR_PIXEL_MAP_I_TO_G
  //      SGR_PIXEL_MAP_I_TO_B
  //      SGR_PIXEL_MAP_I_TO_A
  //      SGR_PIXEL_MAP_R_TO_R
  //      SGR_PIXEL_MAP_G_TO_G
  //      SGR_PIXEL_MAP_B_TO_B
  //      SGR_PIXEL_MAP_A_TO_A

  // PixelStore
  //      SGR_UNPACK_SWAP_BYTES
  //      SGR_UNPACK_LSB_FIRST
  //      SGR_UNPACK_ROW_LENGTH
  //      SGR_UNPACK_SKIP_ROWS
  //      SGR_UNPACK_SKIP_PIXELS
  //      SGR_UNPACK_ALIGNMENT
  //      SGR_PACK_SWAP_BYTES
  //      SGR_PACK_LSB_FIRST
  //      SGR_PACK_ROW_LENGTH
  //      SGR_PACK_SKIP_ROWS
  //      SGR_PACK_SKIP_PIXELS
  //      SGR_PACK_ALIGNMENT

  // PixelTransfer
  //      SGR_MAP_COLOR
  //      SGR_MAP_STENCIL
  //      SGR_INDEX_SHIFT
  //      SGR_INDEX_OFFSET
  //      SGR_RED_SCALE
  //      SGR_RED_BIAS
  //      SGR_GREEN_SCALE
  //      SGR_GREEN_BIAS
  //      SGR_BLUE_SCALE
  //      SGR_BLUE_BIAS
  //      SGR_ALPHA_SCALE
  //      SGR_ALPHA_BIAS
  //      SGR_DEPTH_SCALE
  //      SGR_DEPTH_BIAS

  // PixelType
  SGR_BITMAP                         = $1A00;
  //      SGR_BYTE
  //      SGR_UNSIGNED_BYTE
  //      SGR_SHORT
  //      SGR_UNSIGNED_SHORT
  //      SGR_INT
  //      SGR_UNSIGNED_INT
  //      SGR_FLOAT

  // PolygonMode
  SGR_POINT                          = $1B00;
  SGR_LINE                           = $1B01;
  SGR_FILL                           = $1B02;

  // ReadBufferMode
  //      SGR_FRONT_LEFT
  //      SGR_FRONT_RIGHT
  //      SGR_BACK_LEFT
  //      SGR_BACK_RIGHT
  //      SGR_FRONT
  //      SGR_BACK
  //      SGR_LEFT
  //      SGR_RIGHT
  //      SGR_AUX0
  //      SGR_AUX1
  //      SGR_AUX2
  //      SGR_AUX3

  // RenderingMode
  SGR_RENDER                         = $1C00;
  SGR_FEEDBACK                       = $1C01;
  SGR_SELECT                         = $1C02;

  // ShadingModel
  SGR_FLAT                           = $1D00;
  SGR_SMOOTH                         = $1D01;

  // StencilFunction
  //      SGR_NEVER
  //      SGR_LESS
  //      SGR_EQUAL
  //      SGR_LEQUAL
  //      SGR_GREATER
  //      SGR_NOTEQUAL
  //      SGR_GEQUAL
  //      SGR_ALWAYS

  // StencilOp
  //      SGR_ZERO
  SGR_KEEP                           = $1E00;
  SGR_REPLACE                        = $1E01;
  SGR_INCR                           = $1E02;
  SGR_DECR                           = $1E03;
  //      SGR_INVERT

  // StringName
  SGR_VENDOR                         = $1F00;
  SGR_RENDERER                       = $1F01;
  SGR_VERSION                        = $1F02;
  SGR_EXTENSIONS                     = $1F03;

  // TextureCoordName
  SGR_S                              = $2000;
  SGR_T                              = $2001;
  SGR_R                              = $2002;
  SGR_Q                              = $2003;

  // TexCoordPointerType
  //      SGR_SHORT
  //      SGR_INT
  //      SGR_FLOAT
  //      SGR_DOUBLE

  // TextureEnvMode
  SGR_MODULATE                       = $2100;
  SGR_DECAL                          = $2101;
  //      SGR_BLEND
  //      SGR_REPLACE

  // TextureEnvParameter
  SGR_TEXTURE_ENV_MODE               = $2200;
  SGR_TEXTURE_ENV_COLOR              = $2201;

  // TextureEnvTarget
  SGR_TEXTURE_ENV                    = $2300;

  // TextureGenMode
  SGR_EYE_LINEAR                     = $2400;
  SGR_OBJECT_LINEAR                  = $2401;
  SGR_SPHERE_MAP                     = $2402;

  // TextureGenParameter
  SGR_TEXTURE_GEN_MODE               = $2500;
  SGR_OBJECT_PLANE                   = $2501;
  SGR_EYE_PLANE                      = $2502;

  // TextureMagFilter
  SGR_NEAREST                        = $2600;
  SGR_LINEAR                         = $2601;

  // TextureMinFilter
  //      SGR_NEAREST
  //      SGR_LINEAR
  SGR_NEAREST_MIPMAP_NEAREST         = $2700;
  SGR_LINEAR_MIPMAP_NEAREST          = $2701;
  SGR_NEAREST_MIPMAP_LINEAR          = $2702;
  SGR_LINEAR_MIPMAP_LINEAR           = $2703;

  // TextureParameterName
  SGR_TEXTURE_MAG_FILTER             = $2800;
  SGR_TEXTURE_MIN_FILTER             = $2801;
  SGR_TEXTURE_WRAP_S                 = $2802;
  SGR_TEXTURE_WRAP_T                 = $2803;
  //      SGR_TEXTURE_BORDER_COLOR
  //      SGR_TEXTURE_PRIORITY

  // TextureTarget
  //      SGR_TEXTURE_1D
  //      SGR_TEXTURE_2D
  //      SGR_PROXY_TEXTURE_1D
  //      SGR_PROXY_TEXTURE_2D

  // TextureWrapMode
  SGR_CLAMP                          = $2900;
  SGR_REPEAT                         = $2901;

  // VertexPointerType
  //      SGR_SHORT
  //      SGR_INT
  //      SGR_FLOAT
  //      SGR_DOUBLE

  // ClientAttribMask
  SGR_CLIENT_PIXEL_STORE_BIT         = $00000001;
  SGR_CLIENT_VERTEX_ARRAY_BIT        = $00000002;
  SGR_CLIENT_ALL_ATTRIB_BITS         = $FFFFFFFF;

  // polygon_offset
  SGR_POLYGON_OFFSET_FACTOR          = $8038;
  SGR_POLYGON_OFFSET_UNITS           = $2A00;
  SGR_POLYGON_OFFSET_POINT           = $2A01;
  SGR_POLYGON_OFFSET_LINE            = $2A02;
  SGR_POLYGON_OFFSET_FILL            = $8037;

  // texture
  SGR_ALPHA4                         = $803B;
  SGR_ALPHA8                         = $803C;
  SGR_ALPHA12                        = $803D;
  SGR_ALPHA16                        = $803E;
  SGR_LUMINANCE4                     = $803F;
  SGR_LUMINANCE8                     = $8040;
  SGR_LUMINANCE12                    = $8041;
  SGR_LUMINANCE16                    = $8042;
  SGR_LUMINANCE4_ALPHA4              = $8043;
  SGR_LUMINANCE6_ALPHA2              = $8044;
  SGR_LUMINANCE8_ALPHA8              = $8045;
  SGR_LUMINANCE12_ALPHA4             = $8046;
  SGR_LUMINANCE12_ALPHA12            = $8047;
  SGR_LUMINANCE16_ALPHA16            = $8048;
  SGR_INTENSITY                      = $8049;
  SGR_INTENSITY4                     = $804A;
  SGR_INTENSITY8                     = $804B;
  SGR_INTENSITY12                    = $804C;
  SGR_INTENSITY16                    = $804D;
  SGR_R3_G3_B2                       = $2A10;
  SGR_RGB4                           = $804F;
  SGR_RGB5                           = $8050;
  SGR_RGB8                           = $8051;
  SGR_RGB10                          = $8052;
  SGR_RGB12                          = $8053;
  SGR_RGB16                          = $8054;
  SGR_RGBA2                          = $8055;
  SGR_RGBA4                          = $8056;
  SGR_RGB5_A1                        = $8057;
  SGR_RGBA8                          = $8058;
  SGR_RGB10_A2                       = $8059;
  SGR_RGBA12                         = $805A;
  SGR_RGBA16                         = $805B;
  SGR_TEXTURE_RED_SIZE               = $805C;
  SGR_TEXTURE_GREEN_SIZE             = $805D;
  SGR_TEXTURE_BLUE_SIZE              = $805E;
  SGR_TEXTURE_ALPHA_SIZE             = $805F;
  SGR_TEXTURE_LUMINANCE_SIZE         = $8060;
  SGR_TEXTURE_INTENSITY_SIZE         = $8061;
  SGR_PROXY_TEXTURE_1D               = $8063;
  SGR_PROXY_TEXTURE_2D               = $8064;

  // texture_object
  SGR_TEXTURE_PRIORITY               = $8066;
  SGR_TEXTURE_RESIDENT               = $8067;
  SGR_TEXTURE_BINDING_1D             = $8068;
  SGR_TEXTURE_BINDING_2D             = $8069;

  // vertex_array
  SGR_VERTEX_ARRAY                   = $8074;
  SGR_NORMAL_ARRAY                   = $8075;
  SGR_COLOR_ARRAY                    = $8076;
  SGR_INDEX_ARRAY                    = $8077;
  SGR_TEXTURE_COORD_ARRAY            = $8078;
  SGR_EDGE_FLAG_ARRAY                = $8079;
  SGR_VERTEX_ARRAY_SIZE              = $807A;
  SGR_VERTEX_ARRAY_TYPE              = $807B;
  SGR_VERTEX_ARRAY_STRIDE            = $807C;
  SGR_NORMAL_ARRAY_TYPE              = $807E;
  SGR_NORMAL_ARRAY_STRIDE            = $807F;
  SGR_COLOR_ARRAY_SIZE               = $8081;
  SGR_COLOR_ARRAY_TYPE               = $8082;
  SGR_COLOR_ARRAY_STRIDE             = $8083;
  SGR_INDEX_ARRAY_TYPE               = $8085;
  SGR_INDEX_ARRAY_STRIDE             = $8086;
  SGR_TEXTURE_COORD_ARRAY_SIZE       = $8088;
  SGR_TEXTURE_COORD_ARRAY_TYPE       = $8089;
  SGR_TEXTURE_COORD_ARRAY_STRIDE     = $808A;
  SGR_EDGE_FLAG_ARRAY_STRIDE         = $808C;
  SGR_VERTEX_ARRAY_POINTER           = $808E;
  SGR_NORMAL_ARRAY_POINTER           = $808F;
  SGR_COLOR_ARRAY_POINTER            = $8090;
  SGR_INDEX_ARRAY_POINTER            = $8091;
  SGR_TEXTURE_COORD_ARRAY_POINTER    = $8092;
  SGR_EDGE_FLAG_ARRAY_POINTER        = $8093;
  SGR_V2F                            = $2A20;
  SGR_V3F                            = $2A21;
  SGR_C4UB_V2F                       = $2A22;
  SGR_C4UB_V3F                       = $2A23;
  SGR_C3F_V3F                        = $2A24;
  SGR_N3F_V3F                        = $2A25;
  SGR_C4F_N3F_V3F                    = $2A26;
  SGR_T2F_V3F                        = $2A27;
  SGR_T4F_V4F                        = $2A28;
  SGR_T2F_C4UB_V3F                   = $2A29;
  SGR_T2F_C3F_V3F                    = $2A2A;
  SGR_T2F_N3F_V3F                    = $2A2B;
  SGR_T2F_C4F_N3F_V3F                = $2A2C;
  SGR_T4F_C4F_N3F_V4F                = $2A2D;

  // For compatibility with OpenSG v1.0
  SGR_LOGIC_OP                       = SGR_INDEX_LOGIC_OP;
  SGR_TEXTURE_COMPONENTS             = SGR_TEXTURE_INTERNAL_FORMAT;
  
  
{***** GL_ARB_vertex_buffer_object *****}
const
     SGR_BUFFER_SIZE_ARB = $8764;
     SGR_BUFFER_USAGE_ARB = $8765;
     SGR_ARRAY_BUFFER_ARB = $8892;
     SGR_ELEMENT_ARRAY_BUFFER_ARB = $8893;
     SGR_ARRAY_BUFFER_BINDING_ARB = $8894;
     SGR_ELEMENT_ARRAY_BUFFER_BINDING_ARB = $8895;
     SGR_VERTEX_ARRAY_BUFFER_BINDING_ARB = $8896;
     SGR_NORMAL_ARRAY_BUFFER_BINDING_ARB = $8897;
     SGR_COLOR_ARRAY_BUFFER_BINDING_ARB = $8898;
     SGR_INDEX_ARRAY_BUFFER_BINDING_ARB = $8899;
     SGR_TEXTURE_COORD_ARRAY_BUFFER_BINDING_ARB = $889A;
     SGR_EDGE_FLAG_ARRAY_BUFFER_BINDING_ARB = $889B;
     SGR_SECONDARY_COLOR_ARRAY_BUFFER_BINDING_ARB = $889C;
     SGR_FOG_COORDINATE_ARRAY_BUFFER_BINDING_ARB = $889D;
     SGR_WEIGHT_ARRAY_BUFFER_BINDING_ARB = $889E;
     SGR_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING_ARB = $889F;
     SGR_READ_ONLY_ARB = $88B8;
     SGR_WRITE_ONLY_ARB = $88B9;
     SGR_READ_WRITE_ARB = $88BA;
     SGR_BUFFER_ACCESS_ARB = $88BB;
     SGR_BUFFER_MAPPED_ARB = $88BC;
     SGR_BUFFER_MAP_POINTER_ARB = $88BD;
     SGR_STREAM_DRAW_ARB = $88E0;
     SGR_STREAM_READ_ARB = $88E1;
     SGR_STREAM_COPY_ARB = $88E2;
     SGR_STATIC_DRAW_ARB = $88E4;
     SGR_STATIC_READ_ARB = $88E5;
     SGR_STATIC_COPY_ARB = $88E6;
     SGR_DYNAMIC_DRAW_ARB = $88E8;
     SGR_DYNAMIC_READ_ARB = $88E9;
     SGR_DYNAMIC_COPY_ARB = $88EA;    

//***** SGR_EXT_vertex_shader *****//
const
  SGR_VERTEX_SHADER_EXT = $8780;
  SGR_VARIANT_VALUE_EXT = $87E4;
  SGR_VARIANT_DATATYPE_EXT = $87E5;
  SGR_VARIANT_ARRAY_STRIDE_EXT = $87E6;
  SGR_VARIANT_ARRAY_TYPE_EXT = $87E7;
  SGR_VARIANT_ARRAY_EXT = $87E8;
  SGR_VARIANT_ARRAY_POINTER_EXT = $87E9;
  SGR_INVARIANT_VALUE_EXT = $87EA;
  SGR_INVARIANT_DATATYPE_EXT = $87EB;
  SGR_LOCAL_CONSTANT_VALUE_EXT = $87EC;
  SGR_LOCAL_CONSTANT_DATATYPE_EXT = $87ED;
  SGR_OP_INDEX_EXT = $8782;
  SGR_OP_NEGATE_EXT = $8783;
  SGR_OP_DOT3_EXT = $8784;
  SGR_OP_DOT4_EXT = $8785;
  SGR_OP_MUL_EXT = $8786;
  SGR_OP_ADD_EXT = $8787;
  SGR_OP_MADD_EXT = $8788;
  SGR_OP_FRAC_EXT = $8789;
  SGR_OP_MAX_EXT = $878A;
  SGR_OP_MIN_EXT = $878B;
  SGR_OP_SET_GE_EXT = $878C;
  SGR_OP_SET_LT_EXT = $878D;
  SGR_OP_CLAMP_EXT = $878E;
  SGR_OP_FLOOR_EXT = $878F;
  SGR_OP_ROUND_EXT = $8790;
  SGR_OP_EXP_BASE_2_EXT = $8791;
  SGR_OP_LOG_BASE_2_EXT = $8792;
  SGR_OP_POWER_EXT = $8793;
  SGR_OP_RECIP_EXT = $8794;
  SGR_OP_RECIP_SQRT_EXT = $8795;
  SGR_OP_SUB_EXT = $8796;
  SGR_OP_CROSS_PRODUCT_EXT = $8797;
  SGR_OP_MULTIPLY_MATRIX_EXT = $8798;
  SGR_OP_MOV_EXT = $8799;
  SGR_OUTPUT_VERTEX_EXT = $879A;
  SGR_OUTPUT_COLOR0_EXT = $879B;
  SGR_OUTPUT_COLOR1_EXT = $879C;
  SGR_OUTPUT_TEXTURE_COORD0_EXT = $879D;
  SGR_OUTPUT_TEXTURE_COORD1_EXT = $879E;
  SGR_OUTPUT_TEXTURE_COORD2_EXT = $879F;
  SGR_OUTPUT_TEXTURE_COORD3_EXT = $87A0;
  SGR_OUTPUT_TEXTURE_COORD4_EXT = $87A1;
  SGR_OUTPUT_TEXTURE_COORD5_EXT = $87A2;
  SGR_OUTPUT_TEXTURE_COORD6_EXT = $87A3;
  SGR_OUTPUT_TEXTURE_COORD7_EXT = $87A4;
  SGR_OUTPUT_TEXTURE_COORD8_EXT = $87A5;
  SGR_OUTPUT_TEXTURE_COORD9_EXT = $87A6;
  SGR_OUTPUT_TEXTURE_COORD10_EXT = $87A7;
  SGR_OUTPUT_TEXTURE_COORD11_EXT = $87A8;
  SGR_OUTPUT_TEXTURE_COORD12_EXT = $87A9;
  SGR_OUTPUT_TEXTURE_COORD13_EXT = $87AA;
  SGR_OUTPUT_TEXTURE_COORD14_EXT = $87AB;
  SGR_OUTPUT_TEXTURE_COORD15_EXT = $87AC;
  SGR_OUTPUT_TEXTURE_COORD16_EXT = $87AD;
  SGR_OUTPUT_TEXTURE_COORD17_EXT = $87AE;
  SGR_OUTPUT_TEXTURE_COORD18_EXT = $87AF;
  SGR_OUTPUT_TEXTURE_COORD19_EXT = $87B0;
  SGR_OUTPUT_TEXTURE_COORD20_EXT = $87B1;
  SGR_OUTPUT_TEXTURE_COORD21_EXT = $87B2;
  SGR_OUTPUT_TEXTURE_COORD22_EXT = $87B3;
  SGR_OUTPUT_TEXTURE_COORD23_EXT = $87B4;
  SGR_OUTPUT_TEXTURE_COORD24_EXT = $87B5;
  SGR_OUTPUT_TEXTURE_COORD25_EXT = $87B6;
  SGR_OUTPUT_TEXTURE_COORD26_EXT = $87B7;
  SGR_OUTPUT_TEXTURE_COORD27_EXT = $87B8;
  SGR_OUTPUT_TEXTURE_COORD28_EXT = $87B9;
  SGR_OUTPUT_TEXTURE_COORD29_EXT = $87BA;
  SGR_OUTPUT_TEXTURE_COORD30_EXT = $87BB;
  SGR_OUTPUT_TEXTURE_COORD31_EXT = $87BC;
  SGR_OUTPUT_FOG_EXT = $87BD;
  SGR_SCALAR_EXT = $87BE;
  SGR_VECTOR_EXT = $87BF;
  SGR_MATRIX_EXT = $87C0;
  SGR_VARIANT_EXT = $87C1;
  SGR_INVARIANT_EXT = $87C2;
  SGR_LOCAL_CONSTANT_EXT = $87C3;
  SGR_LOCAL_EXT = $87C4;
  SGR_MAX_VERTEX_SHADER_INSTRUCTIONS_EXT = $87C5;
  SGR_MAX_VERTEX_SHADER_VARIANTS_EXT = $87C6;
  SGR_MAX_VERTEX_SHADER_INVARIANTS_EXT = $87C7;
  SGR_MAX_VERTEX_SHADER_LOCAL_CONSTANTS_EXT = $87C8;
  SGR_MAX_VERTEX_SHADER_LOCALS_EXT = $87C9;
  SGR_MAX_OPTIMIZED_VERTEX_SHADER_INSTRUCTIONS_EXT = $87CA;
  SGR_MAX_OPTIMIZED_VERTEX_SHADER_VARIANTS_EXT = $87CB;
  SGR_MAX_OPTIMIZED_VERTEX_SHADER_LOCAL_CONSTANTS_EXT = $87CC;
  SGR_MAX_OPTIMIZED_VERTEX_SHADER_INVARIANTS_EXT = $87CD;
  SGR_MAX_OPTIMIZED_VERTEX_SHADER_LOCALS_EXT = $87CE;
  SGR_VERTEX_SHADER_INSTRUCTIONS_EXT = $87CF;
  SGR_VERTEX_SHADER_VARIANTS_EXT = $87D0;
  SGR_VERTEX_SHADER_INVARIANTS_EXT = $87D1;
  SGR_VERTEX_SHADER_LOCAL_CONSTANTS_EXT = $87D2;
  SGR_VERTEX_SHADER_LOCALS_EXT = $87D3;
  SGR_VERTEX_SHADER_BINDING_EXT = $8781;
  SGR_VERTEX_SHADER_OPTIMIZED_EXT = $87D4;
  SGR_X_EXT = $87D5;
  SGR_Y_EXT = $87D6;
  SGR_Z_EXT = $87D7;
  SGR_W_EXT = $87D8;
  SGR_NEGATIVE_X_EXT = $87D9;
  SGR_NEGATIVE_Y_EXT = $87DA;
  SGR_NEGATIVE_Z_EXT = $87DB;
  SGR_NEGATIVE_W_EXT = $87DC;
  SGR_ZERO_EXT = $87DD;
  SGR_ONE_EXT = $87DE;
  SGR_NEGATIVE_ONE_EXT = $87DF;
  SGR_NORMALIZED_RANGE_EXT = $87E0;
  SGR_FULL_RANGE_EXT = $87E1;
  SGR_CURRENT_VERTEX_EXT = $87E2;
  SGR_MVP_MATRIX_EXT = $87E3;

//***** SGR_version_2_0 *****//
const
  SGR_BLEND_EQUATION_RGB = $8009;
  SGR_VERTEX_ATTRIB_ARRAY_ENABLED = $8622;
  SGR_VERTEX_ATTRIB_ARRAY_SIZE = $8623;
  SGR_VERTEX_ATTRIB_ARRAY_STRIDE = $8624;
  SGR_VERTEX_ATTRIB_ARRAY_TYPE = $8625;
  SGR_CURRENT_VERTEX_ATTRIB = $8626;
  SGR_VERTEX_PROGRAM_POINT_SIZE = $8642;
  SGR_VERTEX_PROGRAM_TWO_SIDE = $8643;
  SGR_VERTEX_ATTRIB_ARRAY_POINTER = $8645;
  SGR_STENCIL_BACK_FUNC = $8800;
  SGR_STENCIL_BACK_FAIL = $8801;
  SGR_STENCIL_BACK_PASS_DEPTH_FAIL = $8802;
  SGR_STENCIL_BACK_PASS_DEPTH_PASS = $8803;
  SGR_MAX_DRAW_BUFFERS = $8824;
  SGR_DRAW_BUFFER0 = $8825;
  SGR_DRAW_BUFFER1 = $8826;
  SGR_DRAW_BUFFER2 = $8827;
  SGR_DRAW_BUFFER3 = $8828;
  SGR_DRAW_BUFFER4 = $8829;
  SGR_DRAW_BUFFER5 = $882A;
  SGR_DRAW_BUFFER6 = $882B;
  SGR_DRAW_BUFFER7 = $882C;
  SGR_DRAW_BUFFER8 = $882D;
  SGR_DRAW_BUFFER9 = $882E;
  SGR_DRAW_BUFFER10 = $882F;
  SGR_DRAW_BUFFER11 = $8830;
  SGR_DRAW_BUFFER12 = $8831;
  SGR_DRAW_BUFFER13 = $8832;
  SGR_DRAW_BUFFER14 = $8833;
  SGR_DRAW_BUFFER15 = $8834;
  SGR_BLEND_EQUATION_ALPHA = $883D;
  SGR_POINT_SPRITE = $8861;
  SGR_COORD_REPLACE = $8862;
  SGR_MAX_VERTEX_ATTRIBS = $8869;
  SGR_VERTEX_ATTRIB_ARRAY_NORMALIZED = $886A;
  SGR_MAX_TEXTURE_COORDS = $8871;
  SGR_MAX_TEXTURE_IMAGE_UNITS = $8872;
  SGR_FRAGMENT_SHADER = $8B30;
  SGR_VERTEX_SHADER = $8B31;
  SGR_MAX_FRAGMENT_UNIFORM_COMPONENTS = $8B49;
  SGR_MAX_VERTEX_UNIFORM_COMPONENTS = $8B4A;
  SGR_MAX_VARYING_FLOATS = $8B4B;
  SGR_MAX_VERTEX_TEXTURE_IMAGE_UNITS = $8B4C;
  SGR_MAX_COMBINED_TEXTURE_IMAGE_UNITS = $8B4D;
  SGR_SHADER_TYPE = $8B4F;
  SGR_FLOAT_VEC2 = $8B50;
  SGR_FLOAT_VEC3 = $8B51;
  SGR_FLOAT_VEC4 = $8B52;
  SGR_INT_VEC2 = $8B53;
  SGR_INT_VEC3 = $8B54;
  SGR_INT_VEC4 = $8B55;
  SGR_BOOL = $8B56;
  SGR_BOOL_VEC2 = $8B57;
  SGR_BOOL_VEC3 = $8B58;
  SGR_BOOL_VEC4 = $8B59;
  SGR_FLOAT_MAT2 = $8B5A;
  SGR_FLOAT_MAT3 = $8B5B;
  SGR_FLOAT_MAT4 = $8B5C;
  SGR_SAMPLER_1D = $8B5D;
  SGR_SAMPLER_2D = $8B5E;
  SGR_SAMPLER_3D = $8B5F;
  SGR_SAMPLER_CUBE = $8B60;
  SGR_SAMPLER_1D_SHADOW = $8B61;
  SGR_SAMPLER_2D_SHADOW = $8B62;
  SGR_DELETE_STATUS = $8B80;
  SGR_COMPILE_STATUS = $8B81;
  SGR_LINK_STATUS = $8B82;
  SGR_VALIDATE_STATUS = $8B83;
  SGR_INFO_LOG_LENGTH = $8B84;
  SGR_ATTACHED_SHADERS = $8B85;
  SGR_ACTIVE_UNIFORMS = $8B86;
  SGR_ACTIVE_UNIFORM_MAX_LENGTH = $8B87;
  SGR_SHADER_SOURCE_LENGTH = $8B88;
  SGR_ACTIVE_ATTRIBUTES = $8B89;
  SGR_ACTIVE_ATTRIBUTE_MAX_LENGTH = $8B8A;
  SGR_FRAGMENT_SHADER_DERIVATIVE_HINT = $8B8B;
  SGR_SHADING_LANGUAGE_VERSION = $8B8C;
  SGR_CURRENT_PROGRAM = $8B8D;
  SGR_POINT_SPRITE_COORD_ORIGIN = $8CA0;
  SGR_LOWER_LEFT = $8CA1;
  SGR_UPPER_LEFT = $8CA2;
  SGR_STENCIL_BACK_REF = $8CA3;
  SGR_STENCIL_BACK_VALUE_MASK = $8CA4;
  SGR_STENCIL_BACK_WRITEMASK = $8CA5;
  
  //**** SGR_VERSION_2_1 DEPRECATED *****//
const
  SGR_CURRENT_RASTER_SECONDARY_COLOR = $845F;
  SGR_SLUMINANCE_ALPHA = $8C44;
  SGR_SLUMINANCE8_ALPHA8 = $8C45;
  SGR_SLUMINANCE = $8C46;
  SGR_SLUMINANCE8 = $8C47;
  SGR_COMPRESSED_SLUMINANCE = $8C4A;
  SGR_COMPRESSED_SLUMINANCE_ALPHA = $8C4B;

//**** SGR_VERSION_3_0 *****//

const
  SGR_COMPARE_REF_TO_TEXTURE = $884E;
  SGR_CLIP_DISTANCE0 = $3000;
  SGR_CLIP_DISTANCE1 = $3001;
  SGR_CLIP_DISTANCE2 = $3002;
  SGR_CLIP_DISTANCE3 = $3003;
  SGR_CLIP_DISTANCE4 = $3004;
  SGR_CLIP_DISTANCE5 = $3005;
  SGR_CLIP_DISTANCE6 = $3006;
  SGR_CLIP_DISTANCE7 = $3007;
  SGR_MAX_CLIP_DISTANCES = $0D32;
  SGR_MAJOR_VERSION = $821B;
  SGR_MINOR_VERSION = $821C;
  SGR_NUM_EXTENSIONS = $821D;
  SGR_CONTEXT_FLAGS = $821E;
  SGR_DEPTH_BUFFER = $8223;
  SGR_STENCIL_BUFFER = $8224;
  SGR_COMPRESSED_RED = $8225;
  SGR_COMPRESSED_RG = $8226;
  SGR_CONTEXT_FLAG_FORWARD_COMPATIBLE_BIT = $0001;
  SGR_RGBA32F = $8814;
  SGR_RGB32F = $8815;
  SGR_RGBA16F = $881A;
  SGR_RGB16F = $881B;
  SGR_VERTEX_ATTRIB_ARRAY_INTEGER = $88FD;
  SGR_MAX_ARRAY_TEXTURE_LAYERS = $88FF;
  SGR_MIN_PROGRAM_TEXEL_OFFSET = $8904;
  SGR_MAX_PROGRAM_TEXEL_OFFSET = $8905;
  SGR_CLAMP_READ_COLOR = $891C;
  SGR_FIXED_ONLY = $891D;
  SGR_MAX_VARYING_COMPONENTS = $8B4B;
  SGR_TEXTURE_1D_ARRAY = $8C18;
  SGR_PROXY_TEXTURE_1D_ARRAY = $8C19;
  SGR_TEXTURE_2D_ARRAY = $8C1A;
  SGR_PROXY_TEXTURE_2D_ARRAY = $8C1B;
  SGR_TEXTURE_BINDING_1D_ARRAY = $8C1C;
  SGR_TEXTURE_BINDING_2D_ARRAY = $8C1D;
  SGR_R11F_G11F_B10F = $8C3A;
  SGR_UNSIGNED_INT_10F_11F_11F_REV = $8C3B;
  SGR_RGB9_E5 = $8C3D;
  SGR_UNSIGNED_INT_5_9_9_9_REV = $8C3E;
  SGR_TEXTURE_SHARED_SIZE = $8C3F;
  SGR_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH = $8C76;
  SGR_TRANSFORM_FEEDBACK_BUFFER_MODE = $8C7F;
  SGR_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS = $8C80;
  SGR_TRANSFORM_FEEDBACK_VARYINGS = $8C83;
  SGR_TRANSFORM_FEEDBACK_BUFFER_START = $8C84;
  SGR_TRANSFORM_FEEDBACK_BUFFER_SIZE = $8C85;
  SGR_PRIMITIVES_GENERATED = $8C87;
  SGR_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN = $8C88;
  SGR_RASTERIZER_DISCARD = $8C89;
  SGR_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS = $8C8A;
  SGR_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS = $8C8B;
  SGR_INTERLEAVED_ATTRIBS = $8C8C;
  SGR_SEPARATE_ATTRIBS = $8C8D;
  SGR_TRANSFORM_FEEDBACK_BUFFER = $8C8E;
  SGR_TRANSFORM_FEEDBACK_BUFFER_BINDING = $8C8F;
  SGR_RGBA32UI = $8D70;
  SGR_RGB32UI = $8D71;
  SGR_RGBA16UI = $8D76;
  SGR_RGB16UI = $8D77;
  SGR_RGBA8UI = $8D7C;
  SGR_RGB8UI = $8D7D;
  SGR_RGBA32I = $8D82;
  SGR_RGB32I = $8D83;
  SGR_RGBA16I = $8D88;
  SGR_RGB16I = $8D89;
  SGR_RGBA8I = $8D8E;
  SGR_RGB8I = $8D8F;
  SGR_RED_INTEGER = $8D94;
  SGR_GREEN_INTEGER = $8D95;
  SGR_BLUE_INTEGER = $8D96;
  SGR_RGB_INTEGER = $8D98;
  SGR_RGBA_INTEGER = $8D99;
  SGR_BGR_INTEGER = $8D9A;
  SGR_BGRA_INTEGER = $8D9B;
  SGR_SAMPLER_1D_ARRAY = $8DC0;
  SGR_SAMPLER_2D_ARRAY = $8DC1;
  SGR_SAMPLER_1D_ARRAY_SHADOW = $8DC3;
  SGR_SAMPLER_2D_ARRAY_SHADOW = $8DC4;
  SGR_SAMPLER_CUBE_SHADOW = $8DC5;
  SGR_UNSIGNED_INT_VEC2 = $8DC6;
  SGR_UNSIGNED_INT_VEC3 = $8DC7;
  SGR_UNSIGNED_INT_VEC4 = $8DC8;
  SGR_INT_SAMPLER_1D = $8DC9;
  SGR_INT_SAMPLER_2D = $8DCA;
  SGR_INT_SAMPLER_3D = $8DCB;
  SGR_INT_SAMPLER_CUBE = $8DCC;
  SGR_INT_SAMPLER_1D_ARRAY = $8DCE;
  SGR_INT_SAMPLER_2D_ARRAY = $8DCF;
  SGR_UNSIGNED_INT_SAMPLER_1D = $8DD1;
  SGR_UNSIGNED_INT_SAMPLER_2D = $8DD2;
  SGR_UNSIGNED_INT_SAMPLER_3D = $8DD3;
  SGR_UNSIGNED_INT_SAMPLER_CUBE = $8DD4;
  SGR_UNSIGNED_INT_SAMPLER_1D_ARRAY = $8DD6;
  SGR_UNSIGNED_INT_SAMPLER_2D_ARRAY = $8DD7;
  SGR_QUERY_WAIT = $8E13;
  SGR_QUERY_NO_WAIT = $8E14;
  SGR_QUERY_BY_REGION_WAIT = $8E15;
  SGR_QUERY_BY_REGION_NO_WAIT = $8E16;
  SGR_BUFFER_ACCESS_FLAGS = $911F;
  SGR_BUFFER_MAP_LENGTH = $9120;
  SGR_BUFFER_MAP_OFFSET = $9121;
 //**** SGR_VERSION_3_0 DEPRECATED *****//
const
  SGR_CLAMP_VERTEX_COLOR = $891A;
  SGR_CLAMP_FRAGMENT_COLOR = $891B;
  SGR_ALPHA_INTEGER = $8D97;

//**** SGR_VERSION_3_1 *****//
const
  SGR_SAMPLER_2D_RECT = $8B63;
  SGR_SAMPLER_2D_RECT_SHADOW = $8B64;
  SGR_SAMPLER_BUFFER = $8DC2;
  SGR_INT_SAMPLER_2D_RECT = $8DCD;
  SGR_INT_SAMPLER_BUFFER = $8DD0;
  SGR_UNSIGNED_INT_SAMPLER_2D_RECT = $8DD5;
  SGR_UNSIGNED_INT_SAMPLER_BUFFER = $8DD8;
  SGR_TEXTURE_BUFFER = $8C2A;
  SGR_MAX_TEXTURE_BUFFER_SIZE = $8C2B;
  SGR_TEXTURE_BINDING_BUFFER = $8C2C;
  SGR_TEXTURE_BUFFER_DATA_STORE_BINDING = $8C2D;
  SGR_TEXTURE_BUFFER_FORMAT = $8C2E;
  SGR_TEXTURE_RECTANGLE = $84F5;
  SGR_TEXTURE_BINDING_RECTANGLE = $84F6;
  SGR_PROXY_TEXTURE_RECTANGLE = $84F7;
  SGR_MAX_RECTANGLE_TEXTURE_SIZE = $84F8;
  SGR_RED_SNORM = $8F90;
  SGR_RG_SNORM = $8F91;
  SGR_RGB_SNORM = $8F92;
  SGR_RGBA_SNORM = $8F93;
  SGR_R8_SNORM = $8F94;
  SGR_RG8_SNORM = $8F95;
  SGR_RGB8_SNORM = $8F96;
  SGR_RGBA8_SNORM = $8F97;
  SGR_R16_SNORM = $8F98;
  SGR_RG16_SNORM = $8F99;
  SGR_RGB16_SNORM = $8F9A;
  SGR_RGBA16_SNORM = $8F9B;
  SGR_SIGNED_NORMALIZED = $8F9C;
  SGR_PRIMITIVE_RESTART = $8F9D;
  SGR_PRIMITIVE_RESTART_INDEX = $8F9E;
  
  
//**** SGR_VERSION_3_2 *****//
const
  SGR_CONTEXT_CORE_PROFILE_BIT = $00000001;
  SGR_CONTEXT_COMPATIBILITY_PROFILE_BIT = $00000002;
  SGR_LINES_ADJACENCY = $000A;
  SGR_LINE_STRIP_ADJACENCY = $000B;
  SGR_TRIANGLES_ADJACENCY = $000C;
  SGR_TRIANGLE_STRIP_ADJACENCY = $000D;
  SGR_PROGRAM_POINT_SIZE = $8642;
  SGR_MAX_GEOMETRY_TEXTURE_IMAGE_UNITS = $8C29;
  SGR_FRAMEBUFFER_ATTACHMENT_LAYERED = $8DA7;
  SGR_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS = $8DA8;
  SGR_GEOMETRY_SHADER = $8DD9;
  SGR_GEOMETRY_VERTICES_OUT = $8916;
  SGR_GEOMETRY_INPUT_TYPE = $8917;
  SGR_GEOMETRY_OUTPUT_TYPE = $8918;
  SGR_MAX_GEOMETRY_UNIFORM_COMPONENTS = $8DDF;
  SGR_MAX_GEOMETRY_OUTPUT_VERTICES = $8DE0;
  SGR_MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS = $8DE1;
  SGR_MAX_VERTEX_OUTPUT_COMPONENTS = $9122;
  SGR_MAX_GEOMETRY_INPUT_COMPONENTS = $9123;
  SGR_MAX_GEOMETRY_OUTPUT_COMPONENTS = $9124;
  SGR_MAX_FRAGMENT_INPUT_COMPONENTS = $9125;
  SGR_CONTEXT_PROFILE_MASK = $9126;
