extends GUINode

var _active : bool = false

# Newspaper window
var _newpaper_window : Panel
var _paper_background : GUIIcon
var _paper_title : GUIIcon
var _paper_seed : GUILabel
var _paper_close_button : GUIButton
var _paper_date : GUILabel

# Article Main
var _main_image : GUIIcon
var _main_title : GUILabel
var _main_desc : GUILabel

# Article Medium 1
var _med1_image : GUIIcon
var _med1_title : GUILabel
var _med1_desc : GUILabel
# Article Medium 2
var _med2_image : GUIIcon
var _med2_title : GUILabel
var _med2_desc : GUILabel

# Article Small 1
var _small1_title : GUILabel
var _small1_desc : GUILabel
# Article Small 2
var _small2_title : GUILabel
var _small2_desc : GUILabel
# Article Small 3
var _small3_title : GUILabel
var _small3_desc : GUILabel
# Article Small 4
var _small4_title : GUILabel
var _small4_desc : GUILabel
# Article Small 5
var _small5_title : GUILabel
var _small5_desc : GUILabel

class Paper:
	var header : String = "news/arabic_newspaper_title.dds"
	var date : String = "1836.1.1"
	var seed : String = "12345"
	
	var main_title : String = "WOW a title"
	var main_image : String = "news/battles_09_news_image.dds"
	var main_text  : String = "Lorem Ipsum"
	
	var med1_title : String = "bla"
	var med1_image : String = ""
	var med1_text  : String = "bla"
	var med2_title : String = "ASD"
	var med2_image : String = ""
	var med2_text  : String = "asd"
	
	var small1_title : String = ""
	var small1_text  : String = ""
	var small2_title : String = ""
	var small2_text  : String = ""
	var small3_title : String = ""
	var small3_text  : String = ""
	var small4_title : String = ""
	var small4_text  : String = ""
	var small5_title : String = ""
	var small5_text  : String = ""
	
	func load_from_file(file : String):
		pass
	
# News list
var _news_list : Panel
var _list_icon : GUIIcon
var _list_box : GUIListBox
var _scrollbar : GUIScrollbar
var _scroll_index : int = 0
var height : float = 0.0

var _news_unread_count : int = 0
var _news_list_read : Array[bool]
var _news_list_titles : Array[String]
var _news_list_btn_choices : Array[int]

var _news_list_rows : Array[Panel]
var _news_list_label : Array[GUILabel]
var _news_list_btn1 : Array[GUIButton]
var _news_list_btn2 : Array[GUIButton]
var _news_list_btn3 : Array[GUIButton]

#var news_entries : Array = []

# Newspaper Icon
var _open_button : GUIIconButton
var _open_label : GUILabel #how many newspapers we haven't read (default 0)

	#UI TODOS
	#TODO: Position the newspaper correctly
	#TODO: Get data from sim/dataloading
	
	#DATALOADING TODOS
	#TODO: Finish the objects
	#TODO: constructors
	#TODO: define var loading
	#TODO: String substitution
	
	#SIM TODOS
	#TODO: Mean to time generate article
	#TODO: Paper tension (some immediacy measure for moving up printing)
	#TODO: Generate & save news_collected
	#TODO:	update freshness
	#TODO: 	On_collection
	#TODO: Generate & save paper
	#TODO: 	On_printing

func _ready() -> void:
	#behaviour:
	# when icon clicked, both the list and the newspaper are opened (check placed on the news item)
	#	latest unread newspaper opened
	#	when no new news is available, the news list alone is opened
	# when the paper close is clicked, both the list and newspaper are closed
	# the news list item will be greyed if already read and a checkmark placed on it

	# IN THE SAVE FILE:
	# built_news = saved newspaper
	# a built news has style (int), seed (int), and title_image (str)
	# date (date str), and is_read (bool) properties
	#also has x article = {...} properties
	# within article: news_scope = variables for generating an article (apart from size

	#save file also has the news_collector property
	# news_scope = some event we could use for generating a news article
	# if freshness <=0, these news_scopes get eliminated

	#*.gui file, windowType name
	add_gui_element("news", "news_icon")
	_open_button= get_gui_icon_button_from_nodepath(^"news_icon/button")
	_open_label = get_gui_label_from_nodepath(^"news_icon/label")
	if _open_button:
		_open_button.pressed.connect(_click_icon_btn)
	
	add_gui_element("news", "news_list")
	_list_icon = get_gui_icon_from_nodepath(^"news_list/bg")
	_list_box = get_gui_listbox_from_nodepath(^"news_list/list")
	_scrollbar = get_gui_scrollbar_from_nodepath(^"news_list/scrollbar")
	_news_list = get_panel_from_nodepath(^"news_list")
	
	#_list_icon.set_mouse_filter(MOUSE_FILTER_PASS)
	#_list_box.set_mouse_filter(MOUSE_FILTER_PASS)
	#_news_list.set_mouse_filter(MOUSE_FILTER_PASS)
	#_scrollbar.set_mouse_filter(MOUSE_FILTER_PASS)
	
	if _scrollbar:
		_scrollbar.value_changed.connect(
			func (value : int) -> void:
				_scroll_index = value
				_update_list(_scroll_index)
		)
		_news_list.gui_input.connect(
		func (event : InputEvent) -> void:
			if event is InputEventMouseButton:
				if event.is_pressed():
					if event.get_button_index() == MOUSE_BUTTON_WHEEL_UP:
						_scrollbar.decrement_value()
					elif event.get_button_index() == MOUSE_BUTTON_WHEEL_DOWN:
						_scrollbar.increment_value()
		)
	if _list_box:
		_list_box.scroll_index_changed.connect(_update_list)
		#TODO: Remove when done testing
		_list_box.gui_input.connect(
			func(event:InputEvent):
				if event is InputEventMouseButton and event.is_pressed() and event.get_button_index() == MOUSE_BUTTON_RIGHT:
					_add_news_entry()
		)
	
	
	#TODO: Remove when done testing
	while height < _news_list.size.y * 3/4:
		_add_news_entry()
	#_open_label.text = "0"
	
	add_gui_element("news", "news_window_default")
	_paper_background = get_gui_icon_from_nodepath(^"news_window_default/window_bg")
	_paper_title = get_gui_icon_from_nodepath(^"news_window_default/title")
	#seed appears below the paper, likely just a debug thing
	_paper_seed = get_gui_label_from_nodepath(^"news_window_default/seed")
	_paper_close_button = get_gui_icon_button_from_nodepath(^"news_window_default/close_button")
	_paper_date = get_gui_label_from_nodepath(^"news_window_default/date")
	
	_newpaper_window = get_panel_from_nodepath(^"news_window_default")
	#original: -360 -320
	_newpaper_window.set_position(Vector2(320,200))
	
	_main_image = get_gui_icon_from_nodepath(^"news_window_default/article_main/image")
	_main_title = get_gui_label_from_nodepath(^"news_window_default/article_main/title")
	_main_desc  = get_gui_label_from_nodepath(^"news_window_default/article_main/desc")

	_med1_image = get_gui_icon_from_nodepath(^"news_window_default/article_medium_1/image")
	_med1_title = get_gui_label_from_nodepath(^"news_window_default/article_medium_1/title")
	_med1_desc  = get_gui_label_from_nodepath(^"news_window_default/article_medium_1/desc")
	_med2_image = get_gui_icon_from_nodepath(^"news_window_default/article_medium_2/image")
	_med2_title = get_gui_label_from_nodepath(^"news_window_default/article_medium_2/title")
	_med2_desc  = get_gui_label_from_nodepath(^"news_window_default/article_medium_2/desc")

	_small1_title = get_gui_label_from_nodepath(^"news_window_default/article_small_1/title")
	_small1_desc  = get_gui_label_from_nodepath(^"news_window_default/article_small_1/desc")
	_small2_title = get_gui_label_from_nodepath(^"news_window_default/article_small_2/title")
	_small2_desc  = get_gui_label_from_nodepath(^"news_window_default/article_small_2/desc")
	_small3_title = get_gui_label_from_nodepath(^"news_window_default/article_small_3/title")
	_small3_desc  = get_gui_label_from_nodepath(^"news_window_default/article_small_3/desc")
	_small4_title = get_gui_label_from_nodepath(^"news_window_default/article_small_4/title")
	_small4_desc  = get_gui_label_from_nodepath(^"news_window_default/article_small_4/desc")
	_small5_title = get_gui_label_from_nodepath(^"news_window_default/article_small_5/title")
	_small5_desc  = get_gui_label_from_nodepath(^"news_window_default/article_small_5/desc")

	if _paper_close_button:
		_paper_close_button.pressed.connect(_close)
	
	_close()
	_set_paper(Paper.new())
	#close when another menu comes up
	Events.NationManagementScreens.update_active_nation_management_screen.connect(_close)

func _click_icon_btn():
	if _active:
		if _news_list.visible:
		#_close()
			_news_list.hide()
		else:
			_news_list.show()
		return
	
	_news_list.show()
	if _news_unread_count > 0 and not _active:
		var first_unread_index = _news_list_read.size()-1
		for i in range(_news_list_read.size()-1,0,-1):
			if !_news_list_read[i]:
				break
			first_unread_index -= 1
		_set_current_newspaper(first_unread_index)
		_scrollbar.set_value(_news_list_read.size()-1 - first_unread_index,true)
	_active = true

#input var just exists to eat the nation management screen value
func _close(input = 0):
	_active = false
	_newpaper_window.hide()
	_news_list.hide()


var rng = RandomNumberGenerator.new()
var counter = 0
func _add_news_entry():
	
	#TODO: Replace with current date if new or loaded date
	var entry_title = MenuSingleton.get_longform_date().replace("1836",String.num_uint64(1836 + counter))
	counter += 1
	_news_list_titles.push_back(entry_title)
	_news_list_read.push_back(false)
	
	_news_list_btn_choices.push_back(rng.randi_range(0,2))
	
	if _news_list_rows.size() >= 10:
		_news_unread_count += 1
		_update_list(_scroll_index)
		_update_unread_count_label()
		_update_scrollbar()
		return
	
	var news_entry_panel : Panel = GUINode.generate_gui_element("news", "news_list_entry")
	if not news_entry_panel:
		return
	var lbl = GUINode.get_gui_label_from_node(news_entry_panel.get_node(^"./label"))
	# Randomly pick 1 of the 3 buttons (visually different, but functionally identical)
	#TODO: Make randomness deterministic, for now its local so doesn't matter all that much
	var btn1 = GUINode.get_gui_icon_button_from_node(news_entry_panel.get_node(^"./button1"))
	var btn2 = GUINode.get_gui_icon_button_from_node(news_entry_panel.get_node(^"./button2"))
	var btn3 = GUINode.get_gui_icon_button_from_node(news_entry_panel.get_node(^"./button3"))

	_news_list.add_child(news_entry_panel)
	news_entry_panel.set_position(Vector2(0,height))
	
	height += news_entry_panel.size.y
	
	_news_list_rows.push_back(news_entry_panel)
	_news_list_label.push_back(lbl)
	_news_list_btn1.push_back(btn1)
	_news_list_btn2.push_back(btn2)
	_news_list_btn3.push_back(btn3)
	
	
	btn1.pressed.connect(_news_button_clicked.bind(_news_list_btn1.size()-1))
	btn2.pressed.connect(_news_button_clicked.bind(_news_list_btn2.size()-1))
	btn3.pressed.connect(_news_button_clicked.bind(_news_list_btn3.size()-1))
	
	_news_unread_count += 1
	_update_unread_count_label()
	_update_scrollbar()
	_update_list()
	
func _update_unread_count_label():
	_open_label.text = String.num_uint64(_news_unread_count)

func _set_news_read(index:int, read:bool = true) -> void:
	var frame : int = 2
	if !read:
		frame = 1
	_news_list_read[index] = read
	if read:
		_news_unread_count -= 1
		if _news_unread_count < 0 or _news_unread_count > 50:
			push_error("news_unread_count is wrong %s" % _news_unread_count)
	else:
		_news_unread_count += 1
	_update_unread_count_label()
	_update_list(_scroll_index)

func _news_button_clicked(btn_index:int):
	var paper_index = _news_list_read.size()-1 - btn_index -_scroll_index
	_set_current_newspaper(paper_index)

func _set_current_newspaper(index:int):
	if _news_list_read[index] == false:
		_set_news_read(index)
	var paper = Paper.new()
	paper.date = _news_list_titles[index]
	_set_paper(paper)
	_newpaper_window.show()
	#TODO: populate the articles from data

func _update_scrollbar():
	if _scrollbar:
		var max_scroll_index : int = _news_list_read.size() - _news_list_rows.size()#MenuSingleton.get_population_menu_pop_row_count() - _pop_list_rows.size()
		if max_scroll_index > 0:
			_scrollbar.set_limits(0, max_scroll_index)
			_scrollbar.show()
		else:
			_scrollbar.set_limits(0, 0)
			_scrollbar.hide()

func _update_list(scroll_index : int = -1) -> void:
	if not _list_box:
		print("no list box")
		return
	if scroll_index >= 0: #?????
		_list_box.set_scroll_index(scroll_index,false)
	else:
		scroll_index = _scroll_index
	#????
	
	for i:int in range(_news_list_rows.size()):
		#which news entry maps to the current visual row
		var info_index = _news_list_titles.size()-1 - i - scroll_index
		_news_list_label[i].text = _news_list_titles[info_index]
		
		var btn_choice = _news_list_btn_choices[info_index]
		if btn_choice == 0:
			_news_list_btn1[i].show()
			_news_list_btn2[i].hide()
			_news_list_btn3[i].hide()
		elif btn_choice == 1:
			_news_list_btn1[i].hide()
			_news_list_btn2[i].show()
			_news_list_btn3[i].hide()
		else:
			_news_list_btn1[i].hide()
			_news_list_btn2[i].hide()
			_news_list_btn3[i].show()
		
		var frame = 1
		if _news_list_read[info_index]:
			frame = 2
		_news_list_btn1[i].set_icon_index(frame)
		_news_list_btn2[i].set_icon_index(frame)
		_news_list_btn3[i].set_icon_index(frame)


func _set_paper(paper : Paper) -> void:
	if paper.header != "":
		_paper_title.texture = AssetManager.get_texture("gfx/pictures/" + paper.header)
	_paper_date.text = paper.date
	_paper_seed.text = paper.seed
	
	_main_title.text = paper.main_title
	_main_desc.text = paper.main_text
	if paper.main_image != "":
		_main_image.texture = AssetManager.get_texture("gfx/pictures/" + paper.main_image)
	_main_title.text = paper.main_title
	_main_desc.text = paper.main_text
	
	_med1_title.text = paper.med1_title
	_med1_desc.text = paper.med1_text
	if paper.med1_image != "":
		_main_image.texture = AssetManager.get_texture("gfx/pictures/" + paper.med1_image)
	
	_med2_title.text = paper.med2_title
	_med2_title.text = paper.med2_text
	if paper.med2_image != "":
		_main_image.texture = AssetManager.get_texture(paper.med2_image)

	_small1_title.text = paper.small1_title
	_small1_desc.text  = paper.small1_text
	_small2_title.text = paper.small2_title
	_small2_desc.text  = paper.small2_text
	_small3_title.text = paper.small3_title
	_small3_desc.text  = paper.small3_text
	_small4_title.text = paper.small4_title
	_small4_desc.text  = paper.small4_text
	_small5_title.text = paper.small5_title
	_small5_desc.text  = paper.small5_text

#TODO: copied from other menus, does this work here?
func _notification(what : int) -> void:
	match what:
		NOTIFICATION_TRANSLATION_CHANGED:
			_update_info()

func _update_info() -> void:
	if _active:
		show()
	else:
		hide()
