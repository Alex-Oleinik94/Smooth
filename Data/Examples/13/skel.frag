// Fragment Shader 
uniform sampler2D myTexture0; 
uniform sampler2D myTexture1; 
uniform sampler2D myTexture2; 
uniform sampler2D myTexture3; 
uniform sampler2D myTexture4; 
uniform sampler2D myTexture5; 
uniform sampler2D myTexture6; 
varying float texNum; 
void main() 
{ 
 float texNum2 = floor(texNum*255 + 0.001); 
 if (texNum2==0.0) 
  gl_FragColor = texture2D( myTexture0, gl_TexCoord[0].st );  
 else if (texNum2==1.0) 
  gl_FragColor = texture2D( myTexture1, gl_TexCoord[0].st );  
 else if (texNum2==2.0) 
  gl_FragColor = texture2D( myTexture2, gl_TexCoord[0].st );  
 else if (texNum2==3.0) 
  gl_FragColor = texture2D( myTexture3, gl_TexCoord[0].st );  
 else if (texNum2==4.0) 
  gl_FragColor = texture2D( myTexture4, gl_TexCoord[0].st );  
 else if (texNum2==5.0) 
  gl_FragColor = texture2D( myTexture5, gl_TexCoord[0].st );  
 else  gl_FragColor = texture2D( myTexture6, gl_TexCoord[0].st );  
}
