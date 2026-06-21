extends Control

@onready var dialog_ui = %DialogUI

var dialog_index: int = 0;

const dialog_lines: Array[String] = [
	"Narrator: In een verre, kleurige wereld genaamd ArithmeRealm leven de Blobs: ronde, stuiterende wezentjes die alles eten... zolang het maar het goede antwoord op hun rekensom is.",
	"Narrator: Elke Bloblem heeft een som op zijn buik - 7 + 5, 9 - 3, 4 x 6 - en als ze niet het juiste antwoord krijgen, worden ze chagrijnig, sloom en uiteindelijk steenhard.",
	"Narrator: Zonder vrolijke Blobs stopt de hele wereld met draaien.",
	"Narrator: Ooit was ArithmeRealm een plek waar rekenen vanzelf ging. De getallen zweefden door de lucht, de sommen klopten altijd, en de Blobs waren blij en actief.",
	"Narrator: Maar toen verscheen een mysterieuze tovenaar: Bad Mathic. Hij werd jaloers op hoe goed iedereen kon rekenen en besloot de wereld te vervloeken.",
	"Narrator: Hij stuurde \"Bad Mathic Monsters\" de wereld in, monsters die getallen stelen, sommen door elkaar gooien en kinderen laten denken dat rekenen \"saai en moeilijk\" is.",
	"Narrator: De monsters raakten bezeten door deze slechte magie en begonnen rond te dwalen in de verschillende gebieden van ArithmeRealm.",
	"Narrator: Overal waar ze komen, raken de Blobs in de war: hun sommen veranderen, antwoorden verdwijnen, en niemand weet nog wat klopt.",
	"Narrator: Als de vloek niet wordt verbroken, versteent het hele rijk en valt ArithmeRealm uit elkaar.",
	"Narrator: Jij speelt een jonge held die per ongeluk via een magisch schoolboek een portaal in wordt gezogen tijdens de rekenles.",
	"Narrator: In het boek stond een simpele som... tot de cijfers opeens van de bladzijde sprongen en een poort vormden. Je belandt in ArithmeRealm, recht voor de Ranch: een soort veilige basis waar vriendelijke Blobs bij elkaar wonen.",
	"Narrator: Hier vind je ook Equalaser, een cartoonachtig wapen dat geen kogels schiet, maar heldere energie die de Bad Mathic Monsters \"onttovert\".",
	"Narrator: Wanneer je een monster verslaat, vallen er cijfers uit: de verloren getallen van ArithmeRealm.",
	"Narrator: Succes in je verhaal en veel rekenplezier",
]


func _ready() -> void:
	%Next.pressed.connect(Next)
	dialog_index = 0
	process_current_line()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("previous_line"):
		if dialog_index > 0:
			dialog_index -= 1
			process_current_line()


func parse_line(line: String) -> Dictionary:
	var line_info = line.split(":")
	assert(len(line_info) >= 2)
	return {
		"speaker_name": line_info[0],
		"dialog_line": line_info[1]
	}


func process_current_line() -> void:
	var line = dialog_lines[dialog_index]
	var line_info = parse_line(line)
	dialog_ui.change_line(line_info["speaker_name"], line_info["dialog_line"])


func Next() -> void:
	if dialog_ui.animate_text:
		dialog_ui.skip_text_animation()
	else:
		if dialog_index < len(dialog_lines) - 1:
			dialog_index += 1
			process_current_line()
		else:
			get_tree().change_scene_to_file("res://project/scenes/levels/tutorial_level.tscn")
