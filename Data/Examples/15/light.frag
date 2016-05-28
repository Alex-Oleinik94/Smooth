#standartparam 0 shadow
#standartparam 1 0
#standartparam 99 /*#ri*/

#if /*#0*/==shadow
uniform sampler2DShadow shadowMap/*#1*/;
#else
uniform sampler2D shadowMap/*#1*/;
#endif

varying vec4 lpos/*#1*/;
varying vec3 light_vec/*#1*/;
varying vec3 light_dir/*#1*/;

vec3 lightVec/*#1*/;
/*#eoln*/
float diffuse/*#1*/(vec3 /*#99*/) {
	return max(0.3, dot(-lightVec/*#1*/, /*#99*/));
}
/*#eoln*/
float shadow/*#1*/() {
	vec3 smcoord = lpos/*#1*/.xyz / lpos/*#1*/.w;
#if /*#0*/==shadow
	return clamp(shadow2D(shadowMap/*#1*/, smcoord).x,0.2,1.0);
#else
	return clamp(float(smcoord.z <= texture2D(shadowMap/*#1*/, smcoord.xy).x),0.2,1.0);
#endif
}
