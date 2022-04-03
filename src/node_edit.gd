extends GraphEdit




var file_dialog
export (Array, PackedScene) var effect_node_list
var effect_node = preload("res://Nodes/effect_node.gd")

func _ready():
	file_dialog = find_node("NodeFileDialog")
	file_dialog.filters = ["*.eff"]
	translate_nodes()
	scroll_offset = Vector2( - 180, - 150)
	add_valid_connection_type(0, 0)
	add_valid_left_disconnect_type(0)
	add_valid_right_disconnect_type(0)
	
	_on_GraphEdit_connection_request("SourceNode", 0, "OutputNode", 0)
	
	for item in effect_node_list:
		$PopupMenu / EffectNodes.add_item(str(item.get_state().get_node_name(0)))
	$PopupMenu.add_submenu_item(tr("MENU_ADD_NODE"), "EffectNodes")
	
	pass





func clear_nodes():
	for i in get_children():
		if i is effect_node:
			remove_node(i)
	_on_GraphEdit_connection_request("SourceNode", 0, "OutputNode", 0)

func get_nodes():
	var nodes = []
	for i in get_children():
		if i is effect_node:
			var node_dict = {}
			node_dict["type"] = i.type
			node_dict["position"] = global.vec_to_dict(i.offset)
			node_dict["values"] = i.get_values()
			nodes.push_back(node_dict)
	nodes.push_back({"type": - 1, "position":global.vec_to_dict(get_node("SourceNode").offset)})
	nodes.push_back({"type": - 2, "position":global.vec_to_dict(get_node("OutputNode").offset)})
	return nodes

func get_connections():
	return get_connection_list()
	
	
func create_effects_from_dict(dict):
	clear_connections()
	for i in global.try_key(dict, "nodes"):
		if i["type"] > - 1:
			var new_node = add_node(i["type"])
			new_node.offset = global.dict_to_vec(i["position"])
			if i.has("values"):
				new_node.set_values(i["values"])
		else :
			if i["type"] == - 1:
				get_node("SourceNode").offset = global.dict_to_vec(i["position"])
			elif i["type"] == - 2:
				get_node("OutputNode").offset = global.dict_to_vec(i["position"])
	for i in dict["connections"]:
		_on_GraphEdit_connection_request(i["from"], i["from_port"], i["to"], i["to_port"])
	pass

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	
	global.history.create_action("Connect node")
	global.history.add_do_method(get_node(to), "set_input", get_node(from))
	global.history.add_undo_method(get_node(to), "clear_input")
	
	disconnect_existing(to)
	
	global.history.add_do_method(self, "connect_node", from, from_slot, to, to_slot)
	global.history.add_undo_method(self, "disconnect_node", from, from_slot, to, to_slot)
	global.history.commit_action()
	pass


func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	var prev_input = get_node(to).get_input()
	global.history.create_action("Disconnect node")
	global.history.add_do_method(get_node(to), "clear_input")
	global.history.add_undo_method(get_node(to), "set_input", prev_input)
	global.history.add_do_method(self, "disconnect_node", from, from_slot, to, to_slot)
	global.history.add_undo_method(self, "connect_node", from, from_slot, to, to_slot)
	global.history.commit_action()
	
	
	pass


func disconnect_existing(to):
	var list = get_connection_list()
	for item in list:
		if item.to == to:
			global.history.add_do_method(self, "disconnect_node", item.from, item.from_port, item.to, item.to_port)
			global.history.add_undo_method(self, "connect_node", item.from, item.from_port, item.to, item.to_port)
			
	

func _on_GraphEdit_gui_input(ev):
	if ev is InputEventMouse or ev is InputEventMouseButton:
		if ev.is_pressed():
			$PopupMenu.hide()
		if ev.is_pressed() and ev.button_index == BUTTON_MASK_RIGHT:
			$PopupMenu.rect_position = rect_global_position + ev.position
			$PopupMenu.show()
	pass


func _on_EffectNodes_index_pressed(index):
	var new_node = add_node(index)
	new_node.offset = get_local_mouse_position() + scroll_offset - new_node.get_rect().size / 2
	pass

func add_node(type):
	var new_node = effect_node_list[type].instance()
	new_node.type = type
	
	global.history.create_action("add effect node")
	global.history.add_do_method(self, "add_child", new_node)
	global.history.add_undo_method(self, "remove_child", new_node)
	global.history.add_do_reference(new_node)
	global.history.add_do_method(new_node, "connect", "node_closed", self, "remove_node")
	global.history.add_undo_method(new_node, "disconnect", "node_closed", self, "remove_node")
	global.history.commit_action()
	
	return new_node
func _on_GraphEdit_delete_nodes_request():
	var to_erase = []
	for c in get_children():
		if c is GraphNode and c.is_selected() and c.is_close_button_visible():
			to_erase.push_back(c)
	clean_up_and_remove_node(to_erase)
	pass
	

func remove_node(node):
	clean_up_and_remove_node([node])

func clean_up_and_remove_node(nodes):
	global.history.create_action("Remove effect node")
	var list = get_connection_list()
	for n in nodes:
		for item in list:
			if item.to == n.get_name():
				global.history.add_do_method(self, "disconnect_node", item.from, item.from_port, item.to, item.to_port)
				global.history.add_undo_method(self, "connect_node", item.from, item.from_port, item.to, item.to_port)
				

			if item.from == n.get_name():
				global.history.add_do_method(self, "disconnect_node", item.from, item.from_port, item.to, item.to_port)
				global.history.add_undo_method(self, "connect_node", item.from, item.from_port, item.to, item.to_port)
				
				global.history.add_do_method(get_node(item.to), "clear_input")
				global.history.add_undo_method(get_node(item.to), "set_input", get_node(item.to).get_input())
				
		global.history.add_do_method(self, "remove_child", n)
		global.history.add_undo_method(self, "add_child", n)
		global.history.add_undo_reference(n)
		global.history.commit_action()
		
		
func get_average_position():
	var pos = Vector2()
	var count = 0
	for i in get_children():
		if i is GraphNode:
			count += 1
			pos += (i.get_rect().position) - (i.get_rect().size / 2)
	return - (pos / count)


func translate_nodes():
	for i in get_children():
		if i is GraphNode:
			i.translate_node()


func _on_LanguageMenu_lang_updated():
	translate_nodes()
	pass


func _on_Effects__begin_node_move():
	pass





func _on_OutputNode_dragged(from, to):
	global.history.create_action("Node moved")
	global.history.add_do_property($OutputNode, "offset", to)
	global.history.add_undo_property($OutputNode, "offset", from)
	global.history.commit_action()
	pass


func _on_SourceNode_dragged(from, to):
	global.history.create_action("Node moved")
	global.history.add_do_property($SourceNode, "offset", to)
	global.history.add_undo_property($SourceNode, "offset", from)
	global.history.commit_action()
	pass

func _draw():
	draw_string(global.font, Vector2(16, get_rect().size.y - 16), "Right-click to add a new effect", Color(1, 1, 1, 0.6))

func _on_NodeFileDialog_file_selected(path):
	match (file_dialog.mode):
		FileDialog.MODE_SAVE_FILE:
			var data = to_json({"nodes":get_nodes(), "connections":get_connections()})
			var file = File.new()
			var err = file.open(path, File.WRITE)
			if err != 0:
				InfoDialog.show_info("Error: Unable to save node configuration file!")
				return 
			file.store_line(data)
			file.close()
		
		FileDialog.MODE_OPEN_FILE:
			var file = File.new()
			var err = file.open(path, File.READ)
			if err != 0:
				InfoDialog.show_info("Error: Unable to open node configuration file!")
				return 
			var file_data = parse_json(file.get_line())
			file.close()
			if not file_data:
				InfoDialog.show_info("Error: Invalid node configuration file!")
				return 

				
			yield (get_tree(), "idle_frame")
			clear_nodes()
			create_effects_from_dict(file_data)

	pass


func _on_LoadButton_pressed():
	file_dialog.window_title = "Open Node Configuration"
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.popup_centered()
	pass


func _on_SaveButton_pressed():
	file_dialog.window_title = "Save Node Configuration"
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	file_dialog.popup_centered()
	pass
