extends CharacterBody2D

enum EnemyState {IDLE,CHASING,ATTACK,JUMP}

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var speed : float = 4000 
@export var attack_threshold : float = 40

@export_category("Attacks")
@export var attack_pos_left : Vector2
@export var attack_pos_right : Vector2
@export var attack_path : String
@export var attack2_pos_left : Vector2
@export var attack2_pos_right : Vector2
@export var attack2_path : String
@export var attack3_pos_left : Vector2
@export var attack3_pos_right : Vector2
@export var attack3_path : String

var navigation_ready : bool = false
var attack_pos : String = "right"
var player_ref : CharacterBody2D
var state : EnemyState = EnemyState.IDLE
var attack_instance : PackedScene
var can_change_state : bool = true


func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("Player")
	NavigationServer2D.map_changed.connect(_on_navigation_ready)

func _on_navigation_ready(_map_rid) -> void:
	navigation_ready = true

func _physics_process(delta: float) -> void:
	if player_ref == null: return
	
	move_to_player(delta)
	
	if not is_on_floor(): #Controlamos la gravedad
		velocity.y += 900 * delta
		change_state(EnemyState.JUMP)
	
	var distance_to_target : float = position.distance_to(player_ref.position)
	if distance_to_target <= attack_threshold:
		change_state(EnemyState.ATTACK)
	
	#print(state)
	animation_player.animate(state,sign((position - player_ref.position).x)*-1)


func move_to_player(delta) -> void:
	if not navigation_ready: return
	
	agent.target_position = player_ref.position
	var next_position = agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	
	if state != 2:  #Si no esta atacando...
		velocity.x = direction.x * speed * delta
		move_and_slide()
	
	change_state(EnemyState.CHASING)


func change_state(new_state)->void:
	if can_change_state: state = new_state

#--------CALLABLES-----
func instance_attack(attack_data:int):
	var pos : Vector2 
	match attack_data:
		1:
			attack_instance = load(attack_path)
			pos = attack_pos_left if attack_pos == "left" else attack_pos_right
		2:
			attack_instance = load(attack2_path)
			pos = attack2_pos_left if attack_pos == "left" else attack2_pos_right
		3:
			attack_instance = load(attack3_path)
			pos = attack3_pos_left if attack_pos == "left" else attack3_pos_right
		_:
			attack_instance = load(attack_path)
			pos = attack_pos_left if attack_pos == "left" else attack_pos_right
	
	var instance = attack_instance.instantiate()
	add_child(instance)
	instance.position = pos
