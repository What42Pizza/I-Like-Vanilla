#version 330 compatibility

#define SHADER_GBUFFERS_ARMOR_GLINT
#define NETHER
#define VSH

#include "/settings.glsl"
#include "/common.glsl"



#define FIRST_PASS
#define ARGS_IN , false
#define ARGS_OUT , bool dummy
#define ARG_IN false
#define ARG_OUT bool dummy
#define main dummy_main
#include "/program/gbuffers_armor_glint.glsl"
#undef main
#undef FIRST_PASS
#undef ARGS_IN
#undef ARGS_OUT
#undef ARG_IN
#undef ARG_OUT

#include "/import/switchboard.glsl"

#define SECOND_PASS
#define ARGS_IN
#define ARGS_OUT
#define ARG_IN
#define ARG_OUT
#include "/program/gbuffers_armor_glint.glsl"
