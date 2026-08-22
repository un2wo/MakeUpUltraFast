/* MakeUp - volumetric_clouds.glsl
Fast volumetric clouds - MakeUp implementation
*/

uniform int worldDay;

vec3 get_cloud(
	vec3 eye_direction, 
	vec3 block_color, 
	float bright, 
	float dither, 
	vec3 base_pos, 
	int samples, 
	float umbral, 
	vec3 cloud_color, 
	vec3 dark_cloud_color
) {
    #if VOL_LIGHT == 0
        block_color.rgb *= clamp(bright + ((dither - .5) * .1), 0.0, 1.0) * .3 + 1.0;
    #endif

    #if defined DISTANT_HORIZONS && defined DEFERRED_SHADER
        float d_dh = texture2D(dhDepthTex0, gl_FragCoord.xy / vec2(viewWidth, viewHeight)).r;
        float linear_d_dh = ld_dh(d_dh);
        if (linear_d_dh < 0.9999) {
            return block_color;
        }
    #endif

	float cloud_cover_mult = 1.0;
	#if V_CLOUDS > 1
		if (CLOUD_COVER == 0) {
			float cloud_seed0 = hash12(vec2(worldDay));
			float cloud_seed1 = hash12(vec2(worldDay + 1));
			cloud_cover_mult = mix(cloud_seed0, cloud_seed1, day_moment) * 0.40 + 0.60;
		} else {
			cloud_cover_mult = CLOUD_COVER;
		}
		cloud_cover_mult = mix(cloud_cover_mult, 1.0, rainStrength);
	#endif

    if (eye_direction.y > 0.0) {  // Over horizon
        float view_y_inv = 1.0 / eye_direction.y;

        float plane_distance_inf = CLOUD_PLANE * view_y_inv;
        vec3 intersection_pos = (eye_direction * plane_distance_inf) + base_pos;

        float plane_distance_sup = CLOUD_PLANE_SUP * view_y_inv;
        vec3 intersection_pos_sup = (eye_direction * plane_distance_sup) + base_pos;

        float dif_sup = CLOUD_PLANE_SUP - CLOUD_PLANE_CENTER;
        float dif_inf = CLOUD_PLANE_CENTER - CLOUD_PLANE;

        vec3 increment = (intersection_pos_sup - intersection_pos) / samples;

        float increment_dist = length(increment);

        float dist_aux_coeff = (CLOUD_PLANE_SUP - CLOUD_PLANE) * 0.075;
        float dist_aux_coeff_blur = dist_aux_coeff * 0.3;
        float opacity_dist = dist_aux_coeff * 2.0 * view_y_inv;

        float cloud_value = 0.0;
        float density = 0.0; // Inicializar
        bool first_contact = true;

        intersection_pos += (increment * dither);

        for (int i = 0; i < samples; i++) {
            float current_value = texture2D(gaux2, (intersection_pos.xz * 0.0002777777777777778) + (frameTimeCounter * CLOUD_HI_FACTOR)).r * cloud_cover_mult;

            #if V_CLOUDS == 3
                current_value += texture2D(gaux2, (intersection_pos.zx * 0.0002777777777777778) + (frameTimeCounter * CLOUD_LOW_FACTOR)).r * cloud_cover_mult;
                current_value = smoothstep(0.05, 0.95, current_value * 0.5);
            #endif

            current_value = (current_value - umbral) / (1.0 - umbral);

            float surface_inf = CLOUD_PLANE_CENTER + base_pos.y - (current_value * dif_inf);
            float surface_sup = CLOUD_PLANE_CENTER + base_pos.y + (current_value * dif_sup);

            float current_opacity = 0.0;
            float cloud_thickness = surface_sup - surface_inf;

            if (intersection_pos.y > surface_inf && intersection_pos.y < surface_sup) {
                // Dentro de la nube
                current_opacity = min(increment_dist, cloud_thickness);
            }
            else if (cloud_thickness > 0.0 && i > 0) {
                // Cerca del borde de la nube (desenfoque)
                float distance_aux = min(abs(intersection_pos.y - surface_inf), abs(intersection_pos.y - surface_sup));
                if (distance_aux < dist_aux_coeff_blur) {
                    float blur_factor = 1.0 - (distance_aux / dist_aux_coeff_blur);
                    current_opacity = min(blur_factor * increment_dist, cloud_thickness);
                }
            }
            if (current_opacity > 0.0) {
                cloud_value += current_opacity;
                if (first_contact) {
                    first_contact = false;
                    density = (surface_sup - intersection_pos.y) / (CLOUD_PLANE_SUP - CLOUD_PLANE);
                }
            }
            intersection_pos += increment;
        }

        cloud_value = clamp(cloud_value / opacity_dist, 0.0, 1.0);
        density = clamp(density, 0.0001, 1.0);

        float att_factor = mix(1.0, 0.75, bright * (1.0 - rainStrength));

        // --- OPTIMIZACIÓN: Reemplazar pow() por aproximaciones con sqrt() ---
        // pow(x, 0.25) es mucho más rápido y visualmente casi idéntico a pow(x, 0.3) o pow(x, 0.4)
        float density_approx = sqrt(sqrt(density)); // x^0.25

        #if CLOUD_VOL_STYLE == 1
            cloud_color = mix(cloud_color * att_factor, dark_cloud_color * att_factor, density_approx * 0.85);
        #else
            cloud_color = mix(cloud_color * att_factor, dark_cloud_color * att_factor, sqrt(density));
        #endif

        float cloud_value_approx = sqrt(sqrt(cloud_value));
        cloud_color = mix(cloud_color, cloud_color * 13.0, (1.0 - cloud_value_approx) * bright * bright * (1.0 - rainStrength));

        block_color = mix(block_color, cloud_color, cloud_value * clamp((eye_direction.y - 0.06) * 5.0, 0.0, 1.0));
    }

    return block_color;
}
