extends NinePatchRect

signal start_game

const CC_UNPICKED_TEXT = "Choccy Chip"
const SJ_UNPICKED_TEXT = "Strawbry Jammer"
const SCC_UNPICKED_TEXT = "Sandwich Cookie Chan"
const ALREADY_PICKED_TEXT = "ALREADY PICKED"


@onready var current_selection: int = GameState.FACTIONS.SANDWICH_COOKIE
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
@onready var can_select: bool = true


func _ready() -> void:
	print("current game dict: ", GameState.current_player_dict)


func _input(event: InputEvent) -> void:
	if is_animating:
		return
	if event.is_action("ui_left"):
		_scroll_left()
	#if event.is_action("ui_right"):
		#_scroll_right()


func _scroll_left():
	is_animating = true
	prints("can_select", can_select)
	can_select = true
	match current_selection:
		GameState.FACTIONS.SANDWICH_COOKIE:
			anim.play("Select_CC_left")
			prints("cc can_select", can_select, cc_has_been_picked)
			if not cc_has_been_picked:
				print('can select cc')
				confirm_button.text = CC_UNPICKED_TEXT
			else:
				print('cannot select cc')
				can_select = false
				confirm_button.text = ALREADY_PICKED_TEXT
			_update_current_selection(GameState.FACTIONS.CHOCCY_CHIP)
			prints("cc can_select", can_select, cc_has_been_picked)
		GameState.FACTIONS.CHOCCY_CHIP:
			anim.play("Select_SJ_left")
			prints("sj can_select", can_select, sj_has_been_picked)
			if not sj_has_been_picked:
				print('can select sj')
				confirm_button.text = SJ_UNPICKED_TEXT
			else:
				print('cannot select sj')
				can_select = false
				confirm_button.text = ALREADY_PICKED_TEXT
			_update_current_selection(GameState.FACTIONS.STRAWBRY_JAMMER)
			prints("sj can_select", can_select, sj_has_been_picked)
		GameState.FACTIONS.STRAWBRY_JAMMER:
			anim.play("Select_SCC_left")
			prints("scc can_select", can_select, scc_has_been_picked)
			if not scc_has_been_picked:
				print('can select scc')
				confirm_button.text = SCC_UNPICKED_TEXT
			else:
				print('cannot select scc')
				can_select = false
				confirm_button.text = ALREADY_PICKED_TEXT
			_update_current_selection(GameState.FACTIONS.SANDWICH_COOKIE)
			prints("scc can_select", can_select, scc_has_been_picked)
	await anim.animation_finished
	is_animating = false


func _update_current_selection(faction_id: int) -> void: 
	current_selection = faction_id


func _on_confirm_pressed() -> void:
	if not can_select:
		return
	print("SELECTING ", current_selection)
	GameState.current_player_dict[current_player_choosing]["faction_id"] = current_selection
	GameState.current_player_dict[current_player_choosing]["is_ai"] = is_ai
	match current_selection:
		GameState.FACTIONS.SANDWICH_COOKIE:
			scc_has_been_picked = true
			$SCC.modulate = Color(200, 200, 200)
		GameState.FACTIONS.CHOCCY_CHIP:
			cc_has_been_picked = true
			$CC.modulate = Color(200, 200, 200)
		GameState.FACTIONS.STRAWBRY_JAMMER:
			sj_has_been_picked = true
			$SJ.modulate = Color(200, 200, 200)
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
