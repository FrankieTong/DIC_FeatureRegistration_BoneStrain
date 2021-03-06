function [di] = define_minimum_support(uniform_grid, nodal_points, minumum_radius, num_points)

num_uniform_grid = size(uniform_grid,1) ;
for i = 1 : num_uniform_grid

    
    for j = 1 : size(nodal_points,1)
        
        diff(j) = pdist([uniform_grid(i,:); nodal_points(j,:)],'euclidean');
        
    end
    
    sorted_diff = sort(diff);
    
    smallest_radius = sorted_diff(num_points);
    
    if smallest_radius <= minumum_radius
        
        smallest_radius = minumum_radius;
        
    end
    
    di(i) = smallest_radius;
    
end

