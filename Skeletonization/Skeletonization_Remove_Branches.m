function [skeleton_without_branches] = Skeletonization_Remove_Branches(skeleton)

% Removes all branches in the skeleton image input and return the skeleton
% image back up.

%skeleton= bwmorph(ima,'skel',Inf);
B = bwmorph(skeleton, 'branchpoints');
E = bwmorph(skeleton, 'endpoints');
[y,x] = find(E);
B_loc = find(B);
Dmask = false(size(skeleton));
for k = 1:numel(x)
    D = bwdistgeodesic(skeleton,x(k),y(k));
    distanceToBranchPt = min(D(B_loc));
    Dmask(D < distanceToBranchPt) =true;
end
skeleton_without_branches = skeleton - Dmask;
% imshow(skelD);
% hold all;
% [y,x] = find(B); plot(x,y,'ro')

end