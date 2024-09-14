extends Node3D

@onready var _area_3d: Area3D = %Area3D


func _ready() -> void:
	_area_3d.body_entered.connect(func (_body_that_entered: PhysicsBody3D) -> void:
		Events.flag_reached.emit()
	)
