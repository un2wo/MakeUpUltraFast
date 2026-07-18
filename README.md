Personal edit/retune of MakeUp shaders (9.1e).[^1]  

Differences from the original:
- Adjusted shading for foliage and similar blocks; should look better w/ narrower sun angles and shadowless configurations
- Misc. changes to lighting & color grading; overall brighter w/ more contrast
- Different cloudmaps; 'blocky' style clouds are larger with denser coverage, 'natural' style clouds are puffier
- Additional color palettes; +8 for the overworld, +5 for The End
- Entity shadow toggles
- Reorganized settings screen
- Reduced color banding
- Small adjustments to fog density & color
- Voxy support (different implementation from MakeUp 9.5).[^2]

Tested on Nvidia/Linux/Iris. May have issues with other GPUs, operating systems, or with Optifine.  
Performance is slightly better than default Makeup (through no fault of mine; caused by recent changes to MakeUp's bloom). Otherwise, it is about on par.

#### Screenshots
<img width="2560" height="1440" alt="Screenshot From 2026-07-18 14-16-45" src="https://github.com/user-attachments/assets/39c1fd98-829d-453f-94ca-5c0edc1e08a1" /> 
<img width="2560" height="1440" alt="Screenshot From 2026-07-18 14-19-00" src="https://github.com/user-attachments/assets/46ee3528-3f35-4fc8-b360-b72f99db5617" /> 
<img width="2560" height="1440" alt="Screenshot From 2026-07-18 14-25-15" src="https://github.com/user-attachments/assets/54f0653a-7f56-4033-a040-d2c454354102" /> 
<img width="2560" height="1440" alt="Screenshot From 2026-07-18 14-21-18" src="https://github.com/user-attachments/assets/701d1d07-221d-46a6-92a6-8226ef6bb22a" /> 

[^1]: Some changes from the newer versions were ported, but I'm too lazy to fully keep up with it.
[^2]: Differences include voxy chunks having SSAO and raymarched reflections (though not perfect).
