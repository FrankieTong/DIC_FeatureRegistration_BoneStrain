function Skeletonization_Add_Points(points, marker_size, color)

hold on
if ~exist('marker_size','var')
    marker_size = 10.5;
end
if ~exist('color','var')
    color = 'bo';
end
h = plot(points(:,1), points(:,2), color);
set(h,'MarkerSize',marker_size);
hold off


end