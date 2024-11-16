extends CharacterBody3D

# Variables pour gérer la vitesse et la direction du chercheur
var speed = 3.0
var direction = Vector3(1, 0, 0)
var change_direction_time = 3.0
var time_passed = 0.0

# Signal pour notifier main.gd qu'un cacheur a été trouvé
signal cacheur_trouve(position: Vector3)

func _ready():
	# Initialiser une direction aléatoire
	direction = Vector3(randf() - 0.5, 0, randf() - 0.5).normalized()
	
	# Connecter le signal 'body_entered' pour détecter les collisions avec les cacheurs
	if $Area3D:
		$Area3D.connect("body_entered", Callable(self, "_on_body_entered"))
	else:
		print("Erreur : Area3D non trouvé")

func _process(delta):
	# Mise à jour de la direction aléatoire au bout d'un certain temps
	time_passed += delta
	if time_passed > change_direction_time:
		direction = Vector3(randf() - 0.5, 0, randf() - 0.5).normalized()
		time_passed = 0.0

	# Appliquer la direction et la vitesse
	velocity = direction * speed
	move_and_slide()

# Fonction appelée lorsqu'un autre corps est détecté dans l'Area3D
func _on_body_entered(body):
	if body.name == "Cacheur":
		print("Cacheur trouvé !")
		# Émettre le signal avec la position du cacheur trouvé
		emit_signal("cacheur_trouve", body.global_transform.origin)

# Fonction pour se déplacer vers une position spécifiée (appelée par main.gd)
func move_to_position(target_position: Vector3):
	direction = (target_position - global_transform.origin).normalized()
	velocity = direction * speed
	move_and_slide()
