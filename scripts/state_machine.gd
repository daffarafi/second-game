extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is State :
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
	
	# Defer initialization to ensure all @onready variables are ready
	call_deferred("_initialize_state_machine")

func _initialize_state_machine():
	if initial_state :
		initial_state.Enter()
		current_state = initial_state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(delta)
		
func on_child_transition(state, new_state_name) :
	if state != current_state :
		return
	
	var new_state = states.get(new_state_name.to_lower()) 
	
	if !new_state :
		return	
		
	if current_state :
		current_state.Exit()
		
	new_state.Enter()
	
	current_state = new_state
	
