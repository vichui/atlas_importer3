This is an Atlas import plugin fo GoDot 3.0 - Modify from 
(https://github.com/GodotExplorer/atlas_importer)

Atlas importer plugin for other texture pack tools

Load packed atlas texture to filesystem and can be used in godot.

#### Cureent support tools and formats
- TexturePacker : Generic XML
- TexturePacker : JSON hash
- [Attila](https://github.com/r-lyeh/attila) : JSON
- Kenney Spritesheet : Atlas from [Kenney assets](http://kenney.nl/assets)
- LibGDX: (Atlas from LibGDX Framework, which has a nice GUI tools - GDX Texture Packer (https://github.com/crashinvaders/gdx-texture-packer-gui))

As godot doesn't support rotated atlas, so don't rotate sprites when you pack pictures with above tools or you have to rotate them back manually.

Due to bug of selection of Sprites using AtlasTexture in the editor. This plugin work only after 3.0.3-rc1
