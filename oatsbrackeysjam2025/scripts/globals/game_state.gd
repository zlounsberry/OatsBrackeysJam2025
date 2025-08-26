extends Node

enum PLAYER_IDS {
	PLAYER_1,
	PLAYER_2,
	PLAYER_3,
	PLAYER_4,
	PLAYER_99,
}

enum FACTIONS {
	SANDWICH_COOKIE_CHAN,
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

const MAX_ARMY_SIZE: int = 7

@onready var current_state: int = STATE_MACHINE.SELECTING_IN_GAME # For testing confirm button
@onready var current_player_turn: int = GameState.PLAYER_IDS.PLAYER_99 # This gets updated with _update_current_player in the main scene ready function
@onready var current_player_dict: Dictionary = {
	PLAYER_IDS.PLAYER_1: 
		{
			"is_ai": true,
			"faction_id": FACTIONS.SANDWICH_COOKIE_CHAN,
			"is_eliminated": false
		},
	PLAYER_IDS.PLAYER_2: 
		{
			"is_ai": true,
			"faction_id": FACTIONS.SANDWICH_COOKIE_CHAN,
			"is_eliminated": false
		},
	PLAYER_IDS.PLAYER_3: 
		{
			"is_ai": true,
			"faction_id": FACTIONS.SANDWICH_COOKIE_CHAN,
			"is_eliminated": false
		},
	PLAYER_IDS.PLAYER_4: 
		{
			"is_ai": true,
			"faction_id": FACTIONS.SANDWICH_COOKIE_CHAN,
			"is_eliminated": false
		},
}

@onready var number_of_players: int = 2 # This will get updated to an export var controlling the main scene
