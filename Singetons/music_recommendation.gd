extends Node

func get_recommendations(video_id: String):
	var output = []
	var script_path = "res://PythonFiles/get_recommendations.py"
	var absolute_path = ProjectSettings.globalize_path(script_path)
	var exit_code = OS.execute("python", [absolute_path, video_id], output, true)
	
	if exit_code == 0 and output.size() > 0:
		var result = JSON.parse_string(output[0])
		if result and result.has("success"):
			if result["success"]:
				print("Recommandations récupérées: ", result["count"], " pistes")
				for track in result["recommendations"]:
					print(" - ", track["title"], " par ", ", ".join(track["artists"]))
					print("   ", track["videoId"])
				return result["recommendations"]
			else:
				print("Erreur: ", result["error"])
		else:
			print("Format de réponse invalide")
	else:
		print("Erreur d'exécution du script Python. Code: ", exit_code)
		if output.size() > 0:
			print("Sortie: ", output[0])
	
	return []
