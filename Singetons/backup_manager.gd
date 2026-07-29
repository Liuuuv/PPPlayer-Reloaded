extends Node

const BACKUP_FOLDER = "user://backups/"
var FILES_PATH_TO_BACKUP: Array[String] = [] ## eg: [song_infos.json]
const MAX_BACKUPS = 10  # Nombre maximum de backups à conserver

func _ready() -> void:
	# Créer le dossier de backups s'il n'existe pas
	if not DirAccess.dir_exists_absolute("user://backups"):
		DirAccess.make_dir_absolute("user://backups")
	
	#auto_backup_timer()
	
	_initialize.call_deferred()

func _initialize() -> void:
	if not Global.is_in_editor:
		if FILES_PATH_TO_BACKUP.is_empty():
			push_error("NO BACKUP FILES PROVIDED. I CANNOT DO ANY BACKUP.")



## Create a backup for the said files.[br]
## eg: [param custom_filepaths_to_backup][code] = [song_infos.json][/code]
## will create [code]"backup__song_infos__2026-07-28T20-41-09.json"[/code].[br]
## Returns if all the backup were saved successfully.
func create_backup(custom_filepaths_to_backup: Array[String] = FILES_PATH_TO_BACKUP) -> bool:
	print("Creating backups for files: " + ", ".join(custom_filepaths_to_backup))
	var is_ok: bool = true
	for fullpath_to_backup: String in custom_filepaths_to_backup:
		if not FileAccess.file_exists(fullpath_to_backup):
			push_warning("Pas de fichier %s à sauvegarder" % fullpath_to_backup)
			return false
		
		# Générer un nom avec timestamp
		var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
		var backup_name = "backup__%s__%s.json" % [fullpath_to_backup.get_file().get_basename(), timestamp]
		var backup_path = BACKUP_FOLDER + backup_name
		
		# Copier le fichier
		var error = DirAccess.copy_absolute(
			ProjectSettings.globalize_path(fullpath_to_backup),
			ProjectSettings.globalize_path(backup_path)
		)
		
		if error != OK:
			is_ok = false
			push_error("Échec du backup : erreur %d" % error)
		
	if is_ok:
		#_clean_old_backups()
		print("Backups all done!")
		return true
	else:
		return false


#func create_backup_before_save() -> String:
	#"""Backup automatique avant chaque sauvegarde"""
	#return create_backup()


#func restore_latest_backup() -> bool:
	#"""Restaure le backup le plus récent"""
	#var backups = get_backup_list()
	#
	#if backups.is_empty():
		#push_error("Aucun backup disponible")
		#return false
	#
	## Le plus récent (trié par nom décroissant)
	#var latest_backup = backups[-1]
	#return restore_backup(latest_backup)

#
#func restore_backup(backup_filename: String) -> bool:
	#"""
	#Restaure un backup spécifique.
	#Retourne true si réussi.
	#"""
	#var backup_path = BACKUP_FOLDER + backup_filename
	#
	#if not FileAccess.file_exists(backup_path):
		#push_error("Backup introuvable : %s" % backup_path)
		#return false
	#
	## Créer un backup de sécurité avant restauration
	#var safety_backup = "song_infos_before_restore_%s.json" % Time.get_unix_time_from_system()
	#DirAccess.copy_absolute(
		#ProjectSettings.globalize_path(SONG_INFOS_FILE),
		#ProjectSettings.globalize_path(BACKUP_FOLDER + safety_backup)
	#)
	#
	## Restaurer
	#var error = DirAccess.copy_absolute(
		#ProjectSettings.globalize_path(backup_path),
		#ProjectSettings.globalize_path(SONG_INFOS_FILE)
	#)
	#
	#if error == OK:
		#print("Backup restauré : %s" % backup_filename)
		## Recharger les données
		#Global.load_song_infos()
		#return true
	#else:
		#push_error("Échec de la restauration")
		#return false


func get_backup_list() -> Array[String]:
	"""Retourne la liste des backups disponibles (triés par date)"""
	var backups: Array[String] = []
	
	var dir = DirAccess.open(BACKUP_FOLDER)
	if dir == null:
		return backups
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.begins_with("backup__") and file_name.ends_with(".json"):
			backups.append(file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	# Trier par nom (contient le timestamp)
	backups.sort()
	
	return backups

#
#func get_backup_info() -> Array[Dictionary]:
	#"""Retourne les infos détaillées des backups"""
	#var backups = get_backup_list()
	#var info: Array[Dictionary] = []
	#
	#for backup in backups:
		#var path = BACKUP_FOLDER + backup
		#var file = FileAccess.open(path, FileAccess.READ)
		#if file:
			#var size = file.get_length()
			#var modified = FileAccess.get_modified_time(path)
			#file.close()
			#
			#info.append({
				#"filename": backup,
				#"size": size,
				#"modified": modified,
				#"date": Time.get_datetime_string_from_unix_time(modified)
			#})
	#
	#return info
#
#
#func _clean_old_backups() -> void:
	#"""Supprime les backups les plus anciens si > MAX_BACKUPS"""
	#var backups = get_backup_list()
	#
	#while backups.size() > MAX_BACKUPS:
		#var oldest = backups[0]
		#var path = BACKUP_FOLDER + oldest
		#DirAccess.remove_absolute(path)
		#print("Ancien backup supprimé : %s" % oldest)
		#backups.pop_front()
#
#
func auto_backup_timer(interval_minutes: int = 30) -> void:
	var timer = Timer.new()
	timer.wait_time = interval_minutes * 60
	timer.autostart = true
	timer.timeout.connect(create_backup)
	add_child(timer)
	print("Auto-backup activé toutes les %d minutes" % interval_minutes)
