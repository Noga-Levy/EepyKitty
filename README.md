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
<h3 align="center">What if a desktop pet actually behaved like a cat?</h3>

Introducing **EepyKitty**, a virtual shimeji meets emergent behavior AI. Rather than the scripted behavior typically found in desktop companions, EepyKitty uses a simple set of rules to create a personality. That is to say, it can 
- React to its environment,
- Build a spatial memory from its experiences,
- And make "choices" influenced by its internal state.

As a result, EepyKitty does what very few other shimejis can: It puts the "pet" back into desktop pet.

<p align="center">
	<img src="https://github.com/Noga-Levy/EepyKitty/blob/master/Assets/EepyKitty_Showcase_GIF.gif?raw=true" alt="EepyKitty wake up, starts moving towards the foodbowl, but goes to sleep halfway there.">
</p>

## User Interaction
For the most part, the cat is independent of the user; however, the user can interact with the program via

$$
\begin{array}{|c|c|}
\hline
\textbf{Action} & \textbf{Input} \\
\hline
\text{Interact with cat} & \text{Drag the food-bowl window} \\
\hline
\text {Open/close comfort map } & \text{Shift + Space} \\
\hline
\text{Exit} & \text{Close the cat window from the taskbar} \\
\hline
\end{array}
$$

Note that the cat is confined by the borders of the monitor the program started on. 

## Installation
### Download `.exe` file
Head over to the [Releases page](https://github.com/Noga-Levy/EepyKitty/releases/), and download the `.exe` file from the most recent release.  Run the `.exe` file to start the program.

*Note: Installation via the `.exe` is only for Windows devices.*

### Build from source
Alternatively, clone the repository and import the folder into the Godot Editor:

```
git clone https://github.com/Noga-Levy/EepyKitty
```

Running the project from there will automatically load the right scene.

## Behavior System
**Language: GDScript**
### Main scene structure
The project is centered around a single "main" scene, whose hierarchy is shown below:

```
┖╴Logic (Node2D, Root Node) {Connected to window_movement.gd}

	├── Cat (AnimatedSprite2D, child of Logic) {Connected to cat_animation.gd}
	
	├── Food [food_bowl.tscn] (Window, child of Logic) {Connected to food_bowl.gd}
	
	└── Comfort_map [comfort_map.tscn] (Window, child of Logic) {Connected to comfort_map.gd}
```

Utilizing Godot's built-in window management framework, the project uses a small window--`Logic`, created as the root node of `main.tscn`--that evaluates all input events and state transitions. Making up this window, we have
- An `AnimatedSprite2D` that handles the cat's animation, receiving the necessary information (direction, action, etc) via a signal called "`action`."
- A separate, draggable `Window` scene nested in `Logic` allows the user to move a food bowl, giving them an avenue by which they can influence the cat when it gets hungry.
- A non-draggable `Window`, `Comfort_map`, that manages the showing/hiding of the window visualization of the comfort map visualizer.

Additional scripts--not attached to any nodes, though still used frequently in the program--include the following:
- `activities.gd` ~ A collection of activities/goals for the cat.
- `Global.gd` ~ A collection of global variables.

### Internal state
Utilizing the previously mentioned GDScript code files, the cat selects an activity/goal based on which activity has the highest "score," determined by the largest output of each activity's equation. These equations utilize two main internal variables--`Global.stress` and `Global.energy`--to add a preference to the cat's choices.<a id="note-1">[<sup>1</sup>](#footnote-1) <a id="note-2">[<sup>2</sup>](#footnote-2) <a id="note-3">[<sup>3</sup>](#footnote-3)

Additionally, these two internal variables also affect the smaller details of the cat's behavior:
- Stress directly affects speed and inversely affects the likelihood of idling. It decreases over time and increases when the cat bumps into the screen edges and the user's mouse.
- Energy directly relates to the likelihood of idling and directly affects the speed of the cat. Additionally, it decays as the cat wanders for longer periods.

### Spatial comfort map
In addition, based on energy and stress, there is a comfort grid that splits up the cat's playing field, the window it operates in, into 50 pixel squares. From there, the grid assigns comfort "values" to each square, which in turn influence the cat's behavior.
- When stressed, the cat will go to the squares with the highest comfort value.
- When sleeping, eating, and idling, the cat will increase the comfort of the squares around itself.
- When confronted and/or stressed, the cat will decrease the comfort values of the squares around itself.
Moreover, all non-zero comfort values decay over time and approach zero if left untouched for a while.

For users interested in a visualization of the map, press Shift + Space to show/hide the comfort grid visualizer. The redder the value's hue, the more recently it has been changed.

## Project Structure
Key folders include the following:
- `addons/` ~ Contains all the configuration files relevant to Godot.
- `Assets/` ~ Contains all assets relevant to the program.
- `Scenes/` ~ Contains all the scenes relevant to the program.
- `Scripts/` ~ Contains all the scripts relevant to the program.
- `Themes/` ~ Contains all the themes used to stylize the program's elements.

## License
EepyKitty is licensed under the MIT License--see the [LICENSE](https://github.com/Noga-Levy/EepyKitty/blob/master/LICENSE) file for details.
Check [NOTICE.md](https://github.com/Noga-Levy/EepyKitty/blob/master/NOTICE.md) for third-party attribution.

## Footnotes
<a id="footnote-1">[<sup>1</sup>](#note-1)</a>Wandering equation:

$$(w_{\text{energy}} \cdot \text{Global.energy}) - (w_{\text{stress}} \cdot \text{Global.stress}) = W_{\text{score}}$$

$w_{\text{energy}}$ is the weight of the energy, and it's $0.5 \pm 0.2$. Likewise, $w_{\text{stress}}$ is the influence of the cat's stress, equating to $2 \pm 0.5$.

<a id="footnote-2">[<sup>2</sup>](#note-2) Resting equation:

$$(w_{\text{stress}} \cdot \text{Global.stress}) - (w_{\text{energy}} \cdot \text{Global.energy}) = R_{\text{score}}$$

Here, $w_{\text{stress}}$ equals $3.125 \pm 0.375$ and $w_{\text{energy}}$ equals $0.55 \pm 0.15$.

<a id="footnote-3">[<sup>3</sup>](#note-3) Eating equation:

$$2 \cdot e^{^{\left(-\frac{(\text{Global.energy} - E_{\text{desired}})^2}{0.5} \right)}} = E_{\text{score}}$$

In the equation above, $E_{\text{desired}}$ represents the energy state/value at which eating is most desirable, corresponding to $2.5 \pm 0.5$.
