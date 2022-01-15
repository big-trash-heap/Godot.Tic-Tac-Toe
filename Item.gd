extends Node2D

onready var cross = load("res://Sprites/spr_cross.png")
onready var circle = load("res://Sprites/spr_circle.png")

func set_cross():
	$Sprite.texture = cross

func set_circle():
	$Sprite.texture = circle
