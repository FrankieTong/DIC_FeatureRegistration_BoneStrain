function Skeletonization_Display_Figure(image, Origin, SpacingSize, DimensionSize, title_str)

image_x_axis = linspace(Origin(1),Origin(1)+ SpacingSize(1)*DimensionSize(1), DimensionSize(1));
image_y_axis = linspace(Origin(2),Origin(2)+ SpacingSize(2)*DimensionSize(2), DimensionSize(2));

figure
hold on
imagesc(image_x_axis, image_y_axis, image)
colormap('gray')
axis image;
axis off;
if exist('title_str', 'var')
    str=sprintf('%s', title_str);
    title(str);
end
hold off

end