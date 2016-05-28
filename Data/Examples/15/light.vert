#standartparam 0 0
#standartparam 99 /*#ri*/

uniform mat4 lightMatrix/*#0*/;
uniform vec3 lightPos/*#0*/;
uniform vec3 lightDir/*#0*/;

varying vec4 lpos/*#0*/;
varying vec3 light_vec/*#0*/;
varying vec3 light_dir/*#0*/;

void processLight/*#0*/(vec4 /*#99*/) {
	lpos/*#0*/ = lightMatrix/*#0*/ * /*#99*/;
	light_vec/*#0*/ = /*#99*/.xyz - lightPos/*#0*/;
	light_dir/*#0*/ = gl_NormalMatrix * lightDir/*#0*/;
}

