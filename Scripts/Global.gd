"""
Written in March to July of 2026 by Noga Levy.

Global.gd is a collection of all the global variables used throughout the program.
"""

extends Node

var stress
var stress_decr: float = 0.001

# These will be the main variables for the energy system. When the cat runs around, energy 
# decreases, with the amount proportional to the stress level. Additionally, when idling, the energy
# increases. If energy reaches 0, the cat stops whatever it's doing and idles, with an increased
# energy_dlt amount.
var energy                   # energy itself, the variable that will be acted on.
var energy_dlt = 0.01        # energy DELTA, the variable regulating change in energy.
const ENERGY_MIN: float = 0  # ENERGY MINIMUM, so it cannot go into the negative, breaking some of
							 # the calculations and functionality.
const ENERGY_MAX: float = 3  # ENERGY MAXIMUM, so it cannot get infinitely higher, encountering the
							 # same issue as with stress (when it did not have a limiter).

# The globals x and y are a tad bit confusing, I'll admit, but here's the general idea.
# If we consider the playing area that the cat moves upon as a cartesian plane, the x and y 
# variables, respectively, determine if the change in the x and y coordinatinate is negative, 
# positive, or zero.
var x  = 0 # Thus, rather than containing coordinates, these x will either equal 1, -1, or 0.
var y  = 0 # Same for y--1, -1, or 0.
# We set them to 0 at the beginning so the program can determine the first action, and what 
# direction/change in x,y it entails.

# Here is the list we use to determine the values for x and y when we are sure we want to move:
var dir_opts = [-1, 1]

# We also have the speed of the cat, which will determine--along with a couple of other factors--the
# magnitude of x and y change--how fast the cat will move.
var speed

# For these movements, we communicate--via our signal below--to the cat AnimatedSprite2D the speed
# and (x) direction the cat will be moving. From there, the cat_animation.gd program takes these 
# values and plays their assigned animation.
signal action(speed, direction)

# Moreover, to tell us when to re-determine our action, we have
# goal_in_progress, for which we change to true at the beginning of an action
# and false at the end.
var goal_in_progress = false

var food_posx
var food_posy

var comfort_grid = {}
var GRID_SQUARE_SIZE = 50 # Size of each square in the comfort grid
var cat_window_id

const EULERS_NUMBER = exp(1.0)  # We'll need Euler's number for a couple of our values; as it is not
								# a built-in constant, we just calculate Euler's number 


var personality_seed:  Dictionary = {  # window_movement.gd
	"stress_incr" = randf_range(0.65, 1.15),
	"mouse_spook_timeout" = randf_range(1, 5),
	"desirable_comfort_decline" = randf_range(0.1, 0.3),
	"comfort_decay" = randf_range(0.0005, 0.0015),
	"speed_basis" = randf_range(0.3, 0.7),
	# food_bowl.gd, comfort_map.gd, and cat_animation are not affected by peronality.
	# Instead, the next script affected by personality is activities.gd.
	"wander_stress_weight" = randf_range(1.5, 2.5),  # In particular, these 5 are for deciding which
	"wander_energy_weight" = randf_range(0.3, 0.7),  # activity the cat should do next.
	"rest_stress_weight" = randf_range(2.75, 3.5),
	"rest_energy_weight" = randf_range(0.4, 0.7),
	"most_desirable_energy" = randf_range(2, 3)
}
