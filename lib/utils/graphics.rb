# Graphics manipulation functions
#
# http://www.imagemagick.org/Usage/resize
# http://www.ioncannon.net/linux/81/5-imagemagick-command-line-examples-part-1/

module Graphics

class << self

	# The "-thumbnail" operator is a variation of "-resize" designed specifically 
	# for shrinking very very large images to small thumbnails.
	#
	# First it uses "-strip" to remove all profile and other fluff from the 
	# image. It the uses "-sample" to shrink the image down to 5 times the final 
	# height. Finally it does a normal "-resize" to reduce the image to its 
	# final size.
	#
	# All this is to basically speed up thumbnail generation from very large files.
	# However for thumbnails of JPEG images, you can limit the size of the image 
	# read in from disk using the "-size" setting, so the extra speed 
	# improvement is rarely needed for JPEG in thumbnail generation. But it is 
	# still useful for other image formats, such as TIFF, or for its profile 
	# stripping ability. As such it is still the recommended way to resize 
	# images for thumbnail creation.
	
	def thumbnail_image(src_path, dst_path, width, height)
		system("convert #{src_path} -thumbnail #{width}x#{height}\\> #{dst_path}")
	end

end # self

end
