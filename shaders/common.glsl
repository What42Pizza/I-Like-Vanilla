const float PI = 3.1415926538;
const float HALF_PI = PI / 2.0;

#ifdef FSH
	ivec2 texelcoord = ivec2(gl_FragCoord.xy);
#endif

#ifndef SHADER_VOXY
	uniform sampler2D texture;
	uniform sampler2D lightmap;
	uniform sampler2D tex;
	uniform sampler2D colortex1;
	uniform sampler2D colortex2;
	uniform sampler2D colortex3;
	uniform sampler2D colortex4;
	uniform sampler2D colortex5;
	uniform sampler2D colortex6;
	uniform sampler2D colortex7;
	uniform sampler2D colortex8;
	uniform sampler2D depthtex0;
	uniform sampler2D depthtex1;
	uniform sampler2D depthtex2;
	uniform sampler2D shadowtex0;
	uniform sampler2D noisetex;
	#ifdef DISTANT_HORIZONS
		uniform sampler2D dhDepthTex0;
		uniform sampler2D dhDepthTex1;
	#endif
	#ifdef VOXY
		uniform sampler2D vxDepthTexOpaque;
		uniform sampler2D vxDepthTexTrans;
	#endif
#endif



// misc defines

#ifdef FSH
	#define in_out in
#else
	#define in_out out
#endif



// buffer values:

#define MAIN_TEXTURE                tex
#define PREV_TEXTURE                colortex1
#define OPAQUE_DATA_TEXTURE         colortex2
#define TRANSPARENT_DATA_TEXTURE    colortex3
#define BLOOM_TEXTURE               colortex4
#define SKY_OBJECTS_TEXTURE         colortex5
#define NOISY_RENDERS_TEXTURE       colortex6
#define PREV_DEPTH_TEXTURE          colortex7
#define VOXY_TRANSPARENCTS_TEXTURE  colortex8

#define DEPTH_BUFFER_ALL                   depthtex0
#define DEPTH_BUFFER_WO_TRANS              depthtex1
#define DEPTH_BUFFER_WO_TRANS_OR_HANDHELD  depthtex2
#ifdef DISTANT_HORIZONS
	#define DH_DEPTH_BUFFER_ALL       dhDepthTex0
	#define DH_DEPTH_BUFFER_WO_TRANS  dhDepthTex1
#endif
#ifdef VOXY
	#define VX_DEPTH_BUFFER_OPAQUE  vxDepthTexOpaque
	#define VX_DEPTH_BUFFER_TRANS   vxDepthTexTrans
#endif





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

float getLum(vec3 color) {
	return dot(color, vec3(0.299, 0.587, 0.114));
}

float getSaturation(vec3 v) {
	float maxv = max(max(v.r, v.g), v.b);
	float minv = min(min(v.r, v.g), v.b);
	return (maxv == 0.0) ? 0.0 : (maxv - minv) / maxv;
}

// taken from: https://stackoverflow.com/a/17897228, which is licensed under WTFPL (public domain)
vec3 rgbToHsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsvToRgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

//vec3 smoothMin(vec3 v1, vec3 v2, float a) {
//	float v1Lum = getLum(v1);
//	float v2Lum = getLum(v2);
//	return (v1 + v2 - sqrt(pow2(v1 - v2) + a * (v1Lum + v2Lum) / 2.0)) / 2.0;
//}

//vec3 smoothMax(vec3 v1, vec3 v2, float a) {
//	float v1Lum = getLum(v1);
//	float v2Lum = getLum(v2);
//	return (v1 + v2 + sqrt(pow2(v1 - v2) + a * (v1Lum + v2Lum) / 2.0)) / 2.0;
//}

float percentThrough(float v, float low, float high) {
	return clamp((v - low) / (high - low), 0.0, 1.0);
}

vec3 percentThrough(vec3 v, vec3 low, vec3 high) {
	return clamp((v - low) / (high - low), 0.0, 1.0);
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

// Thanks to Jessie (and Complementary) for dithering
float bayer2  (vec2 a) { a = 0.5 * floor(a); return fract(1.5 * fract(a.y) + a.x); }
float bayer4  (vec2 a) { return 0.25 * bayer2  (0.5 * a) + bayer2(a); }
float bayer8  (vec2 a) { return 0.25 * bayer4  (0.5 * a) + bayer2(a); }
float bayer16 (vec2 a) { return 0.25 * bayer8  (0.5 * a) + bayer2(a); }
float bayer32 (vec2 a) { return 0.25 * bayer16 (0.5 * a) + bayer2(a); }
float bayer64 (vec2 a) { return 0.25 * bayer32 (0.5 * a) + bayer2(a); }
float bayer128(vec2 a) { return 0.25 * bayer64 (0.5 * a) + bayer2(a); }
float bayer256(vec2 a) { return 0.25 * bayer128(0.5 * a) + bayer2(a); }

float pack_2x8(vec2 v) {
	return dot(floor(255.0 * v + 0.5), vec2(1.0 / 65535.0, 256.0 / 65535.0));
}
float pack_2x8(float x, float y) { return pack_2x8(vec2(x, y)); }

vec2 unpack_2x8(float pack) {
	vec2 xy; xy.x = modf((65535.0 / 256.0) * pack, xy.y);
	return xy * vec2(256.0 / 255.0, 1.0 / 255.0);
}

// octahedral encoding/decoding
vec2 encodeNormal(vec3 v) {
	v /= abs(v.x) + abs(v.y) + abs(v.z);
	v.xy = (v.z >= 0.0) ? v.xy : (1.0 - abs(v.yx)) * (vec2(v.x >= 0.0, v.y >= 0.0) * 2.0 - 1.0);
	return v.xy * 0.5 + 0.5;
}

vec3 decodeNormal(vec2 v) {
	vec2 f = v * 2.0 - 1.0;
	vec3 n = vec3(f, 1.0 - abs(f.x) - abs(f.y));
	float t = max(-n.z, 0.0);
	n.xy += vec2(n.x >= 0.0 ? -t : t, n.y >= 0.0 ? -t : t);
	return normalize(n);
}



vec4 startMat(vec3 pos) {
	return vec4(pos.xyz, 1.0);
}
vec3 endMat(vec4 pos) {
	return pos.xyz / pos.w;
}

vec3 transform(mat4 matrix, vec3 pos) {
	return mat3(matrix) * pos + matrix[3].xyz;
}

bool depthIsHand(float depth) {
	return depth < HAND_DEPTH;
}

void adjustLmcoord(inout vec2 lmcoord) {
	const float low = 0.0625;
	const float high = 0.95;
	lmcoord -= low;
	lmcoord /= high - low;
	lmcoord = clamp(lmcoord, 0.0, 1.0);
}



uint randomizeUint(inout uint rng) {
	#define ROTATE_RIGHT(value, shift) (value >> shift) | (value << (32u - shift))
	rng = rng * 747796405u + 2891336453u;
	rng ^= ROTATE_RIGHT(rng, 11u);
	rng ^= ROTATE_RIGHT(rng, 17u);
	rng ^= ROTATE_RIGHT(rng, 23u);
	return rng;
}

float randomFloat(inout uint rng) {
	uint v = randomizeUint(rng);
	const uint BIT_MASK = (2u << 16u) - 1u;
	float normalizedValue = float(v & BIT_MASK) / float(BIT_MASK);
	return normalizedValue * 2.0 - 1.0;
}

vec2 randomVec2(inout uint rng) {
	float x = randomFloat(rng);
	float y = randomFloat(rng);
	return vec2(x, y);
}

vec3 randomVec3(inout uint rng) {
	float x = randomFloat(rng);
	float y = randomFloat(rng);
	float z = randomFloat(rng);
	return vec3(x, y, z);
}

vec3 randomVec3FromRValue(uint rng) {
	return randomVec3(rng);
}

float valueHash(vec3 p) {
	p = fract(p * 0.3183099 + vec3(0.71, 0.113, 0.419));
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float valueNoise3(vec3 v) {
	vec3 i = floor(v);
	vec3 f = fract(v);
	
	float lll = valueHash(i);
	float llh = valueHash(i + vec3(0.0, 0.0, 1.0));
	float lhl = valueHash(i + vec3(0.0, 1.0, 0.0));
	float lhh = valueHash(i + vec3(0.0, 1.0, 1.0));
	float hll = valueHash(i + vec3(1.0, 0.0, 0.0));
	float hlh = valueHash(i + vec3(1.0, 0.0, 1.0));
	float hhl = valueHash(i + vec3(1.0, 1.0, 0.0));
	float hhh = valueHash(i + vec3(1.0, 1.0, 1.0));
	
	vec3 u = f * f * (3.0 - 2.0 * f);
	float ll = mix(lll, llh, u.z);
	float lh = mix(lhl, lhh, u.z);
	float hl = mix(hll, hlh, u.z);
	float hh = mix(hhl, hhh, u.z);
	float l = mix(ll, lh, u.y);
	float h = mix(hl, hh, u.y);
	return mix(l, h, u.x);
}



float cubeLength(vec2 v) {
	return pow(abs(v.x * v.x * v.x) + abs(v.y * v.y * v.y), 1.0 / 3.0);
}

float getDistortFactor(vec3 v) {
	return cubeLength(v.xy) + SHADOW_DISTORT_ADDITION;
}

vec3 distort(vec3 v, float distortFactor) {
	return vec3(v.xy / distortFactor, v.z * 0.5);
}

vec3 distort(vec3 v) {
	return distort(v, getDistortFactor(v));
}
