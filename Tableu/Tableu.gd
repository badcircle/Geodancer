extends Node2D

var figures = {}
@export_node_path var dice
@export_node_path var mothers_daughters
@export_node_path var nieces
@export_node_path var witnesses
@export_node_path var final
var mother1 = ["die16", "die15", "die14", "die13"]
var mother2 = ["die12", "die11", "die10", "die9"]
var mother3 = ["die8", "die7", "die6", "die5"]
var mother4 = ["die4", "die3", "die2", "die1"]

# Called when the node enters the scene tree for the first time.
func _ready():
	dice = get_node(dice)
	mothers_daughters = get_node(mothers_daughters)
	nieces = get_node(nieces)
	witnesses = get_node(witnesses)
	final = get_node(final)
	figures["Way"] = Vector4(1, 1, 1, 1)
	figures["Populus"] = Vector4(2, 2, 2, 2)
	figures["Conjunctia"] = Vector4(2, 1, 1, 2)
	figures["Carcer"] = Vector4(1, 2, 2, 1)
	figures["Caput Draconis"] = Vector4(2, 1, 1, 1)
	figures["Cauda Draconis"] = Vector4(1, 1, 1, 2)
	figures["Puella"] = Vector4(1, 1, 2, 1)
	figures["Puer"] = Vector4(1, 2, 1, 1)
	figures["Fortuna Major"] = Vector4(2, 2, 1, 1)
	figures["Fortuna Minor"] = Vector4(1, 1, 2, 2)
	figures["Rubeus"] = Vector4(2, 1, 2, 2)
	figures["Albus"] = Vector4(2, 2, 1, 2)
	figures["Acquisitio"] = Vector4(2, 1, 2, 1)
	figures["Amissio"] = Vector4(1, 2, 1, 2)
	figures["Tristitia"] = Vector4(2, 2, 2, 1)
	figures["Laetitia"] = Vector4(1, 2, 2, 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("Cast Dice"):
		var cast = cast_dice()
#		var mother = build_mother(cast)

func cast_dice():
	var cast = {}
	for _i in dice.get_children():
		var die = str(randi_range(9,20))
		_i.text = die
		cast[_i.name] = die
	return cast

func build_mother(cast):
	var mother = Vector4.ZERO
	if int(cast.die16) % 2 == 1:
		mother.x = 1
	else:
		mother.x = 2
	if int(cast.die16) % 2 == 1:
		mother.y = 1
	else:
		mother.y = 2
	if int(cast.die16) % 2 == 1:
		mother.z = 1
	else:
		mother.z = 2
	if int(cast.die16) % 2 == 1:
		mother.w = 1
	else:
		mother.w = 2
	var name = figures.find_key(mother)
	$mother1.text = str(name)
	return mother
