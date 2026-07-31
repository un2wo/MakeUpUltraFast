Personal edit/retune of MakeUp Ultra Fast 9.1e.[^1] A gameplay-friendly shader with a more subjective take on "semi-realistic."  

## Differences From the Original
- Adjusted shading for foliage and similar blocks; should look better w/ narrower sun angles and shadowless configurations
- Misc. changes to lighting & color grading; overall brighter w/ more contrast
  - Sliders for saturation, contrast, brightness, & exposure also included
- Different cloudmaps; 'blocky' style clouds are larger with denser coverage, 'natural' style clouds are puffier
  - Natural clouds also have variable coverage, based on the in-game day; can be manually overridden
- Adjustments to fog density & color
- Additional color palettes; +8 for the Overworld, +5 for The End
- Entity shadow toggles
- Reorganized settings screen
- Reduced color banding
- Voxy support[^2]

Tested on Nvidia/Linux/Iris. May have issues with other GPUs, operating systems, or with Optifine.  
Performance is slightly better than default Makeup by default (through no fault of mine; caused by recent changes to MakeUp's bloom). When using similar settings, it is about on par with MakeUp and its derivatives.

## Screenshots
<img width="2560" height="1440" alt="Screenshot From 2026-07-30 20-57-28" src="https://github.com/user-attachments/assets/9553bb9e-d91d-484a-b8a7-515fd629e717" />
<img width="2560" height="1440" alt="Screenshot From 2026-07-30 20-37-26" src="https://github.com/user-attachments/assets/b299f29b-6dce-423f-b8ef-aa4f969b6a70" />
<img width="2560" height="1440" alt="Screenshot From 2026-07-18 14-25-15" src="https://github.com/user-attachments/assets/372f89f7-27fa-48b9-a1df-9fd3d78a14dc" />
<img width="2560" height="1440" alt="Screenshot From 2026-07-30 20-40-45" src="https://github.com/user-attachments/assets/845a1d21-b57e-449d-ad6c-11e73105e426" />
<img width="2560" height="1440" alt="Screenshot From 2026-07-31 05-15-03" src="https://github.com/user-attachments/assets/5d179b1e-4924-4d01-a319-183d99a0d712" title="Map: BTE New York City" />


[^1]: Some changes from the newer versions were ported, but I'm too lazy to fully keep up with it.
[^2]: The voxy support is my own implementation. There are some differences, such as voxy chunks having SSAO and raymarched reflections (neither are perfect).
