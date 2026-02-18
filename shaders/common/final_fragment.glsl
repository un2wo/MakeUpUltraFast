#include "/lib/config.glsl"

// Do not remove comments. It works!
/*

noisetex - Water normals
colortex0 - Blue noise
colortex1 - Antialiasing auxiliar
colortex2 - Clouds texture 2 
colortex3 - TAA Averages history
gaux1 - Screen-Space-Reflection / Bloom auxiliar
gaux2 - Clouds texture 1
gaux3 - Exposure auxiliar
gaux4 - Fog auxiliar

const int noisetexFormat = RG8;
const int colortex0Format = R8;
*/
#ifdef DOF
/*
const int colortex1Format = RGBA16F;
*/
#else
/*
const int colortex1Format = R11F_G11F_B10F;
*/
#endif
/*
const int colortex2Format = R8;
*/
#ifdef DOF
/*
const int colortex3Format = RGBA16F;
*/
#else
/*
const int colortex3Format = R11F_G11F_B10F;
*/
#endif
/*
const int gaux1Format = R11F_G11F_B10F;
const int gaux2Format = R8;
const int gaux3Format = R16F;
const int gaux4Format = R11F_G11F_B10F;

const int shadowcolor0Format = RGBA8;
*/

// Buffers clear
const bool colortex0Clear = false;
const bool colortex1Clear = false;
const bool colortex2Clear = false;
const bool colortex3Clear = false;
const bool gaux1Clear = false;
const bool gaux2Clear = false;
const bool gaux3Clear = false;
const bool gaux4Clear = false;

/* Uniforms */

#ifdef DEBUG_MODE
    uniform sampler2D shadowtex1;
    uniform sampler2D shadowcolor0;
    uniform sampler2D colortex3;
#endif

uniform sampler2D gaux3;
uniform sampler2D colortex1;
uniform float viewWidth;
uniform int isEyeInWater;

#if AA_TYPE == 3
    uniform float pixel_size_x;
    uniform float pixel_size_y;
#endif

/* Ins / Outs */

varying vec2 texcoord;
varying float exposure;

/* Utility functions */

#include "/lib/luma.glsl"

#ifdef DESATURATION
	#include "/lib/color_utils.glsl"
#endif

#if AA_TYPE == 3
    #include "/lib/post.glsl"
#endif

#include "/lib/basic_utils.glsl"
#include "/lib/tone_maps.glsl"

#ifdef COLOR_BLINDNESS
    #include "/lib/color_blindness.glsl"
#endif

#if CHROMA_ABER == 1
    #include "/lib/aberration.glsl"
#endif

// MAIN FUNCTION ------------------

void main() {
    #if CHROMA_ABER == 1
        vec3 block_color = color_aberration();
    #else
        vec3 block_color = texture2D(colortex1, texcoord).rgb;
        #if AA_TYPE == 3
            block_color = sharpen(colortex1, block_color, texcoord);
        #endif
    #endif

    #ifdef DESATURATION
        float actual_luma = luma(block_color);
    		
        // underwater tint
        #if WATER_COLOR_SOURCE == 1
        // the water fog currently takes from shader scheme even if resource pack color is requested; need fix?
            #define WATER_COLOR vec3(0.05, 0.11, 0.20)
		#endif
		vec3 underwater_tint = clamp(2.0 * WATER_COLOR / (WATER_COLOR.x + WATER_COLOR.y + WATER_COLOR.z), 0.0, 1.0);
		if (isEyeInWater == 1) {
			float luma_underwater = smoothstep(0.0, 0.2, actual_luma);
			block_color = mix(vec3(actual_luma) * luma_underwater, block_color, luma_underwater * (1 - underwater_tint) + underwater_tint);
		}
		
		// pseudo-purkinje; no real logic behind it, numbers are pretty arbitrary
		float luma_ground = smoothstep(0.0, 0.1, actual_luma);
		actual_luma *= luma_ground * 0.5 + 0.5;
		block_color.rgb = mix(vec3(actual_luma), block_color.rgb, luma_ground * vec3(0.4, 0.2, 0.1) + vec3(0.6, 0.8, 0.9));
    #endif

        block_color *= vec3(exposure);

    #if defined UNKNOWN_DIM
        block_color = custom_sigmoid_alt(block_color);
    #else
        block_color = custom_sigmoid(block_color);
    #endif

    // Color-grading -----
    // DEVELOPER: If your post processing effect only involves the current pixel,
    // it can be placed here. For example:

	// Contrast
	#if CONTRAST <== 1
		block_color = (block_color - 0.5) * CONTRAST + 0.5;
	#else
		block_color = adjustable_smoothstep(block_color, 0.5, CONTRAST);
	#endif
	
	// Brightness
	block_color *= BRIGHTNESS;

    // Saturation:
    // float actual_luma = luma(block_color);
    // block_color = mix(vec3(actual_luma), block_color, 1.5);

    // Color-blindness correction
    #ifdef COLOR_BLINDNESS
        block_color = color_blindness(block_color);
    #endif

    #ifdef DEBUG_MODE
        // vec3 block_color;
        if(texcoord.x < 0.5 && texcoord.y < 0.5) {
            block_color = texture2D(shadowtex1, texcoord * 2.0).rrr;
        } else if(texcoord.x >= 0.5 && texcoord.y >= 0.5) {
            block_color = vec3(texture2D(gaux3, vec2(0.5)).r * 0.25);
        } else if(texcoord.x < 0.5 && texcoord.y >= 0.5) {
            block_color = texture2D(colortex1, ((texcoord - vec2(0.0, 0.5)) * 2.0)).rgb;
        } else if(texcoord.x >= 0.5 && texcoord.y < 0.5) {
            block_color = texture2D(shadowcolor0, ((texcoord - vec2(0.5, 0.0)) * 2.0)).rgb;
        } else {
            block_color = vec3(0.5);
        }

        gl_FragData[0] = vec4(block_color, 1.0);

    #else
        gl_FragData[0] = vec4(block_color, 1.0);
    #endif
}
