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

#These two functions help fulfill UIFUN-301 and UIFUN-302
func _on_resolution_selector_selection_changed(old_resolution,new_resolution):
	if revert_dialog:
		print("Start Revert Countdown!")
		revert_dialog.start_revert_countdown(old_resolution,on_resolution_reset)
		
#A callback which gets executed if the user fails to
#accept the new resolution change
func on_resolution_reset(old_resolution:Vector2i) -> void:
	Resolution.set_resolution(old_resolution)
	resolution_selector._sync_resolutions()
	print("Resolution reset to (%dx%d)" % [old_resolution.x,old_resolution.y])


