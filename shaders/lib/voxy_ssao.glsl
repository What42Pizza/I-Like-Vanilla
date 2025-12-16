float getVoxyAoAmount(vec3 normal) {
	float aoAmount = 1.0;
	
	float centerDepth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	if (centerDepth == 1.0) return 1.0;
	vec3 viewPos = screenToView(vec3(texcoord, centerDepth));
	vec3 blockPos = fract(mat3(vxModelViewInv) * viewPos + cameraPosition);
	float viewPosLen = length(viewPos);
	
	vec3 xDir = cross(normal, gbufferModelView[1].xyz);
	if (dot(xDir, xDir) < 0.001) xDir = cross(normal, gbufferModelView[2].xyz);
	xDir = normalize(xDir);
	vec3 yDir = normalize(cross(normal, xDir));
	xDir *= 0.75;
	yDir *= 0.75;
	
	vec4 plusXPos4 = vxProj * vec4(viewPos + xDir, 1.0);
	vec3 plusXPos = plusXPos4.xyz / plusXPos4.w * 0.5 + 0.5;
	float testPlusX = texture2D(DEPTH_BUFFER_ALL, plusXPos.xy).r;
	vec3 viewPosPlusX = screenToView(vec3(plusXPos.xy, testPlusX));
	float plusXAmount = uint(length(viewPosPlusX) < length(viewPos + xDir) - 0.25);
	plusXAmount *= 0.22 + dot(mat3(vxModelViewInv) * xDir, blockPos - 0.5);
	aoAmount *= 1.0 - plusXAmount;
	
	vec4 minusXPos4 = vxProj * vec4(viewPos - xDir, 1.0);
	vec3 minusXPos = minusXPos4.xyz / minusXPos4.w * 0.5 + 0.5;
	float testMinusX = texture2D(DEPTH_BUFFER_ALL, minusXPos.xy).r;
	vec3 viewPosMinusX = screenToView(vec3(minusXPos.xy, testMinusX));
	float minusXAmount = uint(length(viewPosMinusX) < length(viewPos - xDir) - 0.25);
	minusXAmount *= 0.22 + dot(mat3(vxModelViewInv) * -xDir, blockPos - 0.5);
	aoAmount *= 1.0 - minusXAmount;
	
	vec4 plusYPos4 = vxProj * vec4(viewPos + yDir, 1.0);
	vec3 plusYPos = plusYPos4.xyz / plusYPos4.w * 0.5 + 0.5;
	float testPlusY = texture2D(DEPTH_BUFFER_ALL, plusYPos.xy).r;
	vec3 viewPosPlusY = screenToView(vec3(plusYPos.xy, testPlusY));
	float plusYAmount = uint(length(viewPosPlusY) < length(viewPos + yDir) - 0.25);
	plusYAmount *= 0.22 + dot(mat3(vxModelViewInv) * yDir, blockPos - 0.5);
	aoAmount *= 1.0 - plusYAmount;
	
	vec4 minusYPos4 = vxProj * vec4(viewPos - yDir, 1.0);
	vec3 minusYPos = minusYPos4.xyz / minusYPos4.w * 0.5 + 0.5;
	float testMinusY = texture2D(DEPTH_BUFFER_ALL, minusYPos.xy).r;
	vec3 viewPosMinusY = screenToView(vec3(minusYPos.xy, testMinusY));
	float minusYAmount = uint(length(viewPosMinusY) < length(viewPos - yDir) - 0.25);
	minusYAmount *= 0.22 + dot(mat3(vxModelViewInv) * -yDir, blockPos - 0.5);
	aoAmount *= 1.0 - minusYAmount;
	
	aoAmount = 1.0 - aoAmount;
	aoAmount *= 1.0 - 0.5 * dot(normal, gbufferModelView[1].xyz);
	return aoAmount;
}
