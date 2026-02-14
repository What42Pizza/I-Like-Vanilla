in_out vec2 texcoord;



#ifdef FSH

const bool colortex0MipmapEnabled = true;

#if BORDER_FOG_ENABLED == 1
	#include "/utils/screen_to_view.glsl"
	#include "/utils/borderFogAmount.glsl"
#endif

void main() {
	#if HORROR_MODE == 0
		vec3 bloomColor = texelFetch(MAIN_TEXTURE, texelcoord, 2).rgb * 2.0;
		float depth = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord * 4 + 1, 0).r;
	#else
		vec3 bloomColor = texture2DLod(MAIN_TEXTURE, texcoord, 2).rgb * 2.0;
		float depth = texture2D(DEPTH_BUFFER_WO_TRANS, texcoord).r;
	#endif
	
	
	#ifdef DISTANT_HORIZONS
		float depthDh = texelFetch(DH_DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
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
	
	
	//const vec3 targetColor = vec3(1.0, 1.0, 0.0);
	//float bloomMult = dot(bloomColor / getLum(bloomColor), targetColor / getLum(targetColor) * 0.5) * getLum(bloomColor);
	
	//float bloomMult = getLum(bloomColor);
	//bloomMult *= 1.0 + 0.25 * bloomColor.g - bloomColor.r * 0.125;
	//bloomMult *= bloomMult;
	
	//vec3 bloomColorHsv = rgbToHsv(bloomColor + vec3(0.05, 0.05, 0.0));
	//float bloomMult = 1.0 - 8.0 * abs(bloomColorHsv.x - (51.0 / 360.0));
	//bloomMult = clamp(bloomMult, 0.0, 1.0);
	//bloomMult *= bloomColorHsv.z;
	//bloomMult *= bloomMult;
	
	float bloomMult = dot(bloomColor, vec3(0.2, 0.7, 0.1));
	#if HORROR_MODE == 1
		bloomMult *= 1.5;
	#else
		bloomMult *= bloomMult;
	#endif
	
	bloomMult = smoothstep(BLOOM_LOW_CUTOFF, BLOOM_HIGH_CUTOFF, bloomMult);
	bloomMult *= getSaturation(bloomColor);
	float fogDecrease = 1.0 - 0.5 * fogAmount;
	fogDecrease *= fogDecrease;
	bloomMult *= fogDecrease;
	bloomColor *= bloomMult;
	#if HORROR_MODE == 1
		bloomColor = vec3(bloomMult);
	#endif
	
	// scary mode:
	//const vec3 targetColor = vec3(1.0, 1.0, 0.0);
	//float bloomMult = dot(bloomColor / getLum(bloomColor), targetColor / getLum(targetColor) * 0.75) * getLum(bloomColor);
	//bloomMult = smoothstep(BLOOM_LOW_CUTOFF, BLOOM_HIGH_CUTOFF, bloomMult);
	//bloomMult *= getSaturation(bloomColor);
	//float fogDecrease = 1.0 - 0.5 * fogAmount;
	//fogDecrease *= fogDecrease;
	//bloomMult *= fogDecrease;
	//bloomColor = vec3(bloomMult);
	
	
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
