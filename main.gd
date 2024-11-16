extends Node3D

# Préchargement des scènes pour Cacheur et Chercheur
var CacheurScene = preload("res://cacheur.tscn")
var ChercheurScene = preload("res://chercheur.tscn")

# Nombre de Cacheurs et Chercheurs à créer
var num_cacheurs = 50
var num_chercheurs = 1

# Limites de la carte pour le placement aléatoire
var map_min_bounds = Vector3(-10, 1, -10)
var map_max_bounds = Vector3(10, 1, 10)

# Suivi du nombre actuel de Cacheurs
var remaining_cacheurs = num_cacheurs
var chercheurs = []  # Liste pour stocker les chercheurs

# Fonction pour générer une position aléatoire dans les limites
func get_random_position() -> Vector3:
	return Vector3(
		randf_range(map_min_bounds.x, map_max_bounds.x),
		map_min_bounds.y,  # Garder les objets au niveau de la scène
		randf_range(map_min_bounds.z, map_max_bounds.z)
	)

func _ready() -> void:
	var static_body = $StaticBody3D

	if static_body:
		var used_positions = []
		
		# Création des cacheurs avec des positions aléatoires uniques
		for i in range(num_cacheurs):
			var cacheur_instance = CacheurScene.instantiate()
			var random_position = get_unique_random_position(used_positions)
			cacheur_instance.global_transform.origin = random_position
			static_body.add_child(cacheur_instance)

		# Création des chercheurs avec des positions aléatoires uniques
		for i in range(num_chercheurs):
			var chercheur_instance = ChercheurScene.instantiate()
			var random_position = get_unique_random_position(used_positions)
			chercheur_instance.global_transform.origin = random_position
			chercheur_instance.get_node("Area3D").connect("body_entered", Callable(self, "_on_body_entered"))
			static_body.add_child(chercheur_instance)
			chercheurs.append(chercheur_instance)  # Ajouter le chercheur à la liste des chercheurs
	else:
		print("StaticBody3D node not found!")

# Fonction pour obtenir une position aléatoire unique qui n'est pas dans les positions utilisées
func get_unique_random_position(used_positions: Array) -> Vector3:
	var position = get_random_position()
	while is_position_used(position, used_positions):
		position = get_random_position()
	used_positions.append(position)
	return position

# Vérifie si une position est déjà utilisée
func is_position_used(position: Vector3, used_positions: Array) -> bool:
	for used_position in used_positions:
		if used_position.distance_to(position) < 2.0:  # Assure une séparation de 2 unités entre les instances
			return true
	return false

# Fonction appelée lorsqu'un Chercheur détecte un Cacheur
func _on_body_entered(body):
	if body.has_method("become_chercheur"):
		print("Cacheur détecté, transformation en Chercheur.")
		var parent = body.get_parent()

		# Récupère la position du Cacheur avant de le supprimer
		var cacheur_position = body.global_transform.origin
		
		# Supprime le Cacheur
		body.queue_free()

		# Met à jour le nombre restant de Cacheurs
		remaining_cacheurs -= 1
		print("Cacheurs restants : ", remaining_cacheurs)

		# Vérifie s'il ne reste plus de Cacheurs
		if remaining_cacheurs <= 0:
			print("Plus de Cacheurs. Pause du jeu.")
			get_tree().paused = true
			return

		# Crée un nouveau Chercheur à la place du Cacheur
		var chercheur_instance = ChercheurScene.instantiate()
		chercheur_instance.global_transform.origin = cacheur_position

		# Connecte le signal de détection pour le nouveau Chercheur
		chercheur_instance.get_node("Area3D").connect("body_entered", Callable(self, "_on_body_entered"))

		# Ajoute le nouveau Chercheur à la scène et à la liste des chercheurs
		parent.add_child(chercheur_instance)
		chercheurs.append(chercheur_instance)

		# Appelle les autres Chercheurs pour les faire rejoindre la position du Cacheur trouvé
		appeler_chercheurs(cacheur_position)

# Fonction pour commander tous les Chercheurs à se déplacer vers la position spécifiée
func appeler_chercheurs(position: Vector3):
	print("Appel des autres Chercheurs pour rejoindre la position : ", position)
	for chercheur in chercheurs:
		chercheur.move_to_position(position)  # Déplace chaque chercheur vers la position spécifiée
