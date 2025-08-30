extends Node

enum PLAYER_IDS {
	PLAYER_1,
	PLAYER_2,
	PLAYER_3,
}

enum CONTINENT_IDS {
	COOKIES0,
	COOKIES1,
	COOKIES2,
	COOKIES3,
}

enum FACTIONS {
	SANDWICH_COOKIE,
	CHOCCY_CHIP,
	STRAWBRY_JAMMER,
}

enum STATE_MACHINE {
	DISABLED,
	SELECTING_START,
	CONFIRMING_START,
	SELECTING_IN_GAME,
	CONFIRMING_IN_GAME,
	TRANSITIONING,
	ATTACK_HAPPENING,
	GAME_OVER,
}

const MAX_ARMY_SIZE: int = 9
const MAX_PLAYER_COUNT: int = 3
const TILE_ADJACENT_MAP_DICT: Dictionary = {
	1: [7,8,11],
	2: [3,5,8],
	3: [2,4,5,14],
	4: [3,5,16],
	5: [2,3,4],
	7: [8,1],
	8: [1,2,7],
	9: [12,14,15],
	10: [11,12,13],
	11: [1,10,12,13],
	12: [9,10,11,13,14],
	13: [10,11,12,14],
	14: [3,9,12,13],
	15: [9,16],
	16: [4,15, 17],
	17: [16,18],
	18: [17],
}

@onready var current_state: int = STATE_MACHINE.SELECTING_START # For testing confirm button
@onready var current_player_turn: int = GameState.PLAYER_IDS.PLAYER_1 # This gets updated with _update_current_player in the main scene ready function
@onready var current_player_dict: Dictionary = {
	PLAYER_IDS.PLAYER_1: 
		{
			"is_ai": true,
			"faction_id": FACTIONS.SANDWICH_COOKIE,
			"is_eliminated": true,
		},
	PLAYER_IDS.PLAYER_2: 
		{
			"is_ai": true,
			"faction_id": FACTIONS.SANDWICH_COOKIE,
			"is_eliminated": true,
		},
	PLAYER_IDS.PLAYER_3: 
		{
			"is_ai": true,
			"faction_id": FACTIONS.SANDWICH_COOKIE,
			"is_eliminated": true,
		},
}

@onready var current_continent_control_dict: Dictionary = {
	CONTINENT_IDS.COOKIES0:
		{
			"controlling_player": -99,
			"continent_size": 4,
			"continent_bonus": 1,
		},
	CONTINENT_IDS.COOKIES1:
		{
			"controlling_player": -99,
			"continent_size": 4,
			"continent_bonus": 1,
		},
	CONTINENT_IDS.COOKIES2:
		{
			"controlling_player": -99,
			"continent_size": 5,
			"continent_bonus": 2,
		},
	CONTINENT_IDS.COOKIES3:
		{
			"controlling_player": -99,
			"continent_size": 4,
			"continent_bonus": 1,
		},
}

@onready var number_of_players: int = 2 # This will get updated to an export var controlling the main scene
@onready var menu_open: bool = true # This will get updated to an export var controlling the main scene

var current_selected_army: Army


func update_state(new_state: int) -> void:
	#prints("updating to state", new_state)
	current_state = new_state
