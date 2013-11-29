Computer Graphics Exercise 4 - BRDF and Procedural Textures
===========================================================

General
-------

Two additional colors have been added for steel and hematite.

Inspiration for Perlin noise: https://github.com/ashima/webgl-noise


Implemented features
--------------------

### 2. Lambertian

There are no highlights in this model, and thus neither steel nor hematite look as they should.

### 3. Phong

The Phong Lightning model introduces specular highlights. But the steel looks like plastic. Hematite doesn't look that bad.

### 4. Blinn-Phong

In this model, steel once more looks more like plastic. The hematite looks pretty nice.

### 5. Ward

Hematite looks better, but the steel still doesn't look good.

### 6. Cook

Finally the steel can be displayed correctly, as well as the hematite.

### 7. SVBRDF

Displays rusted steel. Additionally animated rust :) Uses Perlin noise for that.

### A. Wood

Uses Perlin noise. It could be more realistic, but it looks quite nice.
Additional implementation with Cook model.

### B. Marble

Uses Perlin noise and looks very nice.
Additional implementation with Cook model.


### C. Earth

Uses Perlin noise for the clouds and the islands. The clouds are animated.
Bump mapping is implemented, but doesn't look very realistic because the earth is still round around the edges. This is because it is a "fake" implementation with only changing the normals at certain points.
Additional implementation: Icebergs (as "islands", like the north pole) and glaciers (on the normal islands).
Additional implementation with Cook model and Ward model.






