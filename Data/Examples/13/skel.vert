// Vertex Shader 
uniform mat4 boneMat[32]; 
varying float texNum; 
void main() 
{ 
	float boneIndex[3]; 
	float boneWeight[3]; 
	texNum = gl_Vertex[3]; 
	vec4 fixedTexCoord = gl_MultiTexCoord0; 
	vec4 fixedColor = gl_Color; 
	vec4 fixedVertex = gl_Vertex; 
	vec4 finalVertex = vec4(0,0,0,1); 
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
	finalVertex = finalMatrix*fixedVertex; 
	finalVertex[3] = 1.0; 
	gl_Position = gl_ModelViewProjectionMatrix * finalVertex; 
	gl_FrontColor = fixedColor; 
	gl_TexCoord[0] = fixedTexCoord; 
}
