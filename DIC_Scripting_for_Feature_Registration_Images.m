%{
This script displays images that are generated when running the main DIC_Scripting_for_Feature_Registration.m script. Useful for retirving these plots from a saved workspace.

%}

%% DVC

if Skeletonization_Only == false

   %%
    Skeletonization_Display_Figure(fixed_image, Origin, SpacingSize, DimensionSize, 'Fixed Image with Matched Feature Points for DVC');
    Skeletonization_Add_Points(fixed_points_DVC, 10.5, 'r.');

    Skeletonization_Display_Figure(fixed_image, Origin, SpacingSize, DimensionSize, 'Fixed Image with Matched Feature Point Vectors for DVC');
    Skeletonization_Add_Points(fixed_points_DVC, 10.5, 'r.');
    Skeletonization_Add_Vectors(fixed_points_DVC, displacement_DVC, 10.5, 'y');
    
    Skeletonization_Display_Figure(fixed_image, Origin, SpacingSize, DimensionSize, 'Fixed Image with Matched Feature Point Vectors for DVC');
    Skeletonization_Add_Points(fixed_points_DVC, 10.5, 'r.');
    Skeletonization_Add_Vectors(fixed_points_DVC, displacement_DVC, 10.5, 'y');
    Skeletonization_Add_Index_At_Points(fixed_points_DVC, 10, 'r')
    
    Skeletonization_Display_Figure(fixed_image, Origin, SpacingSize, DimensionSize, 'Fixed Image with Scaled Matched Feature Point Vectors for DVC');
    Skeletonization_Add_Points(fixed_points_DVC, 10.5, 'r.');
    Skeletonization_Add_Vectors_Scaled(fixed_points_DVC, displacement_DVC, 10.5, 'b');

end

%% DVC + Skel or Skel only

if DVC_Only == false

    Skeletonization_Display_Figure(fixed_image, Origin, SpacingSize, DimensionSize, 'Fixed Image with Matched Feature Points for Feature Reg');
    Skeletonization_Add_Points(fixed_points_MLS, 10.5, 'r.');
    Skeletonization_Draw_Boundary_Box(fixed_image_feature_find_subimages_boundary_MLS,0.5,['r','g']);

    Skeletonization_Display_Figure(moving_image, Origin, SpacingSize, DimensionSize, 'Moving Image with Matched Feature Points for Feature Reg');
    Skeletonization_Add_Points(moving_points_MLS, 10.5, 'r.');
    Skeletonization_Draw_Boundary_Box(moving_image_feature_find_subimages_boundary_MLS,0.5,['r','g']);

    Skeletonization_Display_Figure(fixed_image, Origin, SpacingSize, DimensionSize, 'Fixed Image with Matched Feature Point Vectors for Feature Reg');
    Skeletonization_Add_Points(fixed_points_MLS, 10.5, 'r.');
    Skeletonization_Add_Vectors(fixed_points_MLS, moving_points_MLS-fixed_points_MLS, 10.5, 'y');
    
    Skeletonization_Display_Figure(fixed_image, Origin, SpacingSize, DimensionSize, 'Fixed Image with Matched Feature Point Vectors for Feature Reg');
    Skeletonization_Add_Points(fixed_points_MLS, 10.5, 'r.');
    Skeletonization_Add_Vectors(fixed_points_MLS, moving_points_MLS-fixed_points_MLS, 10.5, 'y');
    Skeletonization_Add_Index_At_Points(fixed_points_MLS, 10, 'r')
    
    Skeletonization_Display_Figure(fixed_image, Origin, SpacingSize, DimensionSize, 'Fixed Image with Scaled Matched Feature Point Vectors for Feature Reg');
    Skeletonization_Add_Points(fixed_points_MLS, 10.5, 'r.');
    Skeletonization_Add_Vectors_Scaled(fixed_points_MLS, moving_points_MLS-fixed_points_MLS, 10.5, 'b');

% 
%     Skeletonization_Merge_Image_And_Skeleton(bin_fixed_image,skel_fixed_image, Origin, SpacingSize, DimensionSize, 'Skeleton Fixed Image with Matched Feature Points for Feature Reg');
%     Skeletonization_Add_Points(fixed_points_MLS, 10.5, 'r.');
%     Skeletonization_Draw_Boundary_Box(fixed_image_feature_find_subimages_boundary_MLS,0.5,'y');
%     Skeletonization_Draw_Boundary_Box(fixed_image_reconstruct_subimages_boundary_MLS,0.5,'g');
% 
%     Skeletonization_Merge_Image_And_Skeleton(bin_moving_image,skel_moving_image, Origin, SpacingSize, DimensionSize, 'Skeleton Moving Image wrt Fixed Image for Feature Reg');
%     Skeletonization_Draw_Boundary_Box(moving_image_feature_find_subimages_boundary_MLS,0.5,'y');
%     Skeletonization_Draw_Boundary_Box(moving_image_reconstruct_subimages_boundary_MLS,0.5,'g');

end