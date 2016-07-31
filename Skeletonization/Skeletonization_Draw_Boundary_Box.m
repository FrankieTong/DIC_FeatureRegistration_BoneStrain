function Skeletonization_Draw_Boundary_Box(box_list, line_width, line_color)

hold on

if ~exist('line_width', 'var')
    line_width = 0.5;
end

if ~exist('line_color', 'var')
    line_color = 'r';
end

for i = 1:size(box_list,1)
    rectangle('Position', box_list(i,:), 'EdgeColor', line_color, 'LineWidth', line_width);
end

hold off


end