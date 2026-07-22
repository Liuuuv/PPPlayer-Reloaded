extends Node2D

@onready var big_thumbnail: TextureRect = %BigThumbnail

@export_group("Spectrum")
@export var vu_count := 32
@export var freq_min := 20.0
@export var freq_max := 16000.0
@export var min_db := 60.0

@export_group("Display")
@export var width := 500.0
@export var height := 120.0
@export var spacing := 2.0

@export_group("Animation")
@export var attack_speed := 30.0
@export var release_speed := 6.0
@export var peak_fall_speed := 0.45

@export_group("Bass")
@export var bass_boost: float = 1.3

@export_group("Colors")
@export var low_color := Color.GREEN
@export var mid_color := Color.YELLOW
@export var high_color := Color.RED
@export var peak_color := Color.WHITE

var spectrum : AudioEffectSpectrumAnalyzerInstance

var frequencies : PackedFloat32Array
var bars : PackedFloat32Array
var peaks : PackedFloat32Array

var gradient := Gradient.new()

func _ready():
	
	
	spectrum = AudioServer.get_bus_effect_instance(0,0)
	
	if spectrum == null:
		push_error("Spectrum analyzer missing.")
		return
	
	bars.resize(vu_count)
	peaks.resize(vu_count)
	frequencies.resize(vu_count + 1)
	
	#gradient.colors = PackedColorArray([])
	#gradient.add_point(0.0, low_color)
	#gradient.add_point(0.5, mid_color)
	#gradient.add_point(1.0, high_color)
	
	
	Global.music_player.stream_changed.connect(_on_stream_changed)
	
	_compute_frequencies()

func _compute_frequencies():
	
	for i in range(vu_count + 1):
		
		var t = float(i) / vu_count
		
		frequencies[i] = freq_min * pow(freq_max / freq_min, t)

func _process(delta):
	
	if spectrum == null:
		return
	
	for i in range(vu_count):
		var mag = spectrum.get_magnitude_for_frequency_range(
			frequencies[i],
			frequencies[i + 1]
		)
		
		var energy = (mag.x + mag.y) * 0.5
		
		energy = clamp(
			(min_db + linear_to_db(energy)) / min_db,
			0.0,
			1.0
		)
		
		# bass boost
		
		var t = float(i) / vu_count
		
		energy *= lerp(bass_boost,1.0,t)
	
		energy = pow(energy,0.70)
		
		# attack - release
		if energy > bars[i]:
			bars[i] = lerp(
				bars[i],
				energy,
				attack_speed * delta
			)
		else:
			bars[i] = lerp(
				bars[i],
				energy,
				release_speed * delta
			)
		
		
		# Peak
		if bars[i] > peaks[i]:
			peaks[i] = bars[i]
		else:
			peaks[i] -= peak_fall_speed * delta
	
			if peaks[i] < bars[i]:
				peaks[i] = bars[i]
	
	queue_redraw()

func _draw():
	
	if spectrum == null:
		return
	
	var bar_width = (
		width - spacing * (vu_count - 1)
	) / vu_count
	
	for i in range(vu_count):
		
		var x = i * (bar_width + spacing)
		
		var h = bars[i] * height
		
		var rect = Rect2(
			x,
			height - h,
			bar_width,
			max(h,1.0)
		)
		
		#var color = gradient.sample(
			#float(i) / (vu_count - 1)
		#)
		
		var t := float(i) / (vu_count - 1)

		var color: Color

		if t < 0.5:
			color = low_color.lerp(mid_color, t * 2.0)
		else:
			color = mid_color.lerp(high_color, (t - 0.5) * 2.0)
		
		
		color.a = lerp(0.1,1.0,bars[i])
		
		draw_rect(rect,color)
		
		# Glow
		
		draw_rect(
			rect.grow(1),
			Color(
				color.r,
				color.g,
				color.b,
				0.08
			),
			false
		)
		
		# Peak
		
		draw_line(
			Vector2(
				x,
				height - peaks[i] * height
			),
			Vector2(
				x + bar_width,
				height - peaks[i] * height
			),
			peak_color,
			2.0
		)

func _on_stream_changed(_fullpath: String):
	await get_tree().process_frame
	if big_thumbnail.texture:
		var colors: Array = Tools.get_dominant_colors(big_thumbnail.texture.get_image(), 3)
		low_color = colors[0]
		mid_color = colors[1]
		high_color = colors[2]
