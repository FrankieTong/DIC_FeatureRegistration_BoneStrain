function [image_maximum, image_minimum, subimage_maximum, subimage_minimum] = calcimageindex(center, blocksize, maximum, minimum)
%{  This function calculates the image and matching subimage indexes given we want to retrieve a subimage from an image given the
	center of the subimage, the blocksize and the maximum and minimum index values in which we are allowed to retrieve a subimage from
	the original image.
	
	Inputs:
	
	center (dimensionx1 int array) - index value of the center of the subimage.
	blocksize (int or dimensionx1 int array) - size of the subimage block. An int value indicates the blocksize is the same size across all image dimensions
	maximum (dimensionx1 int array) - maximum indexes of the image we are able to retrieve image values from
	minimum (dimensionx1 int array) - minimum indexes of the image we are able to retrieve image values from
	
	Outputs:
	
	image_maximum (dimensionx1 int array) - maximum x and y indexes of the subimage as related to the original image
	image_maximum (dimensionx1 int array) - minimum x and y indexes of the subimage as related to the original image
	subimage_maximum (dimensionx1 int array) - maximum x and y indexes of where image values are defined in the subimage
	subimage_minimum (dimensionx1 int array) - minimum x and y indexes of where image values are defined in the subimage
	
%}    
	
	% Variable initialization
    image_minimum = [];
    image_maximum = [];
    subimage_maximum = [];
    subimage_minimum = [];
    
	% Define same block size across all image dimensions if only a number was given
    if length(blocksize) == 1
        blocksize = blocksize*center./center;
    end

    % Calculate the image and subimage boundaries
    for j = 1:size(center,2)
        
		% Calculate distance from center of subimage to edge of subimage
        blockwidth = floor((blocksize(j)-1)/2);
        subimage_center = blockwidth+1;
        
		% Calculate minimum index values on image and subimage
        minimum_index = minimum(j);
        subimage_minimum_index = 1;
        if (center(j) - blockwidth) > minimum_index
            minimum_index = (center(j) - blockwidth);
        end
        if (center(j) - blockwidth) < minimum_index
            subimage_minimum_index = subimage_center-(center(j)-minimum_index);
        end
            
        image_minimum = [image_minimum, minimum_index];
        subimage_minimum = [subimage_minimum, subimage_minimum_index];

		% Calculate maximum index values on image and subimage
        maximum_index = maximum(j);
        subimage_maximum_index = blocksize(j);
        if (center(j) + blockwidth) < maximum_index
            maximum_index = (center(j) + blockwidth);
        end
        if (center(j) + blockwidth) > maximum_index
            subimage_maximum_index = subimage_center+(maximum_index-center(j));
        end
        
        image_maximum = [image_maximum, maximum_index];
        subimage_maximum = [subimage_maximum, subimage_maximum_index];

    end

end