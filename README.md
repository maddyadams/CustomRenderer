# CustomRenderer
First, change the file path in ViewController.swift. Then, when you run the project, it should render frames and write them to that file path. \
ViewController.swift handles keyboard controls and also controls what rendering method to use. You can specify ScanLiner() or RayTracer() in the call to RendererWrapper() in ViewController.viewDidLoad(). The ViewController.addNodes() method in ViewController.swift sets up the virtual scene with geometry and lighting. \
RayTracer.swift handles the high level concepts of raytracing (shadow rays, reflection rays) and raytraces portions of the screen on different threads. \
ScanLiner.swift handles the scanline rasterization. \
Node.swift represents a node in the scene tree. Nodes apply their transformations to their children and geometry. \
Primitive.swift is a superclass for the Face and Sphere primitives. \
PrimitiveTree.swift is an acceleration structure used by the raytracer. \

![Example of a rendered image](https://ucb56f331b676711368d4ea19864.previews.dropboxusercontent.com/p/thumb/AAuOMZSF62zSj24upweXq3cRke4Fs5e4lg2BhvjU4o5KdLt7tuv8Hq46Wey60SAdbGsj6JFafsmBwCzoILe120CrJwW27LVw4kPs9zioEtROAwUbTd3LHraMjDtZu-uNu01KWO8RPGrcVLw-WgWvfbJyh0BbFQTJOBhGvF1nbp-yfeU9bSV-NXC20sUyjhX0qiTt3vUTOFS7PrbFfR6hm-p3Z0Xi10gyxdoHB0h1P0TwP_pw28rZQrctnR0CDpjRzC5ZvzpWhzBCkxj4IgcgTLmOuoc7cJzS70G9G4P-68LWIgqyplqsoNbamBFmc53GCro4gyV_ArhTMVPojfJN7JMi22YIa44-k_5Ym8PYBk-lmYXk2c0R-TGXDwd-vO5x_I7v94PTu63wdQ6mW83uXRoW/p.png?fv_content=true&size_mode=5)

Keyboard controls are as follows: (Note, when rendering takes a while, you may need to hold down a key until the next frame is complete for the program to register it)\
wasd: moves the camera in the XZ plane. \
qe: moves the camera up or down along the Y axis. \
rf: rotates the camera along the X axis (ie pitch).\
tg: rotates the camera along the Z axis (ie roll). \
yh: rotates the camera along the Y axis (ie yaw). \
uj: rotates the camera around the center of the scene. (Note, if you change the addNodes method, these keys may cause a crash. Feel free to comment them out.)\
zxcvbnm,.: changes the rendered resolution, where z is the best quality and / is the worst quality. Starts on /. I recommend leaving it on / or a little higher but still fairly low to position the camera in the scene, and then change it to z to slowly render a high quality image. \
iop[]\: changes the maximum number of reflections when raytracing, where \ is the best and i is the worst. Starts on i. I recommend leaving it on i or somewhere in the middle to get a general sense of what the reflections might look like, then increasing it to \ before rendering a high quality image with z. 
