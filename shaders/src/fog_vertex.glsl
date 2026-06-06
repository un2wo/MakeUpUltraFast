float sight;
#if defined DISTANT_HORIZONS
    sight = dhRenderDistance;
#elif defined VOXY
	sight = vxRenderDistance * 16; 
#else
    sight = far;
#endif

#if !defined THE_END && !defined NETHER

    // Fog intensity calculation
    #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
        float fog_density_coeff = FOG_DENSITY * FOG_ADJUST;
    #else
        float fog_density_coeff = day_blend_float(
            FOG_SUNSET,
            FOG_DAY,
            FOG_NIGHT
        ) * FOG_ADJUST;
    #endif

    float fog_intensity_coeff = eye_bright_smooth.y * 0.004166666666666667;

	float frog_adjust_base = clamp(gl_FogFragCoord / sight, 0.0, 1.0) * fog_intensity_coeff;
    frog_adjust = pow(
		frog_adjust_base,
        mix(fog_density_coeff * 0.25, 0.25, rainStrength)
    ); // regular fog
	frog_adjust2 = pow(
	    frog_adjust_base,
        mix(fog_density_coeff, 1.0, rainStrength)
	); // border fog
#else
    #if defined NETHER && NETHER_FOG_DISTANCE == 1
        sight = NETHER_SIGHT;
    #endif
    frog_adjust = sqrt(clamp(gl_FogFragCoord / sight, 0.0, 1.0));
#endif
