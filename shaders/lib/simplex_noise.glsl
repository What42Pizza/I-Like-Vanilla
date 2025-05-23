//-----------------------------//
//        SIMPLEX NOISE        //
//-----------------------------//

// This code was taken from here: https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83



#ifdef FIRST_PASS

vec4 grad4(float j, vec4 ip) {
	const vec4 ones = vec4(1.0, 1.0, 1.0, -1.0);
	vec4 p,s;
	
	p.xyz = floor(fract (vec3(j) * ip.xyz) * 7.0) * ip.z - 1.0;
	p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
	s = vec4(lessThan(p, vec4(0.0)));
	p.xyz = p.xyz + (s.xyz*2.0 - 1.0) * s.www;
	
	return p;
}

float mod289(const float x) { return x - floor(x * (1. / 289.)) * 289.; }
vec2 mod289(const vec2 x) { return x - floor(x * (1. / 289.)) * 289.; }
vec3 mod289(const vec3 x) { return x - floor(x * (1. / 289.)) * 289.; }
vec4 mod289(const vec4 x) { return x - floor(x * (1. / 289.)) * 289.; }

float permute(const float x) { return mod289(((x * 34.0) + 1.0) * x); }
vec2 permute(const vec2 x) { return mod289(((x * 34.0) + 1.0) * x); }
vec3 permute(const vec3 x) { return mod289(((x * 34.0) + 1.0) * x); }
vec4 permute(const vec4 x) { return mod289(((x * 34.0) + 1.0) * x); }

float taylorInvSqrt(float r) {return 1.79284291400159 - 0.85373472095314 * r;}
vec4 taylorInvSqrt(vec4 r) {return 1.79284291400159 - 0.85373472095314 * r;}

float simplexNoise(vec2 v) {
	const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
						0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
						-0.577350269189626, // -1.0 + 2.0 * C.x
						0.024390243902439); // 1.0 / 41.0
	// First corner
	vec2 i  = floor(v + dot(v, C.yy) );
	vec2 x0 = v -   i + dot(i, C.xx);
	
	// Other corners
	vec2 i1;
	//i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
	//i1.y = 1.0 - i1.x;
	i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
	// x0 = x0 - 0.0 + 0.0 * C.xx ;
	// x1 = x0 - i1 + 1.0 * C.xx ;
	// x2 = x0 - 1.0 + 2.0 * C.xx ;
	vec4 x12 = x0.xyxy + C.xxzz;
	x12.xy -= i1;
	
	// Permutations
	i = mod289(i); // Avoid truncation effects in permutation
	vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
	+ i.x + vec3(0.0, i1.x, 1.0 ));
	
	vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
	m = m*m ;
	m = m*m ;
	
	// Gradients: 41 points uniformly over a line, mapped onto a diamond.
	// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)
	
	vec3 x = 2.0 * fract(p * C.www) - 1.0;
	vec3 h = abs(x) - 0.5;
	vec3 ox = floor(x + 0.5);
	vec3 a0 = x - ox;
	
	// Normalise gradients implicitly by scaling m
	// Approximation of: m *= inversesqrt( a0*a0 + h*h );
	m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
	
	// Compute final noise value at P
	vec3 g;
	g.x  = a0.x  * x0.x  + h.x  * x0.y;
	g.yz = a0.yz * x12.xz + h.yz * x12.yw;
	return 130.0 * dot(m, g);
}

float simplexNoise(vec3 v){ 
	const vec2 C = vec2(1.0/6.0, 1.0/3.0);
	const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);
	
	// first corner
	vec3 i = floor(v + dot(v, C.yyy));
	vec3 x0 = v - i + dot(i, C.xxx);
	
	// other corners
	vec3 g = step(x0.yzx, x0.xyz);
	vec3 l = 1.0 - g;
	vec3 i1 = min(g.xyz, l.zxy);
	vec3 i2 = max(g.xyz, l.zxy);
	
	// x0 = x0 - 0. + 0.0 * C 
	vec3 x1 = x0 - i1 + 1.0 * C.xxx;
	vec3 x2 = x0 - i2 + 2.0 * C.xxx;
	vec3 x3 = x0 - 1. + 3.0 * C.xxx;
	
	// permutations
	i = mod289(i); 
	vec4 p = permute(
		permute(
			permute(i.z + vec4(0.0, i1.z, i2.z, 1.0))
			+ i.y + vec4(0.0, i1.y, i2.y, 1.0)
		) 
		+ i.x + vec4(0.0, i1.x, i2.x, 1.0)
	);
	
	// gradients
	// (N*N points uniformly over a square, mapped onto an octahedron.)
	float n_ = 1.0/7.0; // N=7
	vec3 ns = n_ * D.wyz - D.xzx;
	
	vec4 j = p - 49.0 * floor(p * ns.z * ns.z); // mod(p,N*N)
	
	vec4 x_ = floor(j * ns.z);
	vec4 y_ = floor(j - 7.0 * x_); // mod(j,N)
	
	vec4 x = x_ *ns.x + ns.yyyy;
	vec4 y = y_ *ns.x + ns.yyyy;
	vec4 h = 1.0 - abs(x) - abs(y);
	
	vec4 b0 = vec4(x.xy, y.xy);
	vec4 b1 = vec4(x.zw, y.zw);
	
	vec4 s0 = floor(b0)*2.0 + 1.0;
	vec4 s1 = floor(b1)*2.0 + 1.0;
	vec4 sh = -step(h, vec4(0.0));
	
	vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy;
	vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww;
	
	vec3 p0 = vec3(a0.xy,h.x);
	vec3 p1 = vec3(a0.zw,h.y);
	vec3 p2 = vec3(a1.xy,h.z);
	vec3 p3 = vec3(a1.zw,h.w);
	
	// normalise gradients
	vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;
	
	// mix final noise value
	vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
	m = m * m;
	return 42.0 * dot(
		m*m,
		vec4(
			dot(p0,x0),
			dot(p1,x1),
			dot(p2,x2),
			dot(p3,x3)
		)
	);
}

float simplexNoise(vec4 v) {
	const vec4 C = vec4(
		0.138196601125011, // (5 - sqrt(5))/20 G4
		0.276393202250021, // 2 * G4
		0.414589803375032, // 3 * G4
		-0.447213595499958 // -1 + 4 * G4
	);
	
	// first corner
	vec4 i = floor(v + dot(v, vec4(.309016994374947451))); // (sqrt(5) - 1)/4
	vec4 x0 = v - i + dot(i, C.xxxx);
	
	// other corners
	
	// rank sorting originally contributed by Bill Licea-Kane, AMD (formerly ATI)
	vec4 i0;
	vec3 isX = step(x0.yzw, x0.xxx);
	vec3 isYZ = step(x0.zww, x0.yyz);
	// i0.x = dot(isX, vec3(1.0));
	i0.x = isX.x + isX.y + isX.z;
	i0.yzw = 1.0 - isX;
	// i0.y += dot(isYZ.xy, vec2(1.0));
	i0.y += isYZ.x + isYZ.y;
	i0.zw += 1.0 - isYZ.xy;
	i0.z += isYZ.z;
	i0.w += 1.0 - isYZ.z;
	
	// i0 now contains the unique values 0,1,2,3 in each channel
	vec4 i3 = clamp(i0, 0.0, 1.0);
	vec4 i2 = clamp(i0-1.0, 0.0, 1.0);
	vec4 i1 = clamp(i0-2.0, 0.0, 1.0);
	
	// x0 = x0 - 0.0 + 0.0 * C.xxxx
	// x1 = x0 - i1 + 1.0 * C.xxxx
	// x2 = x0 - i2 + 2.0 * C.xxxx
	// x3 = x0 - i3 + 3.0 * C.xxxx
	// x4 = x0 - 1.0 + 4.0 * C.xxxx
	vec4 x1 = x0 - i1 + C.xxxx;
	vec4 x2 = x0 - i2 + C.yyyy;
	vec4 x3 = x0 - i3 + C.zzzz;
	vec4 x4 = x0 + C.wwww;
	
	// permutations
	i = mod289(i);
	float j0 = permute(permute(permute(permute(i.w) + i.z) + i.y) + i.x);
	vec4 j1 = permute(
		permute(
			permute(
				permute(i.w + vec4(i1.w, i2.w, i3.w, 1.0))
				+ i.z + vec4(i1.z, i2.z, i3.z, 1.0)
			)
			+ i.y + vec4(i1.y, i2.y, i3.y, 1.0)
		)
		+ i.x + vec4(i1.x, i2.x, i3.x, 1.0)
	);
	
	// gradients: 7x7x6 points over a cube, mapped onto a 4-cross polytope
	// 7*7*6 = 294, which is close to the ring size 17*17 = 289.
	vec4 ip = vec4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0);
	
	vec4 p0 = grad4(j0, ip);
	vec4 p1 = grad4(j1.x, ip);
	vec4 p2 = grad4(j1.y, ip);
	vec4 p3 = grad4(j1.z, ip);
	vec4 p4 = grad4(j1.w, ip);
	
	// normalise gradients
	vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;
	p4 *= taylorInvSqrt(dot(p4,p4));
	
	// mix contributions from the five corners
	vec3 m0 = max(0.6 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
	vec2 m1 = max(0.6 - vec2(dot(x3,x3), dot(x4,x4)), 0.0);
	m0 = m0 * m0;
	m1 = m1 * m1;
	return 49.0 * (
		dot(
			m0*m0,
			vec3(dot(p0, x0), dot(p1, x1), dot(p2, x2))
		)
		+ dot(
			m1*m1,
			vec2(dot(p3, x3), dot(p4, x4))
		)
	);
}

vec3 simplexNoise3From4(vec4 x){
	float s = simplexNoise(vec4(x));
	float s1 = simplexNoise(vec4(x.y - 19.1 * 10, x.z + 33.4 * 10, x.x + 47.2 * 10, x.w + 65.4 * 10));
	float s2 = simplexNoise(vec4(x.z + 74.2 * 10, x.x - 124.5 * 10, x.y + 99.4 * 10, x.w + 113.4 * 10));
	return vec3(s, s1, s2);
}

vec2 simplexNoise2From3(vec3 x){
	float s = simplexNoise(vec3(x));
	float s1 = simplexNoise(vec3(x.y - 19.1 * 10, x.z + 33.4 * 10, x.x + 47.2 * 10));
	return vec2(s, s1);
}

#endif
