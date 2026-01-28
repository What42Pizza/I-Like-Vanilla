# I Like Vanilla Documentation

## Warning: Documentation is still a bit out of date!

<br>

## Additional Documentation:

- [Iris' ShaderDoc](https://github.com/IrisShaders/ShaderDoc)
- [OptiFine Shaders (general)](https://github.com/sp614x/optifine/blob/master/OptiFineDoc/doc/shaders.txt)
- [OptiFine Shaders (.properties)](https://github.com/sp614x/optifine/blob/master/OptiFineDoc/doc/shaders.properties)
- [ShaderLABS](https://wiki.shaderlabs.org/wiki/Main_Page)

<br>
<br>
<br>
<br>
<br>

## Usages of others' copyrighted code

This is the full list of outside code that is used within this shader:

- The file [/shaders/lib/aces.glsl](/shaders/lib/aces.glsl) (under a custom license)
- The file [/shaders/lib/colorblindness.glsl](/shaders/lib/colorblindness.glsl) (public domain)
- The file [/shaders/lib/fxaa.glsl](/shaders/lib/fxaa.glsl) (under the MIT license)
- The file [/shaders/lib/kuwahara.glsl](/shaders/lib/kuwahara.glsl) (public domain)
- The file [/shaders/lib/simplex_noise.glsl](/shaders/lib/simplex_noise.glsl) (under the MIT license)
- Some code in the file [/shaders/lib/hsv_posterize.glsl](/shaders/lib/hsv_posterize.glsl) (public domain)

<br>
<br>
<br>

## Custom Tooling:

Because of the extensive and tedious usage of `#define`s, this repo contains a rust program (named rust-utils) that automates many tasks. Using it isn't necessary for developing this shader, but you'll probably still want to use it. There's a (very simple) readme in the /rust-utils folder which can get you stated.

Here's a list of the commands and why they exist:

- **export:** This creates the zip files which are uploaded to modrinth and curseforge. It takes the shader code, license, changelog, and shader readme and packages it into zip files, and it automatically splices together code to make the style-specific versions.
- **check_settings:** Detects all settings in all setting-related files to check for missing settings, broken settings, mis-ordered settings, etc
- **count_sloc:** Counts the significant lines of code. May not be accurate, idk. It only counts .glsl files, since the .vsh and .fsh files don't contain anything meaningful.

As always, you can edit your repo's rust-utils to add more commands and/or tweak existing commands. If you find something you consider a bug, you can contact me and I'll try to fix it

<br>
<br>
<br>

## OptiFine Support:

OptiFine is now discontinued

<br>
<br>
<br>

## Settings System:

In the settings menu, users can define which base style they use, then override any settings they want to change. This requires some kinda complex and really tedious code (for example, style_vanilla.glsl is over 1300 lines long), but I think it's worth it.

### Basics:

In "/shaders", you'll find "settings.glsl", "setting_defines.glsl", "shaders.properties", "style_vanilla.glsl", "style_realistic.glsl", and so on. The "settings.glsl" file generally controls the defining of settings. The "setting_defines.glsl" file holds the `#define`s which are modified by user settings. The "shaders.properties" file holds a ton of stuff, look elsewhere for info. The "style_..." files hold the default setting values for that style.

You should be able to figure this out yourself, but I'll still give some quick overviews

### How it works:

- 1: "/world" files #include settings.glsl
- 2: settings.glsl defines values are either -1 or the user-selected value
- 3: settings.glsl #include-s the specified style file
- 4: for each setting, the style file replaces every setting still to -1 with the style's default

### If you want to change a default setting value:

- 1: Go to each related style file
- 2: Find the setting and replace its #define

### If you want to add a setting:

- 1: Add the setting to settings.glsl, with it being -1 by default, and specify the allowed values
- 2: For every style file, copy-paste an existing setting's code, and replace the copied setting name and value with the new name and value
- 3: Add the setting to shaders.properties ('screen._=' and (optional) 'sliders=')
- 4: Add the setting to lang file(s)

### If you want to add a style: (removing is similar)

- 1: Copy-paste an existing style
- 2: Replace any values you want
- 3: Update allowed values for 'STYLE' setting (in settings.glsl)
- 4: Update "// style overrides" section (in settings.glsl)

### Important Notes:

- "On/Off" values are defined to be either -1 (use style's value), 0 (off), or 1 (on)

<br>
<br>
<br>
<br>
<br>

## File Structure:

- **/program**: The main shader code
- **/lib**: The more complex, standalone code
- **/world\***: The files that are actually loaded by Iris. These files just use `#include` to copy-paste other files into them
- **/utils**: Functionality a bit too complex for common.glsl
- **/lang**: The displayed names of settings and setting values
- **setting_defines.glsl**: Holds the `#define` for every setting
- **settings.glsl**: Miscellaneous settings loading stuff
- **common.glsl**: Holds commonly used code and macros for easier programming (cannot use uniforms, see 'Uniforms System' above for why)
- **shaders.properties**: Defines the settings menu plus many other details about the shader internals
- **blocks.properties**: Defines what different blocks are mapped to. The shaders retrieve these value from `mc_Entity.x`

<br>

## Shading Effect Locations: (VERY OUTDATED)

This describes which /main_files-s handle different effects

- **Shadows:**
- - Main Processing:  /main_files/deferred.glsl  (via sampleShadow())
- - Rendering:  /main_files/shadow.glsl
- **Reflections**
- - Main Processing:  /main_files/composite.glsl  (via doReflections())
- **Colorblindness Correction**
- - Main Processing:  /main_files/composite5.glsl  (via applyColorblindnessCorrection())
- **TAA:**
- - Main Processing:  /main_files/composite4.glsl  (via doTAA())
- - Jitter:  /main_files/*  (via doTaaJitter())
- **FXAA:**
- - Main Processing:  /main_files/composite4.glsl  (view doFxaa())
- **Isometric Rendering**
- - Main Processing:  /main_files/*  (via projectIsometric())
- **SSAO**
- - Main Processing: /main_files/deferred.glsl  (via getAoAmount())
- **Sunrays:**
- - Main Processing:  /main_files/composite1.glsl  (via getDepthSunraysAmount() and getVolSunraysAmount())
- - Application:  /main_files/composite2.glsl  (calculations are written to a mip-mapped buffer that is sampled with higher lod so that the noise is reduced)
- **Bloom:**
- - Main Processing:  /main_files/composite1.glsl  (via getBloomAddition())
- - Pre-Processing:  /main_files/composite.glsl
- - Application:  /main_files/composite2.glsl  (calculations are written to a mip-mapped buffer that is sampled with higher lod so that the noise is reduced)
- **Depth of Field**
- - Main Processing:  /main_files/composite3.glsl  (via doDOF())
- **Motion Blur**
- - Main Processing:  /main_files/composite4.glsl  (via doMotionBlur())
- **Auto Exposure**
- - Main Processing:  /main_files.composite.glsl
- **Sharpening:**
- - Main Processing:  /main_files/composite4.glsl  (via doSharpening())
- **Waving Blocks**
- - Main Processing:  /main_files/terrain.glsl  (via applyWaving())
- - Main Processing (for shadows):  /main_files/shadow.glsl  (via applyWaving())
- **Fog:**
- - Main Processing:  /main_files/deferred.glsl  (via getFogDistance(), getBorderFogAmount(), and applyBorderFog())
- - Main Processing (transparents):  /main_files/water.glsl  (via getFogDistance(), getBorderFogAmount(), and applyBorderFog())
- - Main Processing (clouds):  /main_files/clouds.glsl  (via getFogDistance(), getBorderFogAmount(), and applyBorderFog())
- **Handheld Light**
- - Main Processing:  /lib/lighting/basic_lighting.glsl
- **Underwater Waviness**
- - Main Processing:  /main_files/composite2.glsl
- **Vignette:**
- - Main Processing:  /main_files/composite5.glsl
- **Color Correction and/or Tonemapping:**
- - Main Processing:  /main_files/composite5.glsl  (via doColorCorrection())
- **Lighting:**
- - Main Processing:  /main_files/terrain.glsl,  /main_files/textured.glsl,  /main_files/water.glsl,  /main_files/entities.glsl,  /main_files/hand.glsl  (via doPreLighting() and getBasicLighting())

<br>

## Buffers: (up to date)

- **colortex0:  Main Image** (stored with 0.5 multiplier)
- **colortex1:  Prev Texture** (stored with 0.5 multiplier)
- **colortex2:  Opaque Data**
- - x: lmcoord.x (8-bit) & lmcoord.y (8-bit)
- - y: reflectiveness (8-bit) & specularness (8-bit)
- - zw: normal
- **colortex3:  Transparent Data**
- - x: lmcoord.x (8-bit) & lmcoord.y (8-bit)
- - y: reflectiveness (8-bit) & is cloud (8-bit)
- - zw: normal
- **colortex4:  Bloom Texture** (stored with 0.5 multiplier)
- **colortex5:  Sky Objects Texture**
- **colortex6:  Noisy Renders Texture**
- - x: depthSunraysAmount (8-bit) & volSunraysAmount (8-bit, value = 1/stored-1)
- - y: clouds transparency (8-bit, value = 1-stored) & clouds brightness (8-bit, value = 1-stored)
- **colortex7:  Prev Depth Texture**
- - r: depth (16-bit)
- **colortex8:  Voxy Transparents Texture** (stored with 0.5 multiplier on rgb)
- **colortex9:  Debug Output** (normally not used)

<br>

## Color Coded Gbuffers:

- ClrwlTranslucent:     0.0, 0.25, 1.0
- Clrwl:                1.0, 0.75, 0.0
- Armor Glint:          1.0, 0.0, 0.5
- Basic:                0.0, 0.0, 0.0
- BeaconBeam:           0.5, 1.0, 1.0
- Block:                1.0, 0.5, 0.0
- Clouds:               0.0, 1.0, 1.0
- DamagedBlock:         0.5, 0.0, 0.0
- Entities:             0.5, 1.0, 0.0
- HandWater:            1.0, 0.5, 0.5
- Hand:                 1.0, 0.5, 0.25
- Line:                 0.25, 0.25, 0.25
- ParticlesTranslucent: 0.5, 0.75, 0.75
- SkyBasic:             1.0, 1.0, 0.5
- SkyTextured:          1.0, 1.0, 0.0
- Terrain:              0.75, 0.75, 0.75
- Textured:             0.5, 0.5, 0.5
- Water:                0.0, 0.0, 1.0
- Weather:              0.0, 0.5, 1.0

<br>
<br>
<br>

## Extras:

- **[Noise Functions](https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83)**
- **[Permission to use Complementary's code](https://discord.com/channels/744189556768636941/744189557913681972/1135737539412643880)** (TAA and transform functions, now basically entirely outdated)
- quick note, it seems like `(1-0.06x*x)^16` is a really good approx for guassian
