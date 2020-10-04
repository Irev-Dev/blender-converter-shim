
I small project for making big smoothies with a 2 litre jar 🥤

The stl is available here it's `nutrition.stl`.

If instead you want to work with the scad file there are two options:

1) If you're familiar with git the easiest way to get started is to clone with submodules
``` git clone --recurse-submodules https://github.com/Irev-Dev/blender-converter-shim.git ```

2) Otherwise you can download each of the three libraries I used for this project and put them in your local openscad library director, once you've done that you need to comment out the first set of `use` statements and uncomment the second set of use statements. As the second set is for using the library folder.
[Instructions on how to include libraries](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries).
Libraries that need to be installed:
- [Round-Anything](https://github.com/Irev-Dev/Round-Anything)
- [scad-utils](https://github.com/openscad/scad-utils)
- [list-comprehension-demos](https://github.com/openscad/list-comprehension-demos)
