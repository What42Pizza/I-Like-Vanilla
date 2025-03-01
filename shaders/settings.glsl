// optifine settings (DON'T DELETE)
/*
const bool  colortex0Clear        = false;
const bool  colortex1Clear        = false;
const int   colortex2Format       = RGB32F;
const bool  colortex2Clear        = false;
const int   colortex3Format       = RGB32F;
const bool  colortex4Clear        = false;
const bool  colortex5Clear        = false;
const bool  colortex6Clear        = false;
const bool  shadowtex0Mipmap      = false;
const bool  shadowtex0Clear       = false;
const bool  shadowtex1Mipmap      = false;
const bool  shadowtex1Clear       = false;
const float wetnessHalflife       = 50.0f;
const float drynessHalflife       = 50.0f;
const float centerDepthHalflife   = 2.5f;
const float eyeBrightnessHalflife = 3.0f;
*/





// settings basics

#include "/setting_defines.glsl"

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
	#undef DEPTH_SUNRAYS_ENABLED
	#define DEPTH_SUNRAYS_ENABLED 0
	#undef VOL_SUNRAYS_ENABLED
	#define VOL_SUNRAYS_ENABLED 0
#endif

#ifdef END
	#undef SHADOWS_ENABLED
	#undef DEPTH_SUNRAYS_ENABLED
	#define DEPTH_SUNRAYS_ENABLED 0
	#undef VOL_SUNRAYS_ENABLED
	#define VOL_SUNRAYS_ENABLED 0
#endif

#ifndef SHADOWS_ENABLED
	#undef VOL_SUNRAYS_ENABLED
	#define VOL_SUNRAYS_ENABLED 0
#endif

#ifdef DISTANT_HORIZONS
	#undef BORDER_FOG_ENABLED
	#define BORDER_FOG_ENABLED 0
#endif



#if SSS_PIXELS != 0
	#undef TAA_ENABLED
	#undef FXAA_ENABLED
	#undef SHARPENING_ENABLED
#endif



#define BLOCK_COLOR vec3(BLOCK_RED, BLOCK_GREEN, BLOCK_BLUE)*BLOCK_BRIGHTNESS
#define CAVE_AMBIENT_COLOR vec3(CAVE_AMBIENT_RED, CAVE_AMBIENT_GREEN, CAVE_AMBIENT_BLUE)*CAVE_AMBIENT_BRIGHTNESS
#define NETHER_BLOCKLIGHT_MULT vec3(NETHER_BLOCKLIGHT_RED_MULT, NETHER_BLOCKLIGHT_GREEN_MULT, NETHER_BLOCKLIGHT_BLUE_MULT) * NETHER_BLOCKLIGHT_BRIGHTNESS_MULT
#define WATER_COLOR vec3(WATER_COLOR_RED, WATER_COLOR_GREEN, WATER_COLOR_BLUE)

#define SKYLIGHT_DAY_COLOR vec3(SKYLIGHT_DAY_RED, SKYLIGHT_DAY_GREEN, SKYLIGHT_DAY_BLUE)*SKYLIGHT_DAY_BRIGHTNESS
#define AMBIENT_DAY_COLOR vec3(AMBIENT_DAY_RED, AMBIENT_DAY_GREEN, AMBIENT_DAY_BLUE)*AMBIENT_DAY_BRIGHTNESS

#define SKYLIGHT_NIGHT_COLOR vec3(SKYLIGHT_NIGHT_RED, SKYLIGHT_NIGHT_GREEN, SKYLIGHT_NIGHT_BLUE)*SKYLIGHT_NIGHT_BRIGHTNESS
#define AMBIENT_NIGHT_COLOR vec3(AMBIENT_NIGHT_RED, AMBIENT_NIGHT_GREEN, AMBIENT_NIGHT_BLUE)*AMBIENT_NIGHT_BRIGHTNESS

#define SKYLIGHT_SUNRISE_COLOR vec3(SKYLIGHT_SUNRISE_RED, SKYLIGHT_SUNRISE_GREEN, SKYLIGHT_SUNRISE_BLUE)*SKYLIGHT_SUNRISE_BRIGHTNESS
#define AMBIENT_SUNRISE_COLOR vec3(AMBIENT_SUNRISE_RED, AMBIENT_SUNRISE_GREEN, AMBIENT_SUNRISE_BLUE)*AMBIENT_SUNRISE_BRIGHTNESS

#define SKYLIGHT_SUNSET_COLOR vec3(SKYLIGHT_SUNSET_RED, SKYLIGHT_SUNSET_GREEN, SKYLIGHT_SUNSET_BLUE)*SKYLIGHT_SUNSET_BRIGHTNESS
#define AMBIENT_SUNSET_COLOR vec3(AMBIENT_SUNSET_RED, AMBIENT_SUNSET_GREEN, AMBIENT_SUNSET_BLUE)*AMBIENT_SUNSET_BRIGHTNESS

#define SUNRAYS_SUN_COLOR vec3(SUNRAYS_SUN_RED, SUNRAYS_SUN_GREEN, SUNRAYS_SUN_BLUE)
#define SUNRAYS_MOON_COLOR vec3(SUNRAYS_MOON_RED, SUNRAYS_MOON_GREEN, SUNRAYS_MOON_BLUE)

#define CONTRAST_DETECT_COLOR vec3(CONTRAST_DETECT_RED, CONTRAST_DETECT_GREEN, CONTRAST_DETECT_BLUE)
#define HSV_POSTERIZE_QUALITY vec3(HSV_POSTERIZE_HUE_QUALITY, HSV_POSTERIZE_SATURATION_QUALITY, HSV_POSTERIZE_BRIGHTNESS_QUALITY)





// misc

const float SHADOW_OFFSET_INCREASE = 1.3 / shadowMapResolution;
const float SHADOW_OFFSET_MIN = 1.1 / pow(shadowMapResolution, 0.95);

// use settings so iris/optifine can detect (not always needed but nice to have just in case)
#ifdef SHADOWS_ENABLED
#endif
#ifdef TAA_ENABLED
#endif
#ifdef FXAA_ENABLED
#endif
#ifdef BLOOM_ENABLED
#endif
#ifdef REFLECTIONS_ENABLED
#endif
#ifdef SHARPENING_ENABLED
#endif
#ifdef SSAO_ENABLED
#endif
#ifdef USE_BETTER_RAND
#endif
#ifdef SHOW_DANGEROUS_LIGHT
#endif
#ifdef SSS_BARREL
#endif
