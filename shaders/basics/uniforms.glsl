uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferPreviousProjection;
uniform mat4 gbufferPreviousModelView;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 dhProjection;
uniform mat4 dhProjectionInverse;
uniform mat4 dhPreviousProjection;
uniform float near;
uniform float far;
uniform float dhNearPlane;
uniform float dhFarPlane;
uniform int dhRenderDistance;
uniform mat4 vxModelViewInv;
uniform mat4 vxProj;
uniform mat4 vxProjInv;

uniform float viewHeight;
uniform float viewWidth;
uniform float aspectRatio;
uniform int frameCounter;
uniform float frameTime;
uniform float frameTimeCounter;
uniform float screenBrightness;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform vec3 cameraPositionFract;
uniform ivec3 cameraPositionInt;
uniform float eyeAltitude;
uniform ivec2 atlasSize;
uniform int renderStage;

uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform vec3 shadowLightPosition;
uniform float sunAngle;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform ivec2 eyeBrightness;
uniform ivec2 eyeBrightnessSmooth;
uniform float rainStrength;
uniform float wetness;
uniform vec4 lightningBoltPosition;
uniform int isEyeInWater;
uniform int heldBlockLightValue;
uniform float cloudHeight;

uniform vec4 entityColor;
uniform int entityId;
uniform float nightVision;
uniform float blindness;
uniform float darknessFactor;
uniform float darknessLightFactor;



#ifdef MODERN_BACKEND

uniform float farPlusNear;
uniform float farMinusNear;
uniform float twoTimesNear;

uniform vec2 viewSize;
uniform vec2 pixelSize;

uniform float betterRainStrength;
uniform float rainReflectionStrength;

uniform bool isSun;

#if MC_VERSION >= 12102
	uniform float inPaleGarden;
#else
	const float inPaleGarden = 0.0;
#endif
uniform float inSnowyBiome;

uniform float lightningFlashAmount;

uniform float smoothPlayerHealth;
uniform float damageAmount;

uniform vec2 taaOffsetUniform;

uniform float sunLightBrightness;
uniform float moonLightBrightness;
uniform float sunriseColorPercent;
uniform float sunsetColorPercent;
uniform float sunNoonColorPercent;

uniform float ambientSunPercent;
uniform float ambientMoonPercent;
uniform float ambientSunrisePercent;
uniform float ambientSunsetPercent;

uniform float dayPercent;

uniform float blockFlickerAmount;

uniform float invAspectRatio;
uniform float invFrameTime;
uniform float invFar;
uniform float invFarMinusNear;

#else

float farPlusNear = far + near;
float farMinusNear = far - near;
float twoTimesNear = 2.0 * near;

vec2 viewSize = vec2(viewWidth, viewHeight);
vec2 pixelSize = vec2(1.0 / viewWidth, 1.0 / viewHeight);

float betterRainStrength = 1.0 - sqrt(1.0 - rainStrength);
float rainReflectionStrength = betterRainStrength;

bool isDay = sunAngle <= 0.5;
bool isOtherLightSource = shadowLightPosition.z > 0.0001;
bool isSun = (isDay && !isOtherLightSource) || (!isDay && isOtherLightSource);

const float inPaleGarden = 0.0;
const float inSnowyBiome = 0.0;

const float lightningFlashAmount = 0.0;

const float smoothPlayerHealth = 1.0;
const float damageAmount = 0.0;

float taaOffsetX = fract(1.3247179572 * frameCounter + 0.5) * 2.0 - 1.0;
float taaOffsetY = fract(1.7548776662 * frameCounter + 0.5) * 2.0 - 1.0;
vec2 taaOffsetUniform = vec2(taaOffsetX / viewWidth * TAA_JITTER_AMOUNT, taaOffsetY / viewHeight * TAA_JITTER_AMOUNT);

const float sunRiseStart = 0.0;
const float sunRiseEnd = 0.05;
const float sunSetStart = 0.45;
const float sunSetEnd = 0.5;
const float moonRiseStart = 0.55;
const float moonRiseEnd = 0.65;
const float moonSetStart = 0.85;
const float moonSetEnd = 0.95;

float sunLightBrightness = sunAngle >= sunRiseStart && sunAngle < sunRiseEnd ? pow((sunAngle - sunRiseStart) / (sunRiseEnd - sunRiseStart), 0.85) : sunAngle >= sunRiseEnd && sunAngle < sunSetStart ? 1.0 : sunAngle >= sunSetStart && sunAngle < sunSetEnd ? pow(1.0 - (sunAngle - sunSetStart) / (sunSetEnd - sunSetStart), 0.85) : 0.0;
float moonLightBrightness = sunAngle >= moonRiseStart && sunAngle < moonRiseEnd ? (sunAngle - moonRiseStart) / (moonRiseEnd - moonRiseStart) : sunAngle >= moonRiseEnd && sunAngle < moonSetStart ? 1.0 : sunAngle >= moonSetStart && sunAngle < moonSetEnd ? 1.0 - (sunAngle - moonSetStart) / (moonSetEnd - moonSetStart) : 0.0;

const float sunriseColorEnd = 0.1;
const float sunsetColorStart = 0.4;

float sunriseColorPercent = sunAngle >= sunRiseStart && sunAngle < sunriseColorEnd ? 1.0 - (sunAngle - sunRiseStart) / (sunriseColorEnd - sunRiseStart) : 0.0;
float sunsetColorPercent = sunAngle >= sunsetColorStart && sunAngle < sunSetEnd ? (sunAngle - sunsetColorStart) / (sunSetEnd - sunsetColorStart) : 0.0;
float sunNoonColorPercent = 1.0 - (sunriseColorPercent + sunsetColorPercent);

const float ambientSunriseStart = 0.94;
const float ambientSunriseEnd = 0.1;
const float ambientSunsetStart = 0.4;
const float ambientSunsetEnd = 0.56;

float ambientSunPercent = sunAngle >= 0.0 && sunAngle < ambientSunriseEnd ? (sunAngle - 0.0) / (ambientSunriseEnd - 0.0) : sunAngle >= ambientSunriseEnd && sunAngle < ambientSunsetStart ? 1.0 : sunAngle >= ambientSunsetStart && sunAngle < 0.5 ? 1.0 - (sunAngle - ambientSunsetStart) / (0.5 - ambientSunsetStart) : 0.0;
float rawAmbientMoonPercent = sunAngle >= 0.5 && sunAngle < ambientSunsetEnd ? pow((sunAngle - 0.5) / (ambientSunsetEnd - 0.5), 2) : sunAngle >= ambientSunsetEnd && sunAngle < ambientSunriseStart ? 1.0 : sunAngle >= ambientSunriseStart && sunAngle < 1.0 ? pow(1.0 - (sunAngle - ambientSunriseStart) / (1.0 - ambientSunriseStart), 2) : 0.0;
float ambientMoonPercent = 1.0 - (1.0 - rawAmbientMoonPercent) * (1.0 - rawAmbientMoonPercent) * (1.0 - rawAmbientMoonPercent);
float ambientSunrisePercent = sunAngle >= ambientSunriseStart && sunAngle < 1.0 ? 1.0 - ambientMoonPercent : sunAngle >= 0.0 && sunAngle < ambientSunriseEnd ? 1.0 - ambientSunPercent : 0.0;
float ambientSunsetPercent = sunAngle >= ambientSunsetStart && sunAngle < 0.5 ? 1.0 - ambientSunPercent : sunAngle >= 0.5 && sunAngle < ambientSunsetEnd ? 1.0 - ambientMoonPercent : 0.0;

float dayPercent = ambientSunPercent + (ambientSunrisePercent + ambientSunsetPercent) * 0.8;
const float blockFlickerAmount = 0.0;

float invAspectRatio = 1.0 / aspectRatio;
float invFrameTime = 1.0 / frameTime;
float invFar = 1.0 / far;
float invFarMinusNear = 1.0 / farMinusNear;

#endif



#ifdef VSH
	attribute vec3 mc_Entity;
	attribute vec2 mc_midTexCoord;
	attribute vec4 at_tangent;
	attribute vec3 at_velocity;
	attribute vec3 at_midBlock;
#endif
