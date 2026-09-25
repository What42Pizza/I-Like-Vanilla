in_out vec2 texcoord;



#ifdef FSH

#include "/utils/depth.glsl"

void main() {
	vec3 color = vec3(0.0);
	
	color += texture2D(BLOOM_TEXTURE, texcoord).rgb * 8.0;
	color += texture2D(BLOOM_TEXTURE, texcoord + BLOOM_SIZE * 1.75 * vec2(pixelSize.x * 4.0 , pixelSize.y *  2.0)).rgb;
	color += texture2D(BLOOM_TEXTURE, texcoord + BLOOM_SIZE * 1.75 * vec2(pixelSize.x * 4.0 , pixelSize.y * -2.0)).rgb;
	color += texture2D(BLOOM_TEXTURE, texcoord + BLOOM_SIZE * 1.75 * vec2(pixelSize.x * -4.0, pixelSize.y *  2.0)).rgb;
	color += texture2D(BLOOM_TEXTURE, texcoord + BLOOM_SIZE * 1.75 * vec2(pixelSize.x * -4.0, pixelSize.y * -2.0)).rgb;
	color += texture2D(BLOOM_TEXTURE, texcoord + BLOOM_SIZE * 1.75 * vec2(pixelSize.x * 2.0 , pixelSize.y *  4.0)).rgb;
	color += texture2D(BLOOM_TEXTURE, texcoord + BLOOM_SIZE * 1.75 * vec2(pixelSize.x * 2.0 , pixelSize.y * -4.0)).rgb;
	color += texture2D(BLOOM_TEXTURE, texcoord + BLOOM_SIZE * 1.75 * vec2(pixelSize.x * -2.0, pixelSize.y *  4.0)).rgb;
	color += texture2D(BLOOM_TEXTURE, texcoord + BLOOM_SIZE * 1.75 * vec2(pixelSize.x * -2.0, pixelSize.y * -4.0)).rgb;
	
	color *= 1.0 / 16.0;
	
	/* DRAWBUFFERS:4 */
	gl_FragData[0] = vec4(color, 1.0);
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	gl_Position.xy = mix(vec2(-1.0), vec2(-1.0/9.0), gl_Position.xy * 0.5 + 0.5);
	texcoord = gl_MultiTexCoord0.xy * 2.0 / 3.0;
}

#endif
