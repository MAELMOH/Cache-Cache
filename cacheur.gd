extends CharacterBody3D

var speed = 3.0  # Speed of the Cacheur
var direction = Vector3.ZERO  # Initial direction
var change_direction_time = 5.0  # Time before changing direction
var time_passed = 0.0  # Internal timer

# Called when becoming a chercheur
func become_chercheur():
	print("Cacheur transformed into chercheur!")  # Debugging message
	
	# Change the script to Chercheur
	set_script(load("res://chercheur.gd"))

	# Call the `_ready()` method manually after the script change to reinitialize the Chercheur script
	if has_method("_ready"):
		_ready()

# Existing Cacheur movement logic
func _ready():
	# Generate an initial random direction
	direction = Vector3(randf() - 0.5, 0, randf() - 0.5).normalized()

func _process(delta):
	# Update the timer and change direction if needed
	time_passed += delta
	if time_passed > change_direction_time:
		direction = Vector3(randf() - 0.5, 0, randf() - 0.5).normalized()
		time_passed = 0.0

	# Move the character
	velocity = direction * speed
	move_and_slide()
