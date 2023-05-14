extends ConfirmationDialog
class_name KeepChangesDialog

@export
var countdown_seconds:int = 5

@onready
var timer:Timer = $Timer



#allows this to be a generic component, but we need to be careful and do
#extra null checking, and error handling
var old_setting = null

#callback function to use to revert the changed setting to
#the old setting
var revert_callback:Callable = bad_callback 
#Callable(self,'bad_ballback') would also be equivalent

func start_revert_countdown(old_setting_in, revert_func:Callable) -> void:
	if old_setting_in == null:
		push_warning("old setting was null")
	old_setting = old_setting_in
	revert_callback = revert_func
	timer.start(countdown_seconds)
	popup_centered()

func _cancel_changes() -> void:
	#if revert_callback is somehow null, you should see a console error
	revert_callback.call(old_setting)
	timer.stop()
	hide()
	
func _process(delta):
	var time_left = -1
	if not timer.is_stopped():
		time_left = timer.time_left
	dialog_text = tr("REVERTING_IN") % time_left

	
func _on_confirmed() -> void:
	timer.stop()
	hide()

#the "no" option of the dialog
func _on_canceled() -> void:
	_cancel_changes()

func _on_timer_timeout() -> void:
	_cancel_changes()

func bad_callback() -> void:
	push_error("Revert Settings callback did not reference a function")
	_on_confirmed()
