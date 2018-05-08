# material_import.gd
tool
extends EditorPlugin

var dock
func _enter_tree():
    #import_plugin_xml = preload("import_plugin_xml.gd").new()
    #add_import_plugin(import_plugin_xml)
    #import_plugin_json = preload("import_plugin_json.gd").new()
    #add_import_plugin(import_plugin_json)
    dock = preload("res://addons/atlas_importer3/importer_gui.tscn").instance()
    # Add the loaded scene to the docks:
    add_control_to_dock(DOCK_SLOT_RIGHT_BL,dock)
    #add_control_to_bottom_panel(dock,"Atlas Importer")
    
	
func _exit_tree():
    #remove_import_plugin(import_plugin_xml)
    #import_plugin_xml = null
    #remove_import_plugin(import_plugin_json)
    #import_plugin_json = null
    remove_custom_type("AtlasCutter")
    remove_control_from_docks(dock) # Remove the dock
    #remove_control_from_bottom_panel(dock) # Remove the dock
    #remove_tool_menu_item("Altas Import")
    dock.free() # Erase the control from the memory