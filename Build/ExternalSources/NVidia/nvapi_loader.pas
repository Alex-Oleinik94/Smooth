{$MODE DELPHI}

unit nvapi_loader;

interface

implementation

uses
	 SmoothBase
	,SmoothLists
	,SmoothDllManager
	,SmoothSysUtils
	
	// nvapi
	,nvapi_lite_common
	,nvapi
	,NvApiDriverSettings
	;

var
	Initialized: Boolean = False;
type
	PNvAPIFuncRec = ^TNvAPIFuncRec;
	TNvAPIFuncRec = record
		ID: Cardinal;
		Func: Pointer;
		end;
const
	NvAPIFunctions: array[0..122] of TNvAPIFuncRec = (
		(ID: $6C2D048C; Func: @@NvAPI_GetErrorMessage),
		(ID: $01053FA5; Func: @@NvAPI_GetInterfaceVersionString),
		
		(ID: $F951A4D1; Func: @@NvAPI_GetDisplayDriverVersion),
		
		(ID: $9ABDD40D; Func: @@NvAPI_EnumNvidiaDisplayHandle),
		(ID: $20DE9260; Func: @@NvAPI_EnumNvidiaUnAttachedDisplayHandle),
		(ID: $35C29134; Func: @@NvAPI_GetAssociatedNvidiaDisplayHandle),
		
		(ID: $E5AC921F; Func: @@NvAPI_EnumPhysicalGPUs),
		(ID: $48B3EA59; Func: @@NvAPI_EnumLogicalGPUs),
		(ID: $34EF9506; Func: @@NvAPI_GetPhysicalGPUsFromDisplay),
		(ID: $5018ED61; Func: @@NvAPI_GetPhysicalGPUFromUnAttachedDisplay),
		(ID: $EE1370CF; Func: @@NvAPI_GetLogicalGPUFromDisplay),
		(ID: $ADD604D1; Func: @@NvAPI_GetLogicalGPUFromPhysicalGPU),
		(ID: $AEA3FA32; Func: @@NvAPI_GetPhysicalGPUsFromLogicalGPU),
		(ID: $22A78B05; Func: @@NvAPI_GetAssociatedNvidiaDisplayName),
		(ID: $4888D790; Func: @@NvAPI_GetUnAttachedAssociatedDisplayName),
		(ID: $63F9799E; Func: @@NvAPI_CreateDisplayFromUnAttachedDisplay),
		(ID: $2863148D; Func: @@NvAPI_EnableHWCursor),
		(ID: $AB163097; Func: @@NvAPI_DisableHWCursor),
		(ID: $67B5DB55; Func: @@NvAPI_GetVBlankCounter),
		(ID: $3092AC32; Func: @@NvAPI_SetRefreshRateOverride),
		(ID: $D995937E; Func: @@NvAPI_GetAssociatedDisplayOutputId),
		(ID: $C64FF367; Func: @@NvAPI_GetDisplayPortInfo),
		(ID: $FA13E65A; Func: @@NvAPI_SetDisplayPort),
		(ID: $6AE16EC3; Func: @@NvAPI_GetHDMISupportInfo),
		
		(ID: $7D554F8E; Func: @@NvAPI_GPU_GetAllOutputs),
		(ID: $1730BFC9; Func: @@NvAPI_GPU_GetConnectedOutputs),
		(ID: $0680DE09; Func: @@NvAPI_GPU_GetConnectedSLIOutputs),
		(ID: $CF8CAF39; Func: @@NvAPI_GPU_GetConnectedOutputsWithLidState),
		(ID: $96043CC7; Func: @@NvAPI_GPU_GetConnectedSLIOutputsWithLidState),
		(ID: $BAAABFCC; Func: @@NvAPI_GPU_GetSystemType),
		(ID: $E3E89B6F; Func: @@NvAPI_GPU_GetActiveOutputs),
		(ID: $37D32E69; Func: @@NvAPI_GPU_GetEDID),
		(ID: $40A505E4; Func: @@NvAPI_GPU_GetOutputType),
		(ID: $34C9C2D4; Func: @@NvAPI_GPU_ValidateOutputCombination),
		(ID: $CEEE8E9F; Func: @@NvAPI_GPU_GetFullName),
		(ID: $2DDFB66E; Func: @@NvAPI_GPU_GetPCIIdentifiers),
		(ID: $C33BAEB1; Func: @@NvAPI_GPU_GetGPUType),
		(ID: $1BB18724; Func: @@NvAPI_GPU_GetBusType),
		(ID: $1BE0B8E5; Func: @@NvAPI_GPU_GetBusId),
		(ID: $2A0A350F; Func: @@NvAPI_GPU_GetBusSlotId),
		(ID: $E4715417; Func: @@NvAPI_GPU_GetIRQ),
		(ID: $ACC3DA0A; Func: @@NvAPI_GPU_GetVbiosRevision),
		(ID: $2D43FB31; Func: @@NvAPI_GPU_GetVbiosOEMRevision),
		(ID: $A561FD7D; Func: @@NvAPI_GPU_GetVbiosVersionString),
		(ID: $6E042794; Func: @@NvAPI_GPU_GetAGPAperture),
		(ID: $C74925A0; Func: @@NvAPI_GPU_GetCurrentAGPRate),
		(ID: $D048C3B1; Func: @@NvAPI_GPU_GetCurrentPCIEDownstreamWidth),
		(ID: $46FBEB03; Func: @@NvAPI_GPU_GetPhysicalFrameBufferSize),
		(ID: $5A04B644; Func: @@NvAPI_GPU_GetVirtualFrameBufferSize),
		(ID: $E3640A56; Func: @@NvAPI_GPU_GetThermalSettings),
		
		(ID: $2FDE12C5; Func: @@NvAPI_I2CRead),
		(ID: $E812EB07; Func: @@NvAPI_I2CWrite)
		,
		(ID: $53DABBCA; Func: @@_NvAPI_SYS_GetChipSetInfo),
		(ID: $CDA14D8A; Func: @@NvAPI_SYS_GetLidAndDockInfo),
		
		(ID: $3805EF7A; Func: @@NvAPI_OGL_ExpertModeSet),
		(ID: $22ED9516; Func: @@NvAPI_OGL_ExpertModeGet),
		(ID: $B47A657E; Func: @@NvAPI_OGL_ExpertModeDefaultsSet),
		(ID: $AE921F12; Func: @@NvAPI_OGL_ExpertModeDefaultsGet),
		
		(ID: $0957D7B6; Func: @@NvAPI_SetView),
		(ID: $D6B99D89; Func: @@NvAPI_GetView),
		(ID: $06B89E68; Func: @@NvAPI_SetViewEx),
		(ID: $DBBC0AF4; Func: @@NvAPI_GetViewEx),
		(ID: $66FB7FC0; Func: @@NvAPI_GetSupportedViews),
		
		(ID: $BE7692EC; Func: @@NvAPI_Stereo_CreateConfigurationProfileRegistryKey), //76  NvAPI_Stereo_CreateConfigurationProfileRegistryKey
		(ID: $F117B834; Func: @@NvAPI_Stereo_DeleteConfigurationProfileRegistryKey), //77  NvAPI_Stereo_DeleteConfigurationProfileRegistryKey
		(ID: $24409F48; Func: @@NvAPI_Stereo_SetConfigurationProfileValue), //78  NvAPI_Stereo_SetConfigurationProfileValue
		(ID: $49BCEECF; Func: @@NvAPI_Stereo_DeleteConfigurationProfileValue), //79  NvAPI_Stereo_DeleteConfigurationProfileValue
		(ID: $239C4545; Func: @@NvAPI_Stereo_Enable), //80  NvAPI_Stereo_Enable
		(ID: $2EC50C2B; Func: @@NvAPI_Stereo_Disable), //81  NvAPI_Stereo_Disable
		(ID: $348FF8E1; Func: @@NvAPI_Stereo_IsEnabled), //82  NvAPI_Stereo_IsEnabled
		(ID: $AC7E37F4; Func: @@NvAPI_Stereo_CreateHandleFromIUnknown), //83  NvAPI_Stereo_CreateHandleFromIUnknown
		(ID: $3A153134; Func: @@NvAPI_Stereo_DestroyHandle), //84  NvAPI_Stereo_DestroyHandle
		(ID: $F6A1AD68; Func: @@NvAPI_Stereo_Activate), //85  NvAPI_Stereo_Activate
		(ID: $2D68DE96; Func: @@NvAPI_Stereo_Deactivate), //86  NvAPI_Stereo_Deactivate
		(ID: $1FB0BC30; Func: @@NvAPI_Stereo_IsActivated), //87  NvAPI_Stereo_IsActivated
		(ID: $451F2134; Func: @@NvAPI_Stereo_GetSeparation), //88  NvAPI_Stereo_GetSeparation
		(ID: $5C069FA3; Func: @@NvAPI_Stereo_SetSeparation), //89  NvAPI_Stereo_SetSeparation
		(ID: $DA044458; Func: @@NvAPI_Stereo_DecreaseSeparation), //90  NvAPI_Stereo_DecreaseSeparation
		(ID: $C9A8ECEC; Func: @@NvAPI_Stereo_IncreaseSeparation), //91  NvAPI_Stereo_IncreaseSeparation
		(ID: $4AB00934; Func: @@NvAPI_Stereo_GetConvergence), //92  NvAPI_Stereo_GetConvergence
		(ID: $3DD6B54B; Func: @@NvAPI_Stereo_SetConvergence), //93  NvAPI_Stereo_SetConvergence
		(ID: $4C87E317; Func: @@NvAPI_Stereo_DecreaseConvergence), //94  NvAPI_Stereo_DecreaseConvergence
		(ID: $A17DAABE; Func: @@NvAPI_Stereo_IncreaseConvergence), //95  NvAPI_Stereo_IncreaseConvergence
		(ID: $E6839B43; Func: @@NvAPI_Stereo_GetFrustumAdjustMode), //96  NvAPI_Stereo_GetFrustumAdjustMode
		(ID: $7BE27FA2; Func: @@NvAPI_Stereo_SetFrustumAdjustMode), //97  NvAPI_Stereo_SetFrustumAdjustMode
		(ID: $932CB140; Func: @@NvAPI_Stereo_CaptureJpegImage), //98  NvAPI_Stereo_CaptureJpegImage
		(ID: $8B7E99B5; Func: @@NvAPI_Stereo_CapturePngImage), //99  NvAPI_Stereo_CapturePngImage
		(ID: $3CD58F89; Func: @@NvAPI_Stereo_ReverseStereoBlitControl), //100 NvAPI_Stereo_ReverseStereoBlitControl
		(ID: $6B9B409E; Func: @@NvAPI_Stereo_SetNotificationMessage), //101 NvAPI_Stereo_SetNotificationMessage
		
		(ID: $1DAE4FBC; Func: @@NvAPI_DRS_GetNumProfiles), // NvAPI_DRS_GetNumProfiles
		(ID: $ED1F8C69; Func: @@NvAPI_DRS_GetApplicationInfo), // NvAPI_DRS_GetApplicationInfo
		(ID: $617BFF9F; Func: @@NvAPI_DRS_GetCurrentGlobalProfile), // NvAPI_DRS_GetCurrentGlobalProfile
		(ID: $4347A9DE; Func: @@NvAPI_DRS_CreateApplication), // NvAPI_DRS_CreateApplication
		(ID: $F020614A; Func: @@NvAPI_DRS_EnumAvailableSettingIds), // NvAPI_DRS_EnumAvailableSettingIds
		(ID: $61CD6FD6; Func: @@NvAPI_DRS_GetProfileInfo), // NvAPI_DRS_GetProfileInfo
		(ID: $1C89C5DF; Func: @@NvAPI_DRS_SetCurrentGlobalProfile), // NvAPI_DRS_SetCurrentGlobalProfile
		(ID: $53F0381E; Func: @@NvAPI_DRS_RestoreProfileDefaultSetting), // NvAPI_DRS_RestoreProfileDefaultSetting
		(ID: $AE3039DA; Func: @@NvAPI_DRS_EnumSettings), // NvAPI_DRS_EnumSettings
		(ID: $7FA2173A; Func: @@NvAPI_DRS_EnumApplications), // NvAPI_DRS_EnumApplications
		(ID: $D61CBE6E; Func: @@NvAPI_DRS_GetSettingNameFromId), // NvAPI_DRS_GetSettingNameFromId
		(ID: $2EC39F90; Func: @@NvAPI_DRS_EnumAvailableSettingValues), // NvAPI_DRS_EnumAvailableSettingValues
		(ID: $DA8466A0; Func: @@NvAPI_DRS_GetBaseProfile), // NvAPI_DRS_GetBaseProfile
		(ID: $C5EA85A1; Func: @@NvAPI_DRS_DeleteApplicationEx), // NvAPI_DRS_DeleteApplicationEx
		(ID: $7E4A9A0B; Func: @@NvAPI_DRS_FindProfileByName), // NvAPI_DRS_FindProfileByName
		(ID: $BC371EE0; Func: @@NvAPI_DRS_EnumProfiles), // NvAPI_DRS_EnumProfiles
		(ID: $CC176068; Func: @@NvAPI_DRS_CreateProfile), // NvAPI_DRS_CreateProfile
		(ID: $73BF8338; Func: @@NvAPI_DRS_GetSetting), // NvAPI_DRS_GetSetting
		(ID: $EEE566B2; Func: @@NvAPI_DRS_FindApplicationByName), // NvAPI_DRS_FindApplicationByName
		(ID: $577DD202; Func: @@NvAPI_DRS_SetSetting), // NvAPI_DRS_SetSetting
		(ID: $17093206; Func: @@NvAPI_DRS_DeleteProfile), // NvAPI_DRS_DeleteProfile
		(ID: $CB7309CD; Func: @@NvAPI_DRS_GetSettingIdFromName), // NvAPI_DRS_GetSettingIdFromName
		(ID: $5927B094; Func: @@NvAPI_DRS_RestoreAllDefaults), // NvAPI_DRS_RestoreAllDefaults
		(ID: $16ABD3A9; Func: @@NvAPI_DRS_SetProfileInfo), // NvAPI_DRS_SetProfileInfo
		(ID: $FA5F6134; Func: @@NvAPI_DRS_RestoreProfileDefault), // NvAPI_DRS_RestoreProfileDefault
		(ID: $E4A26362; Func: @@NvAPI_DRS_DeleteProfileSetting), // NvAPI_DRS_DeleteProfileSetting
		(ID: $2C694BC6; Func: @@NvAPI_DRS_DeleteApplication), // NvAPI_DRS_DeleteApplication
		
		(ID: $D3EDE889; Func: @@NvAPI_DRS_LoadSettingsFromFile), // NvAPI_DRS_LoadSettingsFromFile
		(ID: $375DBD6B; Func: @@NvAPI_DRS_LoadSettings), // NvAPI_DRS_LoadSettings
		(ID: $DAD9CFF8; Func: @@NvAPI_DRS_DestroySession), // NvAPI_DRS_DestroySession
		(ID: $2BE25DF8; Func: @@NvAPI_DRS_SaveSettingsToFile), // NvAPI_DRS_SaveSettingsToFile
		(ID: $0694D52E; Func: @@NvAPI_DRS_CreateSession), // NvAPI_DRS_CreateSession
		(ID: $FCBC7E14; Func: @@NvAPI_DRS_SaveSettings), // NvAPI_DRS_SaveSettings
		
		(ID: 0; Func: nil)); // stop signal

function NvAPI_NotImplemented(): NvAPI_Status; cdecl;
begin
Result := NVAPI_NO_IMPLEMENTATION;
end;

// *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
// =*=*= Smooth DLL IMPLEMENTATION =*=*=*
// *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
type
	TSDllNVAPI = class(TSDll)
			public
		class function SystemNames() : TSStringList; override;
		class function DllNames() : TSStringList; override;
		class function Load(const VDll : TSLibHandle) : TSDllLoadObject; override;
		class procedure Free(); override;
		end;

class function TSDllNVAPI.SystemNames() : TSStringList;
begin
Result := 'nvapi';
end;

class function TSDllNVAPI.DllNames() : TSStringList;
begin
Result := nil;
{$IFDEF CPU64}
Result += 'nvapi64';
Result += 'nvapi64.dll';
{$ELSE}
Result += 'nvapi';
Result += 'nvapi.dll';
{$ENDIF}
end;

class procedure TSDllNVAPI.Free();
var
	Rec: PNvAPIFuncRec;
begin
{ Initialize all function to not implemented }
Rec := @NvAPIFunctions;
while Rec.ID <> 0 do
	begin
	if Rec.Func <> nil then
		PPointer(Rec.Func)^ := @NvAPI_NotImplemented;
	Inc(Rec);
	end;
Initialized := False;
end;

class function TSDllNVAPI.Load(const VDll : TSLibHandle) : TSDllLoadObject;
const
  NvAPI_ID_INIT = $0150E828;
var
  nvapi_QueryInterface: function(ID: LongWord): Pointer; cdecl;
  InitFunc: function: Integer; stdcall;
  P: Pointer;
  Rec: PNvAPIFuncRec;
begin
Result.Clear();
if Initialized then
	Exit;
nvapi_QueryInterface := GetProcAddress(VDll, 'nvapi_QueryInterface');
if Assigned(nvapi_QueryInterface) then
	begin
	InitFunc := nvapi_QueryInterface(NvAPI_ID_INIT);
	if Assigned(InitFunc) then
		begin
		if InitFunc() >= 0 then
			begin
			Rec := @NvAPIFunctions;
			while Rec.ID <> 0 do
				begin
				if Rec.Func <> nil then
					PPointer(Rec.Func)^ := @NvAPI_NotImplemented;
				P := nvapi_QueryInterface(Rec.ID);
				if P <> nil then
					begin
					Result.FFunctionLoaded += 1;
					if Rec.Func <> nil then
						PPointer(Rec.Func)^ := P;
					end;
				Result.FFunctionCount += 1;
				Inc(Rec);
				end;
			end;
		end;
	end;
Initialized := Result.FFunctionCount > 0;
if not Initialized then
	Free();
end;

initialization
	TSDllNVAPI.Create();

end.
