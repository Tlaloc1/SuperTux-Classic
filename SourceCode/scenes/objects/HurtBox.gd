extends Area2D

onready var sprite = get_node_or_null("Sprite")

func _ready():
	if sprite: sprite.hide()

func _on_Lava_body_entered(body):
	if body.is_in_group("players"):
		body.hurt(self)
	elif body.has_method("die"):
		body.die()
