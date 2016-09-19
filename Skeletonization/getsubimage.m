function [subimage, image_maximum, image_minimum, subimage_maximum, subimage_minimum] = getsubimage(image, center, blocksize, pad)
%{  
    This function retrieves a subimage given the image, center and blocksize. 
	Any subimage pixels that lie outside the image boundary is given the value defined in pad.
	
	Works only for 2D images at the moment.
	
	Inputs:
	
	image (2D array) - image to retrive subimage from
	center (2x1 int array) - index value of the center of the subimage.
	blocksize (int or 2x1 int array) - size of the subimage block. An int value indicates the blocksize is the same size across all image dimensions
	pad (float) - value of pixels in the subimage if they are mapped to a region outside of the image boudnaries
	
	Outputs:
	
	subimage (blocksizexblocksize array) - subimage of the image that was asked for
	image_maximum (2x1 int array) - maximum x and y indexes of the subimage as related to the original image
	image_maximum (2x1 int array) - minimum x and y indexes of the subimage as related to the original image
	subimage_maximum (2x1 int array) - maximum x and y indexes of where image values are defined in the subimage
	subimage_minimum (2x1 int array) - minimum x and y indexes of where image values are defined in the subimage
	
%}

	% Define same block size across all image dimensions if only a number was given
    if length(blocksize) == 1
        blocksize(1:length(center)) = blocksize;
    end
    
	%Set the start and stop index of the image to be the entire image region
    template_minimum = size(image)./size(image);
    template_maximum = size(image);
    
    %Get image index limits
    [image_maximum, image_minimum, subimage_maximum, subimage_minimum] = calcimageindex(center, blocksize, template_maximum, template_minimum);
    
    %Create padded image first
    subimage = pad*ones(blocksize);
    
    %Set the subimage into the zero padded zone
    subimage(subimage_minimum(1):subimage_maximum(1), subimage_minimum(2):subimage_maximum(2)) = image(image_minimum(1):image_maximum(1),image_minimum(2):image_maximum(2));

end