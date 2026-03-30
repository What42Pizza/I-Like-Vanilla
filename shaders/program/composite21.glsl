/*
MIT License

Copyright (c) 2022 Lowell Camp

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
*/

// Note: any and all original edits to Lowell Camp's code here are dedicated to the public domain and are licensed under CC0 1.0 Universal (https://creativecommons.org/publicdomain/zero/1.0/)

// Source of code: https://github.com/camplowell/MC_shader_testing/blob/233719e9624cb7c40044fff8c9c457f1680e3a9e/shaders/lib/panini_projection.glsl



in_out vec2 texcoord;
in_out vec2 bl;
in_out vec2 br;
in_out vec2 tl;
in_out vec2 tr;
in_out mat2 cornerDepths;
in_out float panini_stereo_fac;



#ifdef FSH

vec2 panini(vec2 pos) {
	// Get our reference variables
	float depth_ref = mix(
		mix(cornerDepths[0][0], cornerDepths[1][0], pos.x),
		mix(cornerDepths[0][1], cornerDepths[1][1], pos.x),
		pos.y
	);
	float a = sqrt(depth_ref) * 0.25 * PANINI_PROJECTION_STRENGTH;
	// Map to unit cylinder
	vec3 cylinder = vec3(mix(mix(bl, br, pos.x), mix(tl, tr, pos.x), pos.y), 1.0);
	//cylinder /= length(cylinder.xz);
	float scaled_y = cylinder.y * panini_stereo_fac;
	cylinder *= inversesqrt(cylinder.x * cylinder.x + 1.0 + scaled_y * scaled_y);
	// Reproject from further back
	vec3 reprojected = cylinder - vec3(0, 0, a);
	reprojected *= (depth_ref - a) / reprojected.z;
	// Transform back into view space
	//return ndc2screen(view2ndc_p(cylinder)).xy;
	vec4 reprojectedScreen = gbufferProjection * vec4(reprojected + vec3(0, 0, a), 1.0);
	return reprojectedScreen.xy / reprojectedScreen.w * 0.5 + 0.5;
}

void main() {
	
	vec2 texcoord = panini(texcoord);
	
	#if PANINI_SAMPLING_METHOD == 1
		vec3 color = texture2D(MAIN_TEXTURE, texcoord).rgb;
	#elif PANINI_SAMPLING_METHOD == 2
		vec3 color = texelFetch(MAIN_TEXTURE, ivec2(texcoord * viewSize + 0.5), 0).rgb;
	#endif
	
	#if PANINI_SAMPLING_METHOD == 1
		vec3 blur = vec3(0.0);
		blur += texture2D(MAIN_TEXTURE, texcoord + vec2(-pixelSize.x, -pixelSize.y) * 2.0).rgb * (0.368 / 4.900);
		blur += texture2D(MAIN_TEXTURE, texcoord + vec2(-pixelSize.x,          0.0) * 2.0).rgb * (0.607 / 4.900);
		blur += texture2D(MAIN_TEXTURE, texcoord + vec2(-pixelSize.x,  pixelSize.y) * 2.0).rgb * (0.368 / 4.900);
		blur += texture2D(MAIN_TEXTURE, texcoord + vec2(         0.0, -pixelSize.y) * 2.0).rgb * (0.607 / 4.900);
		blur +=                                                                          color * (1.000 / 4.900);
		blur += texture2D(MAIN_TEXTURE, texcoord + vec2(         0.0,  pixelSize.y) * 2.0).rgb * (0.607 / 4.900);
		blur += texture2D(MAIN_TEXTURE, texcoord + vec2( pixelSize.x, -pixelSize.y) * 2.0).rgb * (0.368 / 4.900);
		blur += texture2D(MAIN_TEXTURE, texcoord + vec2( pixelSize.x,          0.0) * 2.0).rgb * (0.607 / 4.900);
		blur += texture2D(MAIN_TEXTURE, texcoord + vec2( pixelSize.x,  pixelSize.y) * 2.0).rgb * (0.368 / 4.900);
		color = mix(color, blur, -PANINI_SHARPENING_STILL - (PANINI_SHARPENING_MOVING - PANINI_SHARPENING_STILL) * float(cameraPosition != previousCameraPosition));
	#endif
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
}

#endif



#ifdef VSH

#include "/utils/projections.glsl"

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	panini_stereo_fac = abs(0.01 * gbufferModelView[1].z);
	
	vec3 bl_c = -screenToView(vec3(0, 0, 1));
	vec3 br_c = -screenToView(vec3(1, 0, 1));
	vec3 tl_c = -screenToView(vec3(0, 1, 1));
	vec3 tr_c = -screenToView(vec3(1, 1, 1));
	
	bl_c /= length(vec3(bl_c.xz, panini_stereo_fac * bl_c.y));
	br_c /= length(vec3(br_c.xz, panini_stereo_fac * bl_c.y));
	tl_c /= length(vec3(tl_c.xz, panini_stereo_fac * bl_c.y));
	tr_c /= length(vec3(tr_c.xz, panini_stereo_fac * bl_c.y));
	
	cornerDepths[0][0] = bl_c.z;
	cornerDepths[1][0] = br_c.z;
	cornerDepths[0][1] = tl_c.z;
	cornerDepths[1][1] = tr_c.z;
	
	bl = bl_c.xy / bl_c.z;
	br = br_c.xy / br_c.z;
	tl = tl_c.xy / tl_c.z;
	tr = tr_c.xy / tr_c.z;
	
}

#endif
