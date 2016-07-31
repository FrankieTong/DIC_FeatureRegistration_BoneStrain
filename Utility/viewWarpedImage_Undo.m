%need to define orgImage

nodesPerFrame = size(TOTAL_DEFORMATIONS(:,:,1),1) * size(TOTAL_DEFORMATIONS(:,:,1),2);
def_image256 = 256*def_image;
warpedStack=warpImageStack(reshape(orig_gridX+TOTAL_DEFORMATIONS(:,:,1),nodesPerFrame,1),reshape(orig_gridY+TOTAL_DEFORMATIONS(:,:,2),nodesPerFrame,1),reshape(orig_gridX,nodesPerFrame,1),reshape(orig_gridY,nodesPerFrame,1),warpedStack);
figure('Name','orgImage');
imshow(orgImage((orig_gridY(1,1)+TOTAL_DEFORMATIONS(1,1,2)):(orig_gridY(end,end)+TOTAL_DEFORMATIONS(end,end,2)),(orig_gridX(1,1)+TOTAL_DEFORMATIONS(1,1,1)):(orig_gridX(end,end)+TOTAL_DEFORMATIONS(end,end,1))),[1,255]);
figure('Name','warpedImage_Undo');
imshow(warpedStack((orig_gridY(1,1)+TOTAL_DEFORMATIONS(1,1,2)):(orig_gridY(end,end)+TOTAL_DEFORMATIONS(end,end,2)),(orig_gridX(1,1)+TOTAL_DEFORMATIONS(1,1,1)):(orig_gridX(end,end)+TOTAL_DEFORMATIONS(end,end,1))),[1,255]);
figure('Name','def_image');
imshow(def_image256((orig_gridY(1,1)+TOTAL_DEFORMATIONS(1,1,2)):(orig_gridY(end,end)+TOTAL_DEFORMATIONS(end,end,2)),(orig_gridX(1,1)+TOTAL_DEFORMATIONS(1,1,1)):(orig_gridX(end,end)+TOTAL_DEFORMATIONS(end,end,1))),[1,255]);

