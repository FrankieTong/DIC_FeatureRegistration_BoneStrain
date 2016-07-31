function Skeletonization_Display_Graphs(points, values, ideal_points, ideal_values, x_axis_limits, title_str, title_x_axis, title_y_axis)
figure
hold on

for i = 1:size(ideal_points,2)
    plot(ideal_points(:,i),ideal_values(:,i),'r-');
end

plot(points, values,'b.');

if x_axis_limits(1) == x_axis_limits(2)
    x_axis_limits(1) = x_axis_limits(1) - 0.1;
    x_axis_limits(2) = x_axis_limits(2) + 0.1;
end

y_axis_limits = [(-0.5*max(ideal_values(:)) + 1.5*min(ideal_values(:))) (1.5*max(ideal_values(:)) - 0.5*min(ideal_values(:)))];
if y_axis_limits(1) == y_axis_limits(2)
        y_axis_limits(1) = y_axis_limits(1) - 0.1;
        y_axis_limits(2) = y_axis_limits(2) + 0.1;
end

xlim(x_axis_limits);
ylim(y_axis_limits);
title(title_str);
xlabel(title_x_axis);
ylabel(title_y_axis);

hold off

end