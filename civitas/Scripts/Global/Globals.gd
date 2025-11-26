extends Node

var Ressources
var Money
var People

# mit der kann man den Wert der Variablen von überall aus ändern
func modify(var_name: String, amount: float) -> void:
	var property_list = get_property_list()
	var exists = false
	
	for p in property_list:
		if p.name == var_name:
			exists = true
			break

	if not exists:
		push_error("Globals: Variable '%s' existiert nicht!" % var_name)
		return

	self.set(var_name, self.get(var_name) + amount)
