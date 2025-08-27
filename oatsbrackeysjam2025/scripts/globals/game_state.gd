extends Node

enum PLAYER_IDS {
	PLAYER_1,
	PLAYER_2,
	PLAYER_3,
	PLAYER_4,
}

enum CONTINENT_IDS {
	COOKIES0,
	COOKIES1,
	COOKIES2,
	COOKIES3,
	COOKIES4,
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
	GAME_OVER,
}

const MAX_ARMY_SIZE: int = 10

@onready var current_state: int = STATE_MACHINE.SELECTING_START # For testing confirm button
@onready var current_player_turn: int = GameState.PLAYER_IDS.PLAYER_1 # This gets updated with _update_current_player in the main scene ready function
@onready var current_player_dict: Dictionary = {
	PLAYER_IDS.PLAYER_1: 
		{
			"is_ai": true,
			"faction_id": FACTIONS.SANDWICH_COOKIE,
			"is_eliminated": false,
			"current_armies": [],
		},
	PLAYER_IDS.PLAYER_2: 
		{
			"is_ai": true,
			"faction_id": FACTIONS.SANDWICH_COOKIE,
			"is_eliminated": false,
			"current_armies": [],
		},
	PLAYER_IDS.PLAYER_3: 
		{
			"is_ai": true,
			"faction_id": FACTIONS.SANDWICH_COOKIE,
			"is_eliminated": false,
			"current_armies": [],
		},
	PLAYER_IDS.PLAYER_4: 
		{
			"is_ai": true,
			"faction_id": FACTIONS.SANDWICH_COOKIE,
			"is_eliminated": false,
			"current_armies": [],
		},
}

@onready var number_of_players: int = 2 # This will get updated to an export var controlling the main scene

var current_selected_army: Army
