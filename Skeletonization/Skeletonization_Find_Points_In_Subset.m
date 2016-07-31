function [fixed_points_found, moving_points_found] = Skeletonization_Find_Points_In_Subset(fixed_points, moving_points,fixed_image_subset_boundary, moving_image_subset_boundary, upsample_scaling)

% Use inpolygon to determine which points are inside the edges of the input
% tetrahedron and which ones are not.

% First change the input boundary points to be useable by inpolygon. Format
% of the input vector for boundary points is [min_x, min_y, length_x, length_y];
% Specify boundary in coutnerclockwise fashion.
xv = [fixed_image_subset_boundary(1);fixed_image_subset_boundary(1);fixed_image_subset_boundary(1)+fixed_image_subset_boundary(3);fixed_image_subset_boundary(1)+fixed_image_subset_boundary(3);fixed_image_subset_boundary(1)];
yv = [fixed_image_subset_boundary(2);fixed_image_subset_boundary(2)+fixed_image_subset_boundary(4);fixed_image_subset_boundary(2)+fixed_image_subset_boundary(4);fixed_image_subset_boundary(2);fixed_image_subset_boundary(2)];

% Fix the boundaries for upsampling factor
xv = xv.*upsample_scaling;
yv = yv.*upsample_scaling;

fixed_points_found_logical = inpolygon(fixed_points(:,1), fixed_points(:,2), xv, yv);

% First change the input boundary points to be useable by inpolygon. Format
% of the input vector for boundary points is [min_x, min_y, length_x, length_y];
% Specify boundary in coutnerclockwise fashion.
xv = [moving_image_subset_boundary(1);moving_image_subset_boundary(1);moving_image_subset_boundary(1)+moving_image_subset_boundary(3);moving_image_subset_boundary(1)+moving_image_subset_boundary(3);moving_image_subset_boundary(1)];
yv = [moving_image_subset_boundary(2);moving_image_subset_boundary(2)+moving_image_subset_boundary(4);moving_image_subset_boundary(2)+moving_image_subset_boundary(4);moving_image_subset_boundary(2);moving_image_subset_boundary(2)];

xv = xv.*upsample_scaling;
yv = yv.*upsample_scaling;

moving_points_found_logical = inpolygon(moving_points(:,1), moving_points(:,2), xv, yv);

fixed_points_found = [];
moving_points_found = [];

for i = 1:size(fixed_points_found_logical,1)
    if fixed_points_found_logical(i) == 1
        fixed_points_found = [fixed_points_found; fixed_points(i,:)];
    end
end

for i = 1:size(moving_points_found_logical,1) 
    if moving_points_found_logical(i) == 1
        moving_points_found = [moving_points_found; moving_points(i,:)];
    end
end

% Readjust fixed_points_found and moving_points_found back to original
% image resolution

for i = 1:size(matchedPoints1,1)
    matchedPoints_fixed(i,:) =  matchedPoints1(i,:).*SpacingSize;
    matchedPoints_moving(i,:) =  matchedPoints2(i,:).*SpacingSize;
end