#version 120
/*#eoln*/
void main(void)
{
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
