extends CharacterBody3D

enum States{
	idle,
	patrol,
	pursue,
}

var currentState : States
var navigationAgent: NavigationAgent3D
@export var waypoints : Array[Marker3D]

# Called when the node enters the scene tree for the first time.
func _ready():
	currentState = States.idle
	navigationAgent = $NavigationAgent3D
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	match currentState:
		States.idle:
			pass
		States.patrol:
			pass
		States.pursue:
			pass
	pass
