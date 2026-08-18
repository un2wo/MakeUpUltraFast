Personal edit/retune of MakeUp Ultra Fast 9.1e.[^1]

## Differences from the original
- Additional color palettes; +9 for the Overworld, +4 for The End
- Adjusted shading for foliage and similar blocks; should look better w/ narrower sun angles and shadowless configurations
- Misc. changes to exposure & color grading; overall brighter w/ more contrast
  - Multiply & screen blend mode options are included on top of the usual contrast/saturation/brightness settings
  - Also adds a desaturation effect in low light
- Different cloudmaps; 'blocky' style clouds are larger with denser coverage, 'natural' style clouds are puffier
  - Natural clouds also have variable coverage, based on the in-game day; can be manually overridden
- Fog color adjustments; now takes influence from the zenith color before fading completely
- Underwater is slightly more pleasant with added tinting (based on the color scheme) and extra bloom
- Reorganized settings screen
- Entity shadow toggles, reduced color banding, & other small stuff
- Voxy support[^2]

Tested on Nvidia/Linux/Iris. May have issues with other GPUs, operating systems, or with Optifine.  
Performance is about on par with MakeUp and its forks. I have not done any extra optimizations, but the bloom setting is slightly more performant (due to newer MakeUp versions using a more expensive bloom function).

## Screenshots
### Default settings w/ voxy (RP: Stay True)
<img width="2560" height="1440" alt="screenshot_01" src="https://github.com/user-attachments/assets/01052034-1b4a-40dd-9f08-c6e60e1cb4d2" />
<img width="2560" height="1440" alt="screenshot_02" src="https://github.com/user-attachments/assets/dd810c23-fa69-4a52-8d5f-fe532bec31cf" />
<img width="2560" height="1440" alt="screenshot_03" src="https://github.com/user-attachments/assets/4da2dc48-9369-4130-95cd-77fa09225781" title="Map: BTE New York City" />
<img width="2560" height="1440" alt="screenshot_04" src="https://github.com/user-attachments/assets/66179771-4211-4a49-a34e-89c93417bc72" />
<img width="2560" height="1440" alt="screenshot_05" src="https://github.com/user-attachments/assets/a64f203f-ed79-4fd4-a7a0-6f38c8f4b66b" />
<img width="2560" height="1440" alt="screenshot_06" src="https://github.com/user-attachments/assets/4783642e-9aab-4751-b594-d757bf178ea0" />

### Un-default settings
<img width="2560" height="1440" alt="screenshot_07" src="https://github.com/user-attachments/assets/0b6490a2-328b-4ac4-a9ef-cfa26082b7bc" />
<img width="2560" height="1440" alt="screenshot_08" src="https://github.com/user-attachments/assets/8646b720-3dd0-424f-b10c-8c9f5500c8c8" />
<img width="2560" height="1440" alt="screenshot_09" src="https://github.com/user-attachments/assets/9431fbe4-d37f-43e5-b3e6-b7e99139956a" />

[^1]: Some changes from the newer versions were ported (not all).
[^2]: The voxy support is my own implementation. There are some differences, such as voxy chunks having SSAO and raymarched reflections (neither are perfect).
