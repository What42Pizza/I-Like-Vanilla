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
uniform float farPlusNear;
uniform float farMinusNear;
uniform float twoTimesNear;
uniform float invFar;
uniform float invFarMinusNear;
uniform float dhNearPlane;
uniform float dhFarPlane;
uniform int dhRenderDistance;
uniform mat4 vxModelViewInv;
uniform mat4 vxProj;
uniform mat4 vxProjInv;

uniform vec2 viewSize;
uniform vec2 pixelSize;
uniform float viewHeight;
uniform float viewWidth;
uniform float aspectRatio;
uniform float invAspectRatio;
uniform int frameCounter;
uniform float frameTime;
uniform float invFrameTime;
uniform float frameTimeCounter;
uniform float screenBrightness;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
#ifdef IS_IRIS
	uniform vec3 cameraPositionFract;
#else
	vec3 cameraPositionFract = fract(cameraPosition);
#endif
uniform float eyeAltitude;
uniform ivec2 atlasSize;

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

uniform vec4 entityColor;
uniform int entityId;
uniform float nightVision;
uniform float blindness;
uniform float darknessFactor;
uniform float darknessLightFactor;

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

uniform bool isSun;
uniform bool isOtherLightSource;
uniform float horizonAltitudeAddend;
uniform float blockFlickerAmount;
uniform float rainReflectionStrength;
uniform float inPaleGarden;
uniform float inSnowyBiome;
uniform float lightningFlashAmount;
uniform float betterRainStrength;
uniform float smoothPlayerHealth;
uniform float damageAmount;
uniform vec2 taaOffsetUniform;

#ifdef VSH
	attribute vec3 mc_Entity;
	attribute vec2 mc_midTexCoord;
	attribute vec4 at_tangent;
	attribute vec3 at_velocity;
	attribute vec3 at_midBlock;
#endif
