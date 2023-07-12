extends CharacterBody3D


const WALK_SPEED = 5.0
const CROUCH_SPEED = 3.5
const SPRINT_SPEED = 7.0
const JUMP_SPEED =7.5      #(HOW FAST YOU MOVE IN AIR)
const JUMP_VELOCITY = 4    #(JUMP HEIGHT ESSENTIALLY)
const SENSITIVITY = 0.002

var truespeed = WALK_SPEED
var isCrouching = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D

# On ready function.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Handles looking with camera.
func _input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-75), deg_to_rad(75))
		
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

	
func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Handle Inventory.
	if Input.is_action_just_pressed("inventory"):
		$Inventory.visible = !$Inventory.visible
		if $Inventory.visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	# Handle Sprint.
	if Input.is_action_pressed("sprint") and isCrouching == false:
		truespeed = SPRINT_SPEED
	else:
		truespeed = WALK_SPEED
	
	# Adding quirks to raise skill ceiling.
	if Input.is_action_pressed("crouch") and !is_on_floor():
		truespeed = JUMP_SPEED

	# Handle Crouch.
	if Input.is_action_just_pressed("crouch"):
		if isCrouching == false:
			movementStateChange("crouch")
			truespeed = CROUCH_SPEED	
		elif isCrouching == true:
			movementStateChange("uncrouch")
			truespeed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "foward", "back")
	var direction = (head.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * truespeed
			velocity.z = direction.z * truespeed
		else:
			velocity.x = lerp(velocity.x, direction.x * truespeed, delta * 10.0)
			velocity.z = lerp(velocity.z, direction.z * truespeed, delta * 10.0)
	else:
			velocity.x = direction.x * JUMP_SPEED
			velocity.z = direction.z * JUMP_SPEED
			
	move_and_slide()

func movementStateChange(changeType):
	match changeType:
		"crouch":
				$AnimationPlayer.play("StandingToCrouch")
				isCrouching = true
				changeCollisionShapeTo("crouching")
				
		"uncrouch":
			$AnimationPlayer.play_backwards("StandingToCrouch")
			isCrouching = false
			changeCollisionShapeTo("standing")

func changeCollisionShapeTo(shape):
	match shape:
		"crouching":
			#Disabled == false is enabled!
			$CrouchingCollisionShape.disabled = false
			$StandingCollisionShape.disabled = true
		"standing":
			#Disabled == false is enabled!
			$StandingCollisionShape.disabled = false
			$CrouchingCollisionShape.disabled = true
