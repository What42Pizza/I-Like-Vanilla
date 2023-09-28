#ifdef FIRST_PASS
	
	const float PI = 3.1415926538;
	const float HALF_PI = PI / 2.0;
	
	#ifdef FSH
		ivec2 texelcoord = ivec2(gl_FragCoord.xy);
	#endif
	
	uniform sampler2D texture;
	uniform sampler2D lightmap;
	uniform sampler2D colortex0;
	uniform sampler2D colortex1;
	uniform sampler2D colortex2;
	uniform sampler2D colortex3;
	uniform sampler2D colortex4;
	uniform sampler2D gaux2;
	uniform sampler2D depthtex0;
	uniform sampler2D depthtex1;
	uniform sampler2D depthtex2;
	uniform sampler2D shadowtex0;
	uniform sampler2D noisetex;
	
	//uniform float centerDepth;
	//uniform float centerDepthSmooth;
	
#endif



// misc defines

#ifdef FSH
	#define flat flat in
#else
	#define flat flat out
#endif

#define HAND_DEPTH 0.19 // idk what should actually be here

#ifdef DEBUG_OUTPUT_ENABLED
	#define DEBUG_ARGS_IN , debugOutput
	#define DEBUG_ARGS_OUT , inout vec3 debugOutput
#else
	#define DEBUG_ARGS_IN
	#define DEBUG_ARGS_OUT
#endif



// buffer values:

#define MAIN_BUFFER                 colortex0
#define TAA_PREV_BUFFER             colortex1
#define BLOOM_BUFFER                colortex2
#define REFLECTION_STRENGTH_BUFFER  colortex3
#define NOISY_ADDITIONS_BUFFER      colortex3
#define NORMALS_BUFFER              colortex4
#define MAIN_BUFFER_COPY            gaux2
#define DEBUG_BUFFER                colortex0

#define DEPTH_BUFFER_ALL                   depthtex0
#define DEPTH_BUFFER_WO_TRANS              depthtex1
#define DEPTH_BUFFER_WO_TRANS_OR_HANDHELD  depthtex2





#ifdef FIRST_PASS
	
	
	
	float pow2(float v) {
		return v * v;
	}
	float pow3(float v) {
		return v * v * v;
	}
	float pow4(float v) {
		float v2 = v * v;
		return v2 * v2;
	}
	float pow5(float v) {
		float v2 = v * v;
		return v2 * v2 * v;
	}
	float pow10(float v) {
		float v2 = v * v;
		float v4 = v2 * v2;
		return v4 * v4 * v2;
	}
	
	vec2 pow2(vec2 v) {
		return v * v;
	}
	vec2 pow3(vec2 v) {
		return v * v * v;
	}
	
	vec3 pow2(vec3 v) {
		return v * v;
	}
	vec3 pow3(vec3 v) {
		return v * v * v;
	}
	
	float getColorLum(vec3 color) {
		return dot(color, vec3(0.2125, 0.7154, 0.0721));
	}
	
	float maxAbs(vec2 v) {
		float r = abs(v.r);
		float g = abs(v.g);
		return max(r, g);
	}
	
	float maxAbs(vec3 v) {
		float r = abs(v.r);
		float g = abs(v.g);
		float b = abs(v.b);
		return max(max(r, g), b);
	}
	
	// all these smooth functions seem the same for speed
	
	//// from: https://iquilezles.org/articles/smin/
	//vec3 smoothMin(vec3 a, vec3 b, float k) {
	//	vec3 h = max(k-abs(a-b), 0.0)/k;
	//	return min(a, b) - h*h*k*0.25;
	//}
	
	//// same as smoothMin but w/ in&out inverted
	//vec3 smoothMax(vec3 a, vec3 b, float k) {
	//	vec3 h = max(k-abs(a-b), 0.0)/k;
	//	return max(a, b) + h*h*k*0.25;
	//}
	
	//// from: https://www.shadertoy.com/view/Ml3Gz8
	//vec3 smoothMin(vec3 a, vec3 b, float k) {
	//	vec3 h = clamp(0.5 + 0.5*(a-b)/k, 0.0, 1.0);
	//	return mix(a, b, h) - k*h*(1.0-h);
	//}
	
	//// same as smoothMin but w/ in&out inverted
	//vec3 smoothMax(vec3 a, vec3 b, float k) {
	//	vec3 h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
	//	return mix(a, b, h) + k*h*(1.0-h);
	//}
	
	vec3 smoothMin(vec3 v1, vec3 v2, float a) {
		float v1Lum = getColorLum(v1);
		float v2Lum = getColorLum(v2);
		return (v1 + v2 - sqrt((v1 - v2) * (v1 - v2) + a * (v1Lum + v2Lum) / 2.0)) / 2.0;
	}
	
	vec3 smoothMax(vec3 v1, vec3 v2, float a) {
		float v1Lum = getColorLum(v1);
		float v2Lum = getColorLum(v2);
		return (v1 + v2 + sqrt((v1 - v2) * (v1 - v2) + a * (v1Lum + v2Lum) / 2.0)) / 2.0;
	}
	
	vec3 smoothClamp(vec3 v, vec3 minV, vec3 maxV, float a) {
		return smoothMax(smoothMin(v, maxV, a), minV, a);
	}
	
	float cosineInterpolate(float edge1, float edge2, float value) {
		float value2 = (1.0 - cos(value * PI)) / 2.0;
		return edge1 * (1.0 - value2) + edge2 * value2;
	}
	
	float cubicInterpolate(float edge0, float edge1, float edge2, float edge3, float value) {
		float value2 = value * value;
		float a0 = edge3 - edge2 - edge0 + edge1;
		float a1 = edge0 - edge1 - a0;
		float a2 = edge2 - edge0;
		float a3 = edge1;
		return(a0 * value * value2 + a1 * value2 + a2 * value + a3);
	}
	
	vec3 cubicInterpolate(vec3 edge0, vec3 edge1, vec3 edge2, vec3 edge3, float value) {
		float x = cubicInterpolate(edge0.x, edge1.x, edge2.x, edge3.x, value);
		float y = cubicInterpolate(edge0.y, edge1.y, edge2.y, edge3.y, value);
		float z = cubicInterpolate(edge0.z, edge1.z, edge2.z, edge3.z, value);
		return vec3(x, y, z);
	}
	
	
	
	vec4 startMat(vec3 pos) {
		return vec4(pos.xyz, 1.0);
	}
	vec3 endMat(vec4 pos) {
		return pos.xyz / pos.w;
	}
	
	bool depthIsSky(float depth) {
		return depth > 0.99;
	}
	bool depthIsHand(float depth) {
		return depth < 0.003;
	}
	
	// never underestimate trial and error
	#ifdef FSH
		float estimateDepthFSH(vec2 texcoord, float linearDepth) {
			float len = length(texcoord * 2.0 - 1.0);
			return linearDepth + len * len / 8.0;
		}
	#else
		float estimateDepthVSH() {
			float len = length(gl_Position.xy) / max(gl_Position.w, 1.0);
			return gl_Position.z * (1.0 + len * len * 0.7);
		}
	#endif
	
	
	
	#ifdef USE_BETTER_RAND
		// taken from: https://www.reedbeta.com/blog/hash-functions-for-gpu-rendering/
		float randomFloat(inout uint rng) {
			rng = rng * 747796405u + 2891336453u;
			uint v = ((rng >> ((rng >> 28u) + 4u)) ^ rng) * 277803737u;
			v = (v >> 22u) ^ v;
			float f = float(v % 1000000u);
			return f / 500000.0 - 1.0;
		}
		/*
		// maybe switch to this:
		// taken from: https://www.pcg-random.org/download.html
		uint32_t pcg32_random_r(pcg32_random_t* rng)
		{
			uint64_t oldstate = rng->state;
			rng->state = oldstate * 6364136223846793005ULL + rng->inc;
			uint32_t xorshifted = ((oldstate >> 18u) ^ oldstate) >> 27u;
			uint32_t rot = oldstate >> 59u;
			return (xorshifted >> rot) | (xorshifted << ((-rot) & 31));
		}
		*/
	#else
		int rotateRight(int value, uint shift) {
			return (value >> shift) | (value << (32u - shift));
		}
		float randomFloat(inout int rng) {
			rng = rng * 747796405 + 2891336453;
			rng ^= rotateRight(rng, 11u);
			rng ^= rotateRight(rng, 17u);
			rng ^= rotateRight(rng, 23u);
			float f = float(rng % 1000000);
			return f / 500000.0 - 1.0;
		}
	#endif

	vec2 randomVec2(inout int rng) {
		float x = randomFloat(rng);
		float y = randomFloat(rng);
		return vec2(x, y);
	}

	vec3 randomVec3(inout int rng) {
		float x = randomFloat(rng);
		float y = randomFloat(rng);
		float z = randomFloat(rng);
		return vec3(x, y, z);
	}

	vec3 randomVec3FromRValue(int rng) {
		return randomVec3(rng);
	}

	float normalizeNoiseAround1(float noise, float range) {
		return noise * range + 1.0;
	}

	vec2 normalizeNoiseAround1(vec2 noise, float range) {
		float x = normalizeNoiseAround1(noise.x, range);
		float y = normalizeNoiseAround1(noise.y, range);
		return vec2(x, y);
	}

	vec3 normalizeNoiseAround1(vec3 noise, float range) {
		float x = normalizeNoiseAround1(noise.x, range);
		float y = normalizeNoiseAround1(noise.y, range);
		float z = normalizeNoiseAround1(noise.z, range);
		return vec3(x, y, z);
	}
	
	
	
#endif

float toLinearDepth(float depth  ARGS_OUT) {
	#include "/import/twoTimesNear.glsl"
	#include "/import/farPlusNear.glsl"
	#include "/import/farMinusNear.glsl"
	return twoTimesNear / (farPlusNear - depth * farMinusNear);
}

float fromLinearDepth(float depth  ARGS_OUT) {
	#include "/import/farPlusNear.glsl"
	#include "/import/twoTimesNear.glsl"
	#include "/import/invFarMinusNear.glsl"
	return (farPlusNear - twoTimesNear / depth) * invFarMinusNear;
}

float toBlockDepth(float depth  ARGS_OUT) {
	#include "/import/twoTimesNearTimesFar.glsl"
	#include "/import/farPlusNear.glsl"
	#include "/import/farMinusNear.glsl"
	return twoTimesNearTimesFar / (farPlusNear - depth * farMinusNear);
}





// CODE FROM COMPLEMENTARY REIMAGINED:

vec3 screenToView(vec3 pos  ARGS_OUT) {
	#include "/import/gbufferProjectionInverse.glsl"
	vec4 iProjDiag = vec4(
		gbufferProjectionInverse[0].x,
		gbufferProjectionInverse[1].y,
		gbufferProjectionInverse[2].zw
	);
	vec3 p3 = pos * 2.0 - 1.0;
	vec4 viewPos = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
	return viewPos.xyz / viewPos.w;
}

float sqrt3(float x  ARGS_OUT) {
	x = 1.0 - x;
	x *= x;
	x *= x;
	x *= x;
	return 1.0 - x;
}

// END OF COMPLEMENTARY REIMAGINED'S CODE



// this code has to be in common bc motion blur uses it too
#if !defined ISOMETRIC_RENDERING_ENABLED
	// Previous frame reprojection from Chocapic13
	vec2 reprojection(vec3 screenPos, vec3 cameraOffset  ARGS_OUT) {
		#include "/import/gbufferProjectionInverse.glsl"
		#include "/import/gbufferModelViewInverse.glsl"
		#include "/import/gbufferPreviousProjection.glsl"
		#include "/import/gbufferPreviousModelView.glsl"
		screenPos = screenPos * 2.0 - 1.0;
		
		vec4 viewPos = gbufferProjectionInverse * vec4(screenPos, 1.0);
		viewPos /= viewPos.w;
		vec4 worldPos = gbufferModelViewInverse * viewPos;
		
		vec4 prevWorldPos = worldPos + vec4(cameraOffset, 0.0);
		vec4 prevCoord = gbufferPreviousProjection * gbufferPreviousModelView * prevWorldPos;
		return prevCoord.xy / prevCoord.w * 0.5 + 0.5;
	}
#else
	vec2 reprojection(vec3 screenPos, vec3 cameraOffset  ARGS_OUT) {
		#include "/import/aspectRatio.glsl"
		#include "/import/gbufferModelViewInverse.glsl"
		#include "/import/gbufferPreviousModelView.glsl"
		const float scale = ISOMETRIC_WORLD_SCALE * 0.5;
		const float forwardPlusBackward = ISOMETRIC_FORWARD_VISIBILITY * 0.5 + ISOMETRIC_BACKWARD_VISIBILITY * 0.5;
		const float forwardMinusBackward = ISOMETRIC_FORWARD_VISIBILITY * 0.5 - ISOMETRIC_BACKWARD_VISIBILITY * 0.5;
		vec4 scaleVec = vec4(scale * aspectRatio, scale, -forwardPlusBackward, 1);
		const vec4 offsetVec = vec4(0, 0, forwardMinusBackward / forwardPlusBackward, 0);
		screenPos = screenPos * 2.0 - 1.0;
		
		vec4 worldPos = gbufferModelViewInverse * ((vec4(screenPos, 1.0) + offsetVec) * scaleVec);
		worldPos /= worldPos.w;
		
		vec4 prevWorldPos = worldPos + vec4(cameraOffset, 0.0);
		vec4 prevCoord = (gbufferPreviousModelView * prevWorldPos) / scaleVec - offsetVec;
		return prevCoord.xy / prevCoord.w * 0.5 + 0.5;
	}
#endif



vec3 getViewPos(vec2 coords, float rawDepth  ARGS_OUT) {
	float linearDepth = toLinearDepth(rawDepth  ARGS_IN);
	if (depthIsSky(linearDepth) || depthIsHand(linearDepth)) {
		return vec3(0.0);
	}
	vec3 screenPos = vec3(coords, rawDepth);
	return screenToView(screenPos  ARGS_IN);
}





float cubeLength(vec2 v  ARGS_OUT) {
	return pow(abs(v.x * v.x * v.x) + abs(v.y * v.y * v.y), 1.0 / 3.0);
}

float getDistortFactor(vec3 v  ARGS_OUT) {
	return cubeLength(v.xy  ARGS_IN) + SHADOW_DISTORT_ADDITION;
}

vec3 distort(vec3 v, float distortFactor  ARGS_OUT) {
	return vec3(v.xy / distortFactor, v.z * 0.5);
}

vec3 distort(vec3 v  ARGS_OUT) {
	return distort(v, getDistortFactor(v  ARGS_IN)  ARGS_IN);
}
