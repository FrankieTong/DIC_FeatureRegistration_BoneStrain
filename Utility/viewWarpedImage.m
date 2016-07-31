%need to define orgImage
function [orgImageROI, warpedImageROI,targetImageROI] = viewWarpedImage(orgImage, workSpaceResultFile, writeFiles, viewFiles)

    %orgImage - the undeformed file supplied to the DIC program
    %workSpaceResultFile - the workspace file that is written out by the DIC program
    %writeFiles - a variable with the following series of 3 flags that indicate whether the orgImage, warpedImage and targetImage will be written to disk with the following default: [false false false]
    %viewFiles - a variable with the following series of 3 flags that indicate whether the orgImage, warpedImage and targetImage will be viewed in separate figure windows with the following default: [false false false]


    workspace_pathstr = '';
    workspace_fileName = '';
    workspace_ext = '';
    currentDIR = pwd;
    
	if nargin < 4
		viewFiles = [false false false];
	end
	if nargin < 3
		writeFiles = [false false false];
	end
	if nargin < 2
		global TOTAL_DEFORMATIONS;
		global def_image;
		global orig_gridX;
		global orig_gridY;
    else
        [workspace_pathstr, workspace_fileName, workspace_ext] = fileparts(workSpaceResultFile);
        if isempty(workspace_pathstr) == false
            cd(workspace_pathstr);
        end
		load(workspace_fileName);
        cd(currentDIR);
        
	end
	if nargin < 1
		global orgImage;
	end
	
	
	
	nodesPerFrame = size(TOTAL_DEFORMATIONS(:,:,1),1) * size(TOTAL_DEFORMATIONS(:,:,1),2);
	def_image256 = 256*def_image;
	warpedStack=warpImageStack(reshape(orig_gridX,nodesPerFrame,1),reshape(orig_gridY,nodesPerFrame,1),reshape(orig_gridX+TOTAL_DEFORMATIONS(:,:,1),nodesPerFrame,1),reshape(orig_gridY+TOTAL_DEFORMATIONS(:,:,2),nodesPerFrame,1),orgImage);
	
	orgImageROI = orgImage(orig_gridY(1,1):orig_gridY(end,end),orig_gridX(1,1):orig_gridX(end,end));
	warpedImageROI = warpedStack(orig_gridY(1,1):orig_gridY(end,end),orig_gridX(1,1):orig_gridX(end,end));
	targetImageROI = def_image256(orig_gridY(1,1):orig_gridY(end,end),orig_gridX(1,1):orig_gridX(end,end));
	
	if viewFiles(1) == true
        minVal = min(min(orgImageROI));
        maxVal = max(max(orgImageROI));
		figure('Name','orgImage');
		imshow(orgImageROI,[minVal,maxVal]);
    end
    if viewFiles(2) == true
        minVal = min(min(warpedImageROI));
        maxVal = max(max(warpedImageROI));
		figure('Name',['warpedImage_' workspace_fileName]);
		imshow(warpedImageROI,[minVal,maxVal]);
    end
    if viewFiles(3) == true
        minVal = min(min(targetImageROI));
        maxVal = max(max(targetImageROI));
		figure('Name','targetImage');
		imshow(targetImageROI,[minVal,maxVal]);
	end
	if writeFiles(1) == true
        if isempty(workspace_pathstr) == false
            cd(workspace_pathstr);
        end
        minVal = min(min(double(orgImageROI)));
        maxVal = max(max(double(orgImageROI)));
        orgImageROI = ((double(orgImageROI)-minVal)+1)*255/(maxVal-minVal);
		imwrite(uint8(orgImageROI),'orgImageROI.tif');
        cd(currentDIR);
    end
	if writeFiles(2) == true
        if isempty(workspace_pathstr) == false
            cd(workspace_pathstr);
        end
        minVal = min(min(warpedImageROI));
        maxVal = max(max(warpedImageROI));
        warpedImageROI = ((warpedImageROI-minVal)+1)*255/(maxVal-minVal);
		imwrite(uint8(warpedImageROI),'warpedImageROI.tif');
        cd(currentDIR);
    end
	if writeFiles(3) == true
        if isempty(workspace_pathstr) == false
            cd(workspace_pathstr);
        end
        minVal = min(min(targetImageROI));
        maxVal = max(max(targetImageROI));
        targetImageROI = ((targetImageROI-minVal)+1)*255/(maxVal-minVal);
		imwrite(uint8(targetImageROI),'targetImageROI.tif');
        cd(currentDIR);
	end
end
