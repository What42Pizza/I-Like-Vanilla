float getVoxyAoAmount(vec3 normal) {
	float aoAmount = 1.0;
	
	float centerDepth = texelFetch(vxDepthTexOpaque, texelcoord, 0).r;
	if (centerDepth == 1.0) return 1.0;
	vec3 viewPos = screenToViewVx(vec3(texcoord, centerDepth));
	vec3 blockPos = fract(mat3(vxModelViewInv) * viewPos + cameraPosition);
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
	
	vec4 plusXPos4 = vxProj * vec4(viewPos + xDir, 1.0);
	vec3 plusXPos = plusXPos4.xyz / plusXPos4.w * 0.5 + 0.5;
	float testPlusX = texture2D(vxDepthTexOpaque, plusXPos.xy).r;
	vec3 viewPosPlusX = screenToViewVx(vec3(plusXPos.xy, testPlusX));
	float plusXAmount = uint(length(viewPosPlusX) < length(viewPos + xDir) * 0.999 - 0.25);
	plusXAmount *= 0.5 + dot(mat3(vxModelViewInv) * xDir, blockPos - 0.5);
	aoAmount *= 1.0 - plusXAmount;
	
	vec4 minusXPos4 = vxProj * vec4(viewPos - xDir, 1.0);
	vec3 minusXPos = minusXPos4.xyz / minusXPos4.w * 0.5 + 0.5;
	float testMinusX = texture2D(vxDepthTexOpaque, minusXPos.xy).r;
	vec3 viewPosMinusX = screenToViewVx(vec3(minusXPos.xy, testMinusX));
	float minusXAmount = uint(length(viewPosMinusX) < length(viewPos - xDir) * 0.999 - 0.25);
	minusXAmount *= 0.5 + dot(mat3(vxModelViewInv) * -xDir, blockPos - 0.5);
	aoAmount *= 1.0 - minusXAmount;
	
	vec4 plusYPos4 = vxProj * vec4(viewPos + yDir, 1.0);
	vec3 plusYPos = plusYPos4.xyz / plusYPos4.w * 0.5 + 0.5;
	float testPlusY = texture2D(vxDepthTexOpaque, plusYPos.xy).r;
	vec3 viewPosPlusY = screenToViewVx(vec3(plusYPos.xy, testPlusY));
	float plusYAmount = uint(length(viewPosPlusY) < length(viewPos + yDir) * 0.999 - 0.25);
	plusYAmount *= 0.5 + dot(mat3(vxModelViewInv) * yDir, blockPos - 0.5);
	aoAmount *= 1.0 - plusYAmount;
	
	vec4 minusYPos4 = vxProj * vec4(viewPos - yDir, 1.0);
	vec3 minusYPos = minusYPos4.xyz / minusYPos4.w * 0.5 + 0.5;
	float testMinusY = texture2D(vxDepthTexOpaque, minusYPos.xy).r;
	vec3 viewPosMinusY = screenToViewVx(vec3(minusYPos.xy, testMinusY));
	float minusYAmount = uint(length(viewPosMinusY) < length(viewPos - yDir) * 0.999 - 0.2);
	minusYAmount *= 0.5 + dot(mat3(vxModelViewInv) * -yDir, blockPos - 0.5);
	aoAmount *= 1.0 - minusYAmount;
	
	aoAmount = 1.0 - aoAmount;
	aoAmount *= 1.0 - 0.5 * dot(normal, gbufferModelView[1].xyz);
	return aoAmount;
}
