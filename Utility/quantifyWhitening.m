
function [avg_Whitening, whiteningMagnitudeImage, whiteningMagnitudeOnNodes] = quantifyWhitening(gridX, gridY, newPositionX, newPositionY, orgImg, whitenedImage, orgReference, subsetSize_smooth)

%Input:
%gridX - A list of the x coordinate of all nodes in the whitening analysis
%gridY - A list of the y coordinate of all nodes in the whitening analysis
%newPositionX - a list of the x coordinate of the displaced position of the
%   original node from gridX
%newPositionY - a list of the y coordinate of the displaced position of the
%   original node from gridY
%orgImage - the original image
%whitenedImage - the deformed and whitened image
%orgReference - a true/false variable used to indicate in the org reference or in the displaced reference frame
%subsetSize_smooth - whitening is calculated by smoothing the image with a 
%   kernal that has this size and then taking the value of the iamge at the node

%Output
%avg_Whitening - average whitening on the whole frame within the ROI implied by gridX, gridY
%whiteningMagnitudeImage - image that takes values by finding difference in
    %the warped and the whitened deformed image when in the same reference,
    %result is then smoothed accordingly
%whiteningMagnitudeOnNodes - value of whitening on nodes defined in
    %gridX,gridY, this is a list of (x,y,whitening)

	nNodes = size(newPositionX,1);
	nFrames = size(newPositionX,2);
	nXpixels = size(orgImg,1);
	nYpixels = size(orgImg,2);
	whiteningMagnitudeImage = ones(nXpixels,nYpixels,nFrames);
	whiteningMagnitudeOnNodes = ones(nNodes,3,nFrames);
    avg_Whitening = ones(1,nFrames);
	
    orgMarks=cell(nNodes,1);
    destMarks=cell(nNodes,1);
	
	if isempty(subsetSize_smooth)
		subsetSize_smooth = 1;
	end
	
	for indFrame=1:nFrames
		%orgMarks=cell(1,2)
		%orgMarks{1}=gridX;
		%orgMarks{2}=gridY;

		%destMarks= cell(1,2)
		%destMarks{1}=newPositionX(:,indFrame);
		%destMarks{2}=newPositionY(:,indFrame);
        boundingBox = ones(1,4);
        boundingBox(1) = 99999;
        boundingBox(2) = 99999;
        boundingBox(3) = -99999;
        boundingBox(4) = -99999;
        
        for indNodes=1:nNodes
            orgMarks{indNodes}=[gridX(indNodes),gridY(indNodes)];
            destMarks{indNodes}=[newPositionX(indNodes,indFrame),newPositionY(indNodes,indFrame)];
            
			if orgReference == true
				whiteningMagnitudeOnNodes(indNodes,1,indFrame) = gridX(indNodes);
				whiteningMagnitudeOnNodes(indNodes,2,indFrame) = gridY(indNodes);
                
                if boundingBox(1) > gridX(indNodes)
                    boundingBox(1) = gridX(indNodes);
                end
                if boundingBox(3) < gridX(indNodes)
                    boundingBox(3) = gridX(indNodes);
                end
                if boundingBox(2) > gridY(indNodes)
                    boundingBox(2) = gridY(indNodes);
                end
                if boundingBox(4) < gridY(indNodes)
                    boundingBox(4) = gridY(indNodes);
                end
			else
				whiteningMagnitudeOnNodes(indNodes,1,indFrame) = newPositionX(indNodes,indFrame);
				whiteningMagnitudeOnNodes(indNodes,2,indFrame) = newPositionY(indNodes,indFrame);
			end
        end
		if orgReference == true
			orgImg_Com = orgImg(boundingBox(2):boundingBox(4),boundingBox(1):boundingBox(3));
			WhitenedImage_Com = warpImage(whitenedImage(:,:,indFrame),destMarks,orgMarks);
            WhitenedImage_Com = WhitenedImage_Com(boundingBox(2):boundingBox(4),boundingBox(1):boundingBox(3));
            figure;
            imshow(WhitenedImage_Com, [1 255]);
            figure;
            imshow(orgImg_Com, [1 255]);
		else
			WhitenedImage_Com = whitenedImage(boundingBox(2):boundingBox(4),boundingBox(1):boundingBox(3),indFrame);
			orgImg_Com = warpImage(orgImg,orgMarks,destMarks);
            orgImg_Com = orgImg_Com(boundingBox(2):boundingBox(4),boundingBox(1):boundingBox(3));
		end
		
		h = fspecial('average', subsetSize_smooth);
        whiteningMagnitudeImageAbsolute = imfilter((WhitenedImage_Com - double(orgImg_Com)),h);
		whiteningMagnitudeImageRelative = imfilter((WhitenedImage_Com - double(orgImg_Com))./double(orgImg_Com),h);
		
        figure;
        %imshow(whiteningMagnitudeImage(boundingBox(2):boundingBox(4),boundingBox(1):boundingBox(3)), [min(min(whiteningMagnitudeImage)) max(max(whiteningMagnitudeImage))]);
        
        tempCol = interp2(whiteningMagnitudeImageAbsolute,whiteningMagnitudeOnNodes(:,1,indFrame)-boundingBox(1)+1,whiteningMagnitudeOnNodes(:,2,indFrame)-boundingBox(2)+1);
		whiteningMagnitudeOnNodes(:,3,indFrame) = tempCol;
        tempCol = interp2(whiteningMagnitudeImageRelative,whiteningMagnitudeOnNodes(:,1,indFrame)-boundingBox(1)+1,whiteningMagnitudeOnNodes(:,2,indFrame)-boundingBox(2)+1);
        whiteningMagnitudeOnNodes(:,4,indFrame) = tempCol;
		
		avg_Whitening(indFrame) = mean(whiteningMagnitudeOnNodes(:,3,indFrame));
	end
end