#standartparam 0 6
#standartparam 1 myTexture
#standartparam 2 0
#standartparam 3 processTexture
#standartparam 4 /*#ri*/
#for i 0 /*#0*/ uniform sampler2D /*#1*//*#i*/;
vec3 /*#3*/(int /*#4*/) {
	#for i 0 /*#0*/-1 {if (/*#4*/ == /*#i*/)
	return texture2D( /*#1*//*#i*/, gl_TexCoord[/*#2*/].st );
else }
		return texture2D( /*#1*//*#0*/, gl_TexCoord[/*#2*/].st );
}
