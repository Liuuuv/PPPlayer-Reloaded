extends BasePage
class_name SearchResultsPage

@onready var search_results: SongVirtualScrollList = %SearchResults
@onready var is_loaded_from_cache: Label = %IsLoadedFromCache
@onready var num_results_query: Label = %NumResultsQuery
@onready var num_results_query_template: String = num_results_query.text



func _ready() -> void:
	super._ready()
	
	Global.search_results_page = self

	close()

func _initialize() -> void:
	super._initialize()
	
	Global.search_tab.search_bar.text_submitted.connect(_on_search_bar_text_submitted)
	

func display_search_results(youtube_ids: Array[String], query: String) -> void:
	hide_loading_overlay()
	num_results_query.text = num_results_query_template % [len(youtube_ids), query]
	
	search_results.clear_items()
	for youtube_id in youtube_ids:

		var song_cache_name: String = Global.RESULTS_CACHE_SONG_TEMPLATE % youtube_id
		var song_result_res: SongCacheResource = Tools.get_cached_results(song_cache_name)
		if song_result_res:
			var result_song_item: Global.ResultSongItem = Global.ResultSongItem.new()
			result_song_item.initialize(
				youtube_id,
				song_result_res.title,
				song_result_res.artists,
				"",
				search_results,
				search_results.items.size()
			)
			search_results._add_item(result_song_item)
		else:
			push_error("No cache for YouTube ID: %s" % youtube_id)


## TODO "topic" thing
func _on_search_bar_text_submitted(new_text: String):
	open()
	show_loading_overlay()
	loading_info.text = "Requesting search results."
	
	var search_res: SearchCacheResource = Tools.get_cached_results(Global.RESULTS_CACHE_SEARCH_RESULT_TEMPLATE % new_text)
	if search_res:
		display_search_results(search_res.results, new_text)
		is_loaded_from_cache.show()
		return
	else:
		is_loaded_from_cache.hide()
	
	var search_script_path = ProjectSettings.globalize_path(Global.PYTHON_SCRIPTS_PATH.path_join("ytmusic_search.py"))
	UsePython.execute_python_script(
		[
			search_script_path,
			new_text
		],
		_process_search_results
	)

func _process_search_results(output: Dictionary):
	if not output.get("success", false):
		push_error("Error in the YouTube Music search: " + output.get("error", ""))
		return
	var result: Array = output.get("result", [])
	var search_result_ids: Array[String] = []
	for track: Dictionary in result:
		var youtube_id: String = track.get("videoId")
		search_result_ids.append(youtube_id)
		Tools.save_youtube_video_infos_to_cache(track)
	
	var search_res: SearchCacheResource = SearchCacheResource.new()
	search_res.results = search_result_ids
	var query: String = output.get("query", "")
	Tools._save_to_cache(search_res, Tools.get_results_cache_path() + Global.RESULTS_CACHE_SEARCH_RESULT_TEMPLATE % query + ".res")
	
	display_search_results(search_result_ids, query)
