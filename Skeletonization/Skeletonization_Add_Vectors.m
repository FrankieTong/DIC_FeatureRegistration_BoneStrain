function Skeletonization_Add_Vectors(points, vectors, marker_size, color)

hold on
if ~exist('marker_size','var')
    marker_size = 10.5;
end
if ~exist('color','var')
    color = 'b';
end
h = quiver(points(:,1),points(:,2),vectors(:,1), vectors(:,2),0,color);
set(h,'MarkerSize',marker_size);
hold off


end