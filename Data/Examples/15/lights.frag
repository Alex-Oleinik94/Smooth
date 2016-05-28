#standartparam 0 1
#standartparam 99 /*#0*/-1
varying vec3 normal;
vec3 normalizedNormal;
/*#eoln*/
float shadow_sum() {
	return (
		#for i 0 /*#0*/-2  shadow/*#i*/() +
		shadow/*#99*/() ) / /*#0*/;
}
/*#eoln*/
float diffuse_sum() {
	return
	#for i 0 /*#0*/-2 max( diffuse/*#i*/(normalizedNormal), 
	diffuse/*#99*/(normalizedNormal)
	#for i 0 /*#0*/-2 {)}
	;
}
/*#eoln*/
float light_sum() {
	return shadow_sum() * diffuse_sum();
}
/*#eoln*/
void light_init() {
	normalizedNormal = normalize(normal);
	#for i 0 /*#0*/-1 lightVec/*#i*/ = normalize(light_vec/*#i*/);
}

