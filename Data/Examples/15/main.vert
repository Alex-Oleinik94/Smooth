#standartparam 0 1
#standartparam 1 32

uniform int renderType;
varying vec4 coll;
varying float texNum;
uniform mat4 boneMat[/*#1*/];
/*#eoln*/
varying vec3 normal;

/*#eoln*/
#for kkk 0 /*#0*/-1 #include light.vert /*#kkk*/

void main(void)
{
	vec4 finalVertex;
	vec3 finalNormal;
	vec4 fixedTexCoord = gl_MultiTexCoord0; 
	vec4 fixedColor = gl_Color; 
	vec4 fixedVertex = gl_Vertex;
	vec3 fixedNormal = gl_Normal;
	if (renderType != 0) {
		finalVertex = fixedVertex;
		finalNormal = fixedNormal;
	} else {
		float boneIndex[3]; 
		float boneWeight[3];
		
		texNum = gl_Vertex[3]; 
		boneIndex[0] = floor(fixedTexCoord[2]*255.0+0.001); 
		boneWeight[0] = fixedTexCoord[3]; 
		boneIndex[1] = floor(fixedColor[0]*255.0+0.001); 
		boneWeight[1] = fixedColor[1]; 
		boneIndex[2] = floor(fixedColor[2]*255.0+0.001); 
		boneWeight[2] = fixedColor[3];
		
		fixedTexCoord[2] = 0.0; 
		fixedTexCoord[3] = 1.0; 
		fixedColor[0] = 1.0; 
		fixedColor[1] = 1.0; 
		fixedColor[2] = 1.0; 
		fixedColor[3] = 1.0;
		fixedVertex[3] = 1.0;
		
		mat4 finalMatrix = mat4(0); 
		for (int i = 0; i < 3; i++)
			finalMatrix += boneWeight[i]*boneMat[int(boneIndex[i])];
		finalVertex = finalMatrix * fixedVertex;
		finalVertex[3] = 1.0;
		
		finalNormal = mat3(finalMatrix) * fixedNormal;
	}
	gl_Position = gl_ModelViewProjectionMatrix * finalVertex; 
	gl_FrontColor = fixedColor;
	gl_TexCoord[0] = fixedTexCoord;
	coll = fixedColor;
	normal = gl_NormalMatrix * finalNormal;
	vec4 vpos = gl_ModelViewMatrix * finalVertex;
	/*#eoln*/
	#for kkk 0 /*#0*/-1 processLight/*#kkk*/(vpos);
}
