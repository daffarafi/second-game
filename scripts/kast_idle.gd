extends State
class_name KastIdle

@export var kast: CharacterBody2D
@export var ray_cast_right:RayCast2D
@export var ray_cast_left:RayCast2D
@export var animated_sprite:AnimatedSprite2D
@export var turn_delay_timer: Timer

var direction = -1
var speed = 50
var is_turning = false  


func Enter() :
	animated_sprite.play("idle")

func Physics_Update(delta: float) :
	if not kast:
		return
	
	if is_turning:
		kast.velocity.x = 0
		return
		
	## Stop character just for debuggin
	kast.velocity.x = 0
	return
	
	# Check collision hanya saat tidak sedang turning
	if ray_cast_right.is_colliding() :
		is_turning = true
		turn_delay_timer.start(2)
		direction = -1
	elif ray_cast_left.is_colliding() :
		is_turning = true
		turn_delay_timer.start(2)
		direction = 1
	kast.velocity.x = direction * speed
	


func _on_timer_timeout() -> void:
	is_turning = false
	# Flip sprite setelah timer selesai dan karakter mulai bergerak lagi
	if direction == -1:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
