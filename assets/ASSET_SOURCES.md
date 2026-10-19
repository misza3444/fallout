# Station asset pack v1

## Surface library — Poly Haven, CC0
Downloaded 2026-10-19 from the official Poly Haven API/download service.
All nine source maps are 1024 × 1024 JPEGs (albedo, OpenGL normal, roughness).
These files are bundled; the game makes no requests to Poly Haven at runtime.

| Local prefix | Original asset | Source |
| --- | --- | --- |
| asphalt | Worn Asphalt | https://polyhaven.com/a/worn_asphalt |
| concrete | Concrete Floor Worn 02 | https://polyhaven.com/a/concrete_floor_worn_02 |
| rust | Rusty Metal 02 | https://polyhaven.com/a/rusty_metal_02 |

License: https://polyhaven.com/license (CC0).
PBR materials use StandardMaterial3D, world-scale triplanar projection, normal maps and roughness maps. No displacement or renderer-specific screen effects.

## Original meshes
`ashen_pump.glb`: 7,176 triangles, 6 material batches; four instances replace the pumps.
`ashen_coupe_wreck.glb`: 13,953 triangles, 9 material batches; replaces the red road wreck at (3.3, 0.07, -38).
Models created for this project in Blender 4.3.2; rust maps are the CC0 maps above.
UVs and normals are exported. Text is mesh geometry; no font required at runtime.
Simple Godot collision shapes are separate from visual meshes.

Editable, packed Blender sources: `art_source/` (excluded from Godot import with `.gdignore`).
Rebuild from repository root:

    blender -b -t 2 -P tools/build_station_assets.py

The scene still contains procedural placeholder vehicles elsewhere. These two assets are the first replacement batch, not a declaration that all environment art is finished.

## Validation
Local Godot 4.5.1: editor import and headless scene startup passed.
Blender render of exported GLBs inspected for silhouette, materials and missing geometry.
Real browser/mobile performance and in-game visual acceptance remain pending.
