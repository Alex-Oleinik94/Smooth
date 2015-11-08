#version 120

uniform sampler2DShadow shadowMap;

varying vec4 lpos;
varying vec3 normal;
varying vec3 light_vec;
varying vec3 light_dir;

const float inner_angle = 0.809017;
const float outer_angle = 0.707107;

void main (void)
{
	vec3 smcoord = lpos.xyz / lpos.w;
	float shadow = shadow2D(shadowMap, smcoord).x;

	vec3 lvec = normalize(light_vec);
	float diffuse = max(dot(-lvec, normalize(normal)), 0.0);
	float angle = dot(lvec, normalize(light_dir));
	float spot = clamp((angle - outer_angle) / (inner_angle - outer_angle), 0.0, 1.0);
	gl_FragColor = vec4(gl_Color.xyz * diffuse * shadow * spot, 1.0);
}
