<p align="center">
	<img src="https://github.com/Noga-Levy/EepyKitty/blob/master/Assets/example_img.png?raw=true">
</p>
<h1 align="center">EepyKitty</h1>
<p align="center">
	<img src="https://img.shields.io/badge/engine-Godot-478cbf">
	<img src="https://img.shields.io/badge/language-GDScript-blue">
	<img src="https://img.shields.io/badge/license-MIT-green">
	<img src="https://img.shields.io/badge/platform-Windows-lightgrey">
</p>
<h3 align="center"> What if a desktop pet actually behaved like a cat?</h3>

Introducing **EepyKitty**, a virtual shimeji powered by an emergent behavior AI.

Using a set of simple rules, EepyKitty mimics cat-like behavior via a stress-based system. Future versions will include graphs showing how internal variables (stress, energy, etc.) evolve over time, and more activities for the cat.

## Logic
**Language: GDScript**

Utilizing Godot's built-in window management framework, I created a small window that evaluates all input events and state transitions. A separate `AnimatedSprite2D` handles the cat's animation, receiving the information via a signal called "`action`."
The main scene tree looks like so:

```
┖╴Logic (Node2D, Root Node) {Connected to window_movement.gd}

	┖╴Cat (AnimatedSprite2D, child node of Logic) {Connected to cat_animation.gd}
```

Other scripts include
- `activities.gd` ~ A collection of activities/goals for the cat.
- `food_bowl.gd` ~ A WIP food window that will, eventually, be used in one of the cat's goals.
- `Global.gd` ~ A collection of global variables

The cat can choose activities via these scripts. While enacting these goals, two internal variables--stress and energy--affect the cat's behavior.
- Stress directly affects speed and inversely affects the likelihood of idling. It decreases over time and increases when the cat bumps into the screen edges and the user's mouse.
- Energy, in contrast, directly relates to the likelihood of idling; however, similar to stress, it directly affects the speed of the cat.

## Project Structure
Key folders include the following:
- `addons/` ~ Contains all the configuration files relevant to Godot.
- `Assets/` ~ Contains all assets relevant to the program
- `Scenes/` ~ Contains all the scenes relevant to the program.
- `Scripts/` ~ Contains all the scripts relevant to the program.

## Installation
*Note: Only works on the Windows OS.*

Head over to the [Releases page](https://github.com/Noga-Levy/EepyKitty/releases/), and download the `.exe` file from the most recent release. Click on it to start the program.

To close the application, go to the taskbar and click the `X` button.

## License
EepyKitty is licensed under the MIT License--see the [LICENSE](https://github.com/Noga-Levy/EepyKitty/blob/master/LICENSE) file for details.
