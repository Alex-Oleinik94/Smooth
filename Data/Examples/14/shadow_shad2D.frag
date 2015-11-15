#version 120

uniform sampler2DShadow shadowMap;

varying vec4 lpos;
varying vec3 normal;
varying vec3 light_vec;
varying vec3 light_dir;

void main (void)
{
	vec3 smcoord = lpos.xyz / lpos.w;
	float shadow = clamp(shadow2D(shadowMap, smcoord).x,0.3,1.0);
	vec3 lvec = normalize(light_vec);
	float diffuse = max(dot(-lvec, normalize(normal)), 0.0);
	gl_FragColor = vec4(gl_Color.xyz * diffuse * shadow, 1.0);
}
