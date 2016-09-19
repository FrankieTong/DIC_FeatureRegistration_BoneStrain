function Skeletonization_Draw_Boundary_Box(box_list, line_width, line_color)

hold on

if ~exist('line_width', 'var')
    line_width = 0.5;
end

if ~exist('line_color', 'var')
    line_color = 'r';
end

alternate_color = length(line_color);

for i = 1:size(box_list,1)
    if ~strcmp(line_color(mod(i,alternate_color)+1), ' ')
        rectangle('Position', box_list(i,:), 'EdgeColor', line_color(mod(i,alternate_color)+1), 'LineWidth', line_width);
    end
end

hold off


end