# Godot-Samsung-XR
Godot project for the Samsung XR. This repository is for those who want to make a game in godot for their Samsung XR. Repository only includes setup for Linux for now.


Steps to get godot to communicate with your SamsungXR
# PC Setup

## Important
Must use the Godot Engine from their official website. Steam version will NOT work as some options in the settings are missing.

## Android Platform Tools
* Download and install "Android Platform Tools" (aka ADB). This is what we use to communicate to the headset for pairing and connecting computer to headset, and installing our game.
* Once installed, verify you have it via running the following command in your terminal `adb version`. If the output isn't an error, move on, otherwise try to reinstall.

## Java JDK 17
* Another prerequisite for getting Godot to export the game correctly is Java. Use Java jdk 17, as the latest version isn't recognized by Godot(at least for me).
* Verify you have java installed by running this command in your terminal: `java --version`. If it outputs without an error, you're fine, otherwise reinstall java.

# Device setup

## Enable Developer Mode
* On your headset, go to the settings app, search for "developer", choose "Developer Options", turn it on.
* Next, scroll down until you see an option labeled "Wireless Debugging" and turn it on.
* This part might be weird, but the label "Wireless Debugging" is technically two buttons - the on/off, and a "more". Press the label that says "Wireless debugging" to get to the "more" part.
* This is the wireless debugging page where we begin to tell the headset to both pair and connect to your PC.
* Choose "Pair device with pairing code", and you will see a window titled "Pair with device" with a code and an IP:PORT underneath it.

# Connect Headset to Computer

* In your terminal, type this command:
`adb start-server` which makes your computer say "Hey I can be connected to"
* Now type this(note: replace "IP":"PORT" with your actual IP and Port)
command: `adb pair IP:PORT` then enter the pair code seen in your headset.
* Once that is completed, type this command: `adb connect IP:PORT` and this actually connects the device to your computer.
* If everything is done correctly, you should see the name of your computer in your headset developer options, and when you run `adb devices` in your terminal, you should see a device. That device is your headset.

## Debugging:
* If for some reason, your device is not connecting, below are some steps that could possibly resolve the issue.
* First, try turning off the wireless debugging for 10 seconds, and back on. Run `adb devices` and if your device is there, you're fine.
* If re-toggling wireless debugging didn't work, try typing `adb kill-server` then `adb start-server`, and then try the re-toggling wireless debugging in your headset.

* To really ensure the device is connected, you can also run `adb shell echo CONNECTED` which will tell you a bit more information than `adb devices`.


# Godot Project Setup
This next part will get you started on creating a PASSTHROUGH game in godot, and install it on your device.

* Before anything, go to the AssetLib in the top middle of Godot, and search for "OpenXR Vendors Plugin" and choose the one with the highest version. Since we are on Godot 4.x, choose v4 of the plugin.


* Enable OpenXR in your project settings. I just search for OpenXR and tick the on, as that is the quickest way than scrolling through every godot project option. Restart editor once completed.

Next is super important, and this is also where the plugin comes into play.

* In project settings, search for extensions. Click OpenXR, and enable the following:
* Hand Tracking
* Eye Gaze Interaction
* Androidxr's Passthrough Camera State
* Enable Shaders (Project Settings > XR > Shaders - on)

If you want to understand more about what these options do, simply hover your mouse over each option and read its description. If you need more information, go on the godot's documentation to know more.

* Click Project > Install Android template to install the Android Template for exporting. Reason as to why we're installing android, is that the Galaxy XR runs on an android OS. It's Android XR, but still android.


## Android Export Configuration
* Click project > Export > Add > Android. This will make an Android export template. You will most likely have a message saying something along the lines of "Target platform requires 'ETC2/ASTC' texture compression" and to enable it. Click the "Show Project Settings" button in that error message, and click on. Save and restart godot.

* Now, we have to enable a handful of options in this editor menu. Add the options below:
* Use Gradle Build
* XR Mode > OpenXR
* Enable Androidxr Plugin
* Access Network State - on
* Camera - on
* Internet - on

Export settings are done, so we can just click export once ready, but we aren't yet. Below is how to make a player controller so that in passthrough we can control the camera and have hands(HAND TRACKING NOT INCLUDED).

# XR Player Scene Setup
* In a new scene, click other node, search for XROrigin3D. It is important that this is the root of our player.
* Add three Children to the XROrigin3D node: 2 XRNode3D nodes(DO NOT DUPLICATE. ADD MANUALLY) and an XRCamera3D.
* Make sure to raise the XRCamera3D and the hands up a little bit to avoid bugs.

Once more, if you need more information on what these nodes do, you can get a description of them in the add node window before confirming your node.

* Rename the XRNode3D nodes to LeftHand/RightHand respectively, and it's optional to rename the XRCamera3D, but I rename it to HMD or Headset.
* Click on Left/RightHand nodes and choose the Trackers Left/Right_hand respectively.
* These instructions don't show how to get hand tracking working, but you can still add a mesh to each node, which we will do below.
* Add a child to each Hand: CSGBox3D with collision enabled if you want collision.

All that is left is making a scene so we can have objects such as a cube in our passthrough to verify it works. Sure, seeing the meshes in either hand confirms it, but we still need an area for our playground.


# Code for enabling passthrough
In your player scene, click the root XROrigin3D, and click the white scroll icon to add a new gdscript to the node.
In the script, copy and paste the following code below:

```
extends XROrigin3D

func _ready():
	var viewport := get_viewport()
	viewport.use_xr = true
	viewport.transparent_bg = true

	var xr := XRServer.find_interface("OpenXR")
	if xr:
		print("XRDBG: OpenXR found")
		xr.initialize()
		print("XRDBG: XR initialized =", xr.is_initialized())
		print("XRDBG: Passthrough supported =", xr.is_passthrough_supported())

		if xr.is_passthrough_supported():
			xr.start_passthrough()
			print("XRDBG: Passthrough started")

	print("XRDBG: viewport.use_xr =", viewport.use_xr)
	print("XRDBG: viewport.transparent_bg =", viewport.transparent_bg)
```
This code is what enables xr, sets viewport background to transparent, initializes the xr mode, and enables passthrough if supported, which it is, but we check anyway.



* Make a new scene with a Node3D as its root. Add a CSGBox3D node as a child and set collision to on. This is our floor. Use F2 to rename if you want to.
* Add your player scene(.tscn file) to this scene. You can drag and drop or right click on the player file and click "Instantiate". Both do the same thing.
* We don't want to see the floor in passthrough, we want to see our world's floor in passthrough. To do this, we have to set the floor node to transparent. To do this, click on the CSGBox3D node, and in your inspector(rigth-hand side) look for Material. Right click and choose "StandardMaterial3D" then click on the white sphere that appears.
* Scroll to Transparency and choose the Transparency option that says "Alpha".
* Scroll down to the Albedo option, and change the Color option(opens an RGB color wheel) to a transparent color by dragging the Alpha value(A) to the left. You should see the CSGBox3D turn blue, but that only happens, because we have it selected. If you click outside of the floor, you shouldn't see the CSGBox3D.

# Install your game to headset.
Now we're going to install the game to the headset and see if we see our cube hands.

* Click project > Export > Click Android(Runnable) > Export Project. A window will appear to give your game apk file(the file we install to the headset) a name, and a directory to save it to. Just save it to your project.
* A big window will appear. Just wait a little bit(shouldn't take more than a minute or so).
* Now go to your terminal and change the directory(cd command) to your project directory. Something like `cd my-xr-project/` replacing `my-xr-project` with your project name.

### NOTE: Make sure your project name is cased without spaces(xr_project or xr-project) as spaces can cause error or warning messages.

* Once in your project folder, type this command: `adb install -r ProjectName.apk` (Replace ProjectName.apk with the name you chose for your apk file in the export window)

After a moment you should see the terminal say something then "Success". Now go to your headset, go to apps, and scroll to the far right to see your game. Launch and look at your hands. If you have hands and can see the world around you, YOU DID IT CONGRATS! First Samsung XR game made by YOU.


# Black screen issues
When doing this my first time, I constantly saw a black screen on launch. Now at first, it asks you for permissions, which is normal, but after that is just black. Below are some troubleshooting steps I did to resolve this issue.

* Make sure your main scene, the one with the floor, is the scene that runs on start. You can do this two ways:
    * quickest is to just press F5 > select current, then press OK in the HMD not found message(don't worry about this), and then press F8. This tells godot that your main scene is the scene to use on ready/ when the game officially starts.
    * You can also go to Project settings > Run and choose your scene via the paper icon, but I find the first step works faster.

* In the 3D tab in your main scene, if you look at the top middle, you should see a sun and world icon. Click the three dots next to them, and click "Add sun into scene" and "Add environment to scene". From here, two new nodes show up.
* Click the WorldEnvironment node, look in the inspector and click "environment" in blue. Click background, and set the mode to Clear Color.

Both of these should fix any black screen issues you have.

* Another thing if this still doesn't work, is make sure the XRCamera3D node's current option is enabled in your player scene. However, not doing this doesn't make a noticable change.



If you encounter issues, you can join my discord and i'll help best I can, but I'm not an expert and would recommend getting official help from the Godot developers instead.



Links:
My Discord(for possible help): https://discord.jaxdanger.com
Godot Official Discord: https://discord.gg/godotengine
















