/* MakeUp - color_utils.glsl
Usefull data for color manipulation.

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifndef VOXY_PATCH
	uniform float day_moment;
	uniform float day_mixer;
	uniform float night_mixer;
#endif

#if END_SCHEME == 0  // Legacy
    #define OMNI_TINT 0.5

    #define LIGHT_SUNSET_COLOR vec3(0.1023825, 0.082467, 0.1023825)
    #define LIGHT_DAY_COLOR vec3(0.1023825, 0.082467, 0.1023825)
    #define LIGHT_NIGHT_COLOR vec3(0.1023825, 0.082467, 0.1023825)
    
    #define ZENITH_SUNSET_COLOR vec3(0.0465375, 0.037485, 0.0465375)
    #define ZENITH_DAY_COLOR vec3(0.0465375, 0.037485, 0.0465375)
    #define ZENITH_NIGHT_COLOR vec3(0.0465375, 0.037485, 0.0465375)
    
    #define HORIZON_SUNSET_COLOR vec3(0.0465375, 0.037485, 0.0465375)
    #define HORIZON_DAY_COLOR vec3(0.0465375, 0.037485, 0.0465375)
    #define HORIZON_NIGHT_COLOR vec3(0.0465375, 0.037485, 0.0465375)
    
    #define WATER_COLOR vec3(0.01647059, 0.13882353, 0.16470588)
#elif END_SCHEME == 1  // Nebula
	#define OMNI_TINT 0.55

	#define LIGHT_SUNSET_COLOR vec3(0.30, 0.20, 0.35)
	#define LIGHT_DAY_COLOR vec3(0.30, 0.20, 0.35)
	#define LIGHT_NIGHT_COLOR vec3(0.30, 0.20, 0.35)

	#define ZENITH_SUNSET_COLOR vec3(0.04, 0.015, 0.05)
	#define ZENITH_DAY_COLOR vec3(0.04, 0.015, 0.05)
	#define ZENITH_NIGHT_COLOR vec3(0.04, 0.015, 0.05)

	#define HORIZON_SUNSET_COLOR vec3(0.0)
	#define HORIZON_DAY_COLOR vec3(0.0)
	#define HORIZON_NIGHT_COLOR vec3(0.0)

	#define WATER_COLOR vec3(0.05, 0.11, 0.20)
#elif END_SCHEME == 2  // Tempest
	#define OMNI_TINT 0.25

	#define LIGHT_SUNSET_COLOR vec3(0.010, 0.016, 0.015)
	#define LIGHT_DAY_COLOR LIGHT_SUNSET_COLOR
	#define LIGHT_NIGHT_COLOR LIGHT_SUNSET_COLOR

	#define ZENITH_SUNSET_COLOR vec3(0.025, 0.042, 0.04)
	#define ZENITH_DAY_COLOR ZENITH_SUNSET_COLOR
	#define ZENITH_NIGHT_COLOR ZENITH_SUNSET_COLOR

	#define HORIZON_SUNSET_COLOR vec3(0.0)
	#define HORIZON_DAY_COLOR vec3(0.0)
	#define HORIZON_NIGHT_COLOR vec3(0.0)

    #define WATER_COLOR vec3(0.05, 0.1, 0.1)
#elif END_SCHEME == 3  // Dust
	#define OMNI_TINT 0.5

	#define LIGHT_SUNSET_COLOR vec3(0.07, 0.08, 0.10)
	#define LIGHT_DAY_COLOR vec3(0.07, 0.08, 0.10)
	#define LIGHT_NIGHT_COLOR vec3(0.07, 0.08, 0.10)

	#define ZENITH_SUNSET_COLOR vec3(0.02, 0.02, 0.02)
	#define ZENITH_DAY_COLOR vec3(0.02, 0.02, 0.02)
	#define ZENITH_NIGHT_COLOR vec3(0.02, 0.02, 0.02)

	#define HORIZON_SUNSET_COLOR vec3(0.0)
	#define HORIZON_DAY_COLOR vec3(0.0)
	#define HORIZON_NIGHT_COLOR vec3(0.0)

    #define WATER_COLOR vec3(0.05, 0.05, 0.05)
#elif END_SCHEME == 4  // Eternal
	#define OMNI_TINT 0.25

	#define LIGHT_SUNSET_COLOR vec3(0.30)
	#define LIGHT_DAY_COLOR vec3(0.30)
	#define LIGHT_NIGHT_COLOR vec3(0.30)

	#define ZENITH_SUNSET_COLOR vec3(1.50)
	#define ZENITH_DAY_COLOR vec3(1.50)
	#define ZENITH_NIGHT_COLOR vec3(1.50)

	#define HORIZON_SUNSET_COLOR vec3(0.0)
	#define HORIZON_DAY_COLOR vec3(0.0)
	#define HORIZON_NIGHT_COLOR vec3(0.0)

	#define WATER_COLOR vec3(0.04, 0.09, 0.10)
#elif END_SCHEME == 5  // Vanillin
	#define OMNI_TINT 0.25

	#define LIGHT_SUNSET_COLOR vec3(0.100, 0.113, 0.110)
	#define LIGHT_DAY_COLOR vec3(0.100, 0.113, 0.110)
	#define LIGHT_NIGHT_COLOR vec3(0.100, 0.113, 0.110)

	#define ZENITH_SUNSET_COLOR vec3(0.040, 0.030, 0.045)
	#define ZENITH_DAY_COLOR vec3(0.040, 0.030, 0.045)
	#define ZENITH_NIGHT_COLOR vec3(0.040, 0.030, 0.045)

	#define HORIZON_SUNSET_COLOR vec3(0.0)
	#define HORIZON_DAY_COLOR vec3(0.0)
	#define HORIZON_NIGHT_COLOR vec3(0.0)

	#define WATER_COLOR vec3(0.05, 0.11, 0.20)
#endif

#if BLOCKLIGHT_TEMP == 0
    #define CANDLE_BASELIGHT vec3(0.29975, 0.15392353, 0.0799)
#elif BLOCKLIGHT_TEMP == 1
    #define CANDLE_BASELIGHT vec3(0.27475, 0.17392353, 0.0899)
#elif BLOCKLIGHT_TEMP == 2
    #define CANDLE_BASELIGHT vec3(0.24975, 0.19392353, 0.0999)
#elif BLOCKLIGHT_TEMP == 3
    #define CANDLE_BASELIGHT vec3(0.22, 0.19, 0.14)
#else
    #define CANDLE_BASELIGHT vec3(0.19, 0.19, 0.19)
#endif

#include "/lib/day_blend.glsl"

// Fog parameter per hour
#if VOL_LIGHT == 1 || (VOL_LIGHT == 2 && defined SHADOW_CASTING)
    #define FOG_DENSITY 1.0
#else
    #define FOG_DAY 1.0
    #define FOG_SUNSET 1.0
    #define FOG_NIGHT 1.0
#endif

#include "/lib/color_conversion.glsl"
