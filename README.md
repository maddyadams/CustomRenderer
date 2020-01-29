# CustomRenderer
This project started as a scanline rasterizer for a school assigment, but after the deadline, I decided to see if I could add a raytracer for fun. At the moment, I support multiple levels of reflections and a variable resolution for rendering, which allows you to temporarily sacrifice quality to move the camera around the scene, and then switch to high reflections and high resolution to get a higher quality render. 

## Build Instructions / Project Overview
1. Change the file path in `ViewController.swift`. Then, when you run the project, it should render frames and write them to that file path.
2. `ViewController.swift` handles keyboard controls and also controls what rendering method to use. You can specify `ScanLiner()` or `RayTracer()` in the call to `RendererWrapper()` in `ViewController.viewDidLoad()`. The `ViewController.addNodes()` method in `ViewController.swift` sets up the virtual scene with geometry and lighting.
3. `RayTracer.swift` handles the high level concepts of raytracing (shadow rays, reflection rays) and raytraces portions of the screen on different threads.
4. `ScanLiner.swift` handles the scanline rasterization.
5. `Node.swift` represents a node in the scene tree. Nodes apply their transformations to their children and geometry.
6. `Primitive.swift` is a superclass for the Face and Sphere primitives.
7. `PrimitiveTree.swift` is an acceleration structure used by the raytracer. 

![Example of a rendered image](https://www.dropbox.com/s/npjazln9h4ap1c4/raytrace-1.png?raw=1)

## Keyboard Controls
Note, when rendering takes a while, you may need to hold down a key until the next frame is complete for the program to register it:
  * wasd: moves the camera in the XZ plane.
  * qe: moves the camera up or down along the Y axis.
  * rf: rotates the camera along the X axis (i.e. pitch).
  * tg: rotates the camera along the Z axis (i.e. roll). 
  * yh: rotates the camera along the Y axis (i.e. yaw).
  * uj: rotates the camera around the center of the scene.
  
    If you change the `addNodes()` method, these keys may cause a crash. Feel free to comment them out.
  
  * zxcvbnm,./: changes the rendered resolution, where z is the best quality and / is the worst quality. Starts on /.
  
    I recommend leaving it on / or a little higher but still fairly low to position the camera in the scene, and then change it to z to slowly render a high quality image.
  
  * iop[]\: changes the maximum number of reflections when raytracing, where \ is the best and i is the worst. Starts on i.
  
    I recommend leaving it on i or somewhere in the middle to get a general sense of what the reflections might look like, then increasing it to \ before rendering a high quality image with z. 
  
