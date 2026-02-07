// these macros must be defined:
// - LOD_SCREEN_TO_VIEW_FN
// - LOD_DEPTH_TEX
// - LOD_MODEL_VIEW_INVERSE_MAT
// - LOD_PROJECTION_MAT

float getLodAoAmount(vec3 normal) {
	float aoAmount = 1.0;
	
	float centerDepth = texelFetch(LOD_DEPTH_TEX, texelcoord, 0).r;
	if (centerDepth == 1.0) return 1.0;
	vec3 viewPos = LOD_SCREEN_TO_VIEW_FN(vec3(texcoord, centerDepth));
	vec3 blockPos = fract(mat3(LOD_MODEL_VIEW_INVERSE_MAT) * viewPos + cameraPosition);
	float viewPosLen = length(viewPos);
	
	vec3 xDir = cross(normal, gbufferModelView[1].xyz);
	if (dot(xDir, xDir) < 0.001) xDir = cross(normal, gbufferModelView[2].xyz);
	xDir = normalize(xDir);
	vec3 yDir = normalize(cross(normal, xDir));
	xDir *= 0.55;
	yDir *= 0.55;
	
	float dither = bayer64(gl_FragCoord.xy);
	dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	viewPos += (xDir + yDir) * dither; // note: for some reason `dither - 0.5` looks worse?
	
	vec4 plusXPos4 = LOD_PROJECTION_MAT * vec4(viewPos + xDir, 1.0);
	vec3 plusXPos = plusXPos4.xyz / plusXPos4.w * 0.5 + 0.5;
	float testPlusX = texture2D(LOD_DEPTH_TEX, plusXPos.xy).r;
	vec3 viewPosPlusX = LOD_SCREEN_TO_VIEW_FN(vec3(plusXPos.xy, testPlusX));
	float plusXAmount = uint(length(viewPosPlusX) < length(viewPos + xDir) * 0.999 - 0.25);
	plusXAmount *= 0.5 + dot(mat3(LOD_MODEL_VIEW_INVERSE_MAT) * xDir, blockPos - 0.5);
	aoAmount *= 1.0 - plusXAmount;
	
	vec4 minusXPos4 = LOD_PROJECTION_MAT * vec4(viewPos - xDir, 1.0);
	vec3 minusXPos = minusXPos4.xyz / minusXPos4.w * 0.5 + 0.5;
	float testMinusX = texture2D(LOD_DEPTH_TEX, minusXPos.xy).r;
	vec3 viewPosMinusX = LOD_SCREEN_TO_VIEW_FN(vec3(minusXPos.xy, testMinusX));
	float minusXAmount = uint(length(viewPosMinusX) < length(viewPos - xDir) * 0.999 - 0.25);
	minusXAmount *= 0.5 + dot(mat3(LOD_MODEL_VIEW_INVERSE_MAT) * -xDir, blockPos - 0.5);
	aoAmount *= 1.0 - minusXAmount;
	
	vec4 plusYPos4 = LOD_PROJECTION_MAT * vec4(viewPos + yDir, 1.0);
	vec3 plusYPos = plusYPos4.xyz / plusYPos4.w * 0.5 + 0.5;
	float testPlusY = texture2D(LOD_DEPTH_TEX, plusYPos.xy).r;
	vec3 viewPosPlusY = LOD_SCREEN_TO_VIEW_FN(vec3(plusYPos.xy, testPlusY));
	float plusYAmount = uint(length(viewPosPlusY) < length(viewPos + yDir) * 0.999 - 0.25);
	plusYAmount *= 0.5 + dot(mat3(LOD_MODEL_VIEW_INVERSE_MAT) * yDir, blockPos - 0.5);
	aoAmount *= 1.0 - plusYAmount;
	
	vec4 minusYPos4 = LOD_PROJECTION_MAT * vec4(viewPos - yDir, 1.0);
	vec3 minusYPos = minusYPos4.xyz / minusYPos4.w * 0.5 + 0.5;
	float testMinusY = texture2D(LOD_DEPTH_TEX, minusYPos.xy).r;
	vec3 viewPosMinusY = LOD_SCREEN_TO_VIEW_FN(vec3(minusYPos.xy, testMinusY));
	float minusYAmount = uint(length(viewPosMinusY) < length(viewPos - yDir) * 0.999 - 0.2);
	minusYAmount *= 0.5 + dot(mat3(LOD_MODEL_VIEW_INVERSE_MAT) * -yDir, blockPos - 0.5);
	aoAmount *= 1.0 - minusYAmount;
	
	aoAmount = 1.0 - aoAmount;
	aoAmount *= 1.0 - 0.5 * dot(normal, gbufferModelView[1].xyz);
	return aoAmount;
}
