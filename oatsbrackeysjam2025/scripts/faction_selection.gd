extends NinePatchRect

signal start_game

@onready var current_selection: int = GameState.FACTIONS.SANDWICH_COOKIE
@onready var left_position: Vector2 = $SCC.position
@onready var right_position: Vector2 = $CC.position
@onready var center_position: Vector2 = $SJ.position
@onready var is_animating: bool = false
@onready var is_ai: bool = false
@onready var current_player_choosing: int = 0
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var confirm_button: Button = $Confirm


func _ready() -> void:
#	 Initialize player dictionary
	#for value in range(GameState.number_of_players):
		#GameState.current_player_dict[value]["faction_id"] = -99
		#GameState.current_player_dict[value]["is_ai"] = false
		#GameState.current_player_dict[value]["is_eliminated"] = false
	print("current game dict: ", GameState.current_player_dict)
	#is_animating = true
	#anim.play("Select_SCC_left")
	#await anim.animation_finished
	#is_animating = false


func _input(event: InputEvent) -> void:
	if is_animating:
		return
	if event.is_action("ui_left"):
		_scroll_left()
	if event.is_action("ui_right"):
		_scroll_right()


func _scroll_left():
	is_animating = true
	match current_selection:
		GameState.FACTIONS.SANDWICH_COOKIE:
			anim.play("Select_CC_left")
			_update_current_selection(GameState.FACTIONS.CHOCCY_CHIP)
			confirm_button.text = "CHOCCY CHIP"
			#current_selection = GameState.FACTIONS.SANDWICH_COOKIE
		GameState.FACTIONS.CHOCCY_CHIP:
			anim.play("Select_SJ_left")
			_update_current_selection(GameState.FACTIONS.STRAWBRY_JAMMER)
			confirm_button.text = "STRAWBRY JAMMER"
			#current_selection = GameState.FACTIONS.CHOCCY_CHIP
		GameState.FACTIONS.STRAWBRY_JAMMER:
			anim.play("Select_SCC_left")
			_update_current_selection(GameState.FACTIONS.SANDWICH_COOKIE)
			confirm_button.text = "SANDWICH_COOKIE"
			#current_selection = GameState.FACTIONS.STRAWBRY_JAMMER
	await anim.animation_finished
	is_animating = false


func _scroll_right():
	is_animating = true
	match current_selection:
		GameState.FACTIONS.SANDWICH_COOKIE:
			anim.play("Select_SJ_right")
			_update_current_selection(GameState.FACTIONS.STRAWBRY_JAMMER)
			confirm_button.text = "STRAWBRY JAMMER"
		GameState.FACTIONS.CHOCCY_CHIP:
			anim.play("Select_SCC_right")
			_update_current_selection(GameState.FACTIONS.SANDWICH_COOKIE)
			confirm_button.text = "SANDWICH COOKIE"
		GameState.FACTIONS.STRAWBRY_JAMMER:
			anim.play("Select_CC_right")
			_update_current_selection(GameState.FACTIONS.CHOCCY_CHIP)
			confirm_button.text = "CHOCCY CHIP"
	await anim.animation_finished
	is_animating = false


func _update_current_selection(faction_id: int) -> void: 
	current_selection = faction_id


func _on_confirm_pressed() -> void:
	GameState.current_player_dict[current_player_choosing]["faction_id"] = current_selection
	GameState.current_player_dict[current_player_choosing]["is_ai"] = is_ai
	current_player_choosing += 1
	if current_player_choosing >= GameState.number_of_players:
		start_game.emit()
		GameState.current_state = GameState.STATE_MACHINE.SELECTING_IN_GAME 
		self.queue_free()


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		is_ai = true
	else:
		is_ai = false
