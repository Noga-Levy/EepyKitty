extends Node

var stress

# These will be the main variables for the energy system. When the cat runs around, energy 
# decreases, with the amount proportional to the stress level. Additionally, when idling, the energy
# increases. If energy reaches 0, the cat stops whatever it's doing and idles, with an increased
# energy_dlt amount.
var energy                   # energy itself, the variable that will be acted on.
const ENERGY_MIN: float = 0  # ENERGY MINIMUM, so it cannot go into the negative, breaking some of
							 # the calculations and functionality.
const ENERGY_MAX: float = 2  # ENERGY MAXIMUM, so it cannot get infinitely higher, encountering the
							 # same issue as with stress (when it did not have a limiter).

# These two handle direction:
var x
var y

# We have the speed of the cat, which will be defined later in window_movement.gd
var speed

# And this communicates with the AnimatedSprite2D of the cat to play the animation
signal action(speed, direction)

var goal_in_progress = false

var dir_opts = [-1, 1]
