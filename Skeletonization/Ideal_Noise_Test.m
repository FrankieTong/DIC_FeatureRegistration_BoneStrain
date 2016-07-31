
clear all
clc
state = 0;
tic;           % help us to see the time required for each step

% Inputs special to meshless methods, domain of influence

shape = 'circle' ;         % shape of domain of influence
form  = 'cubic_spline' ;   % using cubic spline weight function
downsample_scaling = 2;
PixelWidthMin = 5;
PixelWidthMax = -1;
    
domain_influence_variable = false;
beta = 3.0; %[2,3]

calculate_on_nodal_points = true;
calculate_on_segment = true;
neighbouring_points_min = 3;

ideal_case = true;

std_noise = 0.4; %pixels
rng(10);

ND = true;
lambda = 0; %Failed attempt at trying to apply dampening...


%Additional Inputs for testing purposes
%standardResampleScaleMatch_WithOriginal_5offedge_BoundaryBox %Input point information from external source
%standardResampleScaleMatch_1p1and2_subpixel_alligned

%zeroStrain1_diffOctave
%zeroStrain1_diffOctave_v2
%zeroStrain1_sameOctave
%zeroStrain2_diffOctave
%zeroStrain2_sameOctave
%linearly02_diffoctave
%linearly02_diffoctave_v2
%linearly10_diffoctave
%linearly20_diffoctave
linearly20_diffoctave_Skeleton



%More reorganization of information

if exist('displacement_vectors_ideal','var')
    displacement_vectors = displacement_vectors_ideal; 
elseif exist('displacement_eq','var') 
    displacement_vectors = displacement_eq(fixed_points(:,1:ImageDimensionality));
else
    disp('Can not compute ideal case. Lacking information from setup files for ideal displacement field.');
    return
end

if exist('strain_vectors_ideal','var')
    strain_vectors = strain_vectors_ideal;
elseif exist('strain_eq', 'var')
    strain_vectors = strain_eq(fixed_points(:,1:ImageDimensionality));
else
    disp('Can not compute ideal case. Lacking information from setup files for ideal strain field.');
    return
end

if calculate_on_segment == true
    if exist('fixed_image_segment','var') == false
        disp('Can not compute di based on segmented image as segmented image does not exist.');
        return
    end
end

%displacement_vectors(60,2) = displacement_vectors(60,2)*100;

%Generate noisy displacement field
std_noise_vector = randn(size(displacement_vectors,1),ImageDimensionality);

for i = 1:size(std_noise_vector,1)
    std_noise_vector(i,:) = 0.4*SpacingSize.*std_noise_vector(i,:);
end

displacement_vectors_noisy(:,1:ImageDimensionality) = displacement_vectors(:,1:ImageDimensionality) + std_noise_vector;


nodal_points = fixed_points(:,1:ImageDimensionality);
FarCorner = Origin + SpacingSize.*(DimensionSize-1);

%displacement_vectors(70,2) = 10*displacement_vectors(70,2);


%imresize

% Choose method to impose essential boundary condition
% disp_bc_method = 1 : Lagrange multiplier method
% disp_bc_method = 2 : Penalty method

% +++++++++++++++++++++++++++++++++++++
%  PLOT NODES,BACKGROUND MESH, GPOINTS
% +++++++++++++++++++++++++++++++++++++
disp([num2str(toc),'   PLOT NODES AND GAUSS POINTS'])

if ImageDimensionality==2

    figure
    hold on
    imagesc(image_x_axis, image_y_axis, fixed_image)
    colormap('gray')
    h = plot(nodal_points(:,1),nodal_points(:,2),'r.');
    set(h,'MarkerSize',10.5);
    axis image;
    title('Fixed Image');
    
    
    
    figure
    hold on
    imagesc(image_x_axis, image_y_axis, moving_image)
    colormap('gray')
    h = plot(moving_points(:,1),moving_points(:,2),'r.');
    set(h,'MarkerSize',10.5);
    axis image;
    title('Moving Image');

    figure
    hold on
    h = quiver(nodal_points(:,1),nodal_points(:,2),displacement_vectors(:,1), displacement_vectors(:,2),0,'b');
    set(h,'MarkerSize',10.5);
    axis image;
    %axis off
    title('SIFT Displacement Vectors (Ideal)');
    
    %Should go somewhere else
    if calculate_on_nodal_points == true
        figure
        hold on
        h = quiver(nodal_points(:,1),nodal_points(:,2),strain_vectors(:,1), strain_vectors(:,2),0,'r-');
        set(h,'MarkerSize',10.5);
        axis image;
        %axis off  
        title('SIFT Strain Vectors (Ideal)');
    end
    
    
    if calculate_on_segment == true
        figure
        hold on
        imagesc(image_x_axis, image_y_axis, fixed_image_segment)
        colormap('gray')
        h = plot(fixed_points(:,1),fixed_points(:,2),'r.');
        set(h,'MarkerSize',10.5);
        axis image;
        title('Fixed Image Segmented');
    end

end





% +++++++++++++++++++++++++++++++++++++
%          DOMAIN ASSEMBLY
% +++++++++++++++++++++++++++++++++++++
disp([num2str(toc),'   DOMAIN ASSEMBLY'])

matrix_size = floor(DimensionSize./downsample_scaling)-1;


for i = 1:ImageDimensionality
    matrix_size(i) = floor(DimensionSize(i)/downsample_scaling);
    uniform_grid_spacing(i) = (FarCorner(i) - Origin(i))./(matrix_size(i)-1);
    if matrix_size(i) < 1
        matrix_size(i) = 1;
        uniform_grid_spacing(i) = FarCorner(i) - Origin(i);
    end
    
end
%matrix_size = floor(DimensionSize./downsample_scaling);

uniform_grid_size = 1;

for i = 1:ImageDimensionality
    uniform_grid_size = matrix_size(i)* uniform_grid_size;
end

uniform_grid = zeros(uniform_grid_size, ImageDimensionality);

coefficent = ones(1,ImageDimensionality);
    
for i = ImageDimensionality:-1:2
    for j = i-1:-1:1
        coefficent(i) = coefficent(i)*matrix_size(j);
    end
end

for index = 1:uniform_grid_size
    matrix_index = ones(1,ImageDimensionality)*index;
    for i = 1:ImageDimensionality
        for j = ImageDimensionality:-1:i+1
            matrix_index(i) = mod(index-1,coefficent(j))+1;
        end
        matrix_index(i) = floor((matrix_index(i)-1)/coefficent(i))+1;
        uniform_grid(index,i) = (matrix_index(i)-1)*uniform_grid_spacing(i) + Origin(i);
        
    end
end


if calculate_on_nodal_points == false && calculate_on_segment == true
    
    %Resample segmented image into the uniform_grid coordinates
    
    %Generate the grid vectors for the image
    fixed_image_segment_grid_vectors = {};
    for i = 1:ImageDimensionality
       fixed_image_segment_grid_vectors{i} = [Origin(i):SpacingSize(i):FarCorner(i)];
    end
    
    %Generate interpolant for each point
    fixed_image_segment_interpolator = griddedInterpolant(fixed_image_segment_grid_vectors,fixed_image_segment','nearest');
    
    %Go through each point in uniform_grid and determine if it lies in
    %segmented region
    
    uniform_grid_segment = [];
    uniform_grid_segment_index = 1;
    
    for i = 1:size(uniform_grid,1)
       
        if (fixed_image_segment_interpolator(uniform_grid(i,:)) == 1)
            uniform_grid_segment(uniform_grid_segment_index,:) = uniform_grid(i,:);
            uniform_grid_segment_index = uniform_grid_segment_index + 1;
        end
        
    end
    
    
end
 
    
if calculate_on_nodal_points == false && exist('displacement_eq','var')
    uniform_displacement_field_ideal = displacement_eq(uniform_grid);
end

if calculate_on_nodal_points == false && exist('strain_eq', 'var')
    uniform_strain_field_ideal = strain_eq(uniform_grid);
end





    
    
    


%Identify the minimum size of di for each point to encompass at least 3
%points in minimum size is not large enough


if domain_influence_variable == true
    if calculate_on_nodal_points == false
        if calculate_on_segment == false
            di = define_minimum_support2(uniform_grid, nodal_points, SpacingSize(1) * PixelWidthMin, neighbouring_points_min);
        else
            di = define_minimum_support2(uniform_grid_segment, nodal_points, SpacingSize(1) * PixelWidthMin, neighbouring_points_min);
        end
    else
    	di = define_minimum_support2(nodal_points, nodal_points, SpacingSize(1) * PixelWidthMin, neighbouring_points_min);
    end
	
else
	if beta > 0
		nodal_points_average_spacing = (prod(DimensionSize.*SpacingSize)^(1/ImageDimensionality))/(size(nodal_points,1)^(1/ImageDimensionality) - 1);
		di = ones(1,size(nodal_points,1)) * beta * nodal_points_average_spacing;
	else
		di = ones(1,size(nodal_points,1)) *  SpacingSize(1) * PixelWidthMin;
	end
end

di_max = ones(1,size(nodal_points,1))*SpacingSize(1)*PixelWidthMax;

if calculate_on_nodal_points == false
    num_node = size(uniform_grid,1);
else
	num_node = size(nodal_points,1);
end

if ImageDimensionality == 2

    figure
    hold on
    h = plot(nodal_points(:,1),nodal_points(:,2),'b.');
    set(h,'MarkerSize',10.5);
    axis image;
    for i = 1:size(di,2)
        ang=0:0.01:2*pi; 
        xp=di(i)*cos(ang);
        yp=di(i)*sin(ang);
        hold on
        h = plot(xp+nodal_points(i,1),yp+nodal_points(i,2),'r');
    end
    title('SIFT Feature Points and their Domain of Influence');
end









% +++++++++++++++++++++++++++++++++++++
%    COMPUTE THE TRUE DISPLACEMENTS
% +++++++++++++++++++++++++++++++++++++

disp([num2str(toc),'   INTERPOLATION TO GET TRUE DISPLACEMENT'])
displacement = zeros(1,ImageDimensionality*num_node);
strain = zeros(1,ImageDimensionality*num_node);
displacement_effected_by = zeros(1,ImageDimensionality*num_node);
%displacement = zeros(1,2*num_node);
%displacement_effected_by = zeros(1,2*num_node);

%for i = 1 : num_node
for i = 1 : num_node
    
    if calculate_on_nodal_points == false
        [index] = define_support(nodal_points, uniform_grid(i,:),di);
    else
        [index] = define_support(nodal_points, nodal_points(i,:),di);
    end
    
    if di_max > 0
        if calculate_on_nodal_points == false
            [index_defined] = define_support(nodal_points, uniform_grid(i,:),di_max);
        else
            [index_defined] = define_support(nodal_points, nodal_points(i,:),di_max);
        end
    end
    
    nodal_points_in_range_num = size(index,2);
    
    
    
    
    if calculate_on_nodal_points == false && calculate_on_segment == false
        if di_max > 0
            nodal_points_in_range_num = size(index_defined,2);
        end
    end
    
    if calculate_on_nodal_points == false && calculate_on_segment == true
        if fixed_image_segment_interpolator(uniform_grid(i,:)) == 0
            nodal_points_in_range_num = 0;
        end
    end
    
    if nodal_points_in_range_num >= neighbouring_points_min
        
        if ND == false
            % shape function at nodes in neighbouring of node i
            if calculate_on_nodal_points == false
                [phi,dphidx,dphidy] = MLS_ShapeFunction(uniform_grid(i,:), index , nodal_points,di,form);
            else
                [phi,dphidx,dphidy] = MLS_ShapeFunction(nodal_points(i,:), index , nodal_points,di,form);
            end
        else
            % N Dimensions
            if calculate_on_nodal_points == false
                [phi,dphidn] = MLS_ShapeFunctionND(uniform_grid(i,:), index , nodal_points,di,form, lambda);
            else
                [phi,dphidn] = MLS_ShapeFunctionND(nodal_points(i,:), index , nodal_points,di,form, lambda);
            end
            
            %Displacement generated at each point
            
            for j = 1 : size(index,2)
                
                if ND == false
                    if (phi(j)*displacement_vectors(index(j),1)' ~= 0 ||  phi(j)*displacement_vectors(index(j),2)' ~= 0)
                        displacement_effected_by(1,2*i-1) = displacement_effected_by(1,2*i-1) + 1;
                        displacement_effected_by(1,2*i) = displacement_effected_by(1,2*i) + 1;
                    end
                    
                    displacement(1,2*i-1) = displacement(1,2*i-1) + phi(j)*displacement_vectors(index(j),1)'; % x nodal displacement
                    displacement(1,2*i)   = displacement(1,2*i) + phi(j)*displacement_vectors(index(j),2)'; % y nodal displacement
                else
                    for k = 1 : ImageDimensionality
                        if (phi(j)*displacement_vectors(index(j),k)' ~= 0)
                            displacement_effected_by(1,ImageDimensionality*(i-1)+k) = displacement_effected_by(1,ImageDimensionality*(i-1)+k) + 1;
                        end
                        displacement(1,ImageDimensionality*(i-1)+k) = displacement(1,ImageDimensionality*(i-1)+k) + phi(j)*displacement_vectors(index(j),k)';
                    end
                end
                
            end
            
            %Stress generated at each point
            
            for j = 1 : size(index,2)
                
                if ND == false
                    strain(1,2*i-1) = strain(1,2*i-1) + dphidx(j)*displacement_vectors(index(j),1)'; % x nodal displacement
                    strain(1,2*i)   = strain(1,2*i) + dphidy(j)*displacement_vectors(index(j),2)'; % y nodal displacement
                else
                    
                    for k = 1 : ImageDimensionality
                        strain(1,ImageDimensionality*(i-1)+k) = strain(1,ImageDimensionality*(i-1)+k) + dphidn(j,k)*displacement_vectors(index(j),k)';
                    end
                end
                
            end
        end
            
     else
            
            if ND == false
                %Displacement generated at each point
                displacement(1,2*i-1) = NaN; % x nodal displacement
                displacement(1,2*i)   = NaN; % y nodal displacement
                
                strain(1,2*i-1) = NaN; % x nodal displacement
                strain(1,2*i)   = NaN; % y nodal displacement
            else
                for j = 1 : ImageDimensionality
                    displacement(1,ImageDimensionality*(i-1)+j) = NaN;
                    strain(1,ImageDimensionality*(i-1)+j) = NaN;
                end
            end
            
    end
        
        
        
    
    
end




disp([num2str(toc),'   INTERPOLATION TO GET NOISED DISPLACEMENT'])


displacement_noisy = zeros(1,ImageDimensionality*num_node);
strain_noisy = zeros(1,ImageDimensionality*num_node);

ND = true;

%for i = 1 : num_node
for i = 1 : num_node
    
    if calculate_on_nodal_points == false
        [index] = define_support(nodal_points, uniform_grid(i,:),di);
    else
        [index] = define_support(nodal_points, nodal_points(i,:),di);
    end
    
    if di_max > 0
        if calculate_on_nodal_points == false
            [index_defined] = define_support(nodal_points, uniform_grid(i,:),di_max);
        else
            [index_defined] = define_support(nodal_points, nodal_points(i,:),di_max);
        end
    end
    
    nodal_points_in_range_num = size(index,2);
    
    
    
    
    if calculate_on_nodal_points == false && calculate_on_segment == false
        if di_max > 0
            nodal_points_in_range_num = size(index_defined,2);
        end
    end
    
    if calculate_on_nodal_points == false && calculate_on_segment == true
        if fixed_image_segment_interpolator(uniform_grid(i,:)) == 0
            nodal_points_in_range_num = 0;
        end
    end
    
    
    if nodal_points_in_range_num >= neighbouring_points_min
        
        if ND == false
            % shape function at nodes in neighbouring of node i
            if calculate_on_nodal_points == false
                [phi,dphidx,dphidy] = MLS_ShapeFunction(uniform_grid(i,:), index , nodal_points,di,form);
            else
                [phi,dphidx,dphidy] = MLS_ShapeFunction(nodal_points(i,:), index , nodal_points,di,form);
            end
        else
            % N Dimensions
            if calculate_on_nodal_points == false
                [phi,dphidn] = MLS_ShapeFunctionND(uniform_grid(i,:), index , nodal_points,di,form, lambda);
            else
                [phi,dphidn] = MLS_ShapeFunctionND(nodal_points(i,:), index , nodal_points,di,form, lambda);
            end
            
            %Displacement generated at each point
            
            for j = 1 : size(index,2)
                
                if ND == false
                    
                    displacement_noisy(1,2*i-1) = displacement_noisy(1,2*i-1) + phi(j)*displacement_vectors_noisy(index(j),1)'; % x nodal displacement
                    displacement_noisy(1,2*i)   = displacement_noisy(1,2*i) + phi(j)*displacement_vectors_noisy(index(j),2)'; % y nodal displacement
                else
                    for k = 1 : ImageDimensionality
                        displacement_noisy(1,ImageDimensionality*(i-1)+k) = displacement_noisy(1,ImageDimensionality*(i-1)+k) + phi(j)*displacement_vectors_noisy(index(j),k)';
                    end
                end
                
            end
            
            %Stress generated at each point
            
            for j = 1 : size(index,2)
                
                if ND == false
                    strain_noisy(1,2*i-1) = strain_noisy(1,2*i-1) + dphidx(j)*displacement_vectors_noisy(index(j),1)'; % x nodal displacement
                    strain_noisy(1,2*i)   = strain_noisy(1,2*i) + dphidy(j)*displacement_vectors_noisy(index(j),2)'; % y nodal displacement
                else
                    
                    for k = 1 : ImageDimensionality
                        strain_noisy(1,ImageDimensionality*(i-1)+k) = strain_noisy(1,ImageDimensionality*(i-1)+k) + dphidn(j,k)*displacement_vectors_noisy(index(j),k)';
                    end
                end
                
            end
            
            
        end
     else
            
            if ND == false
                %Displacement generated at each point
                displacement_noisy(1,2*i-1) = NaN; % x nodal displacement
                displacement_noisy(1,2*i)   = NaN; % y nodal displacement
                
                strain_noisy(1,2*i-1) = NaN; % x nodal displacement
                strain_noisy(1,2*i)   = NaN; % y nodal displacement
            else
                for j = 1 : ImageDimensionality
                    displacement_noisy(1,ImageDimensionality*(i-1)+j) = NaN;
                    strain_noisy(1,ImageDimensionality*(i-1)+j) = NaN;
                end
            end
            
        end
        
        
        
    
    
end








if ImageDimensionality == 2

    figure
    hold on

    if calculate_on_nodal_points == false
        h = quiver(uniform_grid(:,1),uniform_grid(:,2),displacement(1,1:2:2*num_node-1)', displacement(1,2:2:2*num_node)',0,'b-');
    else
        h = quiver(nodal_points(:,1),nodal_points(:,2),displacement(1,1:2:2*num_node-1)', displacement(1,2:2:2*num_node)',0,'b-');
    end
    
    for i = 1:num_node
        if isnan(displacement(1,2*i))
            h = plot(uniform_grid(i,1),uniform_grid(i,2),'rx');
        end
    end
    
    set(h,'MarkerSize',10.5);
    %axis([Origin(1) FarCorner(1) Origin(2) FarCorner(2)])
    axis image;
    %axis off
    
    title('Displacement Vectors (Calculated)');

    if exist('uniform_displacement_field_ideal','var')
        figure
        hold on
        h = quiver(uniform_grid(:,1),uniform_grid(:,2),uniform_displacement_field_ideal(:,1), uniform_displacement_field_ideal(:,2),0,'b-.');
        set(h,'MarkerSize',10.5);
        %axis([Origin(1) FarCorner(1) Origin(2) FarCorner(2)])
        axis image;
        %axis off
        title('Displacement Vectors (Ideal)');
    end
    
    
    figure
    hold on

    if calculate_on_nodal_points == false
        h = quiver(uniform_grid(:,1),uniform_grid(:,2),strain(1,1:2:2*num_node-1)', strain(1,2:2:2*num_node)',0,'r-');
    else
    	h = quiver(nodal_points(:,1),nodal_points(:,2),strain(1,1:2:2*num_node-1)', strain(1,2:2:2*num_node)',0,'r-');
    end
    axis image;
    for i = 1:num_node
        if isnan(strain(1,2*i))
            h = plot(uniform_grid(i,1),uniform_grid(i,2),'rx');
        end
    end
    set(h,'MarkerSize',10.5);
    %axis([Origin(1) FarCorner(1) Origin(2) FarCorner(2)])
    axis image;
    title('Strain Vectors(Calculated)');
    
    
    
    
    if exist('uniform_strain_field_ideal','var')
        figure
        hold on
        h = quiver(uniform_grid(:,1),uniform_grid(:,2),uniform_strain_field_ideal(:,1), uniform_strain_field_ideal(:,2),0,'r-.');
        set(h,'MarkerSize',10.5);
        %axis([Origin(1) FarCorner(1) Origin(2) FarCorner(2)])
        axis image;
        %axis off
        title('Strain Vectors(Calculated)');
    end
    
    
    
    
    x_axis = uniform_grid(1:floor(DimensionSize(1)/downsample_scaling),1);
    y_axis = uniform_grid(1:floor(DimensionSize(1)/downsample_scaling):floor(DimensionSize(1)/downsample_scaling)*floor(DimensionSize(2)/downsample_scaling),2);

    if calculate_on_nodal_points == false
        strain_matrix = strain(1,2:2:2*num_node);
        strain_matrix = vec2mat(strain_matrix, floor(DimensionSize(1)/downsample_scaling));
        
        % fixed_image_bin = imresize(fixed_image_bin, [length(x_axis) length(y_axis)], 'nearest');
        % for i = 1:size(fixed_image_bin,1)
        %     for j = 1:size(fixed_image_bin,2)
        %         if fixed_image_bin(i,j) == 0
        %             strain_matrix(i,j) = NaN;
        %         end
        %     end
        % end

        figure
        hold on
        imagesc(x_axis,y_axis, strain_matrix, [-0.25,0.25]);
        h = plot(nodal_points(:,1),nodal_points(:,2),'w.');
        set(h,'MarkerSize',10.5);
    %     xlim([min(x_axis) max(x_axis)]);
    %     ylim([min(y_axis) max(y_axis)]);
        axis image;
        z = colorbar;
        ylabel(z, 'Strain field')
        xlabel('test x')
        ylabel('test y')
        title('Strain Field (Calculated)');
        
        
        if exist('uniform_strain_field_ideal','var')
            
            strain_matrix = uniform_strain_field_ideal(:,2);
            strain_matrix = vec2mat(strain_matrix, floor(DimensionSize(1)/downsample_scaling));

            % fixed_image_bin = imresize(fixed_image_bin, [length(x_axis) length(y_axis)], 'nearest');
            % for i = 1:size(fixed_image_bin,1)
            %     for j = 1:size(fixed_image_bin,2)
            %         if fixed_image_bin(i,j) == 0
            %             strain_matrix(i,j) = NaN;
            %         end
            %     end
            % end

            figure
            hold on
            imagesc(x_axis,y_axis, strain_matrix, [-0.25,0.25]);
            h = plot(nodal_points(:,1),nodal_points(:,2),'w.');
            set(h,'MarkerSize',10.5);
        %     xlim([min(x_axis) max(x_axis)]);
        %     ylim([min(y_axis) max(y_axis)]);
            axis image;
            z = colorbar;
            ylabel(z, 'Strain Field Ideal')
            xlabel('test x')
            ylabel('test y')
            title('Strain Field (Ideal)');
        end
        
        
        
    end
    
    
    
    figure
    hold on

    if calculate_on_nodal_points == false
        h = quiver(uniform_grid(:,1),uniform_grid(:,2),displacement_noisy(1,1:2:2*num_node-1)', displacement_noisy(1,2:2:2*num_node)',0,'b-');
    else
        h = quiver(nodal_points(:,1),nodal_points(:,2),displacement_noisy(1,1:2:2*num_node-1)', displacement_noisy(1,2:2:2*num_node)',0,'b-');
    end
    
    for i = 1:num_node
        if isnan(displacement_noisy(1,2*i))
            h = plot(uniform_grid(i,1),uniform_grid(i,2),'rx');
        end
    end
    
    set(h,'MarkerSize',10.5);
    %axis([Origin(1) FarCorner(1) Origin(2) FarCorner(2)])
    axis image;
    %axis off
    
    title('Displacement Vectors (Noisy)');
    
    
    figure
    hold on

    if calculate_on_nodal_points == false
        h = quiver(uniform_grid(:,1),uniform_grid(:,2),strain_noisy(1,1:2:2*num_node-1)', strain_noisy(1,2:2:2*num_node)',0,'r-');
    else
    	h = quiver(nodal_points(:,1),nodal_points(:,2),strain_noisy(1,1:2:2*num_node-1)', strain_noisy(1,2:2:2*num_node)',0,'r-');
    end
    axis image;
    for i = 1:num_node
        if isnan(strain_noisy(1,2*i))
            h = plot(uniform_grid(i,1),uniform_grid(i,2),'rx');
        end
    end
    set(h,'MarkerSize',10.5);
    %axis([Origin(1) FarCorner(1) Origin(2) FarCorner(2)])
    axis image;
    title('Strain Vectors(Noisy)');
    
    
    
    
    x_axis = uniform_grid(1:floor(DimensionSize(1)/downsample_scaling),1);
    y_axis = uniform_grid(1:floor(DimensionSize(1)/downsample_scaling):floor(DimensionSize(1)/downsample_scaling)*floor(DimensionSize(2)/downsample_scaling),2);

    if calculate_on_nodal_points == false
        strain_noisy_matrix = strain_noisy(1,2:2:2*num_node);
        strain_noisy_matrix = vec2mat(strain_noisy_matrix, floor(DimensionSize(1)/downsample_scaling));
        
        % fixed_image_bin = imresize(fixed_image_bin, [length(x_axis) length(y_axis)], 'nearest');
        % for i = 1:size(fixed_image_bin,1)
        %     for j = 1:size(fixed_image_bin,2)
        %         if fixed_image_bin(i,j) == 0
        %             strain_matrix(i,j) = NaN;
        %         end
        %     end
        % end

        figure
        hold on
        imagesc(x_axis,y_axis, strain_noisy_matrix, [-0.25,0.25]);
        h = plot(nodal_points(:,1),nodal_points(:,2),'w.');
        set(h,'MarkerSize',10.5);
    %     xlim([min(x_axis) max(x_axis)]);
    %     ylim([min(y_axis) max(y_axis)]);
        axis image;
        z = colorbar;
        ylabel(z, 'Strain field')
        xlabel('test x')
        ylabel('test y')
        title('Strain Field (Noisy)');
        
        
        
    end
    
    
end

%Reshaping the resulting vectors from MLS for easier handilng
displacement_reshape = reshape(displacement, ImageDimensionality, [])';
strain_reshape = reshape(strain, ImageDimensionality, [])';
displacement_noisy_reshape = reshape(displacement_noisy, ImageDimensionality, [])';
strain_noisy_reshape = reshape(strain_noisy, ImageDimensionality, [])';
    
%Plot Displacement Values vs Position
figure
hold on

if calculate_on_nodal_points == false
    plot(uniform_grid(:,ImageDimensionality),uniform_displacement_field_ideal(:,ImageDimensionality),'b.');
else
    plot(nodal_points(:,ImageDimensionality),displacement_vectors(:,ImageDimensionality),'b.');
end

x_array = zeros(100,ImageDimensionality);
x_array(:,ImageDimensionality) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
y_array = displacement_eq(x_array);

plot(x_array(:,ImageDimensionality),y_array(:,ImageDimensionality),'r-');

xlim([Origin(ImageDimensionality) FarCorner(ImageDimensionality)]);
%ylim([linearly_increasing_strain 0]);
title('Displacement Values (Ideal) vs. Y-Position');
xlabel('Y-Position');
ylabel('Displacement Values (Ideal)');




figure
hold on
if calculate_on_nodal_points == false
    plot(uniform_grid(:,ImageDimensionality),displacement_reshape(:,ImageDimensionality),'b.');
else
    plot(nodal_points(:,ImageDimensionality),displacement_reshape(:,ImageDimensionality),'b.');
end


x_array = zeros(100,ImageDimensionality);
x_array(:,ImageDimensionality) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
y_array = displacement_eq(x_array);

plot(x_array(:,ImageDimensionality),y_array(:,ImageDimensionality),'r-');

xlim([Origin(ImageDimensionality) FarCorner(ImageDimensionality)]);
%ylim([linearly_increasing_strain 0]);
title('Displacement Values (Calculated) vs. Y-Position');
xlabel('Y-Position');
ylabel('Displacement Values (Calculated)');




figure
hold on
if calculate_on_nodal_points == false
    plot(uniform_grid(:,ImageDimensionality),displacement_noisy_reshape(:,ImageDimensionality),'b.');
else
    plot(nodal_points(:,ImageDimensionality),displacement_noisy_reshape(:,ImageDimensionality),'b.');
end


x_array = zeros(100,ImageDimensionality);
x_array(:,ImageDimensionality) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
y_array = displacement_eq(x_array);

plot(x_array(:,ImageDimensionality),y_array(:,ImageDimensionality),'r-');

xlim([Origin(ImageDimensionality) FarCorner(ImageDimensionality)]);

%ylim([linearly_increasing_strain 0]);
title('Displacement Values (Noisy) vs. Y-Position');
xlabel('Y-Position');
ylabel('Displacement Values (Noisy)');







%Plot Strain Values vs Position
figure
hold on
if calculate_on_nodal_points == false
    plot(uniform_grid(:,ImageDimensionality),uniform_strain_field_ideal(:,ImageDimensionality),'b.');
else
    plot(nodal_points(:,ImageDimensionality),strain_vectors(:,ImageDimensionality),'b.');
end
plot([Origin(ImageDimensionality) FarCorner(ImageDimensionality)], [0 linearly_increasing_strain], 'r-');

xlim([Origin(ImageDimensionality) FarCorner(ImageDimensionality)]);
ylim([linearly_increasing_strain 0]);
title('Strain Values (Ideal) vs. Y-Position');
xlabel('Y-Position');
ylabel('Strain Values (Ideal)');




figure
hold on
if calculate_on_nodal_points == false
    plot(uniform_grid(:,ImageDimensionality),strain_reshape(:,ImageDimensionality),'b.');
else
    plot(nodal_points(:,ImageDimensionality),strain_reshape(:,ImageDimensionality),'b.');
end
plot([Origin(ImageDimensionality) FarCorner(ImageDimensionality)], [0 linearly_increasing_strain], 'r-');

xlim([Origin(ImageDimensionality) FarCorner(ImageDimensionality)]);
ylim([linearly_increasing_strain 0]);
title('Strain Values (Calculated) vs. Y-Position');
xlabel('Y-Position');
ylabel('Strain Values (Calculated)');

figure
hold on
if calculate_on_nodal_points == false
    plot(uniform_grid(:,ImageDimensionality),strain_noisy_reshape(:,ImageDimensionality),'b.');
else
    plot(nodal_points(:,ImageDimensionality),strain_noisy_reshape(:,ImageDimensionality),'b.');
end
plot([Origin(2) FarCorner(ImageDimensionality)], [0 linearly_increasing_strain], 'r-');

xlim([Origin(2) FarCorner(ImageDimensionality)]);
ylim([linearly_increasing_strain 0]);
title('Strain Values (Noisy) vs. Y-Position');
xlabel('Y-Position');
ylabel('Strain Values (Noisy)');





%Plot Displacement Calculated and Displacement Noisy vs Displacement Ideal
figure;
if calculate_on_nodal_points == false
    plot(uniform_displacement_field_ideal(:,ImageDimensionality), displacement_reshape(:,ImageDimensionality),'b.');
    hold on

    x_array = linspace(min(uniform_displacement_field_ideal(:,ImageDimensionality)),max(uniform_displacement_field_ideal(:,ImageDimensionality)));
    y_array = x_array;
    plot(x_array,y_array,'r-');

    xlim([min(uniform_displacement_field_ideal(:,ImageDimensionality)) max(uniform_displacement_field_ideal(:,ImageDimensionality))]);
else
    plot(displacement_vectors(:,ImageDimensionality), displacement_reshape(:,ImageDimensionality),'b.');
    hold on

    x_array = linspace(min(displacement_vectors(:,ImageDimensionality)),max(displacement_vectors(:,ImageDimensionality)));
    y_array = x_array;
    plot(x_array,y_array,'r-');

    xlim([min(displacement_vectors(:,ImageDimensionality)) max(displacement_vectors(:,ImageDimensionality))]);
end

title('Displacement Values (Calculated) vs. Displacement Values (Ideal)');
xlabel('Displacement Values (Ideal)');
ylabel('Displacement Values (Calculated)');
ylim([min(displacement_reshape(:,ImageDimensionality)) max(displacement_reshape(:,ImageDimensionality))]);


%Caculate line of best fit for Displacement Calculated vs Displacement Ideal and
%identify zero offset and slope

%Calculate R^2 with Displacement Calculated vs Displacement Ideal

if calculate_on_nodal_points == false

    %Need to recalculate uniform_displacement_field_ideal and
    %displacement_vectors to remove NaNs from the list
    count = 1;
    for i = 1:size(displacement_reshape,1)

        if isfinite(sum(displacement_reshape(i,:))) == true
           uniform_displacement_field_ideal_no_nan(count,:) = uniform_displacement_field_ideal(i,:);
           displacement_no_nan(count,:) = displacement_reshape(i,:);
           count = count + 1;
        end
    end

    F = [uniform_displacement_field_ideal_no_nan(:,ImageDimensionality).^0 uniform_displacement_field_ideal_no_nan(:,ImageDimensionality)];           % make design matrix [1,x]
else
    F = [displacement_vectors(:,ImageDimensionality).^0 displacement_vectors(:,ImageDimensionality)];           % make design matrix [1,x]
    displacement_no_nan = displacement_reshape;
end
c = F\displacement_no_nan(:,ImageDimensionality);                  % get least-squares fit
res = displacement_no_nan(:,ImageDimensionality) - F*c;           % calculate residuals
r2 = 1 - nanvar(res)/nanvar(displacement_no_nan(:,ImageDimensionality));  % calculate R^2

disp('Displacement Calculated vs. Displacement Ideal');

string = sprintf('R^2: %f',r2);
disp(string);
string = sprintf('Offset: %f',c(1));
disp(string);
string = sprintf('Slope: %f',c(2));
disp(string);




figure;
if calculate_on_nodal_points == false
    plot(uniform_displacement_field_ideal(:,ImageDimensionality), displacement_noisy_reshape(:,ImageDimensionality),'b.');
    hold on

    x_array = linspace(min(uniform_displacement_field_ideal(:,ImageDimensionality)),max(uniform_displacement_field_ideal(:,ImageDimensionality)));
    y_array = x_array;
    plot(x_array,y_array,'r-');

    xlim([min(uniform_displacement_field_ideal(:,ImageDimensionality)) max(uniform_displacement_field_ideal(:,ImageDimensionality))]);
else
    plot(displacement_vectors(:,ImageDimensionality), displacement_noisy_reshape(:,ImageDimensionality),'b.');
    hold on

    x_array = linspace(min(displacement_vectors(:,ImageDimensionality)),max(displacement_vectors(:,ImageDimensionality)));
    y_array = x_array;
    plot(x_array,y_array,'r-');

    xlim([min(displacement_vectors(:,ImageDimensionality)) max(displacement_vectors(:,ImageDimensionality))]);
end

title('Displacement Values (Noisy) vs. Displacement Values (Ideal)');
xlabel('Displacement Values (Ideal)');
ylabel('Displacement Values (Noisy)');
ylim([min(displacement_noisy_reshape(:,ImageDimensionality)) max(displacement_noisy_reshape(:,ImageDimensionality))]);

%Caculate line of best fit for Displacement Calculated vs Displacement Ideal and
%identify zero offset and slope

%Calculate R^2 with Displacement Calculated vs Displacement Ideal

if calculate_on_nodal_points == false

    %Need to recalculate uniform_displacement_field_ideal and
    %displacement_vectors to remove NaNs from the list
    count = 1;
    for i = 1:size(displacement_noisy_reshape,1)

        if isfinite(sum(displacement_noisy_reshape(i,:))) == true
           uniform_displacement_field_ideal_no_nan(count,:) = uniform_displacement_field_ideal(i,:);
           displacement_no_nan(count,:) = displacement_noisy_reshape(i,:);
           count = count + 1;
        end
    end

    F = [uniform_displacement_field_ideal_no_nan(:,ImageDimensionality).^0 uniform_displacement_field_ideal_no_nan(:,ImageDimensionality)];           % make design matrix [1,x]
else
    F = [displacement_vectors(:,ImageDimensionality).^0 displacement_vectors(:,ImageDimensionality)];           % make design matrix [1,x]
    displacement_no_nan = displacement_noisy_reshape;
end
c = F\displacement_no_nan(:,ImageDimensionality);                  % get least-squares fit
res = displacement_no_nan(:,ImageDimensionality) - F*c;           % calculate residuals
r2 = 1 - nanvar(res)/nanvar(displacement_no_nan(:,ImageDimensionality));  % calculate R^2

disp('Displacement Noisy vs. Displacement Ideal');

string = sprintf('R^2: %f',r2);
disp(string);
string = sprintf('Offset: %f',c(1));
disp(string);
string = sprintf('Slope: %f',c(2));
disp(string);





%Plot Strain Calculated and Strain Noisy vs Strain Ideal
figure;
if calculate_on_nodal_points == false
    plot(uniform_strain_field_ideal(:,ImageDimensionality), strain_reshape(:,ImageDimensionality),'b.');
    hold on

    x_array = linspace(min(uniform_strain_field_ideal(:,ImageDimensionality)),max(uniform_strain_field_ideal(:,ImageDimensionality)));
    y_array = x_array;
    plot(x_array,y_array,'r-');

    xlim([min(uniform_strain_field_ideal(:,ImageDimensionality)) max(uniform_strain_field_ideal(:,ImageDimensionality))]);
else
    plot(strain_vectors(:,ImageDimensionality), strain_reshape(:,ImageDimensionality),'b.');
    hold on

    x_array = linspace(min(strain_vectors(:,ImageDimensionality)),max(strain_vectors(:,ImageDimensionality)));
    y_array = x_array;
    plot(x_array,y_array,'r-');

    xlim([min(strain_vectors(:,ImageDimensionality)) max(strain_vectors(:,ImageDimensionality))]);
end

title('Strain Values (Calculated) vs. Strain Values (Ideal)');
xlabel('Strain Values (Ideal)');
ylabel('Strain Values (Calculated)');
ylim([min(strain_reshape(:,ImageDimensionality)) max(strain_reshape(:,ImageDimensionality))]);


%Caculate line of best fit for Strain Calculated vs Strain Ideal and
%identify zero offset and slope

%Calculate R^2 with Strain Calculated vs Strain Ideal


if calculate_on_nodal_points == false

    %Need to recalculate uniform_strain_field_ideal and
    %strain_vectors to remove NaNs from the list
    count = 1;
    for i = 1:size(strain_reshape,1)

        if isfinite(sum(strain_reshape(i,:))) == true
           uniform_strain_field_ideal_no_nan(count,:) = uniform_strain_field_ideal(i,:);
           strain_no_nan(count,:) = strain_reshape(i,:);
           count = count + 1;
        end
    end

    F = [uniform_strain_field_ideal_no_nan(:,ImageDimensionality).^0 uniform_strain_field_ideal_no_nan(:,ImageDimensionality)];           % make design matrix [1,x]
else
    F = [strain_vectors(:,ImageDimensionality).^0 strain_vectors(:,ImageDimensionality)];           % make design matrix [1,x]
    strain_no_nan = strain_reshape;
end
c = F\strain_no_nan(:,ImageDimensionality);                  % get least-squares fit
res = strain_no_nan(:,ImageDimensionality) - F*c;           % calculate residuals
r2 = 1 - nanvar(res)/nanvar(strain_no_nan(:,ImageDimensionality));  % calculate R^2

disp('Strain Calculated vs. Strain Ideal');

string = sprintf('R^2: %f',r2);
disp(string);
string = sprintf('Offset: %f',c(1));
disp(string);
string = sprintf('Slope: %f',c(2));
disp(string);






figure;
if calculate_on_nodal_points == false
    plot(uniform_strain_field_ideal(:,ImageDimensionality), strain_noisy_reshape(:,ImageDimensionality),'b.');
    hold on

    x_array = linspace(min(uniform_strain_field_ideal(:,ImageDimensionality)),max(uniform_strain_field_ideal(:,ImageDimensionality)));
    y_array = x_array;
    plot(x_array,y_array,'r-');

    xlim([min(uniform_strain_field_ideal(:,ImageDimensionality)) max(uniform_strain_field_ideal(:,ImageDimensionality))]);
else
    plot(strain_vectors(:,ImageDimensionality), strain_noisy_reshape(:,ImageDimensionality),'b.');
    hold on

    x_array = linspace(min(strain_vectors(:,ImageDimensionality)),max(strain_vectors(:,ImageDimensionality)));
    y_array = x_array;
    plot(x_array,y_array,'r-');

    xlim([min(strain_vectors(:,ImageDimensionality)) max(strain_vectors(:,ImageDimensionality))]);
end

title('Strain Values (Noisy) vs. Strain Values (Ideal)');
xlabel('Strain Values (Ideal)');
ylabel('Strain Values (Noisy)');
ylim([min(strain_noisy_reshape(:,ImageDimensionality)) max(strain_noisy_reshape(:,ImageDimensionality))]);



%Caculate line of best fit for Strain Calculated vs Strain Ideal and
%identify zero offset and slope

%Calculate R^2 with Strain Calculated vs Strain Ideal
if calculate_on_nodal_points == false

    %Need to recalculate uniform_strain_field_ideal and
    %strain_vectors to remove NaNs from the list
    count = 1;
    for i = 1:size(strain_noisy_reshape,1)

        if isfinite(sum(strain_noisy_reshape(i,:))) == true
           uniform_strain_field_ideal_no_nan(count,:) = uniform_strain_field_ideal(i,:);
           strain_no_nan(count,:) = strain_noisy_reshape(i,:);
           count = count + 1;
        end
    end

    F = [uniform_strain_field_ideal_no_nan(:,ImageDimensionality).^0 uniform_strain_field_ideal_no_nan(:,ImageDimensionality)];           % make design matrix [1,x]
else
    F = [strain_vectors(:,ImageDimensionality).^0 strain_vectors(:,ImageDimensionality)];           % make design matrix [1,x]
    strain_no_nan = strain_noisy_reshape;
end
c = F\strain_no_nan(:,ImageDimensionality);                  % get least-squares fit
res = strain_no_nan(:,ImageDimensionality) - F*c;           % calculate residuals
r2 = 1 - nanvar(res)/nanvar(strain_no_nan(:,ImageDimensionality));  % calculate R^2

disp('Strain Noisy vs. Strain Ideal');

string = sprintf('R^2: %f',r2);
disp(string);
string = sprintf('Offset: %f',c(1));
disp(string);
string = sprintf('Slope: %f',c(2));
disp(string);



%% Print out difference measures for displacement and strain results

% displacement_reshape = reshape(displacement, ImageDimensionality, [])';
% strain_reshape = reshape(strain, ImageDimensionality, [])';
% displacement_noisy_reshape = reshape(displacement_noisy, ImageDimensionality, [])';
% strain_noisy_reshape = reshape(strain_noisy, ImageDimensionality, [])';
%     

disp('Displacement Field Results (Calculated)');
string = sprintf('mean: %f',nanmean(displacement_reshape(:,ImageDimensionality)));
disp(string);
string = sprintf('standard deviation: %f',nanstd(displacement_reshape(:,ImageDimensionality)));
disp(string);

if calculate_on_nodal_points == true
    if exist('displacement_vectors','var')
        disp('Displacement Field Difference (Calculated)');
        directional_similarity = displacement_reshape(:,ImageDimensionality).*displacement_vectors(:,ImageDimensionality)./abs(displacement_reshape(:,ImageDimensionality).*displacement_vectors(:,ImageDimensionality));
        difference_of_magnitude = abs(displacement_reshape(:,ImageDimensionality)) - abs(displacement_vectors(:,ImageDimensionality));
        magnitude_of_difference = abs(displacement_reshape(:,ImageDimensionality) - displacement_vectors(:,ImageDimensionality));

        string = sprintf('directional similarity: %f +/- %f',nanmean(directional_similarity), nanstd(directional_similarity));
        disp(string);
        string = sprintf('difference of magnitude: %f +/- %f',nanmean(difference_of_magnitude), nanstd(difference_of_magnitude));
        disp(string);
        string = sprintf('magnitude of difference: %f +/- %f',nanmean(magnitude_of_difference), nanstd(magnitude_of_difference));
        disp(string);
    end
    
else
    
    if exist('uniform_displacement_field_ideal','var')
    
        disp('Displacement Field Difference (Calculated)');
        directional_similarity = displacement_reshape(:,ImageDimensionality).*uniform_displacement_field_ideal(:,ImageDimensionality)./abs(displacement_reshape(:,ImageDimensionality).*uniform_displacement_field_ideal(:,ImageDimensionality));
        difference_of_magnitude = abs(displacement_reshape(:,ImageDimensionality)) - abs(uniform_displacement_field_ideal(:,ImageDimensionality));
        magnitude_of_difference = abs(displacement_reshape(:,ImageDimensionality) - uniform_displacement_field_ideal(:,ImageDimensionality));


        string = sprintf('directional similarity: %f +/- %f',nanmean(directional_similarity), nanstd(directional_similarity));
        disp(string);
        string = sprintf('difference of magnitude: %f +/- %f',nanmean(difference_of_magnitude), nanstd(difference_of_magnitude));
        disp(string);
        string = sprintf('magnitude of difference: %f +/- %f',nanmean(magnitude_of_difference), nanstd(magnitude_of_difference));
        disp(string);
        
    end
end


disp('Strain Field Results (Calculated)');
string = sprintf('mean: %f',nanmean(strain_reshape(:,ImageDimensionality)));
disp(string);
string = sprintf('standard deviation: %f',nanstd(strain_reshape(:,ImageDimensionality)));
disp(string);

if calculate_on_nodal_points == true
    if exist('strain_vectors','var')
        disp('Strain Field Difference (Calculated)');
        directional_similarity = strain_reshape(:,ImageDimensionality).*strain_vectors(:,ImageDimensionality)./abs(strain_reshape(:,ImageDimensionality).*strain_vectors(:,ImageDimensionality));
        difference_of_magnitude = abs(strain_reshape(:,ImageDimensionality)) - abs(strain_vectors(:,ImageDimensionality));
        magnitude_of_difference = abs(strain_reshape(:,ImageDimensionality) - strain_vectors(:,ImageDimensionality));


        string = sprintf('directional similarity: %f +/- %f',nanmean(directional_similarity), nanstd(directional_similarity));
        disp(string);
        string = sprintf('difference of magnitude: %f +/- %f',nanmean(difference_of_magnitude), nanstd(difference_of_magnitude));
        disp(string);
        string = sprintf('magnitude of difference: %f +/- %f',nanmean(magnitude_of_difference), nanstd(magnitude_of_difference));
        disp(string);
    end
    
else
    
    if exist('uniform_strain_field_ideal','var')
    
        disp('Strain Field Difference (Calculated)');
        directional_similarity = strain_reshape(:,ImageDimensionality).*uniform_strain_field_ideal(:,ImageDimensionality)./abs(strain_reshape(:,ImageDimensionality).*uniform_strain_field_ideal(:,ImageDimensionality));
        difference_of_magnitude = abs(strain_reshape(:,ImageDimensionality)) - abs(uniform_strain_field_ideal(:,ImageDimensionality));
        magnitude_of_difference = abs(strain_reshape(:,ImageDimensionality) - uniform_strain_field_ideal(:,ImageDimensionality));


        string = sprintf('directional similarity: %f +/- %f',nanmean(directional_similarity), nanstd(directional_similarity));
        disp(string);
        string = sprintf('difference of magnitude: %f +/- %f',nanmean(difference_of_magnitude), nanstd(difference_of_magnitude));
        disp(string);
        string = sprintf('magnitude of difference: %f +/- %f',nanmean(magnitude_of_difference), nanstd(magnitude_of_difference));
        disp(string);
        
    end
end





disp('Displacement Field Results (Noisy)');
string = sprintf('mean: %f',nanmean(displacement_noisy_reshape(:,ImageDimensionality)));
disp(string);
string = sprintf('standard deviation: %f',nanstd(displacement_noisy_reshape(:,ImageDimensionality)));
disp(string);

if calculate_on_nodal_points == true
    if exist('displacement_vectors','var')
        disp('Displacement Field Difference (Noisy)');
        directional_similarity = displacement_noisy_reshape(:,ImageDimensionality).*displacement_vectors(:,ImageDimensionality)./abs(displacement_noisy_reshape(:,ImageDimensionality).*displacement_vectors(:,ImageDimensionality));
        difference_of_magnitude = abs(displacement_noisy_reshape(:,ImageDimensionality)) - abs(displacement_vectors(:,ImageDimensionality));
        magnitude_of_difference = abs(displacement_noisy_reshape(:,ImageDimensionality) - displacement_vectors(:,ImageDimensionality));

        string = sprintf('directional similarity: %f +/- %f',nanmean(directional_similarity), nanstd(directional_similarity));
        disp(string);
        string = sprintf('difference of magnitude: %f +/- %f',nanmean(difference_of_magnitude), nanstd(difference_of_magnitude));
        disp(string);
        string = sprintf('magnitude of difference: %f +/- %f',nanmean(magnitude_of_difference), nanstd(magnitude_of_difference));
        disp(string);
    end
    
else
    
    if exist('uniform_displacement_field_ideal','var')
    
        disp('Displacement Field Difference (Noisy)');
        directional_similarity = displacement_noisy_reshape(:,ImageDimensionality).*uniform_displacement_field_ideal(:,ImageDimensionality)./abs(displacement_noisy_reshape(:,ImageDimensionality).*uniform_displacement_field_ideal(:,ImageDimensionality));
        difference_of_magnitude = abs(displacement_noisy_reshape(:,ImageDimensionality)) - abs(uniform_displacement_field_ideal(:,ImageDimensionality));
        magnitude_of_difference = abs(displacement_noisy_reshape(:,ImageDimensionality) - uniform_displacement_field_ideal(:,ImageDimensionality));


        string = sprintf('directional similarity: %f +/- %f',nanmean(directional_similarity), nanstd(directional_similarity));
        disp(string);
        string = sprintf('difference of magnitude: %f +/- %f',nanmean(difference_of_magnitude), nanstd(difference_of_magnitude));
        disp(string);
        string = sprintf('magnitude of difference: %f +/- %f',nanmean(magnitude_of_difference), nanstd(magnitude_of_difference));
        disp(string);
        
    end
end


disp('Strain Field Results (Noisy)');
string = sprintf('mean: %f',nanmean(strain_noisy_reshape(:,ImageDimensionality)));
disp(string);
string = sprintf('standard deviation: %f',nanstd(strain_noisy_reshape(:,ImageDimensionality)));
disp(string);

if calculate_on_nodal_points == true
    if exist('strain_vectors','var')
        disp('Strain Field Difference (Noisy)');
        directional_similarity = strain_noisy_reshape(:,ImageDimensionality).*strain_vectors(:,ImageDimensionality)./abs(strain_noisy_reshape(:,ImageDimensionality).*strain_vectors(:,ImageDimensionality));
        difference_of_magnitude = abs(strain_noisy_reshape(:,ImageDimensionality)) - abs(strain_vectors(:,ImageDimensionality));
        magnitude_of_difference = abs(strain_noisy_reshape(:,ImageDimensionality) - strain_vectors(:,ImageDimensionality));


        string = sprintf('directional similarity: %f +/- %f',nanmean(directional_similarity), nanstd(directional_similarity));
        disp(string);
        string = sprintf('difference of magnitude: %f +/- %f',nanmean(difference_of_magnitude), nanstd(difference_of_magnitude));
        disp(string);
        string = sprintf('magnitude of difference: %f +/- %f',nanmean(magnitude_of_difference), nanstd(magnitude_of_difference));
        disp(string);
    end
    
else
    
    if exist('uniform_strain_field_ideal','var')
    
        disp('Strain Field Difference (Noisy)');
        directional_similarity = strain_noisy_reshape(:,ImageDimensionality).*uniform_strain_field_ideal(:,ImageDimensionality)./abs(strain_noisy_reshape(:,ImageDimensionality).*uniform_strain_field_ideal(:,ImageDimensionality));
        difference_of_magnitude = abs(strain_noisy_reshape(:,ImageDimensionality)) - abs(uniform_strain_field_ideal(:,ImageDimensionality));
        magnitude_of_difference = abs(strain_noisy_reshape(:,ImageDimensionality) - uniform_strain_field_ideal(:,ImageDimensionality));


        string = sprintf('directional similarity: %f +/- %f',nanmean(directional_similarity), nanstd(directional_similarity));
        disp(string);
        string = sprintf('difference of magnitude: %f +/- %f',nanmean(difference_of_magnitude), nanstd(difference_of_magnitude));
        disp(string);
        string = sprintf('magnitude of difference: %f +/- %f',nanmean(magnitude_of_difference), nanstd(magnitude_of_difference));
        disp(string);
        
    end
end