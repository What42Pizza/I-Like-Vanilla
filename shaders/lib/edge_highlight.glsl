float getEdgeHighlight(vec3 viewPos, vec3 playerPos, float depth, vec3 normal) {
	
	vec3 tangent = cross(normal, gbufferModelView[1].xyz);
	if (abs(tangent.x) + abs(tangent.y) + abs(tangent.z) < 0.01) {
		tangent = cross(normal, gbufferModelView[0].xyz);
	}
	tangent = normalize(tangent);
	vec3 bitangent = cross(tangent, normal);
	
	tangent /= EDGE_HIGHLIGHT_SIZE;
	bitangent /= EDGE_HIGHLIGHT_SIZE;
	
	vec4 screenPos4;
	vec3 screenPos;
	float testDepth;
	vec3 testNormal;
	
	bool isHighlight = false;
	
	vec3 worldNormal = mat3(gbufferModelViewInverse) * normal;
	vec3 absPlayerPos = abs(playerPos * worldNormal);
	float playerPosMax = max(absPlayerPos.x, max(absPlayerPos.y, absPlayerPos.z));
	float depthAddition = 1.0 / (1.0 + playerPosMax * 2.0) * 0.0005 + 0.000001;
	
	#define UPDATE_EDGE_HIGHLIGHT isHighlight = isHighlight || (testDepth > screenPos.z + depthAddition || (dot(normal, testNormal) < 0.1 && testDepth > screenPos.z + depthAddition * 0.25 && !depthIsHand(testDepth))) && (clamp(screenPos, 0.0, 1.0) == screenPos);
	
	screenPos4 = gbufferProjection * vec4(viewPos + tangent, 1.0);
	screenPos = screenPos4.xyz / screenPos4.w * 0.5 + 0.5;
	testDepth = texture2D(DEPTH_BUFFER_WO_TRANS, screenPos.xy).r;
	testNormal = decodeNormal(texelFetch(OPAQUE_DATA_TEXTURE, ivec2(screenPos.xy * viewSize), 0).zw);
	UPDATE_EDGE_HIGHLIGHT;
	
	screenPos4 = gbufferProjection * vec4(viewPos - tangent, 1.0);
	screenPos = screenPos4.xyz / screenPos4.w * 0.5 + 0.5;
	testDepth = texture2D(DEPTH_BUFFER_WO_TRANS, screenPos.xy).r;
	testNormal = decodeNormal(texelFetch(OPAQUE_DATA_TEXTURE, ivec2(screenPos.xy * viewSize), 0).zw);
	UPDATE_EDGE_HIGHLIGHT;
	
	screenPos4 = gbufferProjection * vec4(viewPos + bitangent, 1.0);
	screenPos = screenPos4.xyz / screenPos4.w * 0.5 + 0.5;
	testDepth = texture2D(DEPTH_BUFFER_WO_TRANS, screenPos.xy).r;
	testNormal = decodeNormal(texelFetch(OPAQUE_DATA_TEXTURE, ivec2(screenPos.xy * viewSize), 0).zw);
	UPDATE_EDGE_HIGHLIGHT;
	
	screenPos4 = gbufferProjection * vec4(viewPos - bitangent, 1.0);
	screenPos = screenPos4.xyz / screenPos4.w * 0.5 + 0.5;
	testDepth = texture2D(DEPTH_BUFFER_WO_TRANS, screenPos.xy).r;
	testNormal = decodeNormal(texelFetch(OPAQUE_DATA_TEXTURE, ivec2(screenPos.xy * viewSize), 0).zw);
	UPDATE_EDGE_HIGHLIGHT;
	
	return float(isHighlight);
}
