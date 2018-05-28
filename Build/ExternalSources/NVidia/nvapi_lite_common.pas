(*****************************************************************************\
|*                                                                           *|
|*      Copyright NVIDIA Corporation.  All rights reserved.                  *|
|*                                                                           *|
|*   NOTICE TO USER:                                                         *|
|*                                                                           *|
|*   This source code is subject to NVIDIA ownership rights under U.S.       *|
|*   and international Copyright laws.  Users and possessors of this         *|
|*   source code are hereby granted a nonexclusive, royalty-free             *|
|*   license to use this code in individual and commercial software.         *|
|*                                                                           *|
|*   NVIDIA MAKES NO REPRESENTATION ABOUT THE SUITABILITY OF THIS SOURCE     *|
|*   CODE FOR ANY PURPOSE. IT IS PROVIDED "AS IS" WITHOUT EXPRESS OR         *|
|*   IMPLIED WARRANTY OF ANY KIND. NVIDIA DISCLAIMS ALL WARRANTIES WITH      *|
|*   REGARD TO THIS SOURCE CODE, INCLUDING ALL IMPLIED WARRANTIES OF         *|
|*   MERCHANTABILITY, NONINFRINGEMENT, AND FITNESS FOR A PARTICULAR          *|
|*   PURPOSE. IN NO EVENT SHALL NVIDIA BE LIABLE FOR ANY SPECIAL,            *|
|*   INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, OR ANY DAMAGES          *|
|*   WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN      *|
|*   AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING     *|
|*   OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOURCE      *|
|*   CODE.                                                                   *|
|*                                                                           *|
|*   U.S. Government End Users. This source code is a "commercial item"      *|
|*   as that term is defined at 48 C.F.R. 2.101 (OCT 1995), consisting       *|
|*   of "commercial computer  software" and "commercial computer software    *|
|*   documentation" as such terms are used in 48 C.F.R. 12.212 (SEPT 1995)   *|
|*   and is provided to the U.S. Government only as a commercial end item.   *|
|*   Consistent with 48 C.F.R.12.212 and 48 C.F.R. 227.7202-1 through        *|
|*   227.7202-4 (JUNE 1995), all U.S. Government End Users acquire the       *|
|*   source code with only those rights set forth herein.                    *|
|*                                                                           *|
|*   Any use of this source code in individual and commercial software must  *|
|*   include, in the user documentation and internal comments to the code,   *|
|*   the above Disclaimer and U.S. Government End Users Notice.              *|
|*                                                                           *|
|*                                                                           *|
\*****************************************************************************)

unit nvapi_lite_common;

interface

// ====================================================
// Universal NvAPI Definitions
// ====================================================
type
	{$ifndef FPC}
		NvHandle = LongWord;
	{$else}
		NvHandle = PtrUInt;
	{$endif}
	
	{ 64-bit types for compilers that support them, plus some obsolete variants }
	{$IF declared(UInt64)}
		NvU64 = UInt64;                { 0 to 18446744073709551615 }
	{$ELSE}
		NvU64 = Int64;                 { 0 to 18446744073709551615 }
	{$IFEND}
	
	// mac os 32-bit still needs this
	NvS32 = Longint;                { -2147483648 to 2147483647 }
	
	NvU32 = LongWord;
	NvU16 = Word;
	NvU8 = Byte;
	
	pNvU8 = ^NvU8;
	pNvU32 = ^ NvU32;
const
	NVAPI_GENERIC_STRING_MAX = 4096;
	NVAPI_LONG_STRING_MAX    = 256;
	NVAPI_SHORT_STRING_MAX   = 64;
	NVAPI_DEFAULT_HANDLE     = 0;
type
	NvSBox = record
		sX: NvS32;
		sY: NvS32;
		sWidth: NvS32;
		sHeight: NvS32;
		end;
const
	NVAPI_MAX_PHYSICAL_GPUS            = 64;
	NVAPI_MAX_LOGICAL_GPUS             = 64;
	NVAPI_MAX_AVAILABLE_GPU_TOPOLOGIES = 256;
	NVAPI_MAX_GPU_TOPOLOGIES           = NVAPI_MAX_PHYSICAL_GPUS;
	NVAPI_MAX_GPU_PER_TOPOLOGY         = 8;
	NVAPI_MAX_DISPLAY_HEADS            = 2;
	NVAPI_MAX_DISPLAYS                 = NVAPI_MAX_PHYSICAL_GPUS * NVAPI_MAX_DISPLAY_HEADS;
	
	NV_MAX_HEADS        = 4;   // Maximum heads, each with NVAPI_DESKTOP_RES resolution
	NV_MAX_VID_STREAMS  = 4;   // Maximum input video streams, each with a NVAPI_VIDEO_SRC_INFO
	NV_MAX_VID_PROFILES = 4;   // Maximum output video profiles supported
type
	NvAPI_String = array[0..NVAPI_GENERIC_STRING_MAX - 1] of AnsiChar;
	NvAPI_LongString = array[0..NVAPI_LONG_STRING_MAX - 1] of AnsiChar;
	NvAPI_ShortString = array[0..NVAPI_SHORT_STRING_MAX - 1] of AnsiChar;

// ====================================================
// NvAPI Status Values
//    All NvAPI functions return one of these codes.
// ====================================================

type
	NvAPI_Status = (
		NVAPI_OK                                    =  0,      // Success
		NVAPI_ERROR                                 = -1,      // Generic error
		NVAPI_LIBRARY_NOT_FOUND                     = -2,      // nvapi.dll can not be loaded
		NVAPI_NO_IMPLEMENTATION                     = -3,      // not implemented in current driver installation
		NVAPI_API_NOT_INTIALIZED                    = -4,      // NvAPI_Initialize has not been called (successfully)
		NVAPI_INVALID_ARGUMENT                      = -5,      // invalid argument
		NVAPI_NVIDIA_DEVICE_NOT_FOUND               = -6,      // no NVIDIA display driver was found
		NVAPI_END_ENUMERATION                       = -7,      // no more to enum
		NVAPI_INVALID_HANDLE                        = -8,      // invalid handle
		NVAPI_INCOMPATIBLE_STRUCT_VERSION           = -9,      // an argument's structure version is not supported
		NVAPI_HANDLE_INVALIDATED                    = -10,     // handle is no longer valid (likely due to GPU or display re-configuration)
		NVAPI_OPENGL_CONTEXT_NOT_CURRENT            = -11,     // no NVIDIA OpenGL context is current (but needs to be)
		NVAPI_NO_GL_EXPERT                          = -12,     // OpenGL Expert is not supported by the current drivers
		NVAPI_INSTRUMENTATION_DISABLED              = -13,     // OpenGL Expert is supported, but driver instrumentation is currently disabled
		NVAPI_EXPECTED_LOGICAL_GPU_HANDLE           = -100,    // expected a logical GPU handle for one or more parameters
		NVAPI_EXPECTED_PHYSICAL_GPU_HANDLE          = -101,    // expected a physical GPU handle for one or more parameters
		NVAPI_EXPECTED_DISPLAY_HANDLE               = -102,    // expected an NV display handle for one or more parameters
		NVAPI_INVALID_COMBINATION                   = -103,    // used in some commands to indicate that the combination of parameters is not valid
		NVAPI_NOT_SUPPORTED                         = -104,    // Requested feature not supported in the selected GPU
		NVAPI_PORTID_NOT_FOUND                      = -105,    // NO port ID found for I2C transaction
		NVAPI_EXPECTED_UNATTACHED_DISPLAY_HANDLE    = -106,    // expected an unattached display handle as one of the input param
		NVAPI_INVALID_PERF_LEVEL                    = -107,    // invalid perf level
		NVAPI_DEVICE_BUSY                           = -108,    // device is busy, request not fulfilled
		NVAPI_NV_PERSIST_FILE_NOT_FOUND             = -109,    // NV persist file is not found
		NVAPI_PERSIST_DATA_NOT_FOUND                = -110,    // NV persist data is not found
		NVAPI_EXPECTED_TV_DISPLAY                   = -111,    // expected TV output display
		NVAPI_EXPECTED_TV_DISPLAY_ON_DCONNECTOR     = -112,    // expected TV output on D Connector - HDTV_EIAJ4120.
		NVAPI_NO_ACTIVE_SLI_TOPOLOGY                = -113,    // SLI is not active on this device
		NVAPI_SLI_RENDERING_MODE_NOTALLOWED         = -114,    // setup of SLI rendering mode is not possible right now
		NVAPI_EXPECTED_DIGITAL_FLAT_PANEL           = -115,    // expected digital flat panel
		NVAPI_ARGUMENT_EXCEED_MAX_SIZE              = -116,    // argument exceeds expected size
		NVAPI_DEVICE_SWITCHING_NOT_ALLOWED          = -117,    // inhibit ON due to one of the flags in NV_GPU_DISPLAY_CHANGE_INHIBIT or SLI Active
		NVAPI_TESTING_CLOCKS_NOT_SUPPORTED          = -118,    // testing clocks not supported
		NVAPI_UNKNOWN_UNDERSCAN_CONFIG              = -119,    // the specified underscan config is from an unknown source (e.g. INF)
		NVAPI_TIMEOUT_RECONFIGURING_GPU_TOPO        = -120,    // timeout while reconfiguring GPUs
		NVAPI_DATA_NOT_FOUND                        = -121,    // Requested data was not found
		NVAPI_EXPECTED_ANALOG_DISPLAY               = -122,    // expected analog display
		NVAPI_NO_VIDLINK                            = -123,    // No SLI video bridge present
		NVAPI_REQUIRES_REBOOT                       = -124,    // NVAPI requires reboot for its settings to take effect
		NVAPI_INVALID_HYBRID_MODE                   = -125,    // the function is not supported with the current hybrid mode.
		NVAPI_MIXED_TARGET_TYPES                    = -126,    // The target types are not all the same
		NVAPI_SYSWOW64_NOT_SUPPORTED                = -127,    // the function is not supported from 32-bit on a 64-bit system
		NVAPI_IMPLICIT_SET_GPU_TOPOLOGY_CHANGE_NOT_ALLOWED = -128,    //there is any implicit GPU topo active. Use NVAPI_SetHybridMode to change topology.
		NVAPI_REQUEST_USER_TO_CLOSE_NON_MIGRATABLE_APPS = -129,      //Prompt the user to close all non-migratable apps.
		NVAPI_OUT_OF_MEMORY                         = -130,    // Could not allocate sufficient memory to complete the call
		NVAPI_WAS_STILL_DRAWING                     = -131,    // The previous operation that is transferring information to or from this surface is incomplete
		NVAPI_FILE_NOT_FOUND                        = -132,    // The file was not found
		NVAPI_TOO_MANY_UNIQUE_STATE_OBJECTS         = -133,    // There are too many unique instances of a particular type of state object
		NVAPI_INVALID_CALL                          = -134,    // The method call is invalid. For example, a method's parameter may not be a valid pointer
		NVAPI_D3D10_1_LIBRARY_NOT_FOUND             = -135,    // d3d10_1.dll can not be loaded
		NVAPI_FUNCTION_NOT_FOUND                    = -136);   // Couldn't find the function in loaded dll library

implementation

end.
