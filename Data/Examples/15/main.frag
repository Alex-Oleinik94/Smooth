#standartparam 0 shadow
#standartparam 1 1
#standartparam 99 /*#1*/-1

uniform int renderType;
varying float texNum;
varying vec4 coll;
/*#eoln*/
#include textures.frag 6 myTexture 0 processTexture
/*#eoln*/
#for kkk 0 /*#1*/-1 #include light.frag /*#0*/ /*#kkk*/
#include lights.frag /*#1*/

vec3 processTexAndBump(int texNumber, int bumpNumber) {
	vec3 d = processTexture(texNumber);
	vec3 b = (processTexture(bumpNumber)- 0.5) * 2;
	float bs = 
		#for i 0 /*#1*/-2 max( dot(b, -lightVec/*#i*/), 
		dot(b, -lightVec/*#99*/)
		#for i 0 /*#1*/-2 {)}
		 ;
	return d * bs;
}
/*#eoln*/
void main ()
{
	light_init();
	
	vec3 fixedColor;
	if (renderType == 2) {
		fixedColor = processTexAndBump(0,1)* shadow_sum();
	} else if (renderType == 1) {
		fixedColor = coll * shadow_sum();
	} else {
		fixedColor = processTexture(int(floor(texNum * 255 + 0.001)));
	}
		gl_FragColor = vec4(fixedColor.xyz * diffuse_sum(), coll.w);
}
