#ifdef FIRST_PASS
	in_out vec2 texcoord;
#endif



#ifdef FSH

void main() {
	vec4 color = texture2D(texture, texcoord);
	gl_FragData[0] = color;
}

#endif



#ifdef VSH

#if WAVING_ENABLED == 1
	#include "/lib/waving.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	#if EXCLUDE_FOLIAGE == 1 || PHYSICALLY_WAVING_WATER_ENABLED == 1
		#include "/import/mc_Entity.glsl"
		int materialId = int(mc_Entity.x);
		materialId %= 100000;
	#endif
	
	#if EXCLUDE_FOLIAGE == 1
		if (materialId >= 1000) {
			int shadowData = (materialId % 100 - materialId % 10) / 10;
			if (shadowData > 0) {
				gl_Position = vec4(1.0);
				return;
			}
		}
	#endif
	
	#if WAVING_ENABLED == 1 || PHYSICALLY_WAVING_WATER_ENABLED == 1
		#include "/import/shadowModelViewInverse.glsl"
		#include "/import/shadowProjectionInverse.glsl"
		vec3 playerPos = (shadowModelViewInverse * shadowProjectionInverse * ftransform()).xyz;
		#if WAVING_ENABLED == 1
			applyWaving(playerPos.xyz  ARGS_IN);
		#endif
		#if PHYSICALLY_WAVING_WATER_ENABLED == 1
			if (materialId == 9000) {
				float wavingAmount = PHYSICALLY_WAVING_WATER_AMOUNT_SURFACE;
				#ifdef DISTANT_HORIZONS
					float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y));
					#include "/import/far.glsl"
					wavingAmount *= smoothstep(far * 0.95 - 10, far * 0.9 - 10, lengthCylinder);
				#endif
				#include "/import/cameraPosition.glsl"
				playerPos += cameraPosition;
				#include "/import/frameTimeCounter.glsl"
				playerPos.y += (sin(playerPos.x * 0.6 + playerPos.z * 1.4 + frameTimeCounter * 3.0) * 0.5 - 0.5) * 0.03 * wavingAmount;
				playerPos.y += (sin(playerPos.x * 0.9 + playerPos.z * 0.6 + frameTimeCounter * 2.5) * 0.5 - 0.5) * 0.02 * wavingAmount;
				playerPos -= cameraPosition;
			}
		#endif
		applyWaving(playerPos  ARGS_IN);
		#include "/import/shadowProjection.glsl"
		#include "/import/shadowModelView.glsl"
		gl_Position = shadowProjection * shadowModelView * vec4(playerPos, 1.0);
	#else
		gl_Position = ftransform();
	#endif
	
	gl_Position.xyz = distort(gl_Position.xyz);
	
}

#endif
