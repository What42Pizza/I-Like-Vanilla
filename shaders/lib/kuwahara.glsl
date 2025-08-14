// Code was taken from: https://github.com/PeterEve/godot-kuwahara

#ifdef FIRST_PASS
	// The coordinates of every point in a quadrant / kernel
	const int kernelLength = 30;
	const ivec2 kernel[kernelLength] = ivec2[kernelLength] (ivec2(-4, 5), ivec2(-3, 4), ivec2(-3, 5), ivec2(-2, 3), ivec2(-2, 4), ivec2(-2, 5), ivec2(-2, 6), ivec2(-1, 2), ivec2(-1, 3), ivec2(-1, 4), ivec2(-1, 5), ivec2(-1, 6), ivec2(0, 1), ivec2(0, 2), ivec2(0, 3), ivec2(0, 4), ivec2(0, 5), ivec2(0, 6), ivec2(1, 2), ivec2(1, 3), ivec2(1, 4), ivec2(1, 5), ivec2(1, 6), ivec2(2, 3), ivec2(2, 4), ivec2(2, 5), ivec2(2, 6), ivec2(3, 4), ivec2(3, 5), ivec2(4, 5));
	//const ivec2 kernel1[kernelLength] = ivec2[kernelLength] (ivec2(5, -4), ivec2(4, -3), ivec2(5, -3), ivec2(-2, 3), ivec2(-2, 4), ivec2(-2, 5), ivec2(-2, 6), ivec2(-1, 2), ivec2(-1, 3), ivec2(-1, 4), ivec2(-1, 5), ivec2(-1, 6), ivec2(0, 1), ivec2(0, 2), ivec2(0, 3), ivec2(0, 4), ivec2(0, 5), ivec2(0, 6), ivec2(1, 2), ivec2(1, 3), ivec2(1, 4), ivec2(1, 5), ivec2(1, 6), ivec2(2, 3), ivec2(2, 4), ivec2(2, 5), ivec2(2, 6), ivec2(3, 4), ivec2(3, 5), ivec2(4, 5));
#endif

// Get the mean color and standard deviation of a single quadrant around the current pixel
vec4 quadrant(sampler2D tex, int xDir, int yDir, vec2 sizeMult  ARGS_OUT) {
	vec3 pointTotal = vec3(0.0, 0.0, 0.0);
	
	float maxPoint = 0.0;
	float minPoint = 1000.0;
	for (int i = 0; i < kernelLength; i++) {
		// Apply the direction modifiers to the coordinate
		vec2 offset = (kernel[i] * ivec2(xDir, yDir)) * sizeMult;
		//offset = mat2(0.7071067812, -0.7071067812, 0.7071067812, 0.7071067812) * offset;
		vec3 point = texture2D(tex, texcoord + offset).xyz;
		
		// Changing this value calculation has interesting effects on the color groupings
		float value = max(max(point.x, point.y), point.z);
		pointTotal += point;
		maxPoint = max(maxPoint, value);
		minPoint = min(minPoint, value);
	}
	
	// Standard deviation can be quickly approximated and the loss of accuracy does not diminish the effect
	float standardDeviation = maxPoint - minPoint;
	
	// Return a vec4 to get round not being able to return structs or arrays
	return vec4(pointTotal.x, pointTotal.y, pointTotal.z, standardDeviation);
}

vec3 doKuwaharaEffect(sampler2D tex, float depth  ARGS_OUT) {
	
	#include "/import/invViewSize.glsl"
	vec2 sizeMult = KUWAHARA_SIZE * invViewSize;
	float blockDepth = toBlockDepth(depth  ARGS_IN);
	sizeMult *= 6.0 / pow(blockDepth, 0.4);
	
	// Get the mean and standard deviation of all quadrants around the current pixel (should be 4 elements but a weird sampling distribution bug seems to actually make it better)
	vec4 quadrants[2] = vec4[2] (
		quadrant(tex,  1, -1, sizeMult  ARGS_IN),
		quadrant(tex,  1,  1, sizeMult  ARGS_IN)
	);
	
	// Find the quadrant with the lowest standard deviation
	float minStandardDeviation = 1000.0;
	vec3 color = vec3(0.0, 0.0, 0.0);
	for (int i = 0; i <= 2; i++) {
		if (quadrants[i].a < minStandardDeviation) {
			minStandardDeviation = quadrants[i].a;
			color = quadrants[i].xyz;
		}
	}
	
	// Use the mean color of the lowest deviation quadrant
	return color / float(kernelLength);
}
