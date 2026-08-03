extends PanelContainer
class_name ClickableListItem

# A reusable menu button with a title, description, and icon.
# Title, description, and icon are all optional: unset fields hide their node.

#### Node references - set in the inspector when building the scene
@export var title_label: Label
@export var description_label: Label
@export var icon_rect: TextureRect

var pressedFunction: Callable


@export var title: String = "":
	set(value):
		title = value
		_apply_title()
		
@export var description: String = "":
	set(value):
		description = value
		_apply_description()
		
@export var icon: Texture2D = null:
	set(value):
		icon = value
		_apply_icon()

func _ready() -> void:
	assert(title_label != null, "MenuButtonPanel: title_label not set")
	assert(description_label != null, "MenuButtonPanel: description_label not set")
	assert(icon_rect != null, "MenuButtonPanel: icon_rect not set")
	_apply_title()
	_apply_description()
	_apply_icon()


func setup(title: String, pressedFunction:Callable, description: String = "", icon: Texture2D = null) -> void:
	self.title = title
	self.description = description
	if icon:
		self.icon = icon
	
	if pressedFunction.is_valid() and not $Button.pressed.is_connected(pressedFunction):
		$Button.pressed.connect(pressedFunction)


func _apply_title() -> void:
	if title_label == null:
		return
	title_label.text = title
	title_label.visible = title != ""

func _apply_description() -> void:
	if description_label == null:
		return
	description_label.text = description
	description_label.visible = description != ""

func _apply_icon() -> void:
	if icon_rect == null:
		return
	icon_rect.texture = icon
	icon_rect.visible = icon != null
