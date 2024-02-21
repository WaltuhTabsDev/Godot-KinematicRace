# ----Car code for kinematic-----
# ----Made by WaltuhTabs----
# Works without the need for wheels,some had issues for trying to use codes but needed wheels
# But this one works with wheels or not
# Hope this helps! :D

extends KinematicBody

# Speed variables

export var speed = 10 #-- Explains it self!, Game will start with that but will increase or be more!
export var rotation_speed = 1.0 #-- Rotation mesh speed!
export var speed_increase = 0.1 #-- How many will the speed increase will be when you don't hold forward
export var max_speed = 200 #-- Speed is limited to prevent any issues!
export var gravity = -9.8 # the gravity constant

# Drift variables

export var drift = false #-- Enable or disable drift
export var drift_factor = 0.9

# Camera variables
onready var _camera = $CameraHolder #--Locate the camera
onready var cameraholder = $CameraHolder/SpringArm/Camera
onready var target = $gwa/gwgw #-- Locate the mesh(replace with your own mesh)
export var camera_distance = 5.0 #-- Distance for camera
export var camera_height = 2.0 #-- Height settings for camera
export var zoom_factor = 1.0 #-- Factor for zooming in and out
export var min_zoom = 5.0 #-- Minimum zoom distance
export var max_zoom = 15.0 #-- Maximum zoom distance
export var cameramode = 1 # -- !:TPS 2:FPS 3:CuzTPS
export var mouse_sensitivity = 0.01 # -- Mouse Sensitivity
export var disable_rotation = false # -- Don't mess with this unless you are working on something related to it

# Debug variables

export var debug = false # Enable or disable debug, keep it off for stabilty!, it is only for testing
onready var labelspeed = $debug2d/speedlabel # Locate the label for speed
onready var driftbutton = $debug2d/driftbutton

# Respawn variables

export var enablerespawn = true #-- Enable or disable the respawn
export var respawn_position = Vector3(0, 0, 0) # the position to re-spawn the character
export var death_threshold = -100 # the y-axis value to trigger re-spawn

func _ready():
	pass
# Use _physics_process for movement, as we're dealing with a KinematicBody!
func _physics_process(delta):
	var velocity = Vector3()
	if debug == false:
		$debug2d.visible = false
	# Forward and backward movement
	if Input.is_action_pressed('ui_up'):
		velocity += -transform.basis.z
		speed = min(speed + speed_increase, max_speed)
	if Input.is_action_pressed('ui_down'):
		velocity += transform.basis.z
		speed = max(speed - speed_increase, 10)
	if not Input.is_action_pressed('ui_up'):
		speed = max(speed - speed_increase, 10)

	# Rotation
	if disable_rotation == false:
		if Input.is_action_pressed('ui_left'):
			rotate_y(rotation_speed * delta)
		if Input.is_action_pressed('ui_right'):
			rotate_y(-rotation_speed * delta)
#		if Input.is_action_just_pressed("ui_cancel"):
#			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Drift
	if drift:
		velocity = velocity.linear_interpolate(Vector3(), drift_factor)
	# apply gravity to the velocity
	velocity.y += gravity * delta
	# Make sure the model moves at the same speed in all directions
	velocity = velocity.normalized() * speed

	# Move the model
	move_and_slide(velocity) # warning-ignore:return_value_discarded
# Check if the free camera mode is disabled
	 # Update the camera position to follow the target
	if cameramode == 1:
		var target_pos = target.global_transform.origin
		var camera_pos = target_pos + transform.basis.z * camera_distance  # Change - to + here
		camera_pos.y += camera_height
		_camera.global_transform.origin = camera_pos
		_camera.look_at(target_pos, Vector3.UP)
		# Zoom in and out based on the input value
		camera_distance -= Input.get_action_strength("zoom_in") * zoom_factor
		camera_distance += Input.get_action_strength("zoom_out") * zoom_factor
		# Clamp the camera distance to the min and max values
		camera_distance = clamp(camera_distance, min_zoom, max_zoom)
		camera_height = clamp(camera_height, 1.0, 10.0)  # Adjust min and max values as needed
		if Input.is_action_pressed("adjust_camera_height"):
			camera_height += Input.get_action_strength("adjust_camera_height") * delta
		if Input.is_action_pressed("adjust_camera_height1"):
			camera_height -= Input.get_action_strength("adjust_camera_height1") * delta
		if Input.is_action_pressed("adjust_dis"):
			camera_distance += Input.get_action_strength("adjust_dis") * delta
		if Input.is_action_pressed("adjust_dis1"):
			camera_distance -= Input.get_action_strength("adjust_dis1") * delta
	if cameramode == 3:
		_camera.translation = Vector3(0, 4.200, 5)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if cameramode == 2:
		_camera.translation = Vector3(-0.993, 0, -1.066)
	if Input.is_action_pressed("toggle_camera_mode"):
		cameramode = cameramode + 1
		if cameramode > 3:
			cameramode = 1
	if debug == true:
		labelspeed.text = "Speed : " + str(speed) # set the label text
	if debug == true:
		if driftbutton.pressed:
			drift = true
		if not driftbutton.pressed:
			drift = false
	if global_transform.origin.y < death_threshold and enablerespawn == true:
		reset()
func reset():
	# re-spawn the character
	 global_transform.origin = respawn_position
	
func _input(event: InputEvent) -> void:
	if cameramode == 3:
		if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
			cameraholder.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
			cameraholder.rotation.x = clamp(cameraholder.rotation.x, deg2rad(-90),deg2rad(90))
			rotate_y(-event.relative.x * mouse_sensitivity)
