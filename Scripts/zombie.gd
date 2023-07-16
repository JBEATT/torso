extends CharacterBody3D

enum States{
	idle,
	patrol,
	pursue,
	wait,
}

@onready var currentState : States
@onready var ap = $AnimationPlayer


@onready var navigationAgent = $NavigationAgent3D
@export var waypoints : Array[Marker3D]
var waypointIndex : int
@export var speed = 7.0
@onready var patrolTimer = $PatrolTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	currentState = States.patrol
	navigationAgent.set_target_position(waypoints[0].global_position)
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	match currentState:
		States.idle:
			ap.play("idle_zombie")
			pass
		States.patrol:
			if (navigationAgent.is_navigation_finished()):
				currentState = States.wait
				patrolTimer.start()
				return
			var targetPosition = navigationAgent.get_next_path_position()
			var direction = global_position.direction_to(targetPosition)
			velocity = direction * speed
			ap.play("run_zombie")
			move_and_slide()
			pass
		States.pursue:
			pass
		States.wait:
			ap.play("idle_zombie")
			pass
	pass


func _on_patrol_timer_timeout():
	currentState = States.patrol
	waypointIndex += 1
	if waypointIndex > waypoints.size() - 1:
		waypointIndex = 0
	navigationAgent.set_target_position(waypoints[waypointIndex].global_position)
	pass # Replace with function body.
