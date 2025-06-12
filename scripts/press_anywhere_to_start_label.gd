extends Label

var fade_tween: Tween
var fade_duration = 1.0  # Duration for one fade cycle (in/out)
var min_alpha = 0.3      # Minimum transparency
var max_alpha = 1.0      # Maximum transparency

func _ready() -> void:
	# Start the flashing animation
	start_flashing_animation()

func start_flashing_animation():
	# Create a new tween for smooth fading
	fade_tween = create_tween()
	fade_tween.set_loops()  # Loop infinitely
	
	# Fade from max to min alpha
	fade_tween.tween_property(self, "modulate:a", min_alpha, fade_duration / 2)
	# Fade from min to max alpha
	fade_tween.tween_property(self, "modulate:a", max_alpha, fade_duration / 2)
	

func stop_flashing():
	# Stop the animation and return to full opacity
	if fade_tween:
		fade_tween.kill()
	modulate.a = max_alpha

func _exit_tree():
	# Clean up tween when node is removed
	if fade_tween:
		fade_tween.kill()
