extends HBoxContainer

@export var initial_focus: Control

@onready
var revert_dialog:KeepChangesDialog = get_node("KeepChangesDialog")
@onready
var resolution_selector:ResolutionSelector = get_node("VBoxContainer/GridContainer/ResolutionSelector")

func _notification(what : int) -> void:
	match(what):
		NOTIFICATION_VISIBILITY_CHANGED:
			if visible and is_inside_tree():
				initial_focus.grab_focus()

#TODO: this depends on the resolution selector handling this
#signal first, this needs to be made more robust

#TODO: This seems to get called both on startup and
#when done through the options, this needs to be stopped
#from doing it on startup



#TODO: Get this localized
func _on_resolution_selector_selection_changed():
#func _on_resolution_selector_item_selected(index):
#	pass
	if revert_dialog:
		print("Start Revert Countdown!")
		revert_dialog.start_revert_countdown(Resolution.get_current_resolution(),on_resolution_reset)
		
func on_resolution_reset(old_resolution:Vector2i) -> void:
	Resolution.set_resolution(old_resolution)
	resolution_selector._sync_resolutions()
	print("Resolution reset to (%dx%d)" % [old_resolution.x,old_resolution.y])
	#TODO: tell the resolution button to sync back with the old resolution


