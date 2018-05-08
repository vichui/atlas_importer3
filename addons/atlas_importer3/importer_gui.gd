tool
extends MarginContainer

var AtlasParser = preload("res://addons/atlas_importer3/atlas.gd")
var fileDialog = FileDialog.new()
const SEL_INPUT_META = 0;
const SEL_OUTPUT_TEX = 1;
const SEL_OUTPUT_FOLDER= 2;
var current_dialog = -1;

onready var sourceBrowse = $Input/Source/Browse
onready var targetBrowse = $Input/Target/Browse
onready var folderBrowse = $Input/Folder/Browse
onready var typeButton = $Input/Type/TypeButton

onready var sourceText = $Input/Source/MetaFileField
onready var targetText = $Input/Target/TargetDirField
onready var folderText = $Input/Folder/FolderField

func _ready():
	typeButton.select(0)
	fileDialog.connect("file_selected", self, "_fileSelected")
	fileDialog.connect("dir_selected", self, "_fileSelected")
	add_child(fileDialog)

	sourceBrowse.connect("pressed",self,"_on_SourceBrowse_pressed")
	targetBrowse.connect("pressed",self,"_selectTargetFile")
	folderBrowse.connect("pressed",self,"_selectFolderFile")
	typeButton.connect("item_selected", self, "_typeSelected")
	
	$Input/Button.connect("pressed",self,"_saveAtlas")
	
	print("ready")
	#et_node("Atlas Importer/Input/Source/Browse").connect("pressed", self, "_selectMetaFile")
	#print(get_node("Atlas Importer/Input/Source/Browse"))
	# Called every time the node is added to the scene.
	# Initialization here
func _typeSelected(id):
	var curtype = id
	if curtype in [AtlasParser.FORMAT_TEXTURE_PACKER_XML, AtlasParser.FORMAT_KENNEY_SPRITESHEET]:
		if !sourceText.text.ends_with(".xml"):
			sourceText.text = ""
	elif curtype in [AtlasParser.FORMAT_TEXTURE_JSON, AtlasParser.FORMAT_ATTILA_JSON]:
		if !sourceText.text.ends_with(".json"):
			sourceText.text = ""
	elif curtype in [AtlasParser.FORMAT_GDX_TEXTURE_PACKER]:
		if !sourceText.text.ends_with(".atlas"):
			sourceText.text = ""

func _showFileDialog():
	fileDialog.set_custom_minimum_size(Vector2(640, 480))
	var file = File.new()
	if fileDialog.get_access() == FileDialog.ACCESS_RESOURCES:
		var path = ""
		if SEL_INPUT_META==current_dialog:
			path = $Input/Source/MetaFileField.text
		if SEL_OUTPUT_TEX==current_dialog:
			path = targetText.text
		
		if file.file_exists(path):
			fileDialog.set_current_dir(_getParentDir(path))
	fileDialog.popup_centered()
	fileDialog.invalidate()
	pass
func _fileSelected(path):
	print(path)
	match current_dialog:
		SEL_INPUT_META:
			sourceText.text = path
			pass
		SEL_OUTPUT_TEX:
			targetText.text = path
			pass
		SEL_OUTPUT_FOLDER:
			folderText.text = path
			pass
		_:
			pass
	current_dialog = -1
	
	 
func _on_SourceBrowse_pressed():
	current_dialog = SEL_INPUT_META
	fileDialog.clear_filters()
	fileDialog.set_access(FileDialog.ACCESS_RESOURCES)
	fileDialog.set_mode(FileDialog.MODE_OPEN_FILE)
	print(typeButton)
	var curtype = typeButton.get_selected_id()
	if curtype in [AtlasParser.FORMAT_TEXTURE_PACKER_XML, AtlasParser.FORMAT_KENNEY_SPRITESHEET]:
		fileDialog.add_filter("*.xml")
	elif curtype in [AtlasParser.FORMAT_TEXTURE_JSON, AtlasParser.FORMAT_ATTILA_JSON]:
		fileDialog.add_filter("*.json")
	elif curtype in [AtlasParser.FORMAT_GDX_TEXTURE_PACKER]:
		fileDialog.add_filter("*.atlas")
	_showFileDialog()
	
func _selectTargetFile(): 
	current_dialog = SEL_OUTPUT_TEX
	fileDialog.clear_filters()
	fileDialog.add_filter("*.png,*.jep,*.jpeg")
	fileDialog.set_access(FileDialog.ACCESS_RESOURCES)
	fileDialog.set_mode(FileDialog.MODE_OPEN_FILE)
	_showFileDialog()
	
func _selectFolderFile():
	current_dialog = SEL_OUTPUT_FOLDER
	fileDialog.clear_filters()
	fileDialog.set_access(FileDialog.ACCESS_RESOURCES)
	fileDialog.set_mode(FileDialog.MODE_OPEN_DIR)
	_showFileDialog()

func _saveAtlas():
	print("Save Atlas")
	if sourceText.text.empty():
		printerr("Source is required")
		return
	if folderText.text.empty():
		printerr("Save Folder is required")
		return
	if targetText.text.empty():
		printerr("Texture is required")
		return
	var atlas = _loadAtlas(sourceText.text, typeButton.get_selected_id()) 
	var path = folderText.text
	var tarf=targetText.text
	if path.begins_with("res://"):
		path = path.substr(6,path.length()-6)	
	#if tarf.begins_with("res://"):
	#	tarf = tarf.substr(6,tarf.length()-6)	
	var tarDir = folderText.text
	atlas.imagePath = tarf
	print(atlas.imagePath)
	var sprite= _loadAtlasTex(path,atlas);
	
	# Remove exsits atexs
	var dir = Directory.new() 
	if dir.open(tarDir) == OK:
		dir.list_dir_begin()
		var f = dir.get_next()
		while f.length():				
			if f.begins_with(str(_getFileName(sourceText.text), ".")) and f.ends_with(".atlastex") and dir.file_exists(f):
				print("remove: ",f)
				print(dir.remove(f)==OK)
			f = dir.get_next()

	
	for s in atlas.sprites:
		var atex = AtlasTexture.new()
		var ap = str(tarDir, "/", _getFileName(sourceText.text), ".", _getFileName(s.name),".atlastex")		
		if not ResourceLoader.has(ap):
			atex.set_path(ap)
		else:
			atex.take_over_path(ap)
		atex.set_path(ap)
		atex.set_name(_getFileName(s.name))
		atex.set_atlas(sprite)
		atex.set_region(s.region)
		ResourceSaver.save(ap, atex)
	

func _getParentDir(path):
	var fileName = path.substr(0, path.find_last("/"))
	return fileName

func _getFileName(path):
	var fileName = path.substr(path.find_last("/")+1, path.length() - path.find_last("/")-1)
	var dotPos = fileName.find_last(".")
	if dotPos != -1:
		fileName = fileName.substr(0,dotPos)
	return fileName
	
func _loadAtlas(metaPath, format):
	var atlas = AtlasParser.new()
	atlas.loadFromFile(metaPath, format)
	return atlas

func _loadAtlasTex(metaPath, atlas):
	var path =  atlas.imagePath
	var tex = null
	if path.begins_with("res://"):
		path = path.substr(6,path.length()-6)	
	if ResourceLoader.has(path):
		tex = ResourceLoader.load(path)
	else:
		tex = ImageTexture.new()
		tex.load(path)
	return tex
	