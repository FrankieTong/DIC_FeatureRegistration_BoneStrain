function warpedImageStack = warpImageStack(gridX, gridY, newPositionX, newPositionY, orgImg)
%Takes an Image and deforms it based upon node original nodes positions and new positions of the nodes using a spline surface fit method

%gridX - An array of the original x positions of all the nodes tracked by DIC
%gridY - An array of the original y positions of all the nodes tracked by DIC
%newPositionX - An array of the new(deformed) x positions of all the nodes tracked by DIC
%newPositionY - An array of the new(deformed) x positions of all the nodes tracked by DIC
%orgImg - the original image


	nNodes = size(newPositionX,1);
	nFrames = size(newPositionX,2);
	nXpixels = size(orgImg,1);
	nYpixels = size(orgImg,2);
	warpedImageStack = ones(nXpixels,nYpixels,nFrames);
    
    orgMarks=cell(nNodes,1);
    destMarks=cell(nNodes,1);
    
	for indFrame=1:nFrames
		%orgMarks=cell(1,2)
		%orgMarks{1}=gridX;
		%orgMarks{2}=gridY;

		%destMarks= cell(1,2)
		%destMarks{1}=newPositionX(:,indFrame);
		%destMarks{2}=newPositionY(:,indFrame);

        for indNodes=1:nNodes
            orgMarks{indNodes}=[gridX(indNodes),gridY(indNodes)];
            destMarks{indNodes}=[newPositionX(indNodes,indFrame),newPositionY(indNodes,indFrame)];
        end
		warpedImageStack(:,:,indFrame) = warpImage(orgImg,orgMarks,destMarks);
	end
end
