extends Control
## Enables interaction with the Space Node to modify Stellar Object Variables


const dist_lbl_pretext = "Distance from Observer: "

const lum_lbl_pretext = "Stellar Luminosity (SolLum): "

const abmag_lbl_pretext = "Absolute Magnitude: "

const apmag_lbl_pretext = "Apparent Magnitude: "

signal temperature_changed(temperature)

signal radius_changed(radius)

signal scale_changed(scale)


func _ready():
	temperature_changed.emit($Panel/Temperature_SpinBox.value)
	radius_changed.emit($Panel/StellarRadius_SpinBox.value)
	scale_changed.emit($Panel/Scale_SpinBox.value)


func update_distance_label(dist):
	$Panel/Distance_Label.text = dist_lbl_pretext + str(dist)


func update_luminosity_label(luminosity):
	$Panel/DependencyPanel/Luminosity_Label.text = lum_lbl_pretext + str(luminosity)


func update_apparent_magnitude_label(apparent_magnitude):
	$Panel/DependencyPanel/ApMag_Label.text = apmag_lbl_pretext + str(apparent_magnitude)


func update_absolute_magnitude_label(absolute_magnitude):
	$Panel/DependencyPanel/AbMag_Label.text = abmag_lbl_pretext + str(absolute_magnitude)


func _on_temperature_spin_box_value_changed(value):
	temperature_changed.emit(value)


func _on_stellar_radius_spin_box_value_changed(value):
	radius_changed.emit(value)


func _on_scale_spin_box_value_changed(value):
	scale_changed.emit(value)
