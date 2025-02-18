// optifine settings (DON'T DELETE)
/*
const int colortex2Format = RGBA32F;
const int colortex3Format = RGBA32F;
const float wetnessHalflife = 50.0f;
const float drynessHalflife = 50.0f;
const float centerDepthHalflife = 2.5f;
const bool shadowtex0Mipmap = false;
const bool shadowtex1Mipmap = false;
const bool shadowtex0Clear = false;
const bool shadowtex1Clear = false;
*/





// user settings

#define STYLE 0 // [0 1 2 3]

#include "/define_settings.glsl"

const int shadowMapResolution = 768; // [256 384 512 768 1024 1536 2048 3072 4096 6144 8192]
const float shadowDistance = 112.0; // [64.0 80.0 96.0 112.0 128.0 160.0 192.0 224.0 256.0 320.0 384.0 512.0 768.0 1024.0]
const float sunPathRotation = -30.0; // [-80.0 -75.0 -70.0 -65.0 -60.0 -55.0 -50.0 -45.0 -40.0 -35.0 -30.0 -25.0 -20.0 -15.0 -10.0 -9.0 -8.0 -7.0 -6.0 -5.0 -4.0 -3.0 -2.0 -1.0 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 65.0 70.0 75.0 80.0]
const float ambientOcclusionLevel = 1.0; // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
//#define SSS_BARREL





// style overrides

#if STYLE == 0
	#include "/style_vanilla.glsl"
#endif
#if STYLE == 1
	#include "/style_realistic.glsl"
#endif
#if STYLE == 2
	#include "/style_fantasy.glsl"
#endif
#if STYLE == 3
	#include "/style_cartoon.glsl"
#endif





// post-processed definitions



#ifdef NETHER
	#undef SHADOWS_ENABLED
	#define SHADOWS_ENABLED 0
	#undef DEPTH_SUNRAYS_ENABLED
	#define DEPTH_SUNRAYS_ENABLED 0
	#undef VOL_SUNRAYS_ENABLED
	#define VOL_SUNRAYS_ENABLED 0
#endif

#ifdef END
	#undef SHADOWS_ENABLED
	#define SHADOWS_ENABLED 0
	#undef DEPTH_SUNRAYS_ENABLED
	#define DEPTH_SUNRAYS_ENABLED 0
	#undef VOL_SUNRAYS_ENABLED
	#define VOL_SUNRAYS_ENABLED 0
#endif

#if SHADOWS_ENABLED == 0
	#undef VOL_SUNRAYS_ENABLED
	#define VOL_SUNRAYS_ENABLED 0
#endif

#ifdef DISTANT_HORIZONS
	#undef FOG_ENABLED
	#define FOG_ENABLED 0
#endif



#if SSS_PIXELS != 0
	#undef AA_STRATEGY
	#define AA_STRATEGY 0
	#undef SHARPENING_ENABLED
	#define SHARPENING_ENABLED 0
#endif

#if AA_STRATEGY == 2 || AA_STRATEGY == 3 || AA_STRATEGY == 4
	#define TAA_JITTER
#endif



#define BLOCK_COLOR vec3(BLOCK_RED, BLOCK_GREEN, BLOCK_BLUE)*BLOCK_BRIGHTNESS

#define CAVE_AMBIENT_COLOR vec3(CAVE_AMBIENT_RED, CAVE_AMBIENT_GREEN, CAVE_AMBIENT_BLUE)*CAVE_AMBIENT_BRIGHTNESS

#define NETHER_BLOCKLIGHT_MULT vec3(NETHER_BLOCKLIGHT_RED_MULT, NETHER_BLOCKLIGHT_GREEN_MULT, NETHER_BLOCKLIGHT_BLUE_MULT) * NETHER_BLOCKLIGHT_BRIGHTNESS_MULT



#define SKYLIGHT_DAY_COLOR vec3(SKYLIGHT_DAY_RED, SKYLIGHT_DAY_GREEN, SKYLIGHT_DAY_BLUE)*SKYLIGHT_DAY_BRIGHTNESS
#define AMBIENT_DAY_COLOR vec3(AMBIENT_DAY_RED, AMBIENT_DAY_GREEN, AMBIENT_DAY_BLUE)*AMBIENT_DAY_BRIGHTNESS

#define SKYLIGHT_NIGHT_COLOR vec3(SKYLIGHT_NIGHT_RED, SKYLIGHT_NIGHT_GREEN, SKYLIGHT_NIGHT_BLUE)*SKYLIGHT_NIGHT_BRIGHTNESS
#define AMBIENT_NIGHT_COLOR vec3(AMBIENT_NIGHT_RED, AMBIENT_NIGHT_GREEN, AMBIENT_NIGHT_BLUE)*AMBIENT_NIGHT_BRIGHTNESS

#define SKYLIGHT_SUNRISE_COLOR vec3(SKYLIGHT_SUNRISE_RED, SKYLIGHT_SUNRISE_GREEN, SKYLIGHT_SUNRISE_BLUE)*SKYLIGHT_SUNRISE_BRIGHTNESS
#define AMBIENT_SUNRISE_COLOR vec3(AMBIENT_SUNRISE_RED, AMBIENT_SUNRISE_GREEN, AMBIENT_SUNRISE_BLUE)*AMBIENT_SUNRISE_BRIGHTNESS

#define SKYLIGHT_SUNSET_COLOR vec3(SKYLIGHT_SUNSET_RED, SKYLIGHT_SUNSET_GREEN, SKYLIGHT_SUNSET_BLUE)*SKYLIGHT_SUNSET_BRIGHTNESS
#define AMBIENT_SUNSET_COLOR vec3(AMBIENT_SUNSET_RED, AMBIENT_SUNSET_GREEN, AMBIENT_SUNSET_BLUE)*AMBIENT_SUNSET_BRIGHTNESS



#define WATER_REFLECTION_CONSTANT (WATER_REFLECTION_AMOUNT * (1.0 - WATER_REFLECTION_FRESNEL))
#define WATER_REFLECTION_VARIABLE (WATER_REFLECTION_AMOUNT * WATER_REFLECTION_FRESNEL)
#define WATER_REFLECTION_STRENGTHS vec2(WATER_REFLECTION_CONSTANT, WATER_REFLECTION_VARIABLE)

#define RAIN_REFLECTION_CONSTANT (RAIN_REFLECTION_AMOUNT * (1.0 - RAIN_REFLECTION_FRESNEL))
#define RAIN_REFLECTION_VARIABLE (RAIN_REFLECTION_AMOUNT * RAIN_REFLECTION_FRESNEL)
#define RAIN_REFLECTION_STRENGTHS vec2(RAIN_REFLECTION_CONSTANT, RAIN_REFLECTION_VARIABLE)



#define SUNRAYS_SUN_COLOR vec3(SUNRAYS_SUN_RED, SUNRAYS_SUN_GREEN, SUNRAYS_SUN_BLUE)
#define SUNRAYS_MOON_COLOR vec3(SUNRAYS_MOON_RED, SUNRAYS_MOON_GREEN, SUNRAYS_MOON_BLUE)



#define CONTRAST_DETECT_COLOR vec3(CONTRAST_DETECT_RED, CONTRAST_DETECT_GREEN, CONTRAST_DETECT_BLUE)



#define HSV_POSTERIZE_QUALITY vec3(HSV_POSTERIZE_HUE_QUALITY, HSV_POSTERIZE_SATURATION_QUALITY, HSV_POSTERIZE_BRIGHTNESS_QUALITY)





// misc

#define LIGHT_SMOOTHING 0.1

const float SHADOW_OFFSET_INCREASE = 1.3 / shadowMapResolution;
const float SHADOW_OFFSET_MIN = 1.1 / pow(shadowMapResolution, 0.95);
