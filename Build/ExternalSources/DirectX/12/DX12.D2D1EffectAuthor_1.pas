{ **************************************************************************
  FreePascal/Delphi DirectX 12 Header Files

  Copyright 2013-2021 Norbert Sonnleitner

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.
  ************************************************************************** }

{ **************************************************************************
  Additional Copyright (C) for this modul:

  Copyright (c) Microsoft Corporation.  All rights reserved.

  This unit consists of the following header files
  File name: D2D1EffectAuthor_1.h

  Header version: 10.0.19041.0

  ************************************************************************** }  
unit DX12.D2D1EffectAuthor_1;

{$IFDEF FPC}
{$mode delphi}
{$ENDIF}

interface

uses
    Windows, Classes, SysUtils, DX12.D2D1, DX12.DXGI, DX12.D2D1_3;

const
    IID_ID2D1EffectContext1: TGUID = '{84ab595a-fc81-4546-bacd-e8ef4d8abe7a}';
    IID_ID2D1EffectContext2: TGUID = '{577ad2a0-9fc7-4dda-8b18-dab810140052}';


type
    ID2D1EffectContext1 = interface(ID2D1EffectContext)
        ['{84ab595a-fc81-4546-bacd-e8ef4d8abe7a}']
        function CreateLookupTable3D(precision: TD2D1_BUFFER_PRECISION; extents: PUINT32; Data: PByte;
            dataCount: UINT32; strides: PUINT32; out lookupTable: ID2D1LookupTable3D): HResult; stdcall;
    end;


    ID2D1EffectContext2 = interface(ID2D1EffectContext1)
        ['{577ad2a0-9fc7-4dda-8b18-dab810140052}']
        function CreateColorContextFromDxgiColorSpace(colorSpace: TDXGI_COLOR_SPACE_TYPE; out colorContext: ID2D1ColorContext1): HResult; stdcall;
        function CreateColorContextFromSimpleColorProfile(const simpleProfile: TD2D1_SIMPLE_COLOR_PROFILE;
            out colorContext: ID2D1ColorContext1): HResult; stdcall;
    end;



implementation

end.













