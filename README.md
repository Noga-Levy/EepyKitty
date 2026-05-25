<p align="center">
	<img src="https://github.com/Noga-Levy/EepyKitty/blob/master/Assets/EepyKitty_Banner.png?raw=true" width="50%">
</p>
<h1 align="center">EepyKitty</h1>
<p align="center">
	<img src="https://img.shields.io/badge/engine-Godot-478cbf">
	<img src="https://img.shields.io/badge/language-GDScript-blue">
	<img src="https://img.shields.io/badge/license-MIT-green">
	<img src="https://img.shields.io/badge/platform-Windows-lightgrey">
</p>
<h3 align="center"> What if a desktop pet actually behaved like a cat?</h3>

Introducing **EepyKitty**, a virtual shimeji powered by an emergent behavior AI. Using a set of simple rules, EepyKitty mimics cat-like behavior via a stress-based system.

## Logic
**Language: GDScript**

Utilizing Godot's built-in window management framework, the project uses a small window that evaluates all input events and state transitions. A child `AnimatedSprite2D` handles the cat's animation, receiving the information via a signal called "`action`." Moreover, a separate, draggable `Window` scene nested in the main program allows the user to move a food bowl, enabling the user to influence the cat when it gets hungry.
The main scene tree looks like so:

```
┖╴Logic (Node2D, Root Node) {Connected to window_movement.gd}

	┖╴Cat (AnimatedSprite2D, child of Logic) {Connected to cat_animation.gd}
	
	┖╴Food [food_bowl.tscn] (Window, child of Logic) {Connected to food_bowl.gd}
	
	┖╴Comfort_map [comfort_map.tscn] (Window, child of Logic) {Connected to comfort_map.gd}
```

Additional scripts include the following:
- `activities.gd` ~ A collection of activities/goals for the cat.
- `Global.gd` ~ A collection of global variables

The cat can choose activities via these scripts. While enacting these goals, two internal variables--`Global.stress` and `Global.energy`--affect the cat's behavior.
- Stress directly affects speed and inversely affects the likelihood of idling. It decreases over time and increases when the cat bumps into the screen edges and the user's mouse.
- Energy, in contrast, directly relates to the likelihood of idling; however, similar to stress, it directly affects the speed of the cat.

Furthermore, based off of the energy and stress, there is a comfort grid that splits up the cat's playing field, the window it operates in, into 50 pixel squares. From there, the grid assigns comfort "values" to each square, which in turn influence the cat's behavior.
- When stressed, the cat will go to the squares with the highest comfort value.
- When sleeping, eating, and idling, the cat will increase the comfort of the squares around itself.
- When confronted and/or stressed, the cat will decrease the comfort values of the squares around itself.
Moroever, all non-zero comfort values decay over time and approach zero if left untouched for a while.

For users interested in a visualization of the map, press Shift + Space to toggle on/off the comfort grid visualizer. The redder the value's hue, the more recently it has been changed.

## Project Structure
Key folders include the following:
- `addons/` ~ Contains all the configuration files relevant to Godot.
- `Assets/` ~ Contains all assets relevant to the program
- `Scenes/` ~ Contains all the scenes relevant to the program.
- `Scripts/` ~ Contains all the scripts relevant to the program.
- `Themes/` ~ Contains all the themes used to stylize the program's elements.

## Installation
*Note: Only works on the Windows OS.*

Head over to the [Releases page](https://github.com/Noga-Levy/EepyKitty/releases/), and download the `.exe` file from the most recent release. Click on the `.exe` file to start the program.

To close the application, go to the taskbar and click the `X` button on the cat's window.

## License
EepyKitty is licensed under the MIT License--see the [LICENSE](https://github.com/Noga-Levy/EepyKitty/blob/master/LICENSE) file for details.
Check [NOTICE.md](https://github.com/Noga-Levy/EepyKitty/blob/master/NOTICE.md) for third-party attribution.
