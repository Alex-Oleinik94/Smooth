const
  SR_ACCUM                          = $0100;
  SR_LOAD                           = $0101;
  SR_RETURN                         = $0102;
  SR_MULT                           = $0103;
  SR_ADD                            = $0104;

  // AlphaFunction
  SR_NEVER                          = $0200;
  SR_LESS                           = $0201;
  SR_EQUAL                          = $0202;
  SR_LEQUAL                         = $0203;
  SR_GREATER                        = $0204;
  SR_NOTEQUAL                       = $0205;
  SR_GEQUAL                         = $0206;
  SR_ALWAYS                         = $0207;

  // AttribMask
  SR_CURRENT_BIT                    = $00000001;
  SR_POINT_BIT                      = $00000002;
  SR_LINE_BIT                       = $00000004;
  SR_POLYGON_BIT                    = $00000008;
  SR_POLYGON_STIPPLE_BIT            = $00000010;
  SR_PIXEL_MODE_BIT                 = $00000020;
  SR_LIGHTING_BIT                   = $00000040;
  SR_FOG_BIT                        = $00000080;
  SR_DEPTH_BUFFER_BIT               = $00000100;
  SR_ACCUM_BUFFER_BIT               = $00000200;
  SR_STENCIL_BUFFER_BIT             = $00000400;
  SR_VIEWPORT_BIT                   = $00000800;
  SR_TRANSFORM_BIT                  = $00001000;
  SR_ENABLE_BIT                     = $00002000;
  SR_COLOR_BUFFER_BIT               = $00004000;
  SR_HINT_BIT                       = $00008000;
  SR_EVAL_BIT                       = $00010000;
  SR_LIST_BIT                       = $00020000;
  SR_TEXTURE_BIT                    = $00040000;
  SR_SCISSOR_BIT                    = $00080000;
  SR_ALL_ATTRIB_BITS                = $000FFFFF;

  // BeginMode
  SR_POINTS                         = $0000;
  SR_LINES                          = $0001;
  SR_LINE_LOOP                      = $0002;
  SR_LINE_STRIP                     = $0003;
  SR_TRIANGLES                      = $0004;
  SR_TRIANGLE_STRIP                 = $0005;
  SR_TRIANGLE_FAN                   = $0006;
  SR_QUADS                          = $0007;
  SR_QUAD_STRIP                     = $0008;
  SR_POLYGON                        = $0009;

  // BlendingFactorDest
  SR_ZERO                           = 0;
  SR_ONE                            = 1;
  SR_SRC_COLOR                      = $0300;
  SR_ONE_MINUS_SRC_COLOR            = $0301;
  SR_SRC_ALPHA                      = $0302;
  SR_ONE_MINUS_SRC_ALPHA            = $0303;
  SR_DST_ALPHA                      = $0304;
  SR_ONE_MINUS_DST_ALPHA            = $0305;

  // BlendingFactorSrc
  //      SR_ZERO
  //      SR_ONE
  SR_DST_COLOR                      = $0306;
  SR_ONE_MINUS_DST_COLOR            = $0307;
  SR_SRC_ALPHA_SATURATE             = $0308;
  //      SR_SRC_ALPHA
  //      SR_ONE_MINUS_SRC_ALPHA
  //      SR_DST_ALPHA
  //      SR_ONE_MINUS_DST_ALPHA

  // Boolean
  SR_TRUE                           = 1;
  SR_FALSE                          = 0;

  // ClearBufferMask
  //      SR_COLOR_BUFFER_BIT
  //      SR_ACCUM_BUFFER_BIT
  //      SR_STENCIL_BUFFER_BIT
  //      SR_DEPTH_BUFFER_BIT

  // ClientArrayType
  //      SR_VERTEX_ARRAY
  //      SR_NORMAL_ARRAY
  //      SR_COLOR_ARRAY
  //      SR_INDEX_ARRAY
  //      SR_TEXTURE_COORD_ARRAY
  //      SR_EDGE_FLAG_ARRAY

  // ClipPlaneName
  SR_CLIP_PLANE0                    = $3000;
  SR_CLIP_PLANE1                    = $3001;
  SR_CLIP_PLANE2                    = $3002;
  SR_CLIP_PLANE3                    = $3003;
  SR_CLIP_PLANE4                    = $3004;
  SR_CLIP_PLANE5                    = $3005;

  // ColorMaterialFace
  //      SR_FRONT
  //      SR_BACK
  //      SR_FRONT_AND_BACK

  // ColorMaterialParameter
  //      SR_AMBIENT
  //      SR_DIFFUSE
  //      SR_SPECULAR
  //      SR_EMISSION
  //      SR_AMBIENT_AND_DIFFUSE

  // ColorPointerType
  //      SR_BYTE
  //      SR_UNSIGNED_BYTE
  //      SR_SHORT
  //      SR_UNSIGNED_SHORT
  //      SR_INT
  //      SR_UNSIGNED_INT
  //      SR_FLOAT
  //      SR_DOUBLE

  // CullFaceMode
  //      SR_FRONT
  //      SR_BACK
  //      SR_FRONT_AND_BACK

  // DataType
  SR_BYTE                           = $1400;
  SR_UNSIGNED_BYTE                  = $1401;
  SR_SHORT                          = $1402;
  SR_UNSIGNED_SHORT                 = $1403;
  SR_INT                            = $1404;
  SR_UNSIGNED_INT                   = $1405;
  SR_FLOAT                          = $1406;
  SR_2_BYTES                        = $1407;
  SR_3_BYTES                        = $1408;
  SR_4_BYTES                        = $1409;
  SR_DOUBLE                         = $140A;

  // DepthFunction
  //      SR_NEVER
  //      SR_LESS
  //      SR_EQUAL
  //      SR_LEQUAL
  //      SR_GREATER
  //      SR_NOTEQUAL
  //      SR_GEQUAL
  //      SR_ALWAYS

  // DrawBufferMode
  SR_NONE                           = 0;
  SR_FRONT_LEFT                     = $0400;
  SR_FRONT_RIGHT                    = $0401;
  SR_BACK_LEFT                      = $0402;
  SR_BACK_RIGHT                     = $0403;
  SR_FRONT                          = $0404;
  SR_BACK                           = $0405;
  SR_LEFT                           = $0406;
  SR_RIGHT                          = $0407;
  SR_FRONT_AND_BACK                 = $0408;
  SR_AUX0                           = $0409;
  SR_AUX1                           = $040A;
  SR_AUX2                           = $040B;
  SR_AUX3                           = $040C;

  // Enable
  //      SR_FOG
  //      SR_LIGHTING
  //      SR_TEXTURE_1D
  //      SR_TEXTURE_2D
  //      SR_LINE_STIPPLE
  //      SR_POLYGON_STIPPLE
  //      SR_CULL_FACE
  //      SR_ALPHA_TEST
  //      SR_BLEND
  //      SR_INDEX_LOGIC_OP
  //      SR_COLOR_LOGIC_OP
  //      SR_DITHER
  //      SR_STENCIL_TEST
  //      SR_DEPTH_TEST
  //      SR_CLIP_PLANE0
  //      SR_CLIP_PLANE1
  //      SR_CLIP_PLANE2
  //      SR_CLIP_PLANE3
  //      SR_CLIP_PLANE4
  //      SR_CLIP_PLANE5
  //      SR_LIGHT0
  //      SR_LIGHT1
  //      SR_LIGHT2
  //      SR_LIGHT3
  //      SR_LIGHT4
  //      SR_LIGHT5
  //      SR_LIGHT6
  //      SR_LIGHT7
  //      SR_TEXTURE_GEN_S
  //      SR_TEXTURE_GEN_T
  //      SR_TEXTURE_GEN_R
  //      SR_TEXTURE_GEN_Q
  //      SR_MAP1_VERTEX_3
  //      SR_MAP1_VERTEX_4
  //      SR_MAP1_COLOR_4
  //      SR_MAP1_INDEX
  //      SR_MAP1_NORMAL
  //      SR_MAP1_TEXTURE_COORD_1
  //      SR_MAP1_TEXTURE_COORD_2
  //      SR_MAP1_TEXTURE_COORD_3
  //      SR_MAP1_TEXTURE_COORD_4
  //      SR_MAP2_VERTEX_3
  //      SR_MAP2_VERTEX_4
  //      SR_MAP2_COLOR_4
  //      SR_MAP2_INDEX
  //      SR_MAP2_NORMAL
  //      SR_MAP2_TEXTURE_COORD_1
  //      SR_MAP2_TEXTURE_COORD_2
  //      SR_MAP2_TEXTURE_COORD_3
  //      SR_MAP2_TEXTURE_COORD_4
  //      SR_POINT_SMOOTH
  //      SR_LINE_SMOOTH
  //      SR_POLYGON_SMOOTH
  //      SR_SCISSOR_TEST
  //      SR_COLOR_MATERIAL
  //      SR_NORMALIZE
  //      SR_AUTO_NORMAL
  //      SR_VERTEX_ARRAY
  //      SR_NORMAL_ARRAY
  //      SR_COLOR_ARRAY
  //      SR_INDEX_ARRAY
  //      SR_TEXTURE_COORD_ARRAY
  //      SR_EDGE_FLAG_ARRAY
  //      SR_POLYGON_OFFSET_POINT
  //      SR_POLYGON_OFFSET_LINE
  //      SR_POLYGON_OFFSET_FILL

  // ErrorCode
  SR_NO_ERROR                       = 0;
  SR_INVALID_ENUM                   = $0500;
  SR_INVALID_VALUE                  = $0501;
  SR_INVALID_OPERATION              = $0502;
  SR_STACK_OVERFLOW                 = $0503;
  SR_STACK_UNDERFLOW                = $0504;
  SR_OUT_OF_MEMORY                  = $0505;

  // FeedBackMode
  SR_2D                             = $0600;
  SR_3D                             = $0601;
  SR_3D_COLOR                       = $0602;
  SR_3D_COLOR_TEXTURE               = $0603;
  SR_4D_COLOR_TEXTURE               = $0604;
  SR_3D_ORTHO 						= $0605;
  
  // FeedBackToken
  SR_PASS_THROUGH_TOKEN             = $0700;
  SR_POINT_TOKEN                    = $0701;
  SR_LINE_TOKEN                     = $0702;
  SR_POLYGON_TOKEN                  = $0703;
  SR_BITMAP_TOKEN                   = $0704;
  SR_DRAW_PIXEL_TOKEN               = $0705;
  SR_COPY_PIXEL_TOKEN               = $0706;
  SR_LINE_RESET_TOKEN               = $0707;

  // FogMode
  //      SR_LINEAR
  SR_EXP                            = $0800;
  SR_EXP2                           = $0801;

  // FogParameter
  //      SR_FOG_COLOR
  //      SR_FOG_DENSITY
  //      SR_FOG_END
  //      SR_FOG_INDEX
  //      SR_FOG_MODE
  //      SR_FOG_START

  // FrontFaceDirection
  SR_CW                             = $0900;
  SR_CCW                            = $0901;

  // GetMapTarget
  SR_COEFF                          = $0A00;
  SR_ORDER                          = $0A01;
  SR_DOMAIN                         = $0A02;

  // GetPixelMap
  //      SR_PIXEL_MAP_I_TO_I
  //      SR_PIXEL_MAP_S_TO_S
  //      SR_PIXEL_MAP_I_TO_R
  //      SR_PIXEL_MAP_I_TO_G
  //      SR_PIXEL_MAP_I_TO_B
  //      SR_PIXEL_MAP_I_TO_A
  //      SR_PIXEL_MAP_R_TO_R
  //      SR_PIXEL_MAP_G_TO_G
  //      SR_PIXEL_MAP_B_TO_B
  //      SR_PIXEL_MAP_A_TO_A

  // GetPointerTarget
  //      SR_VERTEX_ARRAY_POINTER
  //      SR_NORMAL_ARRAY_POINTER
  //      SR_COLOR_ARRAY_POINTER
  //      SR_INDEX_ARRAY_POINTER
  //      SR_TEXTURE_COORD_ARRAY_POINTER
  //      SR_EDGE_FLAG_ARRAY_POINTER

  // GetTarget
  SR_CURRENT_COLOR                  = $0B00;
  SR_CURRENT_INDEX                  = $0B01;
  SR_CURRENT_NORMAL                 = $0B02;
  SR_CURRENT_TEXTURE_COORDS         = $0B03;
  SR_CURRENT_RASTER_COLOR           = $0B04;
  SR_CURRENT_RASTER_INDEX           = $0B05;
  SR_CURRENT_RASTER_TEXTURE_COORDS  = $0B06;
  SR_CURRENT_RASTER_POSITION        = $0B07;
  SR_CURRENT_RASTER_POSITION_VALID  = $0B08;
  SR_CURRENT_RASTER_DISTANCE        = $0B09;
  SR_POINT_SMOOTH                   = $0B10;
  SR_POINT_SIZE                     = $0B11;
  SR_POINT_SIZE_RANGE               = $0B12;
  SR_POINT_SIZE_GRANULARITY         = $0B13;
  SR_LINE_SMOOTH                    = $0B20;
  SR_LINE_WIDTH                     = $0B21;
  SR_LINE_WIDTH_RANGE               = $0B22;
  SR_LINE_WIDTH_GRANULARITY         = $0B23;
  SR_LINE_STIPPLE                   = $0B24;
  SR_LINE_STIPPLE_PATTERN           = $0B25;
  SR_LINE_STIPPLE_REPEAT            = $0B26;
  SR_LIST_MODE                      = $0B30;
  SR_MAX_LIST_NESTING               = $0B31;
  SR_LIST_BASE                      = $0B32;
  SR_LIST_INDEX                     = $0B33;
  SR_POLYGON_MODE                   = $0B40;
  SR_POLYGON_SMOOTH                 = $0B41;
  SR_POLYGON_STIPPLE                = $0B42;
  SR_EDGE_FLAG                      = $0B43;
  SR_CULL_FACE                      = $0B44;
  SR_CULL_FACE_MODE                 = $0B45;
  SR_FRONT_FACE                     = $0B46;
  SR_LIGHTING                       = $0B50;
  SR_LIGHT_MODEL_LOCAL_VIEWER       = $0B51;
  SR_LIGHT_MODEL_TWO_SIDE           = $0B52;
  SR_LIGHT_MODEL_AMBIENT            = $0B53;
  SR_SHADE_MODEL                    = $0B54;
  SR_COLOR_MATERIAL_FACE            = $0B55;
  SR_COLOR_MATERIAL_PARAMETER       = $0B56;
  SR_COLOR_MATERIAL                 = $0B57;
  SR_FOG                            = $0B60;
  SR_FOG_INDEX                      = $0B61;
  SR_FOG_DENSITY                    = $0B62;
  SR_FOG_START                      = $0B63;
  SR_FOG_END                        = $0B64;
  SR_FOG_MODE                       = $0B65;
  SR_FOG_COLOR                      = $0B66;
  SR_DEPTH_RANGE                    = $0B70;
  SR_DEPTH_TEST                     = $0B71;
  SR_DEPTH_WRITEMASK                = $0B72;
  SR_DEPTH_CLEAR_VALUE              = $0B73;
  SR_DEPTH_FUNC                     = $0B74;
  SR_ACCUM_CLEAR_VALUE              = $0B80;
  SR_STENCIL_TEST                   = $0B90;
  SR_STENCIL_CLEAR_VALUE            = $0B91;
  SR_STENCIL_FUNC                   = $0B92;
  SR_STENCIL_VALUE_MASK             = $0B93;
  SR_STENCIL_FAIL                   = $0B94;
  SR_STENCIL_PASS_DEPTH_FAIL        = $0B95;
  SR_STENCIL_PASS_DEPTH_PASS        = $0B96;
  SR_STENCIL_REF                    = $0B97;
  SR_STENCIL_WRITEMASK              = $0B98;
  SR_MATRIX_MODE                    = $0BA0;
  SR_NORMALIZE                      = $0BA1;
  SR_VIEWPORT                       = $0BA2;
  SR_MODELVIEW_STACK_DEPTH          = $0BA3;
  SR_PROJECTION_STACK_DEPTH         = $0BA4;
  SR_TEXTURE_STACK_DEPTH            = $0BA5;
  SR_MODELVIEW_MATRIX               = $0BA6;
  SR_PROJECTION_MATRIX              = $0BA7;
  SR_TEXTURE_MATRIX                 = $0BA8;
  SR_ATTRIB_STACK_DEPTH             = $0BB0;
  SR_CLIENT_ATTRIB_STACK_DEPTH      = $0BB1;
  SR_ALPHA_TEST                     = $0BC0;
  SR_ALPHA_TEST_FUNC                = $0BC1;
  SR_ALPHA_TEST_REF                 = $0BC2;
  SR_DITHER                         = $0BD0;
  SR_BLEND_DST                      = $0BE0;
  SR_BLEND_SRC                      = $0BE1;
  SR_BLEND                          = $0BE2;
  SR_LOGIC_OP_MODE                  = $0BF0;
  SR_INDEX_LOGIC_OP                 = $0BF1;
  SR_COLOR_LOGIC_OP                 = $0BF2;
  SR_AUX_BUFFERS                    = $0C00;
  SR_DRAW_BUFFER                    = $0C01;
  SR_READ_BUFFER                    = $0C02;
  SR_SCISSOR_BOX                    = $0C10;
  SR_SCISSOR_TEST                   = $0C11;
  SR_INDEX_CLEAR_VALUE              = $0C20;
  SR_INDEX_WRITEMASK                = $0C21;
  SR_COLOR_CLEAR_VALUE              = $0C22;
  SR_COLOR_WRITEMASK                = $0C23;
  SR_INDEX_MODE                     = $0C30;
  SR_RGBA_MODE                      = $0C31;
  SR_DOUBLEBUFFER                   = $0C32;
  SR_STEREO                         = $0C33;
  SR_RENDER_MODE                    = $0C40;
  SR_PERSPECTIVE_CORRECTION_HINT    = $0C50;
  SR_POINT_SMOOTH_HINT              = $0C51;
  SR_LINE_SMOOTH_HINT               = $0C52;
  SR_POLYGON_SMOOTH_HINT            = $0C53;
  SR_FOG_HINT                       = $0C54;
  SR_TEXTURE_GEN_S                  = $0C60;
  SR_TEXTURE_GEN_T                  = $0C61;
  SR_TEXTURE_GEN_R                  = $0C62;
  SR_TEXTURE_GEN_Q                  = $0C63;
  SR_PIXEL_MAP_I_TO_I               = $0C70;
  SR_PIXEL_MAP_S_TO_S               = $0C71;
  SR_PIXEL_MAP_I_TO_R               = $0C72;
  SR_PIXEL_MAP_I_TO_G               = $0C73;
  SR_PIXEL_MAP_I_TO_B               = $0C74;
  SR_PIXEL_MAP_I_TO_A               = $0C75;
  SR_PIXEL_MAP_R_TO_R               = $0C76;
  SR_PIXEL_MAP_G_TO_G               = $0C77;
  SR_PIXEL_MAP_B_TO_B               = $0C78;
  SR_PIXEL_MAP_A_TO_A               = $0C79;
  SR_PIXEL_MAP_I_TO_I_SIZE          = $0CB0;
  SR_PIXEL_MAP_S_TO_S_SIZE          = $0CB1;
  SR_PIXEL_MAP_I_TO_R_SIZE          = $0CB2;
  SR_PIXEL_MAP_I_TO_G_SIZE          = $0CB3;
  SR_PIXEL_MAP_I_TO_B_SIZE          = $0CB4;
  SR_PIXEL_MAP_I_TO_A_SIZE          = $0CB5;
  SR_PIXEL_MAP_R_TO_R_SIZE          = $0CB6;
  SR_PIXEL_MAP_G_TO_G_SIZE          = $0CB7;
  SR_PIXEL_MAP_B_TO_B_SIZE          = $0CB8;
  SR_PIXEL_MAP_A_TO_A_SIZE          = $0CB9;
  SR_UNPACK_SWAP_BYTES              = $0CF0;
  SR_UNPACK_LSB_FIRST               = $0CF1;
  SR_UNPACK_ROW_LENGTH              = $0CF2;
  SR_UNPACK_SKIP_ROWS               = $0CF3;
  SR_UNPACK_SKIP_PIXELS             = $0CF4;
  SR_UNPACK_ALIGNMENT               = $0CF5;
  SR_PACK_SWAP_BYTES                = $0D00;
  SR_PACK_LSB_FIRST                 = $0D01;
  SR_PACK_ROW_LENGTH                = $0D02;
  SR_PACK_SKIP_ROWS                 = $0D03;
  SR_PACK_SKIP_PIXELS               = $0D04;
  SR_PACK_ALIGNMENT                 = $0D05;
  SR_MAP_COLOR                      = $0D10;
  SR_MAP_STENCIL                    = $0D11;
  SR_INDEX_SHIFT                    = $0D12;
  SR_INDEX_OFFSET                   = $0D13;
  SR_RED_SCALE                      = $0D14;
  SR_RED_BIAS                       = $0D15;
  SR_ZOOM_X                         = $0D16;
  SR_ZOOM_Y                         = $0D17;
  SR_GREEN_SCALE                    = $0D18;
  SR_GREEN_BIAS                     = $0D19;
  SR_BLUE_SCALE                     = $0D1A;
  SR_BLUE_BIAS                      = $0D1B;
  SR_ALPHA_SCALE                    = $0D1C;
  SR_ALPHA_BIAS                     = $0D1D;
  SR_DEPTH_SCALE                    = $0D1E;
  SR_DEPTH_BIAS                     = $0D1F;
  SR_MAX_EVAL_ORDER                 = $0D30;
  SR_MAX_LIGHTS                     = $0D31;
  SR_MAX_CLIP_PLANES                = $0D32;
  SR_MAX_TEXTURE_SIZE               = $0D33;
  SR_MAX_PIXEL_MAP_TABLE            = $0D34;
  SR_MAX_ATTRIB_STACK_DEPTH         = $0D35;
  SR_MAX_MODELVIEW_STACK_DEPTH      = $0D36;
  SR_MAX_NAME_STACK_DEPTH           = $0D37;
  SR_MAX_PROJECTION_STACK_DEPTH     = $0D38;
  SR_MAX_TEXTURE_STACK_DEPTH        = $0D39;
  SR_MAX_VIEWPORT_DIMS              = $0D3A;
  SR_MAX_CLIENT_ATTRIB_STACK_DEPTH  = $0D3B;
  SR_SUBPIXEL_BITS                  = $0D50;
  SR_INDEX_BITS                     = $0D51;
  SR_RED_BITS                       = $0D52;
  SR_GREEN_BITS                     = $0D53;
  SR_BLUE_BITS                      = $0D54;
  SR_ALPHA_BITS                     = $0D55;
  SR_DEPTH_BITS                     = $0D56;
  SR_STENCIL_BITS                   = $0D57;
  SR_ACCUM_RED_BITS                 = $0D58;
  SR_ACCUM_GREEN_BITS               = $0D59;
  SR_ACCUM_BLUE_BITS                = $0D5A;
  SR_ACCUM_ALPHA_BITS               = $0D5B;
  SR_NAME_STACK_DEPTH               = $0D70;
  SR_AUTO_NORMAL                    = $0D80;
  SR_MAP1_COLOR_4                   = $0D90;
  SR_MAP1_INDEX                     = $0D91;
  SR_MAP1_NORMAL                    = $0D92;
  SR_MAP1_TEXTURE_COORD_1           = $0D93;
  SR_MAP1_TEXTURE_COORD_2           = $0D94;
  SR_MAP1_TEXTURE_COORD_3           = $0D95;
  SR_MAP1_TEXTURE_COORD_4           = $0D96;
  SR_MAP1_VERTEX_3                  = $0D97;
  SR_MAP1_VERTEX_4                  = $0D98;
  SR_MAP2_COLOR_4                   = $0DB0;
  SR_MAP2_INDEX                     = $0DB1;
  SR_MAP2_NORMAL                    = $0DB2;
  SR_MAP2_TEXTURE_COORD_1           = $0DB3;
  SR_MAP2_TEXTURE_COORD_2           = $0DB4;
  SR_MAP2_TEXTURE_COORD_3           = $0DB5;
  SR_MAP2_TEXTURE_COORD_4           = $0DB6;
  SR_MAP2_VERTEX_3                  = $0DB7;
  SR_MAP2_VERTEX_4                  = $0DB8;
  SR_MAP1_GRID_DOMAIN               = $0DD0;
  SR_MAP1_GRID_SEGMENTS             = $0DD1;
  SR_MAP2_GRID_DOMAIN               = $0DD2;
  SR_MAP2_GRID_SEGMENTS             = $0DD3;
  SR_TEXTURE_1D                     = $0DE0;
  SR_TEXTURE_2D                     = $0DE1;
  SR_FEEDBACK_BUFFER_POINTER        = $0DF0;
  SR_FEEDBACK_BUFFER_SIZE           = $0DF1;
  SR_FEEDBACK_BUFFER_TYPE           = $0DF2;
  SR_SELECTION_BUFFER_POINTER       = $0DF3;
  SR_SELECTION_BUFFER_SIZE          = $0DF4;
  //      SR_TEXTURE_BINDING_1D
  //      SR_TEXTURE_BINDING_2D
  //      SR_VERTEX_ARRAY
  //      SR_NORMAL_ARRAY
  //      SR_COLOR_ARRAY
  //      SR_INDEX_ARRAY
  //      SR_TEXTURE_COORD_ARRAY
  //      SR_EDGE_FLAG_ARRAY
  //      SR_VERTEX_ARRAY_SIZE
  //      SR_VERTEX_ARRAY_TYPE
  //      SR_VERTEX_ARRAY_STRIDE
  //      SR_NORMAL_ARRAY_TYPE
  //      SR_NORMAL_ARRAY_STRIDE
  //      SR_COLOR_ARRAY_SIZE
  //      SR_COLOR_ARRAY_TYPE
  //      SR_COLOR_ARRAY_STRIDE
  //      SR_INDEX_ARRAY_TYPE
  //      SR_INDEX_ARRAY_STRIDE
  //      SR_TEXTURE_COORD_ARRAY_SIZE
  //      SR_TEXTURE_COORD_ARRAY_TYPE
  //      SR_TEXTURE_COORD_ARRAY_STRIDE
  //      SR_EDGE_FLAG_ARRAY_STRIDE
  //      SR_POLYGON_OFFSET_FACTOR
  //      SR_POLYGON_OFFSET_UNITS

  // GetTextureParameter
  //      SR_TEXTURE_MAG_FILTER
  //      SR_TEXTURE_MIN_FILTER
  //      SR_TEXTURE_WRAP_S
  //      SR_TEXTURE_WRAP_T
  SR_TEXTURE_WIDTH                  = $1000;
  SR_TEXTURE_HEIGHT                 = $1001;
  SR_TEXTURE_INTERNAL_FORMAT        = $1003;
  SR_TEXTURE_BORDER_COLOR           = $1004;
  SR_TEXTURE_BORDER                 = $1005;
  //      SR_TEXTURE_RED_SIZE
  //      SR_TEXTURE_GREEN_SIZE
  //      SR_TEXTURE_BLUE_SIZE
  //      SR_TEXTURE_ALPHA_SIZE
  //      SR_TEXTURE_LUMINANCE_SIZE
  //      SR_TEXTURE_INTENSITY_SIZE
  //      SR_TEXTURE_PRIORITY
  //      SR_TEXTURE_RESIDENT

  // HintMode
  SR_DONT_CARE                      = $1100;
  SR_FASTEST                        = $1101;
  SR_NICEST                         = $1102;

  // HintTarget
  //      SR_PERSPECTIVE_CORRECTION_HINT
  //      SR_POINT_SMOOTH_HINT
  //      SR_LINE_SMOOTH_HINT
  //      SR_POLYGON_SMOOTH_HINT
  //      SR_FOG_HINT

  // IndexPointerType
  //      SR_SHORT
  //      SR_INT
  //      SR_FLOAT
  //      SR_DOUBLE

  // LightModelParameter
  //      SR_LIGHT_MODEL_AMBIENT
  //      SR_LIGHT_MODEL_LOCAL_VIEWER
  //      SR_LIGHT_MODEL_TWO_SIDE

  // LightName
  SR_LIGHT0                         = $4000;
  SR_LIGHT1                         = $4001;
  SR_LIGHT2                         = $4002;
  SR_LIGHT3                         = $4003;
  SR_LIGHT4                         = $4004;
  SR_LIGHT5                         = $4005;
  SR_LIGHT6                         = $4006;
  SR_LIGHT7                         = $4007;

  // LightParameter
  SR_AMBIENT                        = $1200;
  SR_DIFFUSE                        = $1201;
  SR_SPECULAR                       = $1202;
  SR_POSITION                       = $1203;
  SR_SPOT_DIRECTION                 = $1204;
  SR_SPOT_EXPONENT                  = $1205;
  SR_SPOT_CUTOFF                    = $1206;
  SR_CONSTANT_ATTENUATION           = $1207;
  SR_LINEAR_ATTENUATION             = $1208;
  SR_QUADRATIC_ATTENUATION          = $1209;

  // InterleavedArrays
  //      SR_V2F
  //      SR_V3F
  //      SR_C4UB_V2F
  //      SR_C4UB_V3F
  //      SR_C3F_V3F
  //      SR_N3F_V3F
  //      SR_C4F_N3F_V3F
  //      SR_T2F_V3F
  //      SR_T4F_V4F
  //      SR_T2F_C4UB_V3F
  //      SR_T2F_C3F_V3F
  //      SR_T2F_N3F_V3F
  //      SR_T2F_C4F_N3F_V3F
  //      SR_T4F_C4F_N3F_V4F

  // ListMode
  SR_COMPILE                        = $1300;
  SR_COMPILE_AND_EXECUTE            = $1301;

  // ListNameType
  //      SR_BYTE
  //      SR_UNSIGNED_BYTE
  //      SR_SHORT
  //      SR_UNSIGNED_SHORT
  //      SR_INT
  //      SR_UNSIGNED_INT
  //      SR_FLOAT
  //      SR_2_BYTES
  //      SR_3_BYTES
  //      SR_4_BYTES

  // LogicOp
  SR_CLEAR                          = $1500;
  SR_AND                            = $1501;
  SR_AND_REVERSE                    = $1502;
  SR_COPY                           = $1503;
  SR_AND_INVERTED                   = $1504;
  SR_NOOP                           = $1505;
  SR_XOR                            = $1506;
  SR_OR                             = $1507;
  SR_NOR                            = $1508;
  SR_EQUIV                          = $1509;
  SR_INVERT                         = $150A;
  SR_OR_REVERSE                     = $150B;
  SR_COPY_INVERTED                  = $150C;
  SR_OR_INVERTED                    = $150D;
  SR_NAND                           = $150E;
  SR_SET                            = $150F;

  // MapTarget
  //      SR_MAP1_COLOR_4
  //      SR_MAP1_INDEX
  //      SR_MAP1_NORMAL
  //      SR_MAP1_TEXTURE_COORD_1
  //      SR_MAP1_TEXTURE_COORD_2
  //      SR_MAP1_TEXTURE_COORD_3
  //      SR_MAP1_TEXTURE_COORD_4
  //      SR_MAP1_VERTEX_3
  //      SR_MAP1_VERTEX_4
  //      SR_MAP2_COLOR_4
  //      SR_MAP2_INDEX
  //      SR_MAP2_NORMAL
  //      SR_MAP2_TEXTURE_COORD_1
  //      SR_MAP2_TEXTURE_COORD_2
  //      SR_MAP2_TEXTURE_COORD_3
  //      SR_MAP2_TEXTURE_COORD_4
  //      SR_MAP2_VERTEX_3
  //      SR_MAP2_VERTEX_4

  // MaterialFace
  //      SR_FRONT
  //      SR_BACK
  //      SR_FRONT_AND_BACK

  // MaterialParameter
  SR_EMISSION                       = $1600;
  SR_SHININESS                      = $1601;
  SR_AMBIENT_AND_DIFFUSE            = $1602;
  SR_COLOR_INDEXES                  = $1603;
  //      SR_AMBIENT
  //      SR_DIFFUSE
  //      SR_SPECULAR

  // MatrixMode
  SR_MODELVIEW                      = $1700;
  SR_PROJECTION                     = $1701;
  SR_TEXTURE                        = $1702;

  // MeshMode1
  //      SR_POINT
  //      SR_LINE

  // MeshMode2
  //      SR_POINT
  //      SR_LINE
  //      SR_FILL

  // NormalPointerType
  //      SR_BYTE
  //      SR_SHORT
  //      SR_INT
  //      SR_FLOAT
  //      SR_DOUBLE

  // PixelCopyType
  SR_COLOR                          = $1800;
  SR_DEPTH                          = $1801;
  SR_STENCIL                        = $1802;

  // PixelFormat
  SR_COLOR_INDEX                    = $1900;
  SR_STENCIL_INDEX                  = $1901;
  SR_DEPTH_COMPONENT                = $1902;
  SR_RED                            = $1903;
  SR_GREEN                          = $1904;
  SR_BLUE                           = $1905;
  SR_ALPHA                          = $1906;
  SR_RGB                            = $1907;
  SR_RGBA                           = $1908;
  SR_LUMINANCE                      = $1909;
  SR_LUMINANCE_ALPHA                = $190A;

  // PixelMap
  //      SR_PIXEL_MAP_I_TO_I
  //      SR_PIXEL_MAP_S_TO_S
  //      SR_PIXEL_MAP_I_TO_R
  //      SR_PIXEL_MAP_I_TO_G
  //      SR_PIXEL_MAP_I_TO_B
  //      SR_PIXEL_MAP_I_TO_A
  //      SR_PIXEL_MAP_R_TO_R
  //      SR_PIXEL_MAP_G_TO_G
  //      SR_PIXEL_MAP_B_TO_B
  //      SR_PIXEL_MAP_A_TO_A

  // PixelStore
  //      SR_UNPACK_SWAP_BYTES
  //      SR_UNPACK_LSB_FIRST
  //      SR_UNPACK_ROW_LENGTH
  //      SR_UNPACK_SKIP_ROWS
  //      SR_UNPACK_SKIP_PIXELS
  //      SR_UNPACK_ALIGNMENT
  //      SR_PACK_SWAP_BYTES
  //      SR_PACK_LSB_FIRST
  //      SR_PACK_ROW_LENGTH
  //      SR_PACK_SKIP_ROWS
  //      SR_PACK_SKIP_PIXELS
  //      SR_PACK_ALIGNMENT

  // PixelTransfer
  //      SR_MAP_COLOR
  //      SR_MAP_STENCIL
  //      SR_INDEX_SHIFT
  //      SR_INDEX_OFFSET
  //      SR_RED_SCALE
  //      SR_RED_BIAS
  //      SR_GREEN_SCALE
  //      SR_GREEN_BIAS
  //      SR_BLUE_SCALE
  //      SR_BLUE_BIAS
  //      SR_ALPHA_SCALE
  //      SR_ALPHA_BIAS
  //      SR_DEPTH_SCALE
  //      SR_DEPTH_BIAS

  // PixelType
  SR_BITMAP                         = $1A00;
  //      SR_BYTE
  //      SR_UNSIGNED_BYTE
  //      SR_SHORT
  //      SR_UNSIGNED_SHORT
  //      SR_INT
  //      SR_UNSIGNED_INT
  //      SR_FLOAT

  // PolygonMode
  SR_POINT                          = $1B00;
  SR_LINE                           = $1B01;
  SR_FILL                           = $1B02;

  // ReadBufferMode
  //      SR_FRONT_LEFT
  //      SR_FRONT_RIGHT
  //      SR_BACK_LEFT
  //      SR_BACK_RIGHT
  //      SR_FRONT
  //      SR_BACK
  //      SR_LEFT
  //      SR_RIGHT
  //      SR_AUX0
  //      SR_AUX1
  //      SR_AUX2
  //      SR_AUX3

  // RenderingMode
  SR_RENDER                         = $1C00;
  SR_FEEDBACK                       = $1C01;
  SR_SELECT                         = $1C02;

  // ShadingModel
  SR_FLAT                           = $1D00;
  SR_SMOOTH                         = $1D01;

  // StencilFunction
  //      SR_NEVER
  //      SR_LESS
  //      SR_EQUAL
  //      SR_LEQUAL
  //      SR_GREATER
  //      SR_NOTEQUAL
  //      SR_GEQUAL
  //      SR_ALWAYS

  // StencilOp
  //      SR_ZERO
  SR_KEEP                           = $1E00;
  SR_REPLACE                        = $1E01;
  SR_INCR                           = $1E02;
  SR_DECR                           = $1E03;
  //      SR_INVERT

  // StringName
  SR_VENDOR                         = $1F00;
  SR_RENDERER                       = $1F01;
  SR_VERSION                        = $1F02;
  SR_EXTENSIONS                     = $1F03;

  // TextureCoordName
  SR_S                              = $2000;
  SR_T                              = $2001;
  SR_R                              = $2002;
  SR_Q                              = $2003;

  // TexCoordPointerType
  //      SR_SHORT
  //      SR_INT
  //      SR_FLOAT
  //      SR_DOUBLE

  // TextureEnvMode
  SR_MODULATE                       = $2100;
  SR_DECAL                          = $2101;
  //      SR_BLEND
  //      SR_REPLACE

  // TextureEnvParameter
  SR_TEXTURE_ENV_MODE               = $2200;
  SR_TEXTURE_ENV_COLOR              = $2201;

  // TextureEnvTarget
  SR_TEXTURE_ENV                    = $2300;

  // TextureGenMode
  SR_EYE_LINEAR                     = $2400;
  SR_OBJECT_LINEAR                  = $2401;
  SR_SPHERE_MAP                     = $2402;

  // TextureGenParameter
  SR_TEXTURE_GEN_MODE               = $2500;
  SR_OBJECT_PLANE                   = $2501;
  SR_EYE_PLANE                      = $2502;

  // TextureMagFilter
  SR_NEAREST                        = $2600;
  SR_LINEAR                         = $2601;

  // TextureMinFilter
  //      SR_NEAREST
  //      SR_LINEAR
  SR_NEAREST_MIPMAP_NEAREST         = $2700;
  SR_LINEAR_MIPMAP_NEAREST          = $2701;
  SR_NEAREST_MIPMAP_LINEAR          = $2702;
  SR_LINEAR_MIPMAP_LINEAR           = $2703;

  // TextureParameterName
  SR_TEXTURE_MAG_FILTER             = $2800;
  SR_TEXTURE_MIN_FILTER             = $2801;
  SR_TEXTURE_WRAP_S                 = $2802;
  SR_TEXTURE_WRAP_T                 = $2803;
  //      SR_TEXTURE_BORDER_COLOR
  //      SR_TEXTURE_PRIORITY

  // TextureTarget
  //      SR_TEXTURE_1D
  //      SR_TEXTURE_2D
  //      SR_PROXY_TEXTURE_1D
  //      SR_PROXY_TEXTURE_2D

  // TextureWrapMode
  SR_CLAMP                          = $2900;
  SR_REPEAT                         = $2901;

  // VertexPointerType
  //      SR_SHORT
  //      SR_INT
  //      SR_FLOAT
  //      SR_DOUBLE

  // ClientAttribMask
  SR_CLIENT_PIXEL_STORE_BIT         = $00000001;
  SR_CLIENT_VERTEX_ARRAY_BIT        = $00000002;
  SR_CLIENT_ALL_ATTRIB_BITS         = $FFFFFFFF;

  // polygon_offset
  SR_POLYGON_OFFSET_FACTOR          = $8038;
  SR_POLYGON_OFFSET_UNITS           = $2A00;
  SR_POLYGON_OFFSET_POINT           = $2A01;
  SR_POLYGON_OFFSET_LINE            = $2A02;
  SR_POLYGON_OFFSET_FILL            = $8037;

  // texture
  SR_ALPHA4                         = $803B;
  SR_ALPHA8                         = $803C;
  SR_ALPHA12                        = $803D;
  SR_ALPHA16                        = $803E;
  SR_LUMINANCE4                     = $803F;
  SR_LUMINANCE8                     = $8040;
  SR_LUMINANCE12                    = $8041;
  SR_LUMINANCE16                    = $8042;
  SR_LUMINANCE4_ALPHA4              = $8043;
  SR_LUMINANCE6_ALPHA2              = $8044;
  SR_LUMINANCE8_ALPHA8              = $8045;
  SR_LUMINANCE12_ALPHA4             = $8046;
  SR_LUMINANCE12_ALPHA12            = $8047;
  SR_LUMINANCE16_ALPHA16            = $8048;
  SR_INTENSITY                      = $8049;
  SR_INTENSITY4                     = $804A;
  SR_INTENSITY8                     = $804B;
  SR_INTENSITY12                    = $804C;
  SR_INTENSITY16                    = $804D;
  SR_R3_G3_B2                       = $2A10;
  SR_RGB4                           = $804F;
  SR_RGB5                           = $8050;
  SR_RGB8                           = $8051;
  SR_RGB10                          = $8052;
  SR_RGB12                          = $8053;
  SR_RGB16                          = $8054;
  SR_RGBA2                          = $8055;
  SR_RGBA4                          = $8056;
  SR_RGB5_A1                        = $8057;
  SR_RGBA8                          = $8058;
  SR_RGB10_A2                       = $8059;
  SR_RGBA12                         = $805A;
  SR_RGBA16                         = $805B;
  SR_TEXTURE_RED_SIZE               = $805C;
  SR_TEXTURE_GREEN_SIZE             = $805D;
  SR_TEXTURE_BLUE_SIZE              = $805E;
  SR_TEXTURE_ALPHA_SIZE             = $805F;
  SR_TEXTURE_LUMINANCE_SIZE         = $8060;
  SR_TEXTURE_INTENSITY_SIZE         = $8061;
  SR_PROXY_TEXTURE_1D               = $8063;
  SR_PROXY_TEXTURE_2D               = $8064;

  // texture_object
  SR_TEXTURE_PRIORITY               = $8066;
  SR_TEXTURE_RESIDENT               = $8067;
  SR_TEXTURE_BINDING_1D             = $8068;
  SR_TEXTURE_BINDING_2D             = $8069;

  // vertex_array
  SR_VERTEX_ARRAY                   = $8074;
  SR_NORMAL_ARRAY                   = $8075;
  SR_COLOR_ARRAY                    = $8076;
  SR_INDEX_ARRAY                    = $8077;
  SR_TEXTURE_COORD_ARRAY            = $8078;
  SR_EDGE_FLAG_ARRAY                = $8079;
  SR_VERTEX_ARRAY_SIZE              = $807A;
  SR_VERTEX_ARRAY_TYPE              = $807B;
  SR_VERTEX_ARRAY_STRIDE            = $807C;
  SR_NORMAL_ARRAY_TYPE              = $807E;
  SR_NORMAL_ARRAY_STRIDE            = $807F;
  SR_COLOR_ARRAY_SIZE               = $8081;
  SR_COLOR_ARRAY_TYPE               = $8082;
  SR_COLOR_ARRAY_STRIDE             = $8083;
  SR_INDEX_ARRAY_TYPE               = $8085;
  SR_INDEX_ARRAY_STRIDE             = $8086;
  SR_TEXTURE_COORD_ARRAY_SIZE       = $8088;
  SR_TEXTURE_COORD_ARRAY_TYPE       = $8089;
  SR_TEXTURE_COORD_ARRAY_STRIDE     = $808A;
  SR_EDGE_FLAG_ARRAY_STRIDE         = $808C;
  SR_VERTEX_ARRAY_POINTER           = $808E;
  SR_NORMAL_ARRAY_POINTER           = $808F;
  SR_COLOR_ARRAY_POINTER            = $8090;
  SR_INDEX_ARRAY_POINTER            = $8091;
  SR_TEXTURE_COORD_ARRAY_POINTER    = $8092;
  SR_EDGE_FLAG_ARRAY_POINTER        = $8093;
  SR_V2F                            = $2A20;
  SR_V3F                            = $2A21;
  SR_C4UB_V2F                       = $2A22;
  SR_C4UB_V3F                       = $2A23;
  SR_C3F_V3F                        = $2A24;
  SR_N3F_V3F                        = $2A25;
  SR_C4F_N3F_V3F                    = $2A26;
  SR_T2F_V3F                        = $2A27;
  SR_T4F_V4F                        = $2A28;
  SR_T2F_C4UB_V3F                   = $2A29;
  SR_T2F_C3F_V3F                    = $2A2A;
  SR_T2F_N3F_V3F                    = $2A2B;
  SR_T2F_C4F_N3F_V3F                = $2A2C;
  SR_T4F_C4F_N3F_V4F                = $2A2D;

  // For compatibility with OpenS v1.0
  SR_LOGIC_OP                       = SR_INDEX_LOGIC_OP;
  SR_TEXTURE_COMPONENTS             = SR_TEXTURE_INTERNAL_FORMAT;
  
  
{***** GL_ARB_vertex_buffer_object *****}
const
     SR_BUFFER_SIZE_ARB = $8764;
     SR_BUFFER_USAGE_ARB = $8765;
     SR_ARRAY_BUFFER_ARB = $8892;
     SR_ELEMENT_ARRAY_BUFFER_ARB = $8893;
     SR_ARRAY_BUFFER_BINDING_ARB = $8894;
     SR_ELEMENT_ARRAY_BUFFER_BINDING_ARB = $8895;
     SR_VERTEX_ARRAY_BUFFER_BINDING_ARB = $8896;
     SR_NORMAL_ARRAY_BUFFER_BINDING_ARB = $8897;
     SR_COLOR_ARRAY_BUFFER_BINDING_ARB = $8898;
     SR_INDEX_ARRAY_BUFFER_BINDING_ARB = $8899;
     SR_TEXTURE_COORD_ARRAY_BUFFER_BINDING_ARB = $889A;
     SR_EDGE_FLAG_ARRAY_BUFFER_BINDING_ARB = $889B;
     SR_SECONDARY_COLOR_ARRAY_BUFFER_BINDING_ARB = $889C;
     SR_FOG_COORDINATE_ARRAY_BUFFER_BINDING_ARB = $889D;
     SR_WEIGHT_ARRAY_BUFFER_BINDING_ARB = $889E;
     SR_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING_ARB = $889F;
     SR_READ_ONLY_ARB = $88B8;
     SR_WRITE_ONLY_ARB = $88B9;
     SR_READ_WRITE_ARB = $88BA;
     SR_BUFFER_ACCESS_ARB = $88BB;
     SR_BUFFER_MAPPED_ARB = $88BC;
     SR_BUFFER_MAP_POINTER_ARB = $88BD;
     SR_STREAM_DRAW_ARB = $88E0;
     SR_STREAM_READ_ARB = $88E1;
     SR_STREAM_COPY_ARB = $88E2;
     SR_STATIC_DRAW_ARB = $88E4;
     SR_STATIC_READ_ARB = $88E5;
     SR_STATIC_COPY_ARB = $88E6;
     SR_DYNAMIC_DRAW_ARB = $88E8;
     SR_DYNAMIC_READ_ARB = $88E9;
     SR_DYNAMIC_COPY_ARB = $88EA;    

//***** SR_EXT_vertex_shader *****//
const
  SR_VERTEX_SHADER_EXT = $8780;
  SR_VARIANT_VALUE_EXT = $87E4;
  SR_VARIANT_DATATYPE_EXT = $87E5;
  SR_VARIANT_ARRAY_STRIDE_EXT = $87E6;
  SR_VARIANT_ARRAY_TYPE_EXT = $87E7;
  SR_VARIANT_ARRAY_EXT = $87E8;
  SR_VARIANT_ARRAY_POINTER_EXT = $87E9;
  SR_INVARIANT_VALUE_EXT = $87EA;
  SR_INVARIANT_DATATYPE_EXT = $87EB;
  SR_LOCAL_CONSTANT_VALUE_EXT = $87EC;
  SR_LOCAL_CONSTANT_DATATYPE_EXT = $87ED;
  SR_OP_INDEX_EXT = $8782;
  SR_OP_NEGATE_EXT = $8783;
  SR_OP_DOT3_EXT = $8784;
  SR_OP_DOT4_EXT = $8785;
  SR_OP_MUL_EXT = $8786;
  SR_OP_ADD_EXT = $8787;
  SR_OP_MADD_EXT = $8788;
  SR_OP_FRAC_EXT = $8789;
  SR_OP_MAX_EXT = $878A;
  SR_OP_MIN_EXT = $878B;
  SR_OP_SET_GE_EXT = $878C;
  SR_OP_SET_LT_EXT = $878D;
  SR_OP_CLAMP_EXT = $878E;
  SR_OP_FLOOR_EXT = $878F;
  SR_OP_ROUND_EXT = $8790;
  SR_OP_EXP_BASE_2_EXT = $8791;
  SR_OP_LOG_BASE_2_EXT = $8792;
  SR_OP_POWER_EXT = $8793;
  SR_OP_RECIP_EXT = $8794;
  SR_OP_RECIP_SQRT_EXT = $8795;
  SR_OP_SUB_EXT = $8796;
  SR_OP_CROSS_PRODUCT_EXT = $8797;
  SR_OP_MULTIPLY_MATRIX_EXT = $8798;
  SR_OP_MOV_EXT = $8799;
  SR_OUTPUT_VERTEX_EXT = $879A;
  SR_OUTPUT_COLOR0_EXT = $879B;
  SR_OUTPUT_COLOR1_EXT = $879C;
  SR_OUTPUT_TEXTURE_COORD0_EXT = $879D;
  SR_OUTPUT_TEXTURE_COORD1_EXT = $879E;
  SR_OUTPUT_TEXTURE_COORD2_EXT = $879F;
  SR_OUTPUT_TEXTURE_COORD3_EXT = $87A0;
  SR_OUTPUT_TEXTURE_COORD4_EXT = $87A1;
  SR_OUTPUT_TEXTURE_COORD5_EXT = $87A2;
  SR_OUTPUT_TEXTURE_COORD6_EXT = $87A3;
  SR_OUTPUT_TEXTURE_COORD7_EXT = $87A4;
  SR_OUTPUT_TEXTURE_COORD8_EXT = $87A5;
  SR_OUTPUT_TEXTURE_COORD9_EXT = $87A6;
  SR_OUTPUT_TEXTURE_COORD10_EXT = $87A7;
  SR_OUTPUT_TEXTURE_COORD11_EXT = $87A8;
  SR_OUTPUT_TEXTURE_COORD12_EXT = $87A9;
  SR_OUTPUT_TEXTURE_COORD13_EXT = $87AA;
  SR_OUTPUT_TEXTURE_COORD14_EXT = $87AB;
  SR_OUTPUT_TEXTURE_COORD15_EXT = $87AC;
  SR_OUTPUT_TEXTURE_COORD16_EXT = $87AD;
  SR_OUTPUT_TEXTURE_COORD17_EXT = $87AE;
  SR_OUTPUT_TEXTURE_COORD18_EXT = $87AF;
  SR_OUTPUT_TEXTURE_COORD19_EXT = $87B0;
  SR_OUTPUT_TEXTURE_COORD20_EXT = $87B1;
  SR_OUTPUT_TEXTURE_COORD21_EXT = $87B2;
  SR_OUTPUT_TEXTURE_COORD22_EXT = $87B3;
  SR_OUTPUT_TEXTURE_COORD23_EXT = $87B4;
  SR_OUTPUT_TEXTURE_COORD24_EXT = $87B5;
  SR_OUTPUT_TEXTURE_COORD25_EXT = $87B6;
  SR_OUTPUT_TEXTURE_COORD26_EXT = $87B7;
  SR_OUTPUT_TEXTURE_COORD27_EXT = $87B8;
  SR_OUTPUT_TEXTURE_COORD28_EXT = $87B9;
  SR_OUTPUT_TEXTURE_COORD29_EXT = $87BA;
  SR_OUTPUT_TEXTURE_COORD30_EXT = $87BB;
  SR_OUTPUT_TEXTURE_COORD31_EXT = $87BC;
  SR_OUTPUT_FOG_EXT = $87BD;
  SR_SCALAR_EXT = $87BE;
  SR_VECTOR_EXT = $87BF;
  SR_MATRIX_EXT = $87C0;
  SR_VARIANT_EXT = $87C1;
  SR_INVARIANT_EXT = $87C2;
  SR_LOCAL_CONSTANT_EXT = $87C3;
  SR_LOCAL_EXT = $87C4;
  SR_MAX_VERTEX_SHADER_INSTRUCTIONS_EXT = $87C5;
  SR_MAX_VERTEX_SHADER_VARIANTS_EXT = $87C6;
  SR_MAX_VERTEX_SHADER_INVARIANTS_EXT = $87C7;
  SR_MAX_VERTEX_SHADER_LOCAL_CONSTANTS_EXT = $87C8;
  SR_MAX_VERTEX_SHADER_LOCALS_EXT = $87C9;
  SR_MAX_OPTIMIZED_VERTEX_SHADER_INSTRUCTIONS_EXT = $87CA;
  SR_MAX_OPTIMIZED_VERTEX_SHADER_VARIANTS_EXT = $87CB;
  SR_MAX_OPTIMIZED_VERTEX_SHADER_LOCAL_CONSTANTS_EXT = $87CC;
  SR_MAX_OPTIMIZED_VERTEX_SHADER_INVARIANTS_EXT = $87CD;
  SR_MAX_OPTIMIZED_VERTEX_SHADER_LOCALS_EXT = $87CE;
  SR_VERTEX_SHADER_INSTRUCTIONS_EXT = $87CF;
  SR_VERTEX_SHADER_VARIANTS_EXT = $87D0;
  SR_VERTEX_SHADER_INVARIANTS_EXT = $87D1;
  SR_VERTEX_SHADER_LOCAL_CONSTANTS_EXT = $87D2;
  SR_VERTEX_SHADER_LOCALS_EXT = $87D3;
  SR_VERTEX_SHADER_BINDING_EXT = $8781;
  SR_VERTEX_SHADER_OPTIMIZED_EXT = $87D4;
  SR_X_EXT = $87D5;
  SR_Y_EXT = $87D6;
  SR_Z_EXT = $87D7;
  SR_W_EXT = $87D8;
  SR_NEGATIVE_X_EXT = $87D9;
  SR_NEGATIVE_Y_EXT = $87DA;
  SR_NEGATIVE_Z_EXT = $87DB;
  SR_NEGATIVE_W_EXT = $87DC;
  SR_ZERO_EXT = $87DD;
  SR_ONE_EXT = $87DE;
  SR_NEGATIVE_ONE_EXT = $87DF;
  SR_NORMALIZED_RANGE_EXT = $87E0;
  SR_FULL_RANGE_EXT = $87E1;
  SR_CURRENT_VERTEX_EXT = $87E2;
  SR_MVP_MATRIX_EXT = $87E3;

//***** SR_version_2_0 *****//
const
  SR_BLEND_EQUATION_RGB = $8009;
  SR_VERTEX_ATTRIB_ARRAY_ENABLED = $8622;
  SR_VERTEX_ATTRIB_ARRAY_SIZE = $8623;
  SR_VERTEX_ATTRIB_ARRAY_STRIDE = $8624;
  SR_VERTEX_ATTRIB_ARRAY_TYPE = $8625;
  SR_CURRENT_VERTEX_ATTRIB = $8626;
  SR_VERTEX_PROGRAM_POINT_SIZE = $8642;
  SR_VERTEX_PROGRAM_TWO_SIDE = $8643;
  SR_VERTEX_ATTRIB_ARRAY_POINTER = $8645;
  SR_STENCIL_BACK_FUNC = $8800;
  SR_STENCIL_BACK_FAIL = $8801;
  SR_STENCIL_BACK_PASS_DEPTH_FAIL = $8802;
  SR_STENCIL_BACK_PASS_DEPTH_PASS = $8803;
  SR_MAX_DRAW_BUFFERS = $8824;
  SR_DRAW_BUFFER0 = $8825;
  SR_DRAW_BUFFER1 = $8826;
  SR_DRAW_BUFFER2 = $8827;
  SR_DRAW_BUFFER3 = $8828;
  SR_DRAW_BUFFER4 = $8829;
  SR_DRAW_BUFFER5 = $882A;
  SR_DRAW_BUFFER6 = $882B;
  SR_DRAW_BUFFER7 = $882C;
  SR_DRAW_BUFFER8 = $882D;
  SR_DRAW_BUFFER9 = $882E;
  SR_DRAW_BUFFER10 = $882F;
  SR_DRAW_BUFFER11 = $8830;
  SR_DRAW_BUFFER12 = $8831;
  SR_DRAW_BUFFER13 = $8832;
  SR_DRAW_BUFFER14 = $8833;
  SR_DRAW_BUFFER15 = $8834;
  SR_BLEND_EQUATION_ALPHA = $883D;
  SR_POINT_SPRITE = $8861;
  SR_COORD_REPLACE = $8862;
  SR_MAX_VERTEX_ATTRIBS = $8869;
  SR_VERTEX_ATTRIB_ARRAY_NORMALIZED = $886A;
  SR_MAX_TEXTURE_COORDS = $8871;
  SR_MAX_TEXTURE_IMAGE_UNITS = $8872;
  SR_FRAGMENT_SHADER = $8B30;
  SR_VERTEX_SHADER = $8B31;
  SR_MAX_FRAGMENT_UNIFORM_COMPONENTS = $8B49;
  SR_MAX_VERTEX_UNIFORM_COMPONENTS = $8B4A;
  SR_MAX_VARYING_FLOATS = $8B4B;
  SR_MAX_VERTEX_TEXTURE_IMAGE_UNITS = $8B4C;
  SR_MAX_COMBINED_TEXTURE_IMAGE_UNITS = $8B4D;
  SR_SHADER_TYPE = $8B4F;
  SR_FLOAT_VEC2 = $8B50;
  SR_FLOAT_VEC3 = $8B51;
  SR_FLOAT_VEC4 = $8B52;
  SR_INT_VEC2 = $8B53;
  SR_INT_VEC3 = $8B54;
  SR_INT_VEC4 = $8B55;
  SR_BOOL = $8B56;
  SR_BOOL_VEC2 = $8B57;
  SR_BOOL_VEC3 = $8B58;
  SR_BOOL_VEC4 = $8B59;
  SR_FLOAT_MAT2 = $8B5A;
  SR_FLOAT_MAT3 = $8B5B;
  SR_FLOAT_MAT4 = $8B5C;
  SR_SAMPLER_1D = $8B5D;
  SR_SAMPLER_2D = $8B5E;
  SR_SAMPLER_3D = $8B5F;
  SR_SAMPLER_CUBE = $8B60;
  SR_SAMPLER_1D_SHADOW = $8B61;
  SR_SAMPLER_2D_SHADOW = $8B62;
  SR_DELETE_STATUS = $8B80;
  SR_COMPILE_STATUS = $8B81;
  SR_LINK_STATUS = $8B82;
  SR_VALIDATE_STATUS = $8B83;
  SR_INFO_LOG_LENGTH = $8B84;
  SR_ATTACHED_SHADERS = $8B85;
  SR_ACTIVE_UNIFORMS = $8B86;
  SR_ACTIVE_UNIFORM_MAX_LENGTH = $8B87;
  SR_SHADER_SOURCE_LENGTH = $8B88;
  SR_ACTIVE_ATTRIBUTES = $8B89;
  SR_ACTIVE_ATTRIBUTE_MAX_LENGTH = $8B8A;
  SR_FRAGMENT_SHADER_DERIVATIVE_HINT = $8B8B;
  SR_SHADING_LANGUAGE_VERSION = $8B8C;
  SR_CURRENT_PROGRAM = $8B8D;
  SR_POINT_SPRITE_COORD_ORIGIN = $8CA0;
  SR_LOWER_LEFT = $8CA1;
  SR_UPPER_LEFT = $8CA2;
  SR_STENCIL_BACK_REF = $8CA3;
  SR_STENCIL_BACK_VALUE_MASK = $8CA4;
  SR_STENCIL_BACK_WRITEMASK = $8CA5;
  
  //**** SR_VERSION_2_1 DEPRECATED *****//
const
  SR_CURRENT_RASTER_SECONDARY_COLOR = $845F;
  SR_SLUMINANCE_ALPHA = $8C44;
  SR_SLUMINANCE8_ALPHA8 = $8C45;
  SR_SLUMINANCE = $8C46;
  SR_SLUMINANCE8 = $8C47;
  SR_COMPRESSED_SLUMINANCE = $8C4A;
  SR_COMPRESSED_SLUMINANCE_ALPHA = $8C4B;

//**** SR_VERSION_3_0 *****//

const
  SR_COMPARE_REF_TO_TEXTURE = $884E;
  SR_CLIP_DISTANCE0 = $3000;
  SR_CLIP_DISTANCE1 = $3001;
  SR_CLIP_DISTANCE2 = $3002;
  SR_CLIP_DISTANCE3 = $3003;
  SR_CLIP_DISTANCE4 = $3004;
  SR_CLIP_DISTANCE5 = $3005;
  SR_CLIP_DISTANCE6 = $3006;
  SR_CLIP_DISTANCE7 = $3007;
  SR_MAX_CLIP_DISTANCES = $0D32;
  SR_MAJOR_VERSION = $821B;
  SR_MINOR_VERSION = $821C;
  SR_NUM_EXTENSIONS = $821D;
  SR_CONTEXT_FLAGS = $821E;
  SR_DEPTH_BUFFER = $8223;
  SR_STENCIL_BUFFER = $8224;
  SR_COMPRESSED_RED = $8225;
  SR_COMPRESSED_RG = $8226;
  SR_CONTEXT_FLAG_FORWARD_COMPATIBLE_BIT = $0001;
  SR_RGBA32F = $8814;
  SR_RGB32F = $8815;
  SR_RGBA16F = $881A;
  SR_RGB16F = $881B;
  SR_VERTEX_ATTRIB_ARRAY_INTEGER = $88FD;
  SR_MAX_ARRAY_TEXTURE_LAYERS = $88FF;
  SR_MIN_PROGRAM_TEXEL_OFFSET = $8904;
  SR_MAX_PROGRAM_TEXEL_OFFSET = $8905;
  SR_CLAMP_READ_COLOR = $891C;
  SR_FIXED_ONLY = $891D;
  SR_MAX_VARYING_COMPONENTS = $8B4B;
  SR_TEXTURE_1D_ARRAY = $8C18;
  SR_PROXY_TEXTURE_1D_ARRAY = $8C19;
  SR_TEXTURE_2D_ARRAY = $8C1A;
  SR_PROXY_TEXTURE_2D_ARRAY = $8C1B;
  SR_TEXTURE_BINDING_1D_ARRAY = $8C1C;
  SR_TEXTURE_BINDING_2D_ARRAY = $8C1D;
  SR_R11F_G11F_B10F = $8C3A;
  SR_UNSIGNED_INT_10F_11F_11F_REV = $8C3B;
  SR_RGB9_E5 = $8C3D;
  SR_UNSIGNED_INT_5_9_9_9_REV = $8C3E;
  SR_TEXTURE_SHARED_SIZE = $8C3F;
  SR_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH = $8C76;
  SR_TRANSFORM_FEEDBACK_BUFFER_MODE = $8C7F;
  SR_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS = $8C80;
  SR_TRANSFORM_FEEDBACK_VARYINGS = $8C83;
  SR_TRANSFORM_FEEDBACK_BUFFER_START = $8C84;
  SR_TRANSFORM_FEEDBACK_BUFFER_SIZE = $8C85;
  SR_PRIMITIVES_GENERATED = $8C87;
  SR_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN = $8C88;
  SR_RASTERIZER_DISCARD = $8C89;
  SR_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS = $8C8A;
  SR_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS = $8C8B;
  SR_INTERLEAVED_ATTRIBS = $8C8C;
  SR_SEPARATE_ATTRIBS = $8C8D;
  SR_TRANSFORM_FEEDBACK_BUFFER = $8C8E;
  SR_TRANSFORM_FEEDBACK_BUFFER_BINDING = $8C8F;
  SR_RGBA32UI = $8D70;
  SR_RGB32UI = $8D71;
  SR_RGBA16UI = $8D76;
  SR_RGB16UI = $8D77;
  SR_RGBA8UI = $8D7C;
  SR_RGB8UI = $8D7D;
  SR_RGBA32I = $8D82;
  SR_RGB32I = $8D83;
  SR_RGBA16I = $8D88;
  SR_RGB16I = $8D89;
  SR_RGBA8I = $8D8E;
  SR_RGB8I = $8D8F;
  SR_RED_INTEGER = $8D94;
  SR_GREEN_INTEGER = $8D95;
  SR_BLUE_INTEGER = $8D96;
  SR_RGB_INTEGER = $8D98;
  SR_RGBA_INTEGER = $8D99;
  SR_BGR_INTEGER = $8D9A;
  SR_BGRA_INTEGER = $8D9B;
  SR_SAMPLER_1D_ARRAY = $8DC0;
  SR_SAMPLER_2D_ARRAY = $8DC1;
  SR_SAMPLER_1D_ARRAY_SHADOW = $8DC3;
  SR_SAMPLER_2D_ARRAY_SHADOW = $8DC4;
  SR_SAMPLER_CUBE_SHADOW = $8DC5;
  SR_UNSIGNED_INT_VEC2 = $8DC6;
  SR_UNSIGNED_INT_VEC3 = $8DC7;
  SR_UNSIGNED_INT_VEC4 = $8DC8;
  SR_INT_SAMPLER_1D = $8DC9;
  SR_INT_SAMPLER_2D = $8DCA;
  SR_INT_SAMPLER_3D = $8DCB;
  SR_INT_SAMPLER_CUBE = $8DCC;
  SR_INT_SAMPLER_1D_ARRAY = $8DCE;
  SR_INT_SAMPLER_2D_ARRAY = $8DCF;
  SR_UNSIGNED_INT_SAMPLER_1D = $8DD1;
  SR_UNSIGNED_INT_SAMPLER_2D = $8DD2;
  SR_UNSIGNED_INT_SAMPLER_3D = $8DD3;
  SR_UNSIGNED_INT_SAMPLER_CUBE = $8DD4;
  SR_UNSIGNED_INT_SAMPLER_1D_ARRAY = $8DD6;
  SR_UNSIGNED_INT_SAMPLER_2D_ARRAY = $8DD7;
  SR_QUERY_WAIT = $8E13;
  SR_QUERY_NO_WAIT = $8E14;
  SR_QUERY_BY_REGION_WAIT = $8E15;
  SR_QUERY_BY_REGION_NO_WAIT = $8E16;
  SR_BUFFER_ACCESS_FLAGS = $911F;
  SR_BUFFER_MAP_LENGTH = $9120;
  SR_BUFFER_MAP_OFFSET = $9121;
 //**** SR_VERSION_3_0 DEPRECATED *****//
const
  SR_CLAMP_VERTEX_COLOR = $891A;
  SR_CLAMP_FRAGMENT_COLOR = $891B;
  SR_ALPHA_INTEGER = $8D97;

//**** SR_VERSION_3_1 *****//
const
  SR_SAMPLER_2D_RECT = $8B63;
  SR_SAMPLER_2D_RECT_SHADOW = $8B64;
  SR_SAMPLER_BUFFER = $8DC2;
  SR_INT_SAMPLER_2D_RECT = $8DCD;
  SR_INT_SAMPLER_BUFFER = $8DD0;
  SR_UNSIGNED_INT_SAMPLER_2D_RECT = $8DD5;
  SR_UNSIGNED_INT_SAMPLER_BUFFER = $8DD8;
  SR_TEXTURE_BUFFER = $8C2A;
  SR_MAX_TEXTURE_BUFFER_SIZE = $8C2B;
  SR_TEXTURE_BINDING_BUFFER = $8C2C;
  SR_TEXTURE_BUFFER_DATA_STORE_BINDING = $8C2D;
  SR_TEXTURE_BUFFER_FORMAT = $8C2E;
  SR_TEXTURE_RECTANGLE = $84F5;
  SR_TEXTURE_BINDING_RECTANGLE = $84F6;
  SR_PROXY_TEXTURE_RECTANGLE = $84F7;
  SR_MAX_RECTANGLE_TEXTURE_SIZE = $84F8;
  SR_RED_SNORM = $8F90;
  SR_RG_SNORM = $8F91;
  SR_RGB_SNORM = $8F92;
  SR_RGBA_SNORM = $8F93;
  SR_R8_SNORM = $8F94;
  SR_RG8_SNORM = $8F95;
  SR_RGB8_SNORM = $8F96;
  SR_RGBA8_SNORM = $8F97;
  SR_R16_SNORM = $8F98;
  SR_RG16_SNORM = $8F99;
  SR_RGB16_SNORM = $8F9A;
  SR_RGBA16_SNORM = $8F9B;
  SR_SIGNED_NORMALIZED = $8F9C;
  SR_PRIMITIVE_RESTART = $8F9D;
  SR_PRIMITIVE_RESTART_INDEX = $8F9E;
  
  
//**** SR_VERSION_3_2 *****//
const
  SR_CONTEXT_CORE_PROFILE_BIT = $00000001;
  SR_CONTEXT_COMPATIBILITY_PROFILE_BIT = $00000002;
  SR_LINES_ADJACENCY = $000A;
  SR_LINE_STRIP_ADJACENCY = $000B;
  SR_TRIANGLES_ADJACENCY = $000C;
  SR_TRIANGLE_STRIP_ADJACENCY = $000D;
  SR_PROGRAM_POINT_SIZE = $8642;
  SR_MAX_GEOMETRY_TEXTURE_IMAGE_UNITS = $8C29;
  SR_FRAMEBUFFER_ATTACHMENT_LAYERED = $8DA7;
  SR_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS = $8DA8;
  SR_GEOMETRY_SHADER = $8DD9;
  SR_GEOMETRY_VERTICES_OUT = $8916;
  SR_GEOMETRY_INPUT_TYPE = $8917;
  SR_GEOMETRY_OUTPUT_TYPE = $8918;
  SR_MAX_GEOMETRY_UNIFORM_COMPONENTS = $8DDF;
  SR_MAX_GEOMETRY_OUTPUT_VERTICES = $8DE0;
  SR_MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS = $8DE1;
  SR_MAX_VERTEX_OUTPUT_COMPONENTS = $9122;
  SR_MAX_GEOMETRY_INPUT_COMPONENTS = $9123;
  SR_MAX_GEOMETRY_OUTPUT_COMPONENTS = $9124;
  SR_MAX_FRAGMENT_INPUT_COMPONENTS = $9125;
  SR_CONTEXT_PROFILE_MASK = $9126;
  
  SR_OBJECT_TYPE_ARB = $8B4E;
  SR_OBJECT_SUBTYPE_ARB = $8B4F;
  SR_OBJECT_DELETE_STATUS_ARB = $8B80;
  SR_OBJECT_COMPILE_STATUS_ARB = $8B81;
  SR_OBJECT_LINK_STATUS_ARB = $8B82;
  SR_OBJECT_VALIDATE_STATUS_ARB = $8B83;
  SR_OBJECT_INFO_LOG_LENGTH_ARB = $8B84;
  SR_OBJECT_ATTACHED_OBJECTS_ARB = $8B85;
  SR_OBJECT_ACTIVE_UNIFORMS_ARB = $8B86;
  SR_OBJECT_ACTIVE_UNIFORM_MAX_LENGTH_ARB = $8B87;
  SR_OBJECT_SHADER_SOURCE_LENGTH_ARB = $8B88;

  // SR_ARB_texture_rg
  SR_RG = $8227;
  SR_RG_INTEGER = $8228;
  SR_R8 = $8229;
  SR_R16 = $822A;
  SR_RG8 = $822B;
  SR_RG16 = $822C;
  SR_R16F = $822D;
  SR_R32F = $822E;
  SR_RG16F = $822F;
  SR_RG32F = $8230;
  SR_R8I = $8231;
  SR_R8UI = $8232;
  SR_R16I = $8233;
  SR_R16UI = $8234;
  SR_R32I = $8235;
  SR_R32UI = $8236;
  SR_RG8I = $8237;
  SR_RG8UI = $8238;
  SR_RG16I = $8239;
  SR_RG16UI = $823A;
  SR_RG32I = $823B;
  SR_RG32UI = $823C;

  // SR_EXT_framebuffer_object
  SR_FRAMEBUFFER_EXT = $8D40;
  SR_RENDERBUFFER_EXT = $8D41;
  SR_STENCIL_INDEX_EXT = $8D45;
  SR_STENCIL_INDEX1_EXT = $8D46;
  SR_STENCIL_INDEX4_EXT = $8D47;
  SR_STENCIL_INDEX8_EXT = $8D48;
  SR_STENCIL_INDEX16_EXT = $8D49;
  SR_RENDERBUFFER_WIDTH_EXT = $8D42;
  SR_RENDERBUFFER_HEIGHT_EXT = $8D43;
  SR_RENDERBUFFER_INTERNAL_FORMAT_EXT = $8D44;
  SR_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE_EXT = $8CD0;
  SR_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME_EXT = $8CD1;
  SR_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL_EXT = $8CD2;
  SR_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE_EXT = $8CD3;
  SR_FRAMEBUFFER_ATTACHMENT_TEXTURE_3D_ZOFFSET_EXT = $8CD4;
  SR_COLOR_ATTACHMENT0_EXT = $8CE0;
  SR_COLOR_ATTACHMENT1_EXT = $8CE1;
  SR_COLOR_ATTACHMENT2_EXT = $8CE2;
  SR_COLOR_ATTACHMENT3_EXT = $8CE3;
  SR_COLOR_ATTACHMENT4_EXT = $8CE4;
  SR_COLOR_ATTACHMENT5_EXT = $8CE5;
  SR_COLOR_ATTACHMENT6_EXT = $8CE6;
  SR_COLOR_ATTACHMENT7_EXT = $8CE7;
  SR_COLOR_ATTACHMENT8_EXT = $8CE8;
  SR_COLOR_ATTACHMENT9_EXT = $8CE9;
  SR_COLOR_ATTACHMENT10_EXT = $8CEA;
  SR_COLOR_ATTACHMENT11_EXT = $8CEB;
  SR_COLOR_ATTACHMENT12_EXT = $8CEC;
  SR_COLOR_ATTACHMENT13_EXT = $8CED;
  SR_COLOR_ATTACHMENT14_EXT = $8CEE;
  SR_COLOR_ATTACHMENT15_EXT = $8CEF;
  SR_DEPTH_ATTACHMENT_EXT = $8D00;
  SR_STENCIL_ATTACHMENT_EXT = $8D20;
  SR_FRAMEBUFFER_COMPLETE_EXT = $8CD5;
  SR_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT = $8CD6;
  SR_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT = $8CD7;
  SR_FRAMEBUFFER_INCOMPLETE_DUPLICATE_ATTACHMENT_EXT = $8CD8;
  SR_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT = $8CD9;
  SR_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT = $8CDA;
  SR_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT = $8CDB;
  SR_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT = $8CDC;
  SR_FRAMEBUFFER_UNSUPPORTED_EXT = $8CDD;
  SR_FRAMEBUFFER_STATUS_ERROR_EXT = $8CDE;
  SR_FRAMEBUFFER_BINDING_EXT = $8CA6;
  SR_RENDERBUFFER_BINDING_EXT = $8CA7;
  SR_MAX_COLOR_ATTACHMENTS_EXT = $8CDF;
  SR_MAX_RENDERBUFFER_SIZE_EXT = $84E8;
  SR_INVALID_FRAMEBUFFER_OPERATION_EXT = $0506;

  // SR_VERSION_1_4
  SR_BLEND_DST_RGB = $80C8;
  SR_BLEND_SRC_RGB = $80C9;
  SR_BLEND_DST_ALPHA = $80CA;
  SR_BLEND_SRC_ALPHA = $80CB;
  SR_POINT_FADE_THRESHOLD_SIZE = $8128;
  SR_DEPTH_COMPONENT16 = $81A5;
  SR_DEPTH_COMPONENT24 = $81A6;
  SR_DEPTH_COMPONENT32 = $81A7;
  SR_MIRRORED_REPEAT = $8370;
  SR_MAX_TEXTURE_LOD_BIAS = $84FD;
  SR_TEXTURE_LOD_BIAS = $8501;
  SR_INCR_WRAP = $8507;
  SR_DECR_WRAP = $8508;
  SR_TEXTURE_DEPTH_SIZE = $884A;
  SR_TEXTURE_COMPARE_MODE = $884C;
  SR_TEXTURE_COMPARE_FUNC = $884D;
  
   // SR_VERSION_1_4 // Deprecated
  SR_POINT_SIZE_MIN = $8126;
  SR_POINT_SIZE_MAX = $8127;
  SR_POINT_DISTANCE_ATTENUATION = $8129;
  SR_GENERATE_MIPMAP = $8191;
  SR_GENERATE_MIPMAP_HINT = $8192;
  SR_FOG_COORDINATE_SOURCE = $8450;
  SR_FOG_COORDINATE = $8451;
  SR_FRAGMENT_DEPTH = $8452;
  SR_CURRENT_FOG_COORDINATE = $8453;
  SR_FOG_COORDINATE_ARRAY_TYPE = $8454;
  SR_FOG_COORDINATE_ARRAY_STRIDE = $8455;
  SR_FOG_COORDINATE_ARRAY_POINTER = $8456;
  SR_FOG_COORDINATE_ARRAY = $8457;
  SR_COLOR_SUM = $8458;
  SR_CURRENT_SECONDARY_COLOR = $8459;
  SR_SECONDARY_COLOR_ARRAY_SIZE = $845A;
  SR_SECONDARY_COLOR_ARRAY_TYPE = $845B;
  SR_SECONDARY_COLOR_ARRAY_STRIDE = $845C;
  SR_SECONDARY_COLOR_ARRAY_POINTER = $845D;
  SR_SECONDARY_COLOR_ARRAY = $845E;
  SR_TEXTURE_FILTER_CONTROL = $8500;
  SR_DEPTH_TEXTURE_MODE = $884B;
  SR_COMPARE_R_TO_TEXTURE = $884E;
