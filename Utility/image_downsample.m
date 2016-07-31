function [downSampledImage] = image_downsample(image,reductionFactor)
%this function reduces the size of an "image" volume by reducing the number of
%pixels in accordinance with "reductionFactor" ie if an image has
%100x100x100 pixels and the reductionFactor=5 then the resulting image will
%have 20x20x20 pixels.

imageDimensions = size(image);

downSampledImage = zeros(int16(imageDimensions(1)/reductionFactor), int16(imageDimensions(2)/reductionFactor), int16(imageDimensions(3)/reductionFactor));


downSampledXIndex = 1;

for xIndex = 1:reductionFactor:imageDimensions(1)
    downSampledXIndex = downSampledXIndex + 1;
    downSampledYIndex = 1;
    for yIndex = 1:reductionFactor:imageDimensions(2)
        downSampledYIndex = downSampledYIndex + 1;
        downSampledZIndex = 1;
        for zIndex = 1:reductionFactor:imageDimensions(3)
            downSampledZIndex = downSampledZIndex + 1;
            downSampledImage(downSampledXIndex,downSampledYIndex,downSampledZIndex) = image(xIndex,yIndex,zIndex);
        end
    end
end

