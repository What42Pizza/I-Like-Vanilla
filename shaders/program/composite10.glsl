in_out vec2 texcoord;



#ifdef FSH

const bool colortex0MipmapEnabled = true;

#if BORDER_FOG_ENABLED == 1
	#include "/utils/screen_to_view.glsl"
	#include "/utils/borderFogAmount.glsl"
#endif

void main() {
	
	const int bloomIntScale = 1 << BLOOM_RENDER_SCALE;
	
	#if HORROR_MODE == 0
		vec3 bloomColor = texelFetch(MAIN_TEXTURE, texelcoord, BLOOM_RENDER_SCALE).rgb * 2.0;
		float depth = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord * bloomIntScale + bloomIntScale / 2, 0).r;
	#else
		vec3 bloomColor = texture2DLod(MAIN_TEXTURE, texcoord, BLOOM_RENDER_SCALE).rgb * 2.0;
		float depth = texture2D(DEPTH_BUFFER_WO_TRANS, texcoord).r;
	#endif
	
	
	#ifdef DISTANT_HORIZONS
		float depthDh = texelFetch(DH_DEPTH_BUFFER_WO_TRANS, texelcoord * bloomIntScale + bloomIntScale / 2, 0).r;
		float fogAmount = uint(depth == 1.0 && depthDh == 1.0);
	#elif defined VOXY
		float fogAmount = uint(depth == 1.0);
	#elif BORDER_FOG_ENABLED == 1
		vec3 viewPos = screenToView(vec3(texcoord, depth));
		vec3 playerPos = mat3(gbufferModelViewInverse) * viewPos;
		float _fogDistance;
		float fogAmount = getBorderFogAmount(playerPos, _fogDistance);
	#else
		float fogAmount = uint(depth == 1.0);
	#endif
	
	
	#if HORROR_MODE == 1
		float bloomMult = dot(bloomColor, vec3(0.2, 0.5, 0.1));
		bloomMult *= 1.3;
	#elif BLOOM_STYLE == 1
		float bloomMult = dot(bloomColor, vec3(0.7, 0.4, -0.5) * 0.9);
		bloomMult *= bloomMult;
	#elif BLOOM_STYLE == 2
		float bloomMult = getLum(bloomColor);
	#endif
	
	bloomMult = smoothstep(BLOOM_LOW_CUTOFF, BLOOM_HIGH_CUTOFF, bloomMult);
	#if BLOOM_STYLE == 1
		bloomMult *= 0.5 + 0.5 * getSaturation(bloomColor);
	#endif	
	float fogDecrease = 1.0 - 0.5 * fogAmount;
	fogDecrease *= fogDecrease;
	bloomMult *= fogDecrease;
	bloomColor *= bloomMult;
	#if HORROR_MODE == 1
		bloomColor = vec3(bloomMult);
	#endif
	
	
	/* DRAWBUFFERS:4 */
	gl_FragData[0] = vec4(bloomColor, 1.0);
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}

#endif
