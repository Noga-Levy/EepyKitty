![Example of EepyKitty](https://github.com/Noga-Levy/EepyKitty/blob/master/images/example_img.png?raw=true)

# EepyKitty
### Ever notice how Shimejis can get kind of unrealistic?

Introducing EepyKitty, an emergent behavior AI placed into... a virtual pet?

Using simple rules, EepyKitty plans to mimic cat-like behavior via a stress-based system. Future versions will include energy-based rules and an option to show graphs displaying variable information over time.

## Logic
**Language: GDScript**

Using Godot's pre-built framework for app/window management, I created a small window that evaluates all input events and state transitions. A separate `AnimatedSprite2D` deals with the cat's animation, receiving the information via a signal called "`action.`"
The main scene tree looks like so:
```
┖╴Logic (Node2D, Root Node) {Connected to window_movement.gd}

	┖╴Cat (AnimatedSprite2D, child node of Logic) {Connected to cat_animation.gd}
```

Increased stress leads to increased speed and a lower likelihood of idling. Stress decreases over time, and increases as the cat bumps into screen edges and the user's mouse. 

An energy system, which will keep the cat from forever increasing its stress, is in the works.

## Installation
*Note: Only works on the Windows OS.*

Head over to [releases](https://github.com/Noga-Levy/EepyKitty/releases/), and download the `.exe` file from the most recent release. Click on it to start the program.

To close the application, go to the taskbar and click the `X` button.

## Known Bugs
The user can force the cat to go on "overdrive" by repeatedly hitting it with their mouse, as, after passing a certain threshold, the stress variable increases more than it decreases. A fix is on its way.
If you find any other issues, please add them to its [GitHub Issues](https://github.com/Noga-Levy/EepyKitty/issues) page.

## License
EepyKitty is licensed under the MIT License -- see the [LICENSE](https://github.com/Noga-Levy/EepyKitty/blob/master/LICENSE) file for details.
