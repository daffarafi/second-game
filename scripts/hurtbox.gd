extends Area2D
class_name Hurtbox

func _init() -> void :
	collision_layer = 0
	collision_mask = 2
	
func _ready() -> void :
	connect("area_entered", _on_area_entered)

func _on_area_entered(hitbox: Hitbox) -> void :
	print("Hurtbox hit by: ", hitbox)
	if hitbox == null :
		return
		
	if owner.has_method("take_damage") :
		# Get attacker position for knockback calculation
		var attacker_position = Vector2.ZERO
		if hitbox.owner:
			attacker_position = hitbox.owner.global_position
		
		owner.take_damage(hitbox.damage, attacker_position)
