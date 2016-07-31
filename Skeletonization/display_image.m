%%Display list of matched points with their images

clear all
clc

%standardResampleScaleMatch_WithOriginal_5offedge_BoundaryBox %Input point information from external source
%standardResampleScaleMatch_1p1and2_subpixel_alligned

%zeroStrain1_diffOctave
%zeroStrain1_diffOctave_v2
%zeroStrain1_sameOctave
%zeroStrain2_diffOctave
%zeroStrain2_sameOctave
%linearly02_diffoctave
%linearly02_diffoctave_v2
%linearly10_diffoctave
%linearly20_diffoctave
linearly20_diffoctave_Skeleton


%% Display fixed image and related points

if ImageDimensionality==2

    figure
    hold on
    imagesc(image_x_axis, image_y_axis, fixed_image)
    colormap('gray')
    h = plot(fixed_points(:,1),fixed_points(:,2),'r.');
    set(h,'MarkerSize',10.5);
    axis image;
    title('Fixed Image');
    
    
    
    figure
    hold on
    imagesc(image_x_axis, image_y_axis, moving_image)
    colormap('gray')
    h = plot(moving_points(:,1),moving_points(:,2),'r.');
    set(h,'MarkerSize',10.5);
    axis image;
    title('Moving Image');

    figure
    hold on
    imagesc(image_x_axis, image_y_axis, fixed_image)
    colormap('gray')
    h = quiver(fixed_points(:,1),fixed_points(:,2),(moving_points(:,1)- fixed_points(:,1)), (moving_points(:,2)- fixed_points(:,2)),0,'b');
    set(h,'MarkerSize',10.5);
    axis image;
    %axis off
    title('SIFT Displacement Vectors (Original)');
    
end