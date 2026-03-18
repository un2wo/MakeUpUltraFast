#include "/lib/config.glsl"

// most of the code is adapted from MakeUp's existing DH code.

/* Utility functions */
#if defined THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif
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

#if defined MATERIAL_GLOSS && !defined NETHER
    #include "/lib/material_gloss_fragment.glsl"
#endif

layout(location = 0) out vec4 block_color;

void voxy_emitFragment(VoxyFragmentParameters param) {
    
	#include "/src/light_vertex_vx.glsl"
	
	block_color = tint_color;
	float block_luma = luma(tint_color.rgb);
	vec3 final_candle_color = candle_color;
	float shadow_c = abs((light_mix * 2.0) - 1.0);    

    #if defined MATERIAL_GLOSS && !defined NETHER
		vec4 sub_position = vxModelView * worldPos;
		vec3 sub_position3 = sub_position.xyz;
		
		float gloss_factor = 1.05;
		float gloss_power = 6.0;
		float luma_factor = 1.0;
		float luma_power = 2.0;

        if (sand == 1) {  // Sand-like block
            luma_power = 4.0;
        } else if (metal == 1) {  // Metal-like block
            luma_factor = 1.35;
            luma_power = -1.0;
            gloss_power = 100.0;
        } else if (fabric == 1) {  // Fabric-like blocks
            gloss_power = 3.0;
            gloss_factor = 0.1;
        }

        float final_gloss_power = gloss_power;
        block_luma *= luma_factor;

        if(luma_power < 0.0) {  // Metallic
            final_gloss_power -= (block_luma * 73.334);
        } else {
            block_luma = pow(block_luma, luma_power);
        }

        float material_gloss_factor = material_gloss(reflect(normalize(sub_position3), normal), param.lightMap, final_gloss_power, normal) * gloss_factor;

        float material = material_gloss_factor * block_luma;
        vec3 real_light =
			omni_light +
			(shadow_c * ((direct_light_color * direct_light_strength) + (direct_light_color * material))) * (1.0 - (rainStrength * 0.75)) +
			final_candle_color;
    #else
		vec3 real_light =
			omni_light +
			(shadow_c * direct_light_color * direct_light_strength) * (1.0 - (rainStrength * 0.75)) +
			final_candle_color;
	#endif

	block_color.rgb *= mix(real_light, vec3(1.0), nightVision * 0.125);
	block_color.rgb *= mix(vec3(1.0, 1.0, 1.0), vec3(NV_COLOR_R, NV_COLOR_G, NV_COLOR_B), nightVision);

	block_color.rgba = clamp(block_color, vec4(0.0), vec4(50.0));
    
    #include "/src/position_vertex_vx.glsl"
    #include "/src/finalcolor_vx.glsl"
}
