#standartparam 0 shadow
void main(void)
{
#if /*#0*/==shadow
	gl_FragColor = gl_Color;
#else
	gl_FragColor = vec4(gl_FragCoord.z);
#endif
}
