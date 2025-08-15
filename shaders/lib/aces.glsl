// This code was taken from: https://github.com/selfshadow/ltc_code/blob/master/webgl/shaders/ltc/ltc_blit.fs (and has since been significantly modified)
// This file is distributed under a custom license:

// Copyright (c) 2017, Eric Heitz, Jonathan Dupuy, Stephen Hill and David Neubelt.
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
// * If you use (or adapt) the source code in your own work, please include a 
//   reference to the paper:
// 
//   Real-Time Polygonal-Light Shading with Linearly Transformed Cosines.
//   Eric Heitz, Jonathan Dupuy, Stephen Hill and David Neubelt.
//   ACM Transactions on Graphics (Proceedings of ACM SIGGRAPH 2016) 35(4), 2016.
//   Project page: https://eheitzresearch.wordpress.com/415-2/
// 
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// 
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



#ifdef FIRST_PASS

const mat3 ACES_INPUT_MATRIX = mat3(
	vec3(0.59719, 0.07600, 0.02840),
	vec3(0.35458, 0.90834, 0.13383),
	vec3(0.04823, 0.01566, 0.83777)
);

const mat3 ACES_OUTPUT_MATRIX = mat3(
	vec3( 1.60475, -0.10208, -0.00327),
	vec3(-0.53108,  1.10813, -0.07276),
	vec3(-0.07367, -0.00605,  1.07602)
);

vec3 rttAndOdtFit(vec3 v) {
	vec3 a = v * (v + 0.0245786) - 0.000090537;
	vec3 b = v * (v * 0.983729 + 0.4329510) + 0.238081;
	return a / b;
}

vec3 acesFitted(vec3 v) {
	v *= 1.5;
	v = ACES_INPUT_MATRIX * v;
	v = rttAndOdtFit(v);
	v = ACES_OUTPUT_MATRIX * v;
	v *= 1.3;
	return v;
}

#endif
