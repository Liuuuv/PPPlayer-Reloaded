extends Node

func _ready() -> void:
	pass

func calculate_features(local_id: String, priority: UsePython.REQUEST_PRIORITY = UsePython.REQUEST_PRIORITY.LOW) -> void:
	print("Computing features for local ID %s" % local_id)
	var script_fullpath = Tools.get_python_script_fullpath("get_song_features")
	var song_info: Dictionary = Global.song_infos.get(local_id, {})
	var song_fullpath: String = Tools.get_full_path_from_id(local_id)
	if song_fullpath:
		if song_info:
			UsePython.execute_python_script(
				[
					script_fullpath,
					song_fullpath
				],
				func(data: Dictionary): _process_features_result(data, local_id),
				priority
			)
		else:
			push_error("No song info for local ID: %s" % local_id)
	else:
		push_error("No path found for local ID: %s" % local_id)

func _process_features_result(data: Dictionary, local_id: String) -> void:
	if data.get("success", false):
		if not Global.song_features.has(local_id):
			Global.song_features.set(local_id, {})
		var song_feature: Dictionary = Global.song_features.get(local_id, {})
		var result: Dictionary = data.get("result", {})
		for key in result.keys():
			song_feature.set(key, result.get(key, -1.0))
		Global.save_song_features()
		print("Successfully calculated features for local ID %s" % local_id)
	else:
		push_error("Error processing song features result (from Python script). Error: %s" % data.get("error", ""))
		return



var weights: Dictionary = {
	"rms_mean": 1.0,
	"rms_std": 1.0,
	"zcr_mean": 1.0,
	"zcr_std": 1.0,
	"spectral_centroid_mean": 1.0,
	"spectral_centroid_std": 1.0,
	"mfcc_1_mean": 1.0,
	"mfcc_1_std": 1.0,
	"mfcc_2_mean": 1.0,
	"mfcc_2_std": 1.0,
	"mfcc_3_mean": 1.0,
	"mfcc_3_std": 1.0,
	"mfcc_4_mean": 1.0,
	"mfcc_4_std": 1.0,
	"mfcc_5_mean": 1.0,
	"mfcc_5_std": 1.0,
	"mfcc_6_mean": 1.0,
	"mfcc_6_std": 1.0,
	"mfcc_7_mean": 1.0,
	"mfcc_7_std": 1.0,
	
	#"spectral_centroid_mean": 1.2,
	#"spectral_centroid_std": 1.0,
	#"spectral_bandwidth_mean": 0.8,
	#"spectral_rolloff_mean": 0.8,
	#"mfcc_1_mean": 1.5,
	#"mfcc_2_mean": 1.2,
	#"mfcc_3_mean": 1.0,
	#"tempo": 2.0,
}

func test(target_local_id) -> void:
	
	var similar: Array[Dictionary] = find_similar(target_local_id, -1)
	print(similar.map(func(dict: Dictionary): return dict.get("distance", "")))
	var similar_local_ids: Array[String] = Array(similar.map(func(dict: Dictionary): return dict.get("id", "")), TYPE_STRING, "", null)
	Global.playlists_tab.playlist_content_tab.force_show_tab()
	Global.playlists_tab.playlist_content_tab.display_ids(similar_local_ids)

func find_similar(
	target_local_id: String,
	count: int = 10,
) -> Array[Dictionary]:
	"""
	Trouve les éléments les plus proches dans la base de données.
	
	Args:
		target_features: Dictionnaire de caractéristiques cibles (que des floats)
		database: Base de données {id: {feature: float, ...}}
		count: Nombre de résultats à retourner
		custom_weights: Poids personnalisés (optionnel)
	
	Returns:
		Array de dictionnaires triés par similarité décroissante
		[{"id": "song1", "similarity": 0.95, "features": {...}}, ...]
	"""
	var target_features: Dictionary = Global.song_features.get(target_local_id, {})
	if target_features == {}:
		return []
	var database: Dictionary = Global.song_features # {id: {feature: value, ...}}
	var results: Array[Dictionary] = []
	
	for item_id in database:
		var item_features: Dictionary = database[item_id]
		var distance = _calculate_similarity(target_features, item_features, weights)
		
		results.append({
			"id": item_id,
			"distance": distance,
			"features": item_features
		})
	
	# Trier par similarité décroissante
	results.sort_custom(func(a, b): return a.distance < b.distance)
	
	return results.slice(0, count)



func _calculate_similarity(
	features1: Dictionary,
	features2: Dictionary,
	use_weights: Dictionary
) -> float:
	"""
	Calcule la similarité cosinus-like entre deux ensembles de caractéristiques.
	Retourne une valeur entre 0 (très différent) et 1 (identique).
	"""
	var total_weight: float = 0.0
	var weighted_distance: float = 0.0
	
	for feature in use_weights:
		if features1.has(feature) and features2.has(feature):
			var val1: float = features1[feature]
			var val2: float = features2[feature]
			
			# Normaliser les valeurs entre 0 et 1
			#var norm1 = _normalize(feature, val1)
			#var norm2 = _normalize(feature, val2)
			
			# Distance pondérée
			#var diff = abs(norm1 - norm2)
			var diff = abs(val1 - val2)
			weighted_distance += use_weights[feature] * diff
			total_weight += use_weights[feature]
	
	
	if total_weight == 0.0:
		return 0.0
	
	# Convertir distance en similarité
	var avg_distance = weighted_distance / total_weight
	return avg_distance

#
