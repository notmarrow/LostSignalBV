extends CharacterBody3D

# stuff that will be taken out after debugging is done
@onready var textLabel = get_node("/root/main_scene/UI/RichTextLabel")

const SPEED = 10.0
const JUMP_VELOCITY = 7
const SENSITIVITY = 0.001

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8
var signal_strenght = 0
var gamestage : int = 0

@onready var pivot = $pivot
@onready var camera = $pivot/Camera3D

@onready var hotspot1 = get_node("/root/main_scene/map/Hotspot1")
@onready var hotspot2 = get_node("/root/main_scene/map/Hotspot2")
@onready var hotspot3 = get_node("/root/main_scene/map/Hotspot3")
@onready var active_hotspot = hotspot1

@onready var wifi1 = get_node("/root/main_scene/UI/Wifi1")
var distance1 = 170
@onready var wifi2 = get_node("/root/main_scene/UI/Wifi2")
var distance2 = 130
@onready var wifi3 = get_node("/root/main_scene/UI/Wifi3")
var distance3 = 90
@onready var wifi4 = get_node("/root/main_scene/UI/Wifi4")
var distance4 = 50
var active_wifi : TextureRect

var lock : bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		pivot.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	
		
func _process(_delta):
	calculate_hotspot_distance(active_hotspot)

func calculate_hotspot_distance(hots):
	if(active_wifi != null):
		active_wifi.hide()
	if (global_transform.origin.distance_to(hots.global_transform.origin) > distance2):
		active_wifi	= wifi1
	if (global_transform.origin.distance_to(hots.global_transform.origin) < distance2):
		active_wifi = wifi2
	if (global_transform.origin.distance_to(hots.global_transform.origin) < distance3):
		active_wifi = wifi3
	if (global_transform.origin.distance_to(hots.global_transform.origin) < distance4):
		active_wifi = wifi4
		process_message()
		
	if(active_wifi != null):
		active_wifi.show()

func process_message():
	# do stuff with messages
	if(gamestage == 0):
		textLabel.text = "enviando mensajes del primer hotspot..."
		active_hotspot = hotspot2
	if(gamestage == 1):
		textLabel.text = "enviando mensajes del segundo hotspot..."
		active_hotspot = hotspot3
	if(gamestage == 2):
		textLabel.text = "enviando mensajes del tercer hotspot..."
	
	gamestage = gamestage + 1

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
