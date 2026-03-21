vec4 tint_color = param.sampledColour * param.tinting;

uint blockId = param.customId;
float foliage = float(blockId == 10031 || blockId == 10175 || blockId == 10176 || blockId == 10059 || blockId == 10032);
float leaves = float(blockId == 10018 || blockId == 10033 || blockId == 10106); // leaves / leaves_nw / vines
float emissive = float(blockId == 10089 || blockId == 10090);
float water_like = float(blockId == 10008);
float reflective = float(blockId == 10079);
float sand = float(blockId == 10410);
float metal = float(blockId == 10400);
float fabric = float(blockId == 10440);

vec3 normal = vec3(0.0); // this snippet is taken from BSL. thank you BSL. (sorry BSL)
switch (uint(param.face) >> 1u) {
	case 0u:
	normal = vxModelView[1].xyz;
	break;
	case 1u:
	normal = vxModelView[2].xyz;
	break;
	case 2u:
	normal = vxModelView[0].xyz;
	break;
}
if ((param.face & 1) == 0) {
	normal = -normal;
};

vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
vec4 iProjDiag = vec4(
	vxProjInv[0].x,
	vxProjInv[1].y,
	vxProjInv[2].zw
);
vec3 p3 = screenPos * 2.0 - 1.0;
vec4 viewPos_pre = iProjDiag * p3.xyzz + vxProjInv[3];
vec3 viewPos = viewPos_pre.xyz / viewPos_pre.w;
	
vec4 worldPos = vec4(mat3(vxModelViewInv) * viewPos + vxModelViewInv[3].xyz, 1.0); // replaces gl_Vertex
// end

vec4 sub_position = vxModelView * worldPos;
vec3 sub_position3 = sub_position.xyz; // used by translucents & material gloss

#if defined THE_END || defined NETHER
    vec2 illumination = vec2(param.lightMap.x, 1.0);
#else
    vec2 illumination = param.lightMap;
#endif

// illumination.y = (max(illumination.y, 0.065) - 0.065) * 1.06951871657754;
// float visible_sky = clamp(illumination.y, 0.0, 1.0);
float visible_sky = clamp(illumination.y * 1.03, 0.0, 1.0); // arbitrary number go!

vec3 candle_color = CANDLE_BASELIGHT * (pow(illumination.x, 1.5) + sixth_pow(illumination.x * 1.17));
candle_color = clamp(candle_color, vec3(0.0), vec3(4.0));

#if defined THE_END || defined NETHER
    vec3 sun_vec = normalize(vxModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
#else
    vec3 sun_vec = normalize(sunPosition);
#endif

float sun_light_strength;
if (length(normal) != 0.0) {
	normal = normalize(normal);
	sun_light_strength = dot(normal, sun_vec);
} else { // Workaround for undefined normals
	normal = vec3(0.0, 1.0, 0.0);
	sun_light_strength = 1.0;
}

#if defined THE_END || defined NETHER
    float direct_light_strength = sun_light_strength;
#else
	float direct_light_strength = mix(-sun_light_strength, sun_light_strength, light_mix);
#endif

float omni_strength = direct_light_strength * 0.125 + 1.0;

// these were uniforms but i had to recalc everything because it was stuck in sunset mode whyyyy
// now i've realized that the cause of this problem was because the uniforms were defined a second time in color_utils.glsl (idk why that's a problem)
// wrapping those with an #ifndef VOXY_PATCH fixed the issue, but for some reason, this only worked with voxy_translucent?
// even though both trans & opaque have the same includes?? even though VOXY_PATCH was defined after the includes in both???
float day_moment_a = hour_world * 0.04166666666666667;
float moment_aux_a = day_moment_a - 0.25;
float moment_aux_2_a = moment_aux_a * moment_aux_a;
float day_mixer_a = clamp(-moment_aux_2_a * 20.0 + 1.25, 0.0, 1.0);

float moment_aux_3_a = day_moment_a - 0.75;
float moment_aux_4_a = moment_aux_3_a * moment_aux_3_a;
float night_mixer_a = clamp(-moment_aux_4_a * 50.0 + 3.125, 0.0, 1.0);

vec3 day_color = mix(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, day_mixer_a);
vec3 night_color = mix(LIGHT_SUNSET_COLOR, LIGHT_NIGHT_COLOR, night_mixer_a);
vec3 direct_light_color = mix(day_color, night_color, step(0.5, day_moment_a));

vec3 day_color_sky = mix(ZENITH_SUNSET_COLOR, ZENITH_DAY_COLOR, day_mixer_a);
vec3 night_color_sky = mix(ZENITH_SUNSET_COLOR, ZENITH_NIGHT_COLOR, night_mixer_a);
vec3 hi_sky_color_rgb = mix(day_color_sky, night_color_sky, step(0.5, day_moment_a));
hi_sky_color_rgb = mix(hi_sky_color_rgb, ZENITH_SKY_RAIN_COLOR * luma(hi_sky_color_rgb), rainStrength);
vec3 hi_sky_color = rgb_to_xyz(hi_sky_color_rgb);

vec3 day_color_horz = mix(HORIZON_SUNSET_COLOR, HORIZON_DAY_COLOR, day_mixer_a);
vec3 night_color_horz = mix(HORIZON_SUNSET_COLOR, HORIZON_NIGHT_COLOR, night_mixer_a);
vec3 low_sky_color_rgb = mix(day_color_horz, night_color_horz, step(0.5, day_moment_a));
low_sky_color_rgb = mix(low_sky_color_rgb, HORIZON_SKY_RAIN_COLOR * luma(low_sky_color_rgb), rainStrength);
vec3 low_sky_color = rgb_to_xyz(low_sky_color_rgb);

//direct_light_color = day_blend(
//    LIGHT_SUNSET_COLOR,
//    LIGHT_DAY_COLOR,
//    LIGHT_NIGHT_COLOR
//);

if (foliage == 1) {
	direct_light_strength = clamp(direct_light_strength, 0.0, 1.0) * 0.3 + 0.5;
} else if (leaves == 1) {
    direct_light_strength = clamp(direct_light_strength, 0.0, 1.0) + 0.2;
} else {
	direct_light_strength = clamp(direct_light_strength, 0.0, 1.0);
}

#if defined THE_END || defined NETHER
    vec3 omni_light = LIGHT_DAY_COLOR;
#else
	direct_light_color = mix(
		direct_light_color,
		ZENITH_SKY_RAIN_COLOR * luma(direct_light_color) * 0.4,
		rainStrength
	);

	// minimal light
	vec3 omni_color = mix(hi_sky_color_rgb, direct_light_color * 0.45, OMNI_TINT);
	float omni_color_luma = color_average(omni_color);
	float luma_ratio = AVOID_DARK_LEVEL / omni_color_luma;
	vec3 omni_color_min = omni_color * luma_ratio;
	omni_color = max(omni_color, omni_color_min);

	vec3 omni_light = mix(omni_color_min, omni_color, visible_sky) * omni_strength;
#endif

#if !defined THE_END && !defined NETHER
	if (isEyeInWater == 0) {
		direct_light_strength = mix(0.0, direct_light_strength, pow(visible_sky, 10.0));
	} else {
		direct_light_strength = mix(0.0, direct_light_strength, visible_sky);
	}
#else
    direct_light_strength = mix(0.0, direct_light_strength, visible_sky);
#endif

if (emissive == 1) {
    direct_light_strength = 1.0;
}
