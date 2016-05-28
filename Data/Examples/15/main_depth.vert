#standartparam 0 32

uniform mat4 boneMat[/*#0*/];

void main(void)
{
	float boneIndex[3]; 
	float boneWeight[3]; 
	vec4 fixedVertex = gl_Vertex; 
	vec4 finalVertex = vec4(0,0,0,1);
	vec4 fixedTexCoord = gl_MultiTexCoord0;
	vec4 fixedColor = gl_Color; 
	boneIndex[0] = floor(fixedTexCoord[2]*255.0+0.001); 
	boneWeight[0] = fixedTexCoord[3]; 
	boneIndex[1] = floor(fixedColor[0]*255.0+0.001); 
	boneWeight[1] = fixedColor[1]; 
	boneIndex[2] = floor(fixedColor[2]*255.0+0.001); 
	boneWeight[2] = fixedColor[3];
	fixedVertex[3] = 1.0; 
	mat4 finalMatrix = mat4(0); 
	for (int i = 0; i < 3; i++) 
		finalMatrix += boneWeight[i]*boneMat[int(boneIndex[i])]; 
	finalVertex = finalMatrix*fixedVertex; 
	finalVertex[3] = 1.0; 
	gl_Position = gl_ModelViewProjectionMatrix * finalVertex;
}
