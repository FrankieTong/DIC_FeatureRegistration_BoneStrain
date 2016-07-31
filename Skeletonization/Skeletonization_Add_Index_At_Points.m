function Skeletonization_Add_Index_At_Points(points, font_size, color)

hold on
if ~exist('font_size','var')
    font_size = 10;
end
if ~exist('color','var')
    color = 'k';
end
for i = 1:size(points,1)
    text(points(i,1),points(i,2),num2str(i),'Color',color,'FontSize',font_size);
end


hold off


end