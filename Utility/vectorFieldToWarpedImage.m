function [ warpedImage, equivalentAffineTransform ] = vectorFieldToWarpedImage( deformationField, image )
%use the deformationfield output by image_registration to deform the image
%using warpImage function

xSize = size(deformationField,2);
ySize = size(deformationField,1);

originalPosition = cell(xSize*ySize,1);
destination = cell(xSize*ySize,1);

originalPositionDouble = zeros(xSize*ySize,2);
destinationDouble = zeros(xSize*ySize,2);

counter = 1;
for indx = 1:xSize
    for indy = 1:ySize
        currentPosition = zeros(1,2);
        currentDestination = zeros(1,2);

        currentPosition(1,1) = indx;
        currentPosition(1,2) = indy;
        currentDestination(1,1) = indx+deformationField(indy,indx,2);
        currentDestination(1,2) = indy+deformationField(indy,indx,1);
        
        %Bx=B(:,:,1); By=B(:,:,2);
        
        originalPosition{counter} = currentPosition;
        destination{counter} = currentDestination;
        
        originalPositionDouble(counter,:)=currentPosition;
        destinationDouble(counter,:)=currentDestination;
        
        counter = counter +1;
    end
end



warpedImage = warpImage(image, originalPosition, destination);

equivalentAffineTransform = cp2tform(originalPositionDouble, destinationDouble, 'affine');


end

