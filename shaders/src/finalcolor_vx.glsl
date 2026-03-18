#ifdef NETHER
    #if NETHER_FOG_DISTANCE == 1
        block_color.rgb = mix(fogColor * 0.1, vec3(1.0), 0.04);
    #else
        block_color.rgb = mix(block_color.rgb, mix(fogColor * 0.1, vec3(1.0), 0.04), frog_adjust);
    #endif
#else
    #ifdef FOG_ACTIVE
        vec3 fog_texture = texture2D(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y)).rgb;
        block_color.rgb = mix(block_color.rgb, fog_texture, frog_adjust);
    #endif
#endif

#if MC_VERSION >= 11900
    if(blindness > .01 || darknessFactor > .01) {
        block_color.rgb = mix(block_color.rgb, vec3(0.0), max(blindness, darknessLightFactor) * fog_frag_coord * 0.24);
    }
#else
    if(blindness > .01) {
        block_color.rgb = mix(block_color.rgb, vec3(0.0), blindness * fog_frag_coord * 0.24);
    }
#endif
