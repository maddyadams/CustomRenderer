# CustomRenderer
First, change the file path in ViewController.swift. Then, when you run the project, it should render frames and write them to that file path. \
ViewController.swift handles keyboard controls and also controls what rendering method to use. You can specify ScanLiner() or RayTracer() in the call to RendererWrapper() in ViewController.viewDidLoad(). The ViewController.addNodes() method in ViewController.swift sets up the virtual scene with geometry and lighting. \
RayTracer.swift handles the high level concepts of raytracing (shadow rays, reflection rays) and raytraces portions of the screen on different threads. \
ScanLiner.swift handles the scanline rasterization. \
Node.swift represents a node in the scene tree. Nodes apply their transformations to their children and geometry. \
Primitive.swift is a superclass for the Face and Sphere primitives. \
PrimitiveTree.swift is an acceleration structure used by the raytracer. \

Keyboard controls are as follows: (Note, when rendering takes a while, you may need to hold down a key until the next frame is complete for the program to register it)\
wasd: moves the camera in the XZ plane. \
qe: moves the camera up or down along the Y axis. \
rf: rotates the camera along the X axis (ie pitch).\
tg: rotates the camera along the Z axis (ie roll). \
yh: rotates the camera along the Y axis (ie yaw). \
uj: rotates the camera around the center of the scene. (Note, if you change the addNodes method, these keys may cause a crash. Feel free to comment them out.)\
zxcvbnm,.: changes the rendered resolution, where z is the best quality and / is the worst quality. Starts on /. I recommend leaving it on / or a little higher but still fairly low to position the camera in the scene, and then change it to z to slowly render a high quality image. \
iop[]\: changes the maximum number of reflections when raytracing, where \ is the best and i is the worst. Starts on i. I recommend leaving it on i or somewhere in the middle to get a general sense of what the reflections might look like, then increasing it to \ before rendering a high quality image with z. 
