extends Node

var score_data = []

func record_score(player_name: String, score: int, result: String):
	var current_time = Time.get_time_dict_from_system()
	var timestamp = "%d-%02d-%02d %02d:%02d:%02d" % [
		current_time.get("year", 0),
		current_time.get("month", 0),
		current_time.get("day", 0),
		current_time.get("hour", 0),
		current_time.get("minute", 0),
		current_time.get("second", 0)
	]
	score_data.append([timestamp, player_name, score, result])
	print("📌 Score recorded:", timestamp, player_name, score, result)

func export_to_csv(file_path: String = "E:/Review2 godot projects_AshwinRavi/Dataset/DNF_2.csv"):
	var file = FileAccess.open(file_path, FileAccess.READ_WRITE)
	if file:
		file.seek_end()
		if file.get_position() == 0:
			file.store_line("Timestamp,Player,Score,Result")

		for entry in score_data:
			file.store_line("%s,%s,%d,%s" % [entry[0], entry[1], entry[2], entry[3]])

		file.close()
		score_data.clear()
		print("✅ CSV file updated at:", file_path)
	else:
		print("⚠️ ERROR: Failed to open the CSV file.")
