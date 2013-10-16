const
  SG_ACCUM                          = $0100;
  SG_LOAD                           = $0101;
  SG_RETURN                         = $0102;
  SG_MULT                           = $0103;
  SG_ADD                            = $0104;

  // AlphaFunction
  SG_NEVER                          = $0200;
  SG_LESS                           = $0201;
  SG_EQUAL                          = $0202;
  SG_LEQUAL                         = $0203;
  SG_GREATER                        = $0204;
  SG_NOTEQUAL                       = $0205;
  SG_GEQUAL                         = $0206;
  SG_ALWAYS                         = $0207;

  // AttribMask
  SG_CURRENT_BIT                    = $00000001;
  SG_POINT_BIT                      = $00000002;
  SG_LINE_BIT                       = $00000004;
  SG_POLYGON_BIT                    = $00000008;
  SG_POLYGON_STIPPLE_BIT            = $00000010;
  SG_PIXEL_MODE_BIT                 = $00000020;
  SG_LIGHTING_BIT                   = $00000040;
  SG_FOG_BIT                        = $00000080;
  SG_DEPTH_BUFFER_BIT               = $00000100;
  SG_ACCUM_BUFFER_BIT               = $00000200;
  SG_STENCIL_BUFFER_BIT             = $00000400;
  SG_VIEWPORT_BIT                   = $00000800;
  SG_TRANSFORM_BIT                  = $00001000;
  SG_ENABLE_BIT                     = $00002000;
  SG_COLOR_BUFFER_BIT               = $00004000;
  SG_HINT_BIT                       = $00008000;
  SG_EVAL_BIT                       = $00010000;
  SG_LIST_BIT                       = $00020000;
  SG_TEXTURE_BIT                    = $00040000;
  SG_SCISSOR_BIT                    = $00080000;
  SG_ALL_ATTRIB_BITS                = $000FFFFF;

  // BeginMode
  SG_POINTS                         = $0000;
  SG_LINES                          = $0001;
  SG_LINE_LOOP                      = $0002;
  SG_LINE_STRIP                     = $0003;
  SG_TRIANGLES                      = $0004;
  SG_TRIANGLE_STRIP                 = $0005;
  SG_TRIANGLE_FAN                   = $0006;
  SG_QUADS                          = $0007;
  SG_QUAD_STRIP                     = $0008;
  SG_POLYGON                        = $0009;

  // BlendingFactorDest
  SG_ZERO                           = 0;
  SG_ONE                            = 1;
  SG_SRC_COLOR                      = $0300;
  SG_ONE_MINUS_SRC_COLOR            = $0301;
  SG_SRC_ALPHA                      = $0302;
  SG_ONE_MINUS_SRC_ALPHA            = $0303;
  SG_DST_ALPHA                      = $0304;
  SG_ONE_MINUS_DST_ALPHA            = $0305;

  // BlendingFactorSrc
  //      SG_ZERO
  //      SG_ONE
  SG_DST_COLOR                      = $0306;
  SG_ONE_MINUS_DST_COLOR            = $0307;
  SG_SRC_ALPHA_SATURATE             = $0308;
  //      SG_SRC_ALPHA
  //      SG_ONE_MINUS_SRC_ALPHA
  //      SG_DST_ALPHA
  //      SG_ONE_MINUS_DST_ALPHA

  // Boolean
  SG_TRUE                           = 1;
  SG_FALSE                          = 0;

  // ClearBufferMask
  //      SG_COLOR_BUFFER_BIT
  //      SG_ACCUM_BUFFER_BIT
  //      SG_STENCIL_BUFFER_BIT
  //      SG_DEPTH_BUFFER_BIT

  // ClientArrayType
  //      SG_VERTEX_ARRAY
  //      SG_NORMAL_ARRAY
  //      SG_COLOR_ARRAY
  //      SG_INDEX_ARRAY
  //      SG_TEXTURE_COORD_ARRAY
  //      SG_EDGE_FLAG_ARRAY

  // ClipPlaneName
  SG_CLIP_PLANE0                    = $3000;
  SG_CLIP_PLANE1                    = $3001;
  SG_CLIP_PLANE2                    = $3002;
  SG_CLIP_PLANE3                    = $3003;
  SG_CLIP_PLANE4                    = $3004;
  SG_CLIP_PLANE5                    = $3005;

  // ColorMaterialFace
  //      SG_FRONT
  //      SG_BACK
  //      SG_FRONT_AND_BACK

  // ColorMaterialParameter
  //      SG_AMBIENT
  //      SG_DIFFUSE
  //      SG_SPECULAR
  //      SG_EMISSION
  //      SG_AMBIENT_AND_DIFFUSE

  // ColorPointerType
  //      SG_BYTE
  //      SG_UNSIGNED_BYTE
  //      SG_SHORT
  //      SG_UNSIGNED_SHORT
  //      SG_INT
  //      SG_UNSIGNED_INT
  //      SG_FLOAT
  //      SG_DOUBLE

  // CullFaceMode
  //      SG_FRONT
  //      SG_BACK
  //      SG_FRONT_AND_BACK

  // DataType
  SG_BYTE                           = $1400;
  SG_UNSIGNED_BYTE                  = $1401;
  SG_SHORT                          = $1402;
  SG_UNSIGNED_SHORT                 = $1403;
  SG_INT                            = $1404;
  SG_UNSIGNED_INT                   = $1405;
  SG_FLOAT                          = $1406;
  SG_2_BYTES                        = $1407;
  SG_3_BYTES                        = $1408;
  SG_4_BYTES                        = $1409;
  SG_DOUBLE                         = $140A;

  // DepthFunction
  //      SG_NEVER
  //      SG_LESS
  //      SG_EQUAL
  //      SG_LEQUAL
  //      SG_GREATER
  //      SG_NOTEQUAL
  //      SG_GEQUAL
  //      SG_ALWAYS

  // DrawBufferMode
  SG_NONE                           = 0;
  SG_FRONT_LEFT                     = $0400;
  SG_FRONT_RIGHT                    = $0401;
  SG_BACK_LEFT                      = $0402;
  SG_BACK_RIGHT                     = $0403;
  SG_FRONT                          = $0404;
  SG_BACK                           = $0405;
  SG_LEFT                           = $0406;
  SG_RIGHT                          = $0407;
  SG_FRONT_AND_BACK                 = $0408;
  SG_AUX0                           = $0409;
  SG_AUX1                           = $040A;
  SG_AUX2                           = $040B;
  SG_AUX3                           = $040C;

  // Enable
  //      SG_FOG
  //      SG_LIGHTING
  //      SG_TEXTURE_1D
  //      SG_TEXTURE_2D
  //      SG_LINE_STIPPLE
  //      SG_POLYGON_STIPPLE
  //      SG_CULL_FACE
  //      SG_ALPHA_TEST
  //      SG_BLEND
  //      SG_INDEX_LOGIC_OP
  //      SG_COLOR_LOGIC_OP
  //      SG_DITHER
  //      SG_STENCIL_TEST
  //      SG_DEPTH_TEST
  //      SG_CLIP_PLANE0
  //      SG_CLIP_PLANE1
  //      SG_CLIP_PLANE2
  //      SG_CLIP_PLANE3
  //      SG_CLIP_PLANE4
  //      SG_CLIP_PLANE5
  //      SG_LIGHT0
  //      SG_LIGHT1
  //      SG_LIGHT2
  //      SG_LIGHT3
  //      SG_LIGHT4
  //      SG_LIGHT5
  //      SG_LIGHT6
  //      SG_LIGHT7
  //      SG_TEXTURE_GEN_S
  //      SG_TEXTURE_GEN_T
  //      SG_TEXTURE_GEN_R
  //      SG_TEXTURE_GEN_Q
  //      SG_MAP1_VERTEX_3
  //      SG_MAP1_VERTEX_4
  //      SG_MAP1_COLOR_4
  //      SG_MAP1_INDEX
  //      SG_MAP1_NORMAL
  //      SG_MAP1_TEXTURE_COORD_1
  //      SG_MAP1_TEXTURE_COORD_2
  //      SG_MAP1_TEXTURE_COORD_3
  //      SG_MAP1_TEXTURE_COORD_4
  //      SG_MAP2_VERTEX_3
  //      SG_MAP2_VERTEX_4
  //      SG_MAP2_COLOR_4
  //      SG_MAP2_INDEX
  //      SG_MAP2_NORMAL
  //      SG_MAP2_TEXTURE_COORD_1
  //      SG_MAP2_TEXTURE_COORD_2
  //      SG_MAP2_TEXTURE_COORD_3
  //      SG_MAP2_TEXTURE_COORD_4
  //      SG_POINT_SMOOTH
  //      SG_LINE_SMOOTH
  //      SG_POLYGON_SMOOTH
  //      SG_SCISSOR_TEST
  //      SG_COLOR_MATERIAL
  //      SG_NORMALIZE
  //      SG_AUTO_NORMAL
  //      SG_VERTEX_ARRAY
  //      SG_NORMAL_ARRAY
  //      SG_COLOR_ARRAY
  //      SG_INDEX_ARRAY
  //      SG_TEXTURE_COORD_ARRAY
  //      SG_EDGE_FLAG_ARRAY
  //      SG_POLYGON_OFFSET_POINT
  //      SG_POLYGON_OFFSET_LINE
  //      SG_POLYGON_OFFSET_FILL

  // ErrorCode
  SG_NO_ERROR                       = 0;
  SG_INVALID_ENUM                   = $0500;
  SG_INVALID_VALUE                  = $0501;
  SG_INVALID_OPERATION              = $0502;
  SG_STACK_OVERFLOW                 = $0503;
  SG_STACK_UNDERFLOW                = $0504;
  SG_OUT_OF_MEMORY                  = $0505;

  // FeedBackMode
  SG_2D                             = $0600;
  SG_3D                             = $0601;
  SG_3D_COLOR                       = $0602;
  SG_3D_COLOR_TEXTURE               = $0603;
  SG_4D_COLOR_TEXTURE               = $0604;
  SG_3D_ORTHO 						= $0605;
  
  // FeedBackToken
  SG_PASS_THROUGH_TOKEN             = $0700;
  SG_POINT_TOKEN                    = $0701;
  SG_LINE_TOKEN                     = $0702;
  SG_POLYGON_TOKEN                  = $0703;
  SG_BITMAP_TOKEN                   = $0704;
  SG_DRAW_PIXEL_TOKEN               = $0705;
  SG_COPY_PIXEL_TOKEN               = $0706;
  SG_LINE_RESET_TOKEN               = $0707;

  // FogMode
  //      SG_LINEAR
  SG_EXP                            = $0800;
  SG_EXP2                           = $0801;

  // FogParameter
  //      SG_FOG_COLOR
  //      SG_FOG_DENSITY
  //      SG_FOG_END
  //      SG_FOG_INDEX
  //      SG_FOG_MODE
  //      SG_FOG_START

  // FrontFaceDirection
  SG_CW                             = $0900;
  SG_CCW                            = $0901;

  // GetMapTarget
  SG_COEFF                          = $0A00;
  SG_ORDER                          = $0A01;
  SG_DOMAIN                         = $0A02;

  // GetPixelMap
  //      SG_PIXEL_MAP_I_TO_I
  //      SG_PIXEL_MAP_S_TO_S
  //      SG_PIXEL_MAP_I_TO_R
  //      SG_PIXEL_MAP_I_TO_G
  //      SG_PIXEL_MAP_I_TO_B
  //      SG_PIXEL_MAP_I_TO_A
  //      SG_PIXEL_MAP_R_TO_R
  //      SG_PIXEL_MAP_G_TO_G
  //      SG_PIXEL_MAP_B_TO_B
  //      SG_PIXEL_MAP_A_TO_A

  // GetPointerTarget
  //      SG_VERTEX_ARRAY_POINTER
  //      SG_NORMAL_ARRAY_POINTER
  //      SG_COLOR_ARRAY_POINTER
  //      SG_INDEX_ARRAY_POINTER
  //      SG_TEXTURE_COORD_ARRAY_POINTER
  //      SG_EDGE_FLAG_ARRAY_POINTER

  // GetTarget
  SG_CURRENT_COLOR                  = $0B00;
  SG_CURRENT_INDEX                  = $0B01;
  SG_CURRENT_NORMAL                 = $0B02;
  SG_CURRENT_TEXTURE_COORDS         = $0B03;
  SG_CURRENT_RASTER_COLOR           = $0B04;
  SG_CURRENT_RASTER_INDEX           = $0B05;
  SG_CURRENT_RASTER_TEXTURE_COORDS  = $0B06;
  SG_CURRENT_RASTER_POSITION        = $0B07;
  SG_CURRENT_RASTER_POSITION_VALID  = $0B08;
  SG_CURRENT_RASTER_DISTANCE        = $0B09;
  SG_POINT_SMOOTH                   = $0B10;
  SG_POINT_SIZE                     = $0B11;
  SG_POINT_SIZE_RANGE               = $0B12;
  SG_POINT_SIZE_GRANULARITY         = $0B13;
  SG_LINE_SMOOTH                    = $0B20;
  SG_LINE_WIDTH                     = $0B21;
  SG_LINE_WIDTH_RANGE               = $0B22;
  SG_LINE_WIDTH_GRANULARITY         = $0B23;
  SG_LINE_STIPPLE                   = $0B24;
  SG_LINE_STIPPLE_PATTERN           = $0B25;
  SG_LINE_STIPPLE_REPEAT            = $0B26;
  SG_LIST_MODE                      = $0B30;
  SG_MAX_LIST_NESTING               = $0B31;
  SG_LIST_BASE                      = $0B32;
  SG_LIST_INDEX                     = $0B33;
  SG_POLYGON_MODE                   = $0B40;
  SG_POLYGON_SMOOTH                 = $0B41;
  SG_POLYGON_STIPPLE                = $0B42;
  SG_EDGE_FLAG                      = $0B43;
  SG_CULL_FACE                      = $0B44;
  SG_CULL_FACE_MODE                 = $0B45;
  SG_FRONT_FACE                     = $0B46;
  SG_LIGHTING                       = $0B50;
  SG_LIGHT_MODEL_LOCAL_VIEWER       = $0B51;
  SG_LIGHT_MODEL_TWO_SIDE           = $0B52;
  SG_LIGHT_MODEL_AMBIENT            = $0B53;
  SG_SHADE_MODEL                    = $0B54;
  SG_COLOR_MATERIAL_FACE            = $0B55;
  SG_COLOR_MATERIAL_PARAMETER       = $0B56;
  SG_COLOR_MATERIAL                 = $0B57;
  SG_FOG                            = $0B60;
  SG_FOG_INDEX                      = $0B61;
  SG_FOG_DENSITY                    = $0B62;
  SG_FOG_START                      = $0B63;
  SG_FOG_END                        = $0B64;
  SG_FOG_MODE                       = $0B65;
  SG_FOG_COLOR                      = $0B66;
  SG_DEPTH_RANGE                    = $0B70;
  SG_DEPTH_TEST                     = $0B71;
  SG_DEPTH_WRITEMASK                = $0B72;
  SG_DEPTH_CLEAR_VALUE              = $0B73;
  SG_DEPTH_FUNC                     = $0B74;
  SG_ACCUM_CLEAR_VALUE              = $0B80;
  SG_STENCIL_TEST                   = $0B90;
  SG_STENCIL_CLEAR_VALUE            = $0B91;
  SG_STENCIL_FUNC                   = $0B92;
  SG_STENCIL_VALUE_MASK             = $0B93;
  SG_STENCIL_FAIL                   = $0B94;
  SG_STENCIL_PASS_DEPTH_FAIL        = $0B95;
  SG_STENCIL_PASS_DEPTH_PASS        = $0B96;
  SG_STENCIL_REF                    = $0B97;
  SG_STENCIL_WRITEMASK              = $0B98;
  SG_MATRIX_MODE                    = $0BA0;
  SG_NORMALIZE                      = $0BA1;
  SG_VIEWPORT                       = $0BA2;
  SG_MODELVIEW_STACK_DEPTH          = $0BA3;
  SG_PROJECTION_STACK_DEPTH         = $0BA4;
  SG_TEXTURE_STACK_DEPTH            = $0BA5;
  SG_MODELVIEW_MATRIX               = $0BA6;
  SG_PROJECTION_MATRIX              = $0BA7;
  SG_TEXTURE_MATRIX                 = $0BA8;
  SG_ATTRIB_STACK_DEPTH             = $0BB0;
  SG_CLIENT_ATTRIB_STACK_DEPTH      = $0BB1;
  SG_ALPHA_TEST                     = $0BC0;
  SG_ALPHA_TEST_FUNC                = $0BC1;
  SG_ALPHA_TEST_REF                 = $0BC2;
  SG_DITHER                         = $0BD0;
  SG_BLEND_DST                      = $0BE0;
  SG_BLEND_SRC                      = $0BE1;
  SG_BLEND                          = $0BE2;
  SG_LOGIC_OP_MODE                  = $0BF0;
  SG_INDEX_LOGIC_OP                 = $0BF1;
  SG_COLOR_LOGIC_OP                 = $0BF2;
  SG_AUX_BUFFERS                    = $0C00;
  SG_DRAW_BUFFER                    = $0C01;
  SG_READ_BUFFER                    = $0C02;
  SG_SCISSOR_BOX                    = $0C10;
  SG_SCISSOR_TEST                   = $0C11;
  SG_INDEX_CLEAR_VALUE              = $0C20;
  SG_INDEX_WRITEMASK                = $0C21;
  SG_COLOR_CLEAR_VALUE              = $0C22;
  SG_COLOR_WRITEMASK                = $0C23;
  SG_INDEX_MODE                     = $0C30;
  SG_RGBA_MODE                      = $0C31;
  SG_DOUBLEBUFFER                   = $0C32;
  SG_STEREO                         = $0C33;
  SG_RENDER_MODE                    = $0C40;
  SG_PERSPECTIVE_CORRECTION_HINT    = $0C50;
  SG_POINT_SMOOTH_HINT              = $0C51;
  SG_LINE_SMOOTH_HINT               = $0C52;
  SG_POLYGON_SMOOTH_HINT            = $0C53;
  SG_FOG_HINT                       = $0C54;
  SG_TEXTURE_GEN_S                  = $0C60;
  SG_TEXTURE_GEN_T                  = $0C61;
  SG_TEXTURE_GEN_R                  = $0C62;
  SG_TEXTURE_GEN_Q                  = $0C63;
  SG_PIXEL_MAP_I_TO_I               = $0C70;
  SG_PIXEL_MAP_S_TO_S               = $0C71;
  SG_PIXEL_MAP_I_TO_R               = $0C72;
  SG_PIXEL_MAP_I_TO_G               = $0C73;
  SG_PIXEL_MAP_I_TO_B               = $0C74;
  SG_PIXEL_MAP_I_TO_A               = $0C75;
  SG_PIXEL_MAP_R_TO_R               = $0C76;
  SG_PIXEL_MAP_G_TO_G               = $0C77;
  SG_PIXEL_MAP_B_TO_B               = $0C78;
  SG_PIXEL_MAP_A_TO_A               = $0C79;
  SG_PIXEL_MAP_I_TO_I_SIZE          = $0CB0;
  SG_PIXEL_MAP_S_TO_S_SIZE          = $0CB1;
  SG_PIXEL_MAP_I_TO_R_SIZE          = $0CB2;
  SG_PIXEL_MAP_I_TO_G_SIZE          = $0CB3;
  SG_PIXEL_MAP_I_TO_B_SIZE          = $0CB4;
  SG_PIXEL_MAP_I_TO_A_SIZE          = $0CB5;
  SG_PIXEL_MAP_R_TO_R_SIZE          = $0CB6;
  SG_PIXEL_MAP_G_TO_G_SIZE          = $0CB7;
  SG_PIXEL_MAP_B_TO_B_SIZE          = $0CB8;
  SG_PIXEL_MAP_A_TO_A_SIZE          = $0CB9;
  SG_UNPACK_SWAP_BYTES              = $0CF0;
  SG_UNPACK_LSB_FIRST               = $0CF1;
  SG_UNPACK_ROW_LENGTH              = $0CF2;
  SG_UNPACK_SKIP_ROWS               = $0CF3;
  SG_UNPACK_SKIP_PIXELS             = $0CF4;
  SG_UNPACK_ALIGNMENT               = $0CF5;
  SG_PACK_SWAP_BYTES                = $0D00;
  SG_PACK_LSB_FIRST                 = $0D01;
  SG_PACK_ROW_LENGTH                = $0D02;
  SG_PACK_SKIP_ROWS                 = $0D03;
  SG_PACK_SKIP_PIXELS               = $0D04;
  SG_PACK_ALIGNMENT                 = $0D05;
  SG_MAP_COLOR                      = $0D10;
  SG_MAP_STENCIL                    = $0D11;
  SG_INDEX_SHIFT                    = $0D12;
  SG_INDEX_OFFSET                   = $0D13;
  SG_RED_SCALE                      = $0D14;
  SG_RED_BIAS                       = $0D15;
  SG_ZOOM_X                         = $0D16;
  SG_ZOOM_Y                         = $0D17;
  SG_GREEN_SCALE                    = $0D18;
  SG_GREEN_BIAS                     = $0D19;
  SG_BLUE_SCALE                     = $0D1A;
  SG_BLUE_BIAS                      = $0D1B;
  SG_ALPHA_SCALE                    = $0D1C;
  SG_ALPHA_BIAS                     = $0D1D;
  SG_DEPTH_SCALE                    = $0D1E;
  SG_DEPTH_BIAS                     = $0D1F;
  SG_MAX_EVAL_ORDER                 = $0D30;
  SG_MAX_LIGHTS                     = $0D31;
  SG_MAX_CLIP_PLANES                = $0D32;
  SG_MAX_TEXTURE_SIZE               = $0D33;
  SG_MAX_PIXEL_MAP_TABLE            = $0D34;
  SG_MAX_ATTRIB_STACK_DEPTH         = $0D35;
  SG_MAX_MODELVIEW_STACK_DEPTH      = $0D36;
  SG_MAX_NAME_STACK_DEPTH           = $0D37;
  SG_MAX_PROJECTION_STACK_DEPTH     = $0D38;
  SG_MAX_TEXTURE_STACK_DEPTH        = $0D39;
  SG_MAX_VIEWPORT_DIMS              = $0D3A;
  SG_MAX_CLIENT_ATTRIB_STACK_DEPTH  = $0D3B;
  SG_SUBPIXEL_BITS                  = $0D50;
  SG_INDEX_BITS                     = $0D51;
  SG_RED_BITS                       = $0D52;
  SG_GREEN_BITS                     = $0D53;
  SG_BLUE_BITS                      = $0D54;
  SG_ALPHA_BITS                     = $0D55;
  SG_DEPTH_BITS                     = $0D56;
  SG_STENCIL_BITS                   = $0D57;
  SG_ACCUM_RED_BITS                 = $0D58;
  SG_ACCUM_GREEN_BITS               = $0D59;
  SG_ACCUM_BLUE_BITS                = $0D5A;
  SG_ACCUM_ALPHA_BITS               = $0D5B;
  SG_NAME_STACK_DEPTH               = $0D70;
  SG_AUTO_NORMAL                    = $0D80;
  SG_MAP1_COLOR_4                   = $0D90;
  SG_MAP1_INDEX                     = $0D91;
  SG_MAP1_NORMAL                    = $0D92;
  SG_MAP1_TEXTURE_COORD_1           = $0D93;
  SG_MAP1_TEXTURE_COORD_2           = $0D94;
  SG_MAP1_TEXTURE_COORD_3           = $0D95;
  SG_MAP1_TEXTURE_COORD_4           = $0D96;
  SG_MAP1_VERTEX_3                  = $0D97;
  SG_MAP1_VERTEX_4                  = $0D98;
  SG_MAP2_COLOR_4                   = $0DB0;
  SG_MAP2_INDEX                     = $0DB1;
  SG_MAP2_NORMAL                    = $0DB2;
  SG_MAP2_TEXTURE_COORD_1           = $0DB3;
  SG_MAP2_TEXTURE_COORD_2           = $0DB4;
  SG_MAP2_TEXTURE_COORD_3           = $0DB5;
  SG_MAP2_TEXTURE_COORD_4           = $0DB6;
  SG_MAP2_VERTEX_3                  = $0DB7;
  SG_MAP2_VERTEX_4                  = $0DB8;
  SG_MAP1_GRID_DOMAIN               = $0DD0;
  SG_MAP1_GRID_SEGMENTS             = $0DD1;
  SG_MAP2_GRID_DOMAIN               = $0DD2;
  SG_MAP2_GRID_SEGMENTS             = $0DD3;
  SG_TEXTURE_1D                     = $0DE0;
  SG_TEXTURE_2D                     = $0DE1;
  SG_FEEDBACK_BUFFER_POINTER        = $0DF0;
  SG_FEEDBACK_BUFFER_SIZE           = $0DF1;
  SG_FEEDBACK_BUFFER_TYPE           = $0DF2;
  SG_SELECTION_BUFFER_POINTER       = $0DF3;
  SG_SELECTION_BUFFER_SIZE          = $0DF4;
  //      SG_TEXTURE_BINDING_1D
  //      SG_TEXTURE_BINDING_2D
  //      SG_VERTEX_ARRAY
  //      SG_NORMAL_ARRAY
  //      SG_COLOR_ARRAY
  //      SG_INDEX_ARRAY
  //      SG_TEXTURE_COORD_ARRAY
  //      SG_EDGE_FLAG_ARRAY
  //      SG_VERTEX_ARRAY_SIZE
  //      SG_VERTEX_ARRAY_TYPE
  //      SG_VERTEX_ARRAY_STRIDE
  //      SG_NORMAL_ARRAY_TYPE
  //      SG_NORMAL_ARRAY_STRIDE
  //      SG_COLOR_ARRAY_SIZE
  //      SG_COLOR_ARRAY_TYPE
  //      SG_COLOR_ARRAY_STRIDE
  //      SG_INDEX_ARRAY_TYPE
  //      SG_INDEX_ARRAY_STRIDE
  //      SG_TEXTURE_COORD_ARRAY_SIZE
  //      SG_TEXTURE_COORD_ARRAY_TYPE
  //      SG_TEXTURE_COORD_ARRAY_STRIDE
  //      SG_EDGE_FLAG_ARRAY_STRIDE
  //      SG_POLYGON_OFFSET_FACTOR
  //      SG_POLYGON_OFFSET_UNITS

  // GetTextureParameter
  //      SG_TEXTURE_MAG_FILTER
  //      SG_TEXTURE_MIN_FILTER
  //      SG_TEXTURE_WRAP_S
  //      SG_TEXTURE_WRAP_T
  SG_TEXTURE_WIDTH                  = $1000;
  SG_TEXTURE_HEIGHT                 = $1001;
  SG_TEXTURE_INTERNAL_FORMAT        = $1003;
  SG_TEXTURE_BORDER_COLOR           = $1004;
  SG_TEXTURE_BORDER                 = $1005;
  //      SG_TEXTURE_RED_SIZE
  //      SG_TEXTURE_GREEN_SIZE
  //      SG_TEXTURE_BLUE_SIZE
  //      SG_TEXTURE_ALPHA_SIZE
  //      SG_TEXTURE_LUMINANCE_SIZE
  //      SG_TEXTURE_INTENSITY_SIZE
  //      SG_TEXTURE_PRIORITY
  //      SG_TEXTURE_RESIDENT

  // HintMode
  SG_DONT_CARE                      = $1100;
  SG_FASTEST                        = $1101;
  SG_NICEST                         = $1102;

  // HintTarget
  //      SG_PERSPECTIVE_CORRECTION_HINT
  //      SG_POINT_SMOOTH_HINT
  //      SG_LINE_SMOOTH_HINT
  //      SG_POLYGON_SMOOTH_HINT
  //      SG_FOG_HINT

  // IndexPointerType
  //      SG_SHORT
  //      SG_INT
  //      SG_FLOAT
  //      SG_DOUBLE

  // LightModelParameter
  //      SG_LIGHT_MODEL_AMBIENT
  //      SG_LIGHT_MODEL_LOCAL_VIEWER
  //      SG_LIGHT_MODEL_TWO_SIDE

  // LightName
  SG_LIGHT0                         = $4000;
  SG_LIGHT1                         = $4001;
  SG_LIGHT2                         = $4002;
  SG_LIGHT3                         = $4003;
  SG_LIGHT4                         = $4004;
  SG_LIGHT5                         = $4005;
  SG_LIGHT6                         = $4006;
  SG_LIGHT7                         = $4007;

  // LightParameter
  SG_AMBIENT                        = $1200;
  SG_DIFFUSE                        = $1201;
  SG_SPECULAR                       = $1202;
  SG_POSITION                       = $1203;
  SG_SPOT_DIRECTION                 = $1204;
  SG_SPOT_EXPONENT                  = $1205;
  SG_SPOT_CUTOFF                    = $1206;
  SG_CONSTANT_ATTENUATION           = $1207;
  SG_LINEAR_ATTENUATION             = $1208;
  SG_QUADRATIC_ATTENUATION          = $1209;

  // InterleavedArrays
  //      SG_V2F
  //      SG_V3F
  //      SG_C4UB_V2F
  //      SG_C4UB_V3F
  //      SG_C3F_V3F
  //      SG_N3F_V3F
  //      SG_C4F_N3F_V3F
  //      SG_T2F_V3F
  //      SG_T4F_V4F
  //      SG_T2F_C4UB_V3F
  //      SG_T2F_C3F_V3F
  //      SG_T2F_N3F_V3F
  //      SG_T2F_C4F_N3F_V3F
  //      SG_T4F_C4F_N3F_V4F

  // ListMode
  SG_COMPILE                        = $1300;
  SG_COMPILE_AND_EXECUTE            = $1301;

  // ListNameType
  //      SG_BYTE
  //      SG_UNSIGNED_BYTE
  //      SG_SHORT
  //      SG_UNSIGNED_SHORT
  //      SG_INT
  //      SG_UNSIGNED_INT
  //      SG_FLOAT
  //      SG_2_BYTES
  //      SG_3_BYTES
  //      SG_4_BYTES

  // LogicOp
  SG_CLEAR                          = $1500;
  SG_AND                            = $1501;
  SG_AND_REVERSE                    = $1502;
  SG_COPY                           = $1503;
  SG_AND_INVERTED                   = $1504;
  SG_NOOP                           = $1505;
  SG_XOR                            = $1506;
  SG_OR                             = $1507;
  SG_NOR                            = $1508;
  SG_EQUIV                          = $1509;
  SG_INVERT                         = $150A;
  SG_OR_REVERSE                     = $150B;
  SG_COPY_INVERTED                  = $150C;
  SG_OR_INVERTED                    = $150D;
  SG_NAND                           = $150E;
  SG_SET                            = $150F;

  // MapTarget
  //      SG_MAP1_COLOR_4
  //      SG_MAP1_INDEX
  //      SG_MAP1_NORMAL
  //      SG_MAP1_TEXTURE_COORD_1
  //      SG_MAP1_TEXTURE_COORD_2
  //      SG_MAP1_TEXTURE_COORD_3
  //      SG_MAP1_TEXTURE_COORD_4
  //      SG_MAP1_VERTEX_3
  //      SG_MAP1_VERTEX_4
  //      SG_MAP2_COLOR_4
  //      SG_MAP2_INDEX
  //      SG_MAP2_NORMAL
  //      SG_MAP2_TEXTURE_COORD_1
  //      SG_MAP2_TEXTURE_COORD_2
  //      SG_MAP2_TEXTURE_COORD_3
  //      SG_MAP2_TEXTURE_COORD_4
  //      SG_MAP2_VERTEX_3
  //      SG_MAP2_VERTEX_4

  // MaterialFace
  //      SG_FRONT
  //      SG_BACK
  //      SG_FRONT_AND_BACK

  // MaterialParameter
  SG_EMISSION                       = $1600;
  SG_SHININESS                      = $1601;
  SG_AMBIENT_AND_DIFFUSE            = $1602;
  SG_COLOR_INDEXES                  = $1603;
  //      SG_AMBIENT
  //      SG_DIFFUSE
  //      SG_SPECULAR

  // MatrixMode
  SG_MODELVIEW                      = $1700;
  SG_PROJECTION                     = $1701;
  SG_TEXTURE                        = $1702;

  // MeshMode1
  //      SG_POINT
  //      SG_LINE

  // MeshMode2
  //      SG_POINT
  //      SG_LINE
  //      SG_FILL

  // NormalPointerType
  //      SG_BYTE
  //      SG_SHORT
  //      SG_INT
  //      SG_FLOAT
  //      SG_DOUBLE

  // PixelCopyType
  SG_COLOR                          = $1800;
  SG_DEPTH                          = $1801;
  SG_STENCIL                        = $1802;

  // PixelFormat
  SG_COLOR_INDEX                    = $1900;
  SG_STENCIL_INDEX                  = $1901;
  SG_DEPTH_COMPONENT                = $1902;
  SG_RED                            = $1903;
  SG_GREEN                          = $1904;
  SG_BLUE                           = $1905;
  SG_ALPHA                          = $1906;
  SG_RGB                            = $1907;
  SG_RGBA                           = $1908;
  SG_LUMINANCE                      = $1909;
  SG_LUMINANCE_ALPHA                = $190A;

  // PixelMap
  //      SG_PIXEL_MAP_I_TO_I
  //      SG_PIXEL_MAP_S_TO_S
  //      SG_PIXEL_MAP_I_TO_R
  //      SG_PIXEL_MAP_I_TO_G
  //      SG_PIXEL_MAP_I_TO_B
  //      SG_PIXEL_MAP_I_TO_A
  //      SG_PIXEL_MAP_R_TO_R
  //      SG_PIXEL_MAP_G_TO_G
  //      SG_PIXEL_MAP_B_TO_B
  //      SG_PIXEL_MAP_A_TO_A

  // PixelStore
  //      SG_UNPACK_SWAP_BYTES
  //      SG_UNPACK_LSB_FIRST
  //      SG_UNPACK_ROW_LENGTH
  //      SG_UNPACK_SKIP_ROWS
  //      SG_UNPACK_SKIP_PIXELS
  //      SG_UNPACK_ALIGNMENT
  //      SG_PACK_SWAP_BYTES
  //      SG_PACK_LSB_FIRST
  //      SG_PACK_ROW_LENGTH
  //      SG_PACK_SKIP_ROWS
  //      SG_PACK_SKIP_PIXELS
  //      SG_PACK_ALIGNMENT

  // PixelTransfer
  //      SG_MAP_COLOR
  //      SG_MAP_STENCIL
  //      SG_INDEX_SHIFT
  //      SG_INDEX_OFFSET
  //      SG_RED_SCALE
  //      SG_RED_BIAS
  //      SG_GREEN_SCALE
  //      SG_GREEN_BIAS
  //      SG_BLUE_SCALE
  //      SG_BLUE_BIAS
  //      SG_ALPHA_SCALE
  //      SG_ALPHA_BIAS
  //      SG_DEPTH_SCALE
  //      SG_DEPTH_BIAS

  // PixelType
  SG_BITMAP                         = $1A00;
  //      SG_BYTE
  //      SG_UNSIGNED_BYTE
  //      SG_SHORT
  //      SG_UNSIGNED_SHORT
  //      SG_INT
  //      SG_UNSIGNED_INT
  //      SG_FLOAT

  // PolygonMode
  SG_POINT                          = $1B00;
  SG_LINE                           = $1B01;
  SG_FILL                           = $1B02;

  // ReadBufferMode
  //      SG_FRONT_LEFT
  //      SG_FRONT_RIGHT
  //      SG_BACK_LEFT
  //      SG_BACK_RIGHT
  //      SG_FRONT
  //      SG_BACK
  //      SG_LEFT
  //      SG_RIGHT
  //      SG_AUX0
  //      SG_AUX1
  //      SG_AUX2
  //      SG_AUX3

  // RenderingMode
  SG_RENDER                         = $1C00;
  SG_FEEDBACK                       = $1C01;
  SG_SELECT                         = $1C02;

  // ShadingModel
  SG_FLAT                           = $1D00;
  SG_SMOOTH                         = $1D01;

  // StencilFunction
  //      SG_NEVER
  //      SG_LESS
  //      SG_EQUAL
  //      SG_LEQUAL
  //      SG_GREATER
  //      SG_NOTEQUAL
  //      SG_GEQUAL
  //      SG_ALWAYS

  // StencilOp
  //      SG_ZERO
  SG_KEEP                           = $1E00;
  SG_REPLACE                        = $1E01;
  SG_INCR                           = $1E02;
  SG_DECR                           = $1E03;
  //      SG_INVERT

  // StringName
  SG_VENDOR                         = $1F00;
  SG_RENDERER                       = $1F01;
  SG_VERSION                        = $1F02;
  SG_EXTENSIONS                     = $1F03;

  // TextureCoordName
  SG_S                              = $2000;
  SG_T                              = $2001;
  SG_R                              = $2002;
  SG_Q                              = $2003;

  // TexCoordPointerType
  //      SG_SHORT
  //      SG_INT
  //      SG_FLOAT
  //      SG_DOUBLE

  // TextureEnvMode
  SG_MODULATE                       = $2100;
  SG_DECAL                          = $2101;
  //      SG_BLEND
  //      SG_REPLACE

  // TextureEnvParameter
  SG_TEXTURE_ENV_MODE               = $2200;
  SG_TEXTURE_ENV_COLOR              = $2201;

  // TextureEnvTarget
  SG_TEXTURE_ENV                    = $2300;

  // TextureGenMode
  SG_EYE_LINEAR                     = $2400;
  SG_OBJECT_LINEAR                  = $2401;
  SG_SPHERE_MAP                     = $2402;

  // TextureGenParameter
  SG_TEXTURE_GEN_MODE               = $2500;
  SG_OBJECT_PLANE                   = $2501;
  SG_EYE_PLANE                      = $2502;

  // TextureMagFilter
  SG_NEAREST                        = $2600;
  SG_LINEAR                         = $2601;

  // TextureMinFilter
  //      SG_NEAREST
  //      SG_LINEAR
  SG_NEAREST_MIPMAP_NEAREST         = $2700;
  SG_LINEAR_MIPMAP_NEAREST          = $2701;
  SG_NEAREST_MIPMAP_LINEAR          = $2702;
  SG_LINEAR_MIPMAP_LINEAR           = $2703;

  // TextureParameterName
  SG_TEXTURE_MAG_FILTER             = $2800;
  SG_TEXTURE_MIN_FILTER             = $2801;
  SG_TEXTURE_WRAP_S                 = $2802;
  SG_TEXTURE_WRAP_T                 = $2803;
  //      SG_TEXTURE_BORDER_COLOR
  //      SG_TEXTURE_PRIORITY

  // TextureTarget
  //      SG_TEXTURE_1D
  //      SG_TEXTURE_2D
  //      SG_PROXY_TEXTURE_1D
  //      SG_PROXY_TEXTURE_2D

  // TextureWrapMode
  SG_CLAMP                          = $2900;
  SG_REPEAT                         = $2901;

  // VertexPointerType
  //      SG_SHORT
  //      SG_INT
  //      SG_FLOAT
  //      SG_DOUBLE

  // ClientAttribMask
  SG_CLIENT_PIXEL_STORE_BIT         = $00000001;
  SG_CLIENT_VERTEX_ARRAY_BIT        = $00000002;
  SG_CLIENT_ALL_ATTRIB_BITS         = $FFFFFFFF;

  // polygon_offset
  SG_POLYGON_OFFSET_FACTOR          = $8038;
  SG_POLYGON_OFFSET_UNITS           = $2A00;
  SG_POLYGON_OFFSET_POINT           = $2A01;
  SG_POLYGON_OFFSET_LINE            = $2A02;
  SG_POLYGON_OFFSET_FILL            = $8037;

  // texture
  SG_ALPHA4                         = $803B;
  SG_ALPHA8                         = $803C;
  SG_ALPHA12                        = $803D;
  SG_ALPHA16                        = $803E;
  SG_LUMINANCE4                     = $803F;
  SG_LUMINANCE8                     = $8040;
  SG_LUMINANCE12                    = $8041;
  SG_LUMINANCE16                    = $8042;
  SG_LUMINANCE4_ALPHA4              = $8043;
  SG_LUMINANCE6_ALPHA2              = $8044;
  SG_LUMINANCE8_ALPHA8              = $8045;
  SG_LUMINANCE12_ALPHA4             = $8046;
  SG_LUMINANCE12_ALPHA12            = $8047;
  SG_LUMINANCE16_ALPHA16            = $8048;
  SG_INTENSITY                      = $8049;
  SG_INTENSITY4                     = $804A;
  SG_INTENSITY8                     = $804B;
  SG_INTENSITY12                    = $804C;
  SG_INTENSITY16                    = $804D;
  SG_R3_G3_B2                       = $2A10;
  SG_RGB4                           = $804F;
  SG_RGB5                           = $8050;
  SG_RGB8                           = $8051;
  SG_RGB10                          = $8052;
  SG_RGB12                          = $8053;
  SG_RGB16                          = $8054;
  SG_RGBA2                          = $8055;
  SG_RGBA4                          = $8056;
  SG_RGB5_A1                        = $8057;
  SG_RGBA8                          = $8058;
  SG_RGB10_A2                       = $8059;
  SG_RGBA12                         = $805A;
  SG_RGBA16                         = $805B;
  SG_TEXTURE_RED_SIZE               = $805C;
  SG_TEXTURE_GREEN_SIZE             = $805D;
  SG_TEXTURE_BLUE_SIZE              = $805E;
  SG_TEXTURE_ALPHA_SIZE             = $805F;
  SG_TEXTURE_LUMINANCE_SIZE         = $8060;
  SG_TEXTURE_INTENSITY_SIZE         = $8061;
  SG_PROXY_TEXTURE_1D               = $8063;
  SG_PROXY_TEXTURE_2D               = $8064;

  // texture_object
  SG_TEXTURE_PRIORITY               = $8066;
  SG_TEXTURE_RESIDENT               = $8067;
  SG_TEXTURE_BINDING_1D             = $8068;
  SG_TEXTURE_BINDING_2D             = $8069;

  // vertex_array
  SG_VERTEX_ARRAY                   = $8074;
  SG_NORMAL_ARRAY                   = $8075;
  SG_COLOR_ARRAY                    = $8076;
  SG_INDEX_ARRAY                    = $8077;
  SG_TEXTURE_COORD_ARRAY            = $8078;
  SG_EDGE_FLAG_ARRAY                = $8079;
  SG_VERTEX_ARRAY_SIZE              = $807A;
  SG_VERTEX_ARRAY_TYPE              = $807B;
  SG_VERTEX_ARRAY_STRIDE            = $807C;
  SG_NORMAL_ARRAY_TYPE              = $807E;
  SG_NORMAL_ARRAY_STRIDE            = $807F;
  SG_COLOR_ARRAY_SIZE               = $8081;
  SG_COLOR_ARRAY_TYPE               = $8082;
  SG_COLOR_ARRAY_STRIDE             = $8083;
  SG_INDEX_ARRAY_TYPE               = $8085;
  SG_INDEX_ARRAY_STRIDE             = $8086;
  SG_TEXTURE_COORD_ARRAY_SIZE       = $8088;
  SG_TEXTURE_COORD_ARRAY_TYPE       = $8089;
  SG_TEXTURE_COORD_ARRAY_STRIDE     = $808A;
  SG_EDGE_FLAG_ARRAY_STRIDE         = $808C;
  SG_VERTEX_ARRAY_POINTER           = $808E;
  SG_NORMAL_ARRAY_POINTER           = $808F;
  SG_COLOR_ARRAY_POINTER            = $8090;
  SG_INDEX_ARRAY_POINTER            = $8091;
  SG_TEXTURE_COORD_ARRAY_POINTER    = $8092;
  SG_EDGE_FLAG_ARRAY_POINTER        = $8093;
  SG_V2F                            = $2A20;
  SG_V3F                            = $2A21;
  SG_C4UB_V2F                       = $2A22;
  SG_C4UB_V3F                       = $2A23;
  SG_C3F_V3F                        = $2A24;
  SG_N3F_V3F                        = $2A25;
  SG_C4F_N3F_V3F                    = $2A26;
  SG_T2F_V3F                        = $2A27;
  SG_T4F_V4F                        = $2A28;
  SG_T2F_C4UB_V3F                   = $2A29;
  SG_T2F_C3F_V3F                    = $2A2A;
  SG_T2F_N3F_V3F                    = $2A2B;
  SG_T2F_C4F_N3F_V3F                = $2A2C;
  SG_T4F_C4F_N3F_V4F                = $2A2D;

  // For compatibility with OpenSG v1.0
  SG_LOGIC_OP                       = SG_INDEX_LOGIC_OP;
  SG_TEXTURE_COMPONENTS             = SG_TEXTURE_INTERNAL_FORMAT;
{***** GL_ARB_vertex_buffer_object *****}
const
     SG_BUFFER_SIZE_ARB = $8764;
     SG_BUFFER_USAGE_ARB = $8765;
     SG_ARRAY_BUFFER_ARB = $8892;
     SG_ELEMENT_ARRAY_BUFFER_ARB = $8893;
     SG_ARRAY_BUFFER_BINDING_ARB = $8894;
     SG_ELEMENT_ARRAY_BUFFER_BINDING_ARB = $8895;
     SG_VERTEX_ARRAY_BUFFER_BINDING_ARB = $8896;
     SG_NORMAL_ARRAY_BUFFER_BINDING_ARB = $8897;
     SG_COLOR_ARRAY_BUFFER_BINDING_ARB = $8898;
     SG_INDEX_ARRAY_BUFFER_BINDING_ARB = $8899;
     SG_TEXTURE_COORD_ARRAY_BUFFER_BINDING_ARB = $889A;
     SG_EDGE_FLAG_ARRAY_BUFFER_BINDING_ARB = $889B;
     SG_SECONDARY_COLOR_ARRAY_BUFFER_BINDING_ARB = $889C;
     SG_FOG_COORDINATE_ARRAY_BUFFER_BINDING_ARB = $889D;
     SG_WEIGHT_ARRAY_BUFFER_BINDING_ARB = $889E;
     SG_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING_ARB = $889F;
     SG_READ_ONLY_ARB = $88B8;
     SG_WRITE_ONLY_ARB = $88B9;
     SG_READ_WRITE_ARB = $88BA;
     SG_BUFFER_ACCESS_ARB = $88BB;
     SG_BUFFER_MAPPED_ARB = $88BC;
     SG_BUFFER_MAP_POINTER_ARB = $88BD;
     SG_STREAM_DRAW_ARB = $88E0;
     SG_STREAM_READ_ARB = $88E1;
     SG_STREAM_COPY_ARB = $88E2;
     SG_STATIC_DRAW_ARB = $88E4;
     SG_STATIC_READ_ARB = $88E5;
     SG_STATIC_COPY_ARB = $88E6;
     SG_DYNAMIC_DRAW_ARB = $88E8;
     SG_DYNAMIC_READ_ARB = $88E9;
     SG_DYNAMIC_COPY_ARB = $88EA;    
