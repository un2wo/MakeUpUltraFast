vec4 tint_color = param.sampledColour * param.tinting;

uint blockId = param.customId;
float foliage = float(blockId == 10031 || blockId == 10175 || blockId == 10176 || blockId == 10059 || blockId == 10032);
float leaves = float(blockId == 10018 || blockId == 10033 || blockId == 10106);
float emissive = float(blockId == 10089 || blockId == 10090);
float water_like = float(blockId == 10008);
float reflective = float(blockId == 10079);
float sand = float(blockId == 10410);
float metal = float(blockId == 10400);
float fabric = float(blockId == 10440);
uint face = param.face;

vec3 normal = vec3(uint((face>>1)==2), uint((face>>1)==0), uint((face>>1)==1)) * (float(int(face)&1)*2-1);
normal = mat3(vxModelView) * normal;

// 1. Reconstruir posición en clip space
vec2 ndc = (gl_FragCoord.xy / vec2(viewWidth, viewHeight)) * 2.0 - 1.0;
float depth = gl_FragCoord.z * 2.0 - 1.0;
vec4 clipPos = vec4(ndc, depth, 1.0);

// 2. Pasar a world space
vec4 worldPos = vxViewProjInv * clipPos;
worldPos /= worldPos.w; // replaces gl_Vertex

vec4 sub_position = vxModelView * worldPos;
vec3 sub_position3 = sub_position.xyz; // used by translucents & material gloss

#if defined THE_END || defined NETHER
    vec2 illumination = vec2(param.lightMap.x, 1.0);
#else
    vec2 illumination = param.lightMap;
#endif

illumination.y = (max(illumination.y, 0.065) - 0.065) * 1.06951871657754;
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

vec3 hi_sky_color;
vec3 hi_sky_color_rgb;
#include "/src/hi_sky.glsl"

vec3 direct_light_color = day_blend(
	LIGHT_SUNSET_COLOR,
	LIGHT_DAY_COLOR,
	LIGHT_NIGHT_COLOR
);

if (foliage == 1) {
	// direct_light_strength = clamp(direct_light_strength, 0.0, 1.0) * 0.3 + 0.5;
	direct_light_strength = 0.45;
} else if (leaves == 1) {
    direct_light_strength = clamp(direct_light_strength, 0.0, 1.0) + 0.2;
} else {
	direct_light_strength = clamp(direct_light_strength, 0.0, 1.0) * 0.95 + 0.05;
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
