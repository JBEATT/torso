extends CharacterBody3D

enum States{
	idle,
	patrol,
	pursue,
	wait,
	hunt,
}

@onready var currentState : States
@onready var ap = $AnimationPlayer
@onready var player := get_tree().get_nodes_in_group("player")[0]

@onready var navigationAgent = $NavigationAgent3D
@export var waypoints : Array[Marker3D]
var waypointIndex : int
@export var patrolSpeed = 3.0
@export var pursueSpeed = 5.5
@export var huntSpeed = 6.5
@onready var patrolTimer = $PatrolTimer

@onready var playerInEarshot : bool
@onready var playerInEyesightFar : bool
@onready var playerInEyesightClose : bool

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
			MoveTowardsPoint(delta, patrolSpeed)
			print("patrolling")
			pass
		States.pursue:
			if(navigationAgent.is_navigation_finished()):
				patrolTimer.start()
				currentState = States.wait
			navigationAgent.set_target_position(player.global_position)
			MoveTowardsPoint(delta, pursueSpeed)
			print("pursing player")
			pass
		States.wait:
			ap.play("idle_zombie")
			pass
		States.hunt:
			if(navigationAgent.is_navigation_finished()):
				patrolTimer.start()
				currentState = States.wait
			MoveTowardsPoint(delta, huntSpeed)
			print("hunting player")
			pass
	pass
	
func MoveTowardsPoint(delta, patrolSpeed):
	var targetPosition = navigationAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPosition)
	velocity = direction * patrolSpeed
	ap.play("run_zombie")
	look_at(global_position - direction, Vector3.UP)
	move_and_slide()
	if(playerInEarshot):
		CheckForPlayer()
	
func CheckForPlayer():
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create($"Armature/Skeleton3D/Physical Bone mixamorig_Head/CollisionShape3D".global_position, player.get_node("Head/Camera3D").global_position, 1, [self.get_rid()]))
	if result.size() > 0:
		
		if(result["collider"].is_in_group("player")):
			if(playerInEarshot):
				if(result["collider"].crouched == false):
					currentState = States.hunt
					navigationAgent.set_target_position(player.global_position)
					
		if(result["collider"].is_in_group("player")):
			if(playerInEyesightClose):
				currentState = States.pursue
					
		if(result["collider"].is_in_group("player")):
			if(playerInEyesightFar):
				currentState = States.hunt
				navigationAgent.set_target_position(player.global_position)
					

func _on_patrol_timer_timeout():
	currentState = States.patrol
	waypointIndex += 1
	if waypointIndex > waypoints.size() - 1:
		waypointIndex = 0
	navigationAgent.set_target_position(waypoints[waypointIndex].global_position)
	pass # Replace with function body.


func _on_sight_close_body_entered(body):
	if body.is_in_group("player"):
		playerInEyesightClose = true
		print("Player has entered close sight")
	pass # Replace with function body.


func _on_sight_close_body_exited(body):
	if body.is_in_group("player"):
		playerInEyesightClose = false
		print("Player has left close sight")
	pass # Replace with function body.


func _on_sight_far_body_entered(body):
	if body.is_in_group("player"):
		playerInEyesightFar = true
		print("Player has entered far sight")
	pass # Replace with function body.


func _on_sight_far_body_exited(body):
	if body.is_in_group("player"):
		playerInEyesightFar = false
		print("Player has left far sight")
	pass # Replace with function body.



func _on_earshot_body_entered(body):
	if body.is_in_group("player"):
		playerInEarshot = true
		print("Player has entered far earshot")
	pass # Replace with function body.


func _on_earshot_body_exited(body):
		if body.is_in_group("player"):
			playerInEarshot = false
			print("Player has left far earshot")
		pass # Replace with function body.
