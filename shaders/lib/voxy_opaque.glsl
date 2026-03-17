#include "/lib/config.glsl"

// most of the code is adapted from MakeUp's existing DH code.

/* Utility functions */
#include "/lib/color_utils.glsl"
#include "/lib/basic_utils.glsl"
#include "/lib/luma.glsl"

#define VOXY_PATCH

// for reference
// struct VoxyFragmentParameters {
//    vec4 sampledColour;
//    vec2 tile;
//    vec2 uv;
//    uint face;
//    uint modelId;
//    vec2 lightMap;
//    vec4 tinting;
//    uint customId;//Same as iris's modelId
// };

layout(location = 0) out vec4 block_color;

void voxy_emitFragment(VoxyFragmentParameters param) {
    
	#include "/src/light_vertex_vx.glsl"
	
	block_color = tint_color;
	float block_luma = luma(tint_color.rgb);
	vec3 final_candle_color = candle_color;
	float shadow_c = abs((light_mix * 2.0) - 1.0);    

	vec3 real_light =
		omni_light +
		(shadow_c * direct_light_color * direct_light_strength) * (1.0 - (rainStrength * 0.75)) +
		final_candle_color;

	block_color.rgb *= mix(real_light, vec3(1.0), nightVision * 0.125);
	block_color.rgb *= mix(vec3(1.0, 1.0, 1.0), vec3(NV_COLOR_R, NV_COLOR_G, NV_COLOR_B), nightVision);

	block_color.rgba = clamp(block_color, vec4(0.0), vec4(50.0));
    
    #include "/src/position_vertex_vx.glsl"
    #include "/src/finalcolor_vx.glsl"
}
