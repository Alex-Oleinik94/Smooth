{$IFDEF INC_PLACE_INTERFACE}
type
	STRUCT_P_2 = ^ STRUCT_2;
	STRUCT_2 = object
			public
		x, y : STRUCT_TYPE;
			public
		procedure Import(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Write();                                                      {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure WriteLn();                                                    {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		{$IFDEF STRUCT_IS_FLOAT}
			function Round():STRUCT_2;                                          {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			function Normalized() : STRUCT_2;                                   {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		{$ENDIF STRUCT_IS_FLOAT}
		function FieldsArray() : STRUCT_PTYPE;                                  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property Data : STRUCT_PTYPE read FieldsArray;
		{$IFDEF STRUCT_IS_COLOR}
			property r : STRUCT_TYPE read x write x;
			property g : STRUCT_TYPE read y write y;
		{$ENDIF}
		end;
	
	{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
	STRUCT_P_3 = ^ STRUCT_3;
	STRUCT_3 = object(STRUCT_2)
			public
		z : STRUCT_TYPE;
			public
		procedure Import(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0;const z1 : STRUCT_TYPE = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Write();                   {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure WriteLn();                 {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		{$IFDEF STRUCT_IS_FLOAT}
			function Round():STRUCT_3;       {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			function Normalized() : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		{$ENDIF STRUCT_IS_FLOAT}
		{$IFDEF STRUCT_IS_COLOR}
			property b : STRUCT_TYPE read z write z;
		{$ENDIF}
		end;
	{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
	STRUCT_P_4 = ^ STRUCT_4;
	STRUCT_4 = object(STRUCT_3)
			public
		w : STRUCT_TYPE;
			public
		procedure Import(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0;const z1 : STRUCT_TYPE = 0;const w1 : STRUCT_TYPE = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Write();                   {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure WriteLn();                 {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		{$IFDEF STRUCT_IS_FLOAT}
			function Round():STRUCT_4;       {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		{$ENDIF STRUCT_IS_FLOAT}
		{$IFDEF STRUCT_IS_COLOR}
			property a : STRUCT_TYPE read w write w;
		{$ENDIF}
		end;
	{$ENDIF defined(STRUCT_4) and defined(STRUCT_P_4)}
	{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}

{$IFNDEF INC_WITHOUT_FORWARD}

{$IFDEF STRUCT_IS_FLOAT}
function Abs(const S : STRUCT_2):STRUCT_TYPE;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
function Abs(const S : STRUCT_3):STRUCT_TYPE;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF STRUCT_IS_FLOAT}


{$ENDIF INC_WITHOUT_FORWARD}

{$ENDIF INC_PLACE_INTERFACE}

{$IFDEF INC_PLACE_IMPLEMENTATION}
function STRUCT_2.FieldsArray() : STRUCT_PTYPE;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := STRUCT_PTYPE(@x);
end;

procedure STRUCT_2.Import(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
x := x1;
y := y1;
end;

procedure STRUCT_2.Write();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
{$IFDEF STRUCT_IS_FLOAT}
	System.Write(x:0:4,' ',y:0:4);
{$ELSE STRUCT_IS_FLOAT}
	System.Write(x,' ',y);
{$ENDIF STRUCT_IS_FLOAT}
end;

procedure STRUCT_2.WriteLn();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Write();
System.WriteLn();
end;

{$IFDEF STRUCT_IS_FLOAT}
	function Abs(const S : STRUCT_2) : STRUCT_TYPE;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
	begin
	Result := sqrt(sqr(S.x) + sqr(S.y));
	end;
	
	function STRUCT_2.Round() : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	begin
	Result.Import(System.Round(x),System.Round(y));
	end;
	
	function STRUCT_2.Normalized() : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	var
		ST : STRUCT_TYPE;
	begin
	ST := Abs(Self);
	Result.Import(x / ST, y / ST);
	end;
{$ENDIF STRUCT_IS_FLOAT}

{$IF defined(STRUCT_3) and defined(STRUCT_P_3)}
procedure STRUCT_3.Import(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0;const z1 : STRUCT_TYPE = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
x := x1;
y := y1;
z := z1;
end;

procedure STRUCT_3.Write();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
{$IFDEF STRUCT_IS_FLOAT}
	System.Write(x:0:4,' ',y:0:4,' ',z:0:4);
{$ELSE STRUCT_IS_FLOAT}
	System.Write(x,' ',y,' ',z);
{$ENDIF STRUCT_IS_FLOAT}
end;

procedure STRUCT_3.WriteLn();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Write();System.WriteLn();
end;

{$IFDEF STRUCT_IS_FLOAT}
	function Abs(const S : STRUCT_3):STRUCT_TYPE;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
	begin
	Result := sqrt(sqr(S.x) + sqr(S.y) + sqr(S.z));
	end;
	
	function STRUCT_3.Round():STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	begin
	Result.Import(System.Round(x),System.Round(y),System.Round(z));
	end;
	
	function STRUCT_3.Normalized() : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	var
		ST : STRUCT_TYPE;
	begin
	ST := Abs(Self);
	Result.Import(x / ST, y / ST, z / ST);
	end;
{$ENDIF STRUCT_IS_FLOAT}

{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
procedure STRUCT_4.Import(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0;const z1 : STRUCT_TYPE = 0;const w1 : STRUCT_TYPE = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
x := x1;
y := y1;
z := z1;
w := w1;
end;

procedure STRUCT_4.Write();                   {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
{$IFDEF STRUCT_IS_FLOAT}
	System.Write(x:0:4,' ',y:0:4,' ',z:0:4,' ',w:0:4);
{$ELSE STRUCT_IS_FLOAT}
	System.Write(x,' ',y,' ',z,' ',w);
{$ENDIF STRUCT_IS_FLOAT}
end;

procedure STRUCT_4.WriteLn();                 {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Write();System.WriteLn();
end;

{$IFDEF STRUCT_IS_FLOAT}
	function STRUCT_4.Round():STRUCT_4;       {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	begin
	Result.Import(System.Round(x),System.Round(y),System.Round(z),System.Round(w));
	end;
{$ENDIF STRUCT_IS_FLOAT}
{$ENDIF defined(STRUCT_4) and defined(STRUCT_P_4)}
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF INC_PLACE_IMPLEMENTATION}

{$IFDEF INC_PLACE_RENDER_CLASS}
	{$DEFINE INC_PLACE_RENDER_INTERFACE}
{$ENDIF INC_PLACE_RENDER_CLASS}

{$IFDEF INC_PLACE_RENDER_INTERFACE}

{$IFDEF STRUCT_IS_VERTEX}
procedure Vertex(const S : STRUCT_2);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
procedure Vertex(const S : STRUCT_3);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
procedure Normal(const S : STRUCT_3);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
procedure Vertex(const S : STRUCT_4);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$ENDIF defined(STRUCT_4) and defined(STRUCT_P_4)}
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF STRUCT_IS_VERTEX}

{$IFDEF STRUCT_IS_COLOR}
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
procedure Color(const S :  STRUCT_3);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
procedure Color(const S :  STRUCT_4);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$ENDIF defined(STRUCT_4) and defined(STRUCT_P_4)}
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF STRUCT_IS_COLOR}

{$IFDEF STRUCT_IS_TEX_VERTEX}
procedure TexCoord(const S : STRUCT_2);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
procedure TexCoord(const S :  STRUCT_3);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
procedure TexCoord(const S :  STRUCT_4);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$ENDIF defined(STRUCT_4) and defined(STRUCT_P_4)}
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF STRUCT_IS_TEX_VERTEX}

{$ENDIF INC_PLACE_RENDER_INTERFACE}

{$IFDEF INC_PLACE_RENDER_CLASS}
	{$UNDEF INC_PLACE_RENDER_INTERFACE}
{$ENDIF}

{$IFDEF INC_PLACE_RENDER_IMPLEMENTATION}

{$IFDEF STRUCT_IS_VERTEX}
procedure RENDER_CLASS.Vertex(const S : STRUCT_2);overload;
begin
Vertex2f(S.x,S.y);
end;
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
procedure RENDER_CLASS.Vertex(const S : STRUCT_3);overload;
begin
Vertex3f(S.x,S.y,S.z);
end;
procedure RENDER_CLASS.Normal(const S : STRUCT_3);overload;
begin
Normal3f(S.x,S.y,S.z);
end;
{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
procedure RENDER_CLASS.Vertex(const S : STRUCT_4);overload;
begin
//Vertex4f(S.x,S.y,S.z,S.w);
end;
{$ENDIF defined(STRUCT_4) and defined(STRUCT_P_4)}
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF STRUCT_IS_VERTEX}

{$IFDEF STRUCT_IS_COLOR}
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
procedure RENDER_CLASS.Color(const S :  STRUCT_3);overload;
begin
//{$IFDEF STRUCT_IS_FLOAT}
Color3f(S.r,S.g,S.b);
//{$ELSE  STRUCT_IS_FLOAT}
//Color3b(S.r,S.g,S.b);
//{$ENDIF STRUCT_IS_FLOAT}
end;
{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
procedure RENDER_CLASS.Color(const S :  STRUCT_4);overload;
begin
//{$IFDEF STRUCT_IS_FLOAT}
Color4f(S.r,S.g,S.b,S.a);
//{$ELSE  STRUCT_IS_FLOAT}
//Color4b(S.r,S.g,S.b,S.a);
//{$ENDIF STRUCT_IS_FLOAT}
end;
{$ENDIF defined(STRUCT_4) and defined(STRUCT_P_4)}
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF STRUCT_IS_COLOR}

{$IFDEF STRUCT_IS_TEX_VERTEX}
procedure RENDER_CLASS.TexCoord(const S : STRUCT_2);overload;
begin
TexCoord2f(S.x,S.y);
end;
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
procedure RENDER_CLASS.TexCoord(const S :  STRUCT_3);overload;
begin
//TexCoord3f(S.x,S.y,S.z);
end;
{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
procedure RENDER_CLASS.TexCoord(const S :  STRUCT_4);overload;
begin
//TexCoord4f(S.x,S.y,S.z,S.w);
end;
{$ENDIF defined(STRUCT_4) and defined(STRUCT_P_4)}
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF STRUCT_IS_TEX_VERTEX}

{$ENDIF INC_PLACE_RENDER_IMPLEMENTATION}
