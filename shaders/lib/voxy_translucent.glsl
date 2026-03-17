#include "/lib/config.glsl"

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
#include "/lib/projection_utils_vx.glsl"
#include "/lib/dither.glsl"
// #include "/src/position_vertex_water.glsl"

#include "/lib/water_vx.glsl"

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

// checklist:
// color yes
// normals yes
// water texture yes (but mismatched) 
// vanilla-like no (i never liked the look of it anyway)
// absorption maybe?
// reflections yes (clouds don't reflect)
// sun reflection yes


layout(location = 0) out vec4 block_color;

void voxy_emitFragment(VoxyFragmentParameters param) {

	#include "/src/light_vertex_vx.glsl"
	
	vec3 real_light;

	vec4 position2 = vxModelView * worldPos;
	vec3 fragposition = position2.xyz;
	vec4 worldposition_pre = vxModelViewInv * position2; // also for waves?
	vec4 worldposition = worldposition_pre + vec4(cameraPosition.xyz, 0.0); // for waves

    #if AA_TYPE > 0
        float dither = shifted_r_dither(gl_FragCoord.xy);
    #else
        float dither = r_dither(gl_FragCoord.xy);
    #endif

    #ifdef VANILLA_WATER
        vec3 water_normal_base = vec3(0.0, 0.0, 1.0);
    #else
        // normal_waves (original not the neutered dh one)
		float speed = frameTimeCounter * .025;
		vec2 wave_1 =
		    texture2D(noisetex, ((worldposition.xz - worldposition.y * 0.2) * 0.05) + vec2(speed, speed)).rg;
		wave_1 = wave_1 - .5;
		vec2 wave_2 =
		    texture2D(noisetex, ((worldposition.xz - worldposition.y * 0.2) * 0.03125) - speed).rg;
		wave_2 = wave_2 - .5;
		vec2 wave_3 =
		    texture2D(noisetex, ((worldposition.xz - worldposition.y * 0.2) * 0.125) + vec2(speed, -speed)).rg;
		wave_3 = wave_3 - .5;
		wave_3 *= 0.66;

		vec2 partial_wave = wave_1 + wave_2 + wave_3;
		vec3 final_wave = vec3(partial_wave, WATER_TURBULENCE - (rainStrength * 0.6 * WATER_TURBULENCE * visible_sky));

        vec3 water_normal_base = normalize(final_wave);
    #endif
    
    	// get_normals; water_vx variables
		vec3 surface_normal;
		vec3 binormal = normalize(vxModelView[2].xyz);
		vec3 tangent = normalize(vxModelView[0].xyz);
					
		mat3 tbn_matrix = mat3(
			tangent.x, binormal.x, normal.x,
			tangent.y, binormal.y, normal.y,
			tangent.z, binormal.z, normal.z
		);
		
		float NdotE = abs(dot(normal, normalize(fragposition)));

		if(water_like == 1.0) {
			water_normal_base *= vec3(NdotE) + vec3(0.0, 0.0, 1.0 - NdotE);
			surface_normal = water_normal_base * tbn_matrix;
		} else {
			vec3 bump = vec3(0.0, 0.0, 1.0);
			bump *= vec3(NdotE) + vec3(0.0, 0.0, 1.0 - NdotE);
			surface_normal = bump * tbn_matrix;
		}
    //

    float normal_dot_eye = dot(surface_normal, normalize(fragposition));
    float fresnel = square_pow(1.0 + normal_dot_eye); // 

    vec3 reflect_water_vec = reflect(fragposition, surface_normal);
    vec3 norm_reflect_water_vec = normalize(reflect_water_vec);
    
    vec3 sky_color_reflect;
    	vec3 up_vec = normalize(vxModelView[1].xyz);
    	
    if(isEyeInWater == 0 || isEyeInWater == 2) {
        sky_color_reflect = mix(low_sky_color, hi_sky_color, sqrt(clamp(dot(norm_reflect_water_vec, up_vec), 0.0001, 1.0)));
    } else {
        sky_color_reflect = hi_sky_color * .5 * ((eyeBrightnessSmooth.y * .8 + 48) * 0.004166666666666667);
    }

    sky_color_reflect = xyz_to_rgb(sky_color_reflect);

	//  solid_dh_water_fragment.glsl 	
	if (water_like == 1) {
        #if WATER_TEXTURE == 1
            float water_texture = luma(param.sampledColour.rgb); // this has different brightness from the other thing?
        #else
            float water_texture = 1.0;
        #endif
        
        real_light = 
			omni_light +
			(direct_light_strength * visible_sky * direct_light_color) * (1.0 - rainStrength * 0.75) +
			candle_color;
			
        #if WATER_COLOR_SOURCE == 0
            block_color.rgb = water_texture * real_light * WATER_COLOR;
        #elif WATER_COLOR_SOURCE == 1
            block_color.rgb = 0.3 * water_texture * real_light * param.tinting.rgb;
        #endif

        block_color = vec4(refraction(fragposition, block_color.rgb, water_normal_base), 1.0);
        
        #if WATER_TEXTURE == 1
            fresnel = clamp(fresnel * (water_texture * water_texture + 0.5), 0.0, 1.0);
        #endif
        
		block_color.rgb = water_shader_vx(fragposition, surface_normal, block_color.rgb, sky_color_reflect, norm_reflect_water_vec, fresnel, visible_sky, direct_light_color, param.lightMap);
	} else {
		block_color = tint_color;
		float shadow_c = abs((light_mix * 2.0) - 1.0);

		real_light = 
			omni_light +
		    (direct_light_strength * shadow_c * direct_light_color) * (1.0 - rainStrength * 0.75) +
		    candle_color;

		block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125);
        //if(block_type > 1.5) {  // Glass
            block_color = cristal_shader(fragposition, normal, block_color, sky_color_reflect, fresnel * fresnel, visible_sky, dither, direct_light_color, param.lightMap);
        //}
    }
    
    #include "/src/position_vertex_vx.glsl"
    #include "/src/finalcolor_vx.glsl"
}
