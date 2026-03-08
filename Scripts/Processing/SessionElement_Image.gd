class_name SessionElement_Image
extends SessionElement_SingleFile
	

static func get_type_static() -> String:
	return "IMAGE"


func _init() -> void:
	super._init()
	_end_time.set_value(10.0)


func get_default_display_name() -> String:
	return "Image"


func get_type() -> String:
	return get_type_static()


func get_image_data() -> PackedByteArray:
	return get_file_data()


func get_image_ext() -> String:
	return get_file_ext()


# Loads the image associated with this SessionElement into the given Image object,
# choosing the correct function according to the file extension.
func load_image_object(image_obj: Image) -> void:
	var ext: String = get_image_ext()
	var buffer: PackedByteArray = get_image_data()
	
	if(ext == "png"):
		image_obj.load_png_from_buffer(buffer)
	else: if(ext == "jpg" || ext == "jpeg"):
		image_obj.load_jpg_from_buffer(buffer)
	else: if(ext == "svg"):
		image_obj.load_svg_from_buffer(buffer)
	else: if(ext == "webp"):
		image_obj.load_webp_from_buffer(buffer)
	else:
		print("ERROR: cannot load image from " + ext + " file.")
		
