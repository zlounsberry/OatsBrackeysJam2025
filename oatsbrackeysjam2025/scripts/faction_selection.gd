extends NinePatchRect

signal start_game

const CC_UNPICKED_TEXT = "Choccy Chip"
const SJ_UNPICKED_TEXT = "Strawbry Jammer"
const SCC_UNPICKED_TEXT = "Sandwich Cookie Chan"
const ALREADY_PICKED_TEXT = "ALREADY PICKED"


@onready var current_selection: int = GameState.FACTIONS.STRAWBRY_JAMMER
@onready var left_position: Vector2 = $SCC.position
@onready var right_position: Vector2 = $CC.position
@onready var center_position: Vector2 = $SJ.position
@onready var is_animating: bool = false
@onready var is_ai: bool = false
@onready var current_player_choosing: int = 0
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var confirm_button: Button = $Confirm
@onready var scc_has_been_picked: bool = false
@onready var cc_has_been_picked: bool = false
@onready var sj_has_been_picked: bool = false
@onready var can_select: bool = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		_on_next_team_pressed()


func _scroll_left():
	is_animating = true
	can_select = true
	match current_selection:
		GameState.FACTIONS.SANDWICH_COOKIE:
			anim.play("Select_CC_left")
			if not cc_has_been_picked:
				confirm_button.text = CC_UNPICKED_TEXT
			else:
				can_select = false
				confirm_button.text = ALREADY_PICKED_TEXT
			_update_current_selection(GameState.FACTIONS.CHOCCY_CHIP)
		GameState.FACTIONS.CHOCCY_CHIP:
			anim.play("Select_SJ_left")
			if not sj_has_been_picked:
				confirm_button.text = SJ_UNPICKED_TEXT
			else:
				can_select = false
				confirm_button.text = ALREADY_PICKED_TEXT
			_update_current_selection(GameState.FACTIONS.STRAWBRY_JAMMER)
		GameState.FACTIONS.STRAWBRY_JAMMER:
			anim.play("Select_SCC_left")
			if not scc_has_been_picked:
				confirm_button.text = SCC_UNPICKED_TEXT
			else:
				can_select = false
				confirm_button.text = ALREADY_PICKED_TEXT
			_update_current_selection(GameState.FACTIONS.SANDWICH_COOKIE)
	await anim.animation_finished
	is_animating = false


func _update_current_selection(faction_id: int) -> void: 
	current_selection = faction_id


func _on_confirm_pressed() -> void:
	if not can_select:
		return
	$AI.disabled = false
	can_select = false
	confirm_button.text = ALREADY_PICKED_TEXT
	GameState.current_player_dict[current_player_choosing]["faction_id"] = current_selection
	prints("GameState.current_player_dict[current_player_choosing]['is_ai'] =", is_ai)
	GameState.current_player_dict[current_player_choosing]["is_ai"] = is_ai
	match current_selection:
		GameState.FACTIONS.SANDWICH_COOKIE:
			scc_has_been_picked = true
			$SCC.get_node("Sprite").modulate.a = 0.4
		GameState.FACTIONS.CHOCCY_CHIP:
			cc_has_been_picked = true
			$CC.get_node("Sprite").modulate.a = 0.4
		GameState.FACTIONS.STRAWBRY_JAMMER:
			sj_has_been_picked = true
			$SJ.get_node("Sprite").modulate.a = 0.4
	current_player_choosing += 1
	if current_player_choosing >= GameState.number_of_players:
		print("game start!")
		start_game.emit()
		GameState.update_state(GameState.STATE_MACHINE.SELECTING_IN_GAME)
		GameState.menu_open = false
		self.queue_free()


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		is_ai = true
		prints('is ai', is_ai)
	else:
		is_ai = false
		prints('is ai', is_ai)
		


func _on_next_team_pressed() -> void:
	if is_animating:
		return
	$NextTeam.text = "Next Faction"
	_scroll_left()
