{$MODE OBJFPC}
program Main;
uses san,sanprograms,crt,gl;
var
	fogColor:array[0..3]of real = (0,0,0,1);
begin
GlSanCOGWAIOG(GlSanStringToPChar('SG System'));
InitWindowDoska;

glEnable(GL_FOG);
glFogi(GL_FOG_MODE, GL_LINEAR);
glHint (GL_FOG_HINT, GL_NICEST);
//glHint(GL_FOG_HINT, GL_DONT_CARE);
glFogf (GL_FOG_START, 10);
glFogf (GL_FOG_END, 100.0);
glFogfv(GL_FOG_COLOR, @fogColor);
glFogf(GL_FOG_DENSITY, 0.75);
repeat
if Length(GlSanWinds)=0 then
	begin
	try
		Halt(1);
	except
		halt;
		end;
	end;
until GlSanAfterUntil(0,false,true);
end.
{NewDelayWindow(nil);
NewMenuWindow;}
