extends Node2D
## Provides the interactive field for the Stellar Object and Observer to interact in.
##
## Calculates the following:
## - The Distance between the Observer and the Stellar Object in Light Years
## - The Luminosity of the Stellar Object determined by its Radius in Solar Radii and its Temperature
##   in Kelvin
## - The Stellar Object's Absolute Magnitude given the ratio between its Luminosity and
##   Zero-Point Luminosity
## - The Stellar Object's Apparent Magnitude given its Absolute Magnitude and Distance from
##   the Observer

var dragging = false

## Signal for communicating that the distance between the observer and the stellar object has changed.
signal stellar_object_distance_changed(distance)

## Signal for communicating that the luminosity of the stellar object has changed.
signal stellar_object_luminosity_changed(luminosity)

## Signal for communicating that the apparent magnitude of the stellar object has changed.
signal stellar_object_apparent_magnitude_changed(apparent_magnitude)

## Signal for communicating that the absolute magnitude of the stellar object has changed.
signal stellar_object_absolute_magnitude_changed(absolute_magnitude)

## The Radius of the Stellar Object in Solar Radii
@export var stellar_object_radius: float 

## The Temperature of the Stellar Object in Kelvin
@export var stellar_object_temperature: int

## How many pixels is a light year?
@export var space_scale: int


## The Distance between the Stellar Object and the Observer in Light Years
var stellar_object_distance: float

## The Luminosity of the Stellar Object in Solar Luminosities
var stellar_object_luminosity: float

## The Absolute Magnitude of the Stellar Object
var stellar_object_absolute_magnitude: float

## The Apparent Magnitude of the Stellar Object from the perspective of the Observer
var stellar_object_apparent_magnitude: float


#const zero_point_luminosity_in_watts = int(3.0128 * pow(10,28))
## Zero Point Luminosity is used to calculate the absolute magnitude of a stellar object.
const zero_point_luminosity_in_petawatts = int(3.0128 * pow(10,13))

#const solar_luminosity_in_watts = int(3.828 * pow(10, 26))
## Solar Luminosity is used to calculate the absolute magnitude of a stellar object.
const solar_luminosity_in_petawatts = int(3.828 * pow(10, 11))


## On Startup Function
func _ready():
	stellar_object_distance = get_stellar_object_distance()
	recalculate_values()


## When a single value is changed by the UI, every calculation needs to be redone. This function recalculates them.
func recalculate_values():
	stellar_object_distance = get_stellar_object_distance()
	stellar_object_luminosity = get_stellar_object_luminosity(stellar_object_radius, stellar_object_temperature)
	stellar_object_absolute_magnitude = get_stellar_object_absolute_magnitude()
	stellar_object_apparent_magnitude = get_stellar_object_apparent_magnitude()
	stellar_object_absolute_magnitude_changed.emit(stellar_object_absolute_magnitude)
	stellar_object_apparent_magnitude_changed.emit(stellar_object_apparent_magnitude)
	stellar_object_luminosity_changed.emit(stellar_object_luminosity)
	stellar_object_distance_changed.emit(stellar_object_distance)


## Only used for moving the Stellar Object around with a click and drag motion
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if (event.position - $StellarObject.position).length() < 32:
			if not dragging and event.pressed:
				dragging = true
		if dragging and not event.pressed:
			dragging = false
	if event is InputEventMouseMotion and dragging:
		$StellarObject.position = event.position
		recalculate_values()


## Returns the Stellar Objects Distance from the Observer in Light Years
func get_stellar_object_distance():
	return ($Observer.position - $StellarObject.position).length() / space_scale


## Returns the Stellar Object's Luminosity in Solar Luminosities using it's Radius and Temperature
func get_stellar_object_luminosity(solar_radii, temperature_kelvin):
	#var R: float
	#var T: float
	var R = pow(solar_radii, 2)
	var T = pow(temperature_kelvin / 5778.0, 4)
	return R * T


## Returns the Apparent Magnitude of the Stellar Object
func get_stellar_object_apparent_magnitude():
	var output = stellar_object_absolute_magnitude - 5 + (5 * log10(get_parsecs_from_light_years(stellar_object_distance)))
	if output > 6.5:
		$Observer.texture = load("res://textures/black_dot.png")
	else:
		$Observer.texture = load("res://textures/green_dot.png")
	return output


## Converts Light Years to Parsecs
func get_parsecs_from_light_years(light_year_val):
	return light_year_val * 0.3066013938



## Returns the Stellar Object's Absolute Magnitude
func get_stellar_object_absolute_magnitude():
	return -2.5 * log10(get_stellar_luminosity_in_petawatts() / zero_point_luminosity_in_petawatts)


## Custom Log Function cos Godot doesn't have a custom log base function >:(
func log10(param):
	return log(param) / log(10)


## Returns the Stellar Object Luminosity in Petawatts
func get_stellar_luminosity_in_petawatts():
	return stellar_object_luminosity * solar_luminosity_in_petawatts



## Sets the Stellar Object Temperature to what the UI has told it to.
## Updates the Sprite based on temperature.
## Recalculates all values.
func on_stellar_object_temperature_changed(temperature):
	stellar_object_temperature = temperature
	if temperature <= 3900:
		$StellarObject.texture = load("res://textures/M_dot.png")
	elif temperature > 3900 and temperature <= 5300:
		$StellarObject.texture = load("res://textures/K_dot.png")
	elif temperature > 5300 and temperature <= 6000:
		$StellarObject.texture = load("res://textures/G_dot.png")
	elif temperature > 6000 and temperature <= 7300:
		$StellarObject.texture = load("res://textures/F_dot.png")
	elif temperature > 7300 and temperature <= 10000:
		$StellarObject.texture = load("res://textures/A_dot.png")
	elif temperature > 10000 and temperature <= 33000:
		$StellarObject.texture = load("res://textures/B_dot.png")
	else:
		$StellarObject.texture = load("res://textures/O_dot.png")
	recalculate_values()


## Sets the Stellar Object's Radius to what the UI has told it to.
## Sets the Sprite's scale to the radius
## Recalculates all values
func on_stellar_object_radius_changed(radius):
	stellar_object_radius = radius
	$StellarObject.scale.x = radius
	$StellarObject.scale.y = radius
	recalculate_values()


## Sets Space's Scale to what the UI has told it to.
## Recalculates all values.
func on_space_scale_changed(new_scale):
	space_scale = new_scale
	recalculate_values()
