vec4 position = vxModelViewInv * vxModelView * worldPos;

if(water_like == 1.0) {  // Water
    position.y -= 0.125;
}

// Fog intensity calculation
#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
    float fog_density_coeff = FOG_DENSITY * FOG_ADJUST;
#else
    float fog_density_coeff = day_blend_float(FOG_SUNSET, FOG_DAY, FOG_NIGHT) * FOG_ADJUST;
#endif

float fog_frag_coord = length(position.xyz);

#if !defined THE_END && !defined NETHER
    float fog_intensity_coeff = eyeBrightnessSmooth.y * 0.004166666666666667;
    float frog_adjust = pow(
        clamp(fog_frag_coord / (vxRenderDistance * 16), 0.0, 1.0) * fog_intensity_coeff,
        mix(fog_density_coeff * 0.15, 0.25, rainStrength)
    );
#else
    float frog_adjust = sqrt(clamp(fog_frag_coord / (vxRenderDistance * 16), 0.0, 1.0));
#endif
