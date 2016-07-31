function Skeletonization_Merge_Image_And_Skeleton( image, skel_image, Origin, SpacingSize, DimensionSize, title_str )

image_x_axis = linspace(Origin(1),Origin(1)+ SpacingSize(1)*DimensionSize(1), DimensionSize(1));
image_y_axis = linspace(Origin(2),Origin(2)+ SpacingSize(2)*DimensionSize(2), DimensionSize(2));

skel_color = [1, 0, 1];

scale_ratio = max(image(:)) - min(image(:));

RGB_image = double(cat(3, image./scale_ratio, image./scale_ratio, image./scale_ratio));

RGB_image_merge = RGB_image;



for idx = 1:size(skel_image,1)
    for idy = 1:size(skel_image,2)
        if skel_image(idx,idy)>0
            RGB_image_merge(idx,idy,:) = skel_color;
        end
    end
end

figure
hold on
imagesc(image_x_axis, image_y_axis, RGB_image_merge)
%image('XData',image_x_axis, 'YData', image_y_axis, 'CData', RGB_image_merge);
axis image;
%axis off;
if exist('title_str', 'var')
    str=sprintf('%s', title_str);
    title(str);
end
hold off


end

