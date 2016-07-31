if exist('calculate_strain','var') == false || calculate_strain == false
    %clear all
    %clc
    
    %Additional Inputs for testing purposes
    %standardResampleScaleMatch_WithOriginal_5offedge_BoundaryBox %Input point information from external source
    %standardResampleScaleMatch_1p1and2_subpixel_alligned

    %zeroStrain1_diffOctave
    %zeroStrain1_diffOctave_v2
    %zeroStrain1_diffOctave_Skeleton
    %zeroStrain1_sameOctave
    %zeroStrain2_diffOctave
    %zeroStrain2_sameOctave
    %linearly02_diffoctave
    %linearly02_diffoctave_v2
    %linearly02_diffoctave_Skeleton
    %linearly10_diffoctave
    %linearly20_diffoctave
    %linearly20_diffoctave_Skeleton
    %linearly20_diffoctave_Skeletonv2
    %linearly20_diffoctave_Skeletonv3




    %zeroStrain_Deconv
    %zeroStrain_Deconv_Trabeculae
    %zeroStrain_Deconv_Trabeculae_NoGrowthPlates
    %linearly02_Deconv
    %linearly02_Deconv_Trabeculae
    %linearly02_Deconv_Trabeculae_NoGrowthPlates
    %linearly20_Deconv
    %linearly20_Deconv_Trabeculae
    %linearly20_Deconv_Trabeculae_NoGrowthPlates
    
    %linearly02_zeroStrain_Deconv
    %linearly02_zeroStrain_Deconv_Trabeculae
    linearly02_zeroStrain_Deconv_Trabeculae_NoGrowthPlates
    
end

%%
tic;           % help us to see the time required for each step

% Inputs special to meshless methods, domain of influence

shape = 'circle' ;         % shape of domain of influence
form  = 'cubic_spline' ;   % using cubic spline weight function
upsample_scaling_uniform_grid = 1;
PixelWidthMin = 5;
    
domain_influence_variable = false;
beta = 3.0; %[2,3]

calculate_on_nodal_points = true;
calculate_on_segment = false;
segment_refine = 1000;


neighbouring_points_min = 5;

use_calculated_displacement = true;

ideal_case = false;
Ideal_Noise_Test = false;
std_noise = 0.025; %pixels
rng(10);

ND = true;


image_x_axis = linspace(Origin(1),Origin(1)+ SpacingSize(1)*DimensionSize(1), DimensionSize(1));
image_y_axis = linspace(Origin(2),Origin(2)+ SpacingSize(2)*DimensionSize(2), DimensionSize(2));


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
   
        mask = zeros(size(fixed_image));
        mask( 5:end-5, 5:end-5) = 1;

        fixed_image_segment = activecontour(fixed_image, mask, segment_refine); %generates a binary mask
        
        fixed_image_segment = fixed_image_segment + 0; %convert from logical matrix to double matrix
    
%         disp('Can not compute di based on segmented image as segmented image does not exist.');
%         return
    end
end



displacement_vectors_actual = moving_points(:,1:ImageDimensionality) - fixed_points(:,1:ImageDimensionality);



if ideal_case == true && Ideal_Noise_Test == true
    %Generate noisy displacement field
    std_noise_vector = randn(size(displacement_vectors_actual,1),ImageDimensionality);

    for i = 1:size(std_noise_vector,1)
        if exist('downsample_scaling','var') == true
            std_noise_vector(i,:) = std_noise*(SpacingSize*downsample_scaling).*std_noise_vector(i,:);
        else 
            std_noise_vector(i,:) = std_noise*SpacingSize.*std_noise_vector(i,:);
        end
    end

    displacement_vectors_actual(:,1:ImageDimensionality) = displacement_vectors(:,1:ImageDimensionality) + std_noise_vector;
end


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
    title('Displacement Vectors (Ideal)');
    

    figure
    hold on
    h = quiver(nodal_points(:,1),nodal_points(:,2),displacement_vectors_actual(:,1), displacement_vectors_actual(:,2),0,'b');
    set(h,'MarkerSize',10.5);
    axis image;
    %axis off
    title('Displacement Vectors (Actual)');
        
    
    %Should go somewhere else
    if calculate_on_nodal_points == true
        figure
        hold on
        h = quiver(nodal_points(:,1),nodal_points(:,2),strain_vectors(:,1), strain_vectors(:,2),0,'r-');
        set(h,'MarkerSize',10.5);
        axis image;
        %axis off  
        title('Strain Vectors (Ideal)');
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

matrix_size = floor(DimensionSize./upsample_scaling_uniform_grid)-1;


for i = 1:ImageDimensionality
    matrix_size(i) = floor(DimensionSize(i)/upsample_scaling_uniform_grid);
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

if calculate_on_nodal_points == false
    num_node = size(uniform_grid,1);
else
	num_node = size(nodal_points,1);
end

if ImageDimensionality == 2

%     figure
%     hold on
%     h = plot(nodal_points(:,1),nodal_points(:,2),'r.');
%     set(h,'MarkerSize',10.5);
%     axis image;
%     for i = 1:size(di,2)
%         ang=0:0.01:2*pi; 
%         xp=di(i)*cos(ang);
%         yp=di(i)*sin(ang);
%         hold on
%         h = plot(xp+nodal_points(i,1),yp+nodal_points(i,2),'b');
%     end
%     title('Feature Points and their Domain of Influence');
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

for i = 1 : num_node
    
    if calculate_on_nodal_points == false
        [index] = define_support(nodal_points, uniform_grid(i,:),di);
    else
        [index] = define_support(nodal_points, nodal_points(i,:),di);
    end
    
    nodal_points_in_range_num = size(index,2);
    
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
                [phi,dphidn] = MLS_ShapeFunctionND(uniform_grid(i,:), index , nodal_points,di,form);
            else
                [phi,dphidn] = MLS_ShapeFunctionND(nodal_points(i,:), index , nodal_points,di,form);
            end
            
            %Displacement generated at each point
            
            for j = 1 : size(index,2)
                
                if ideal_case == true && Ideal_Noise_Test == false
                    if ND == false
                        displacement(1,2*i-1) = displacement(1,2*i-1) + phi(j)*displacement_vectors(index(j),1)'; % x nodal displacement
                        displacement(1,2*i)   = displacement(1,2*i) + phi(j)*displacement_vectors(index(j),2)'; % y nodal displacement
                    else
                        for k = 1 : ImageDimensionality
                            displacement(1,ImageDimensionality*(i-1)+k) = displacement(1,ImageDimensionality*(i-1)+k) + phi(j)*displacement_vectors(index(j),k)';
                        end
                    end
                else
                    if ND == false
                        displacement(1,2*i-1) = displacement(1,2*i-1) + phi(j)*displacement_vectors_actual(index(j),1)'; % x nodal displacement
                        displacement(1,2*i)   = displacement(1,2*i) + phi(j)*displacement_vectors_actual(index(j),2)'; % y nodal displacement
                    else
                        for k = 1 : ImageDimensionality
                            displacement(1,ImageDimensionality*(i-1)+k) = displacement(1,ImageDimensionality*(i-1)+k) + phi(j)*displacement_vectors_actual(index(j),k)';
                        end
                    end
                end
                
            end
            
            %Stress generated at each point
            
            for j = 1 : size(index,2)
                
                if ideal_case == true && Ideal_Noise_Test == false
                    if ND == false
                        strain(1,2*i-1) = strain(1,2*i-1) + dphidx(j)*displacement_vectors(index(j),1)'; % x nodal displacement
                        strain(1,2*i)   = strain(1,2*i) + dphidy(j)*displacement_vectors(index(j),2)'; % y nodal displacement
                    else

                        for k = 1 : ImageDimensionality
                            strain(1,ImageDimensionality*(i-1)+k) = strain(1,ImageDimensionality*(i-1)+k) + dphidn(j,k)*displacement_vectors(index(j),k)';
                        end
                    end
                else
                    
                    if ND == false
                        strain(1,2*i-1) = strain(1,2*i-1) + dphidx(j)*displacement_vectors_actual(index(j),1)'; % x nodal displacement
                        strain(1,2*i)   = strain(1,2*i) + dphidy(j)*displacement_vectors_actual(index(j),2)'; % y nodal displacement
                    else

                        for k = 1 : ImageDimensionality
                            strain(1,ImageDimensionality*(i-1)+k) = strain(1,ImageDimensionality*(i-1)+k) + dphidn(j,k)*displacement_vectors_actual(index(j),k)';
                        end
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





%Reshaping the resulting vectors from MLS for easier handilng
displacement_reshape = reshape(displacement, ImageDimensionality, [])';
strain_reshape = reshape(strain, ImageDimensionality, [])';


%Recalculate strain using smoothed displacement values from MLS

if use_calculated_displacement == true
    
    displacement = zeros(1,size(displacement,2));
    strain = zeros(1,size(strain,2));
    
    for i = 1 : num_node

        if calculate_on_nodal_points == false
            [index] = define_support(nodal_points, uniform_grid(i,:),di);
        else
            [index] = define_support(nodal_points, nodal_points(i,:),di);
        end

        nodal_points_in_range_num = size(index,2);

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
                    [phi,dphidn] = MLS_ShapeFunctionND(uniform_grid(i,:), index , nodal_points,di,form);
                else
                    [phi,dphidn] = MLS_ShapeFunctionND(nodal_points(i,:), index , nodal_points,di,form);
                end
                
                
                %Displacement generated at each point
            
                for j = 1 : size(index,2)

                        if ND == false
                            displacement(1,2*i-1) = displacement(1,2*i-1) + phi(j)*displacement_reshape(index(j),1)'; % x nodal displacement
                            displacement(1,2*i)   = displacement(1,2*i) + phi(j)*displacement_reshape(index(j),2)'; % y nodal displacement
                        else
                            for k = 1 : ImageDimensionality
                                displacement(1,ImageDimensionality*(i-1)+k) = displacement(1,ImageDimensionality*(i-1)+k) + phi(j)*displacement_reshape(index(j),k)';
                            end
                        end
                   

                end

                %Stress generated at each point
            
                for j = 1 : size(index,2)


                        if ND == false
                            strain(1,2*i-1) = strain(1,2*i-1) + dphidx(j)*displacement_reshape(index(j),1)'; % x nodal displacement
                            strain(1,2*i)   = strain(1,2*i) + dphidy(j)*displacement_reshape(index(j),2)'; % y nodal displacement
                        else

                            for k = 1 : ImageDimensionality
                                strain(1,ImageDimensionality*(i-1)+k) = strain(1,ImageDimensionality*(i-1)+k) + dphidn(j,k)*displacement_reshape(index(j),k)';
                            end
                        end


                    
                end
            end
            
            
        
         else

                if ND == false
                    %Displacement generated at each point

                    strain(1,2*i-1) = NaN; % x nodal displacement
                    strain(1,2*i)   = NaN; % y nodal displacement
                else
                    for j = 1 : ImageDimensionality
                        strain(1,ImageDimensionality*(i-1)+j) = NaN;
                    end
                end

        end
    end
    
    %Reshaping the resulting vectors from MLS for easier handilng
    displacement_reshape = reshape(displacement, ImageDimensionality, [])';
    strain_reshape = reshape(strain, ImageDimensionality, [])';
end
                




% %Identify neighbouring points with defined support at each of the grid
% %points
% 
% clear u; clear d;
% % +++++++++++++++++++++++++++++++++++++
% %   COMPUTE STRESSES AT GAUSS POINTS
% % +++++++++++++++++++++++++++++++++++++
% disp([num2str(toc),'   COMPUTE STRESS AT GAUSS POINTS'])
% ind = 0 ;
% for igp = 1 : size(W,1)
%     pt = Q(igp,:);                             % quadrature point
%     wt = W(igp);                               % quadrature weight
%     [index] = define_support(node,pt,di);
%     B = zeros(3,2*size(index,2)) ;
%     en = zeros(1,2*size(index,2));  
%     [phi,dphidx,dphidy] = MLS_ShapeFunction(pt,index,node,di,form);
%     for m = 1 : size(index,2)       
%         B(1:3,2*m-1:2*m) = [dphidx(m) 0 ; 0 dphidy(m); dphidy(m) dphidx(m)];
%         en(2*m-1) = 2*index(m)-1;
%         en(2*m  ) = 2*index(m)  ;
%     end
%     ind = ind + 1 ;
%     stress_gp(1:3,ind) = C*B*u2(en);  % sigma = C*epsilon = C*(B*u)
% end

    %x_stressex(1,ind) = (P/Imo)*(Lb-gg(1,1))*gg(2,1);
    %x_stressex(2,ind) = 0;
    %x_stressex(3,ind) = -P/(2*Imo)*(D^2/4 - gg(2,1)^2);
%end

% +++++++++++++++++++++++++++++++++++++
%            VISUALIATION
% +++++++++++++++++++++++++++++++++++++

% Deformed configuration
% ----------------------

%figure
%plot_mesh(node,element,'Q4','-');
% fac = 1 ; % visualization factor
% 
% cntr = plot([Origin(1),FarCorner(1),FarCorner(1),Origin(1),Origin(1)],[Origin(2),Origin(2),FarCorner(2),FarCorner(2),Origin(2)]); %defining the boundaries
% set(cntr,'LineWidth',3)
% h = plot(nodal_points(:,1),nodal_points(:,2),'bo');
% set(h,'MarkerSize',10.5);
% axis([Origin(1) FarCorner(1) Origin(2) FarCorner(2)])

if ImageDimensionality == 2

%     figure
%     hold on
% 
%     if calculate_on_nodal_points == false
%         h = quiver(uniform_grid(:,1),uniform_grid(:,2),displacement(1,1:2:2*num_node-1)', displacement(1,2:2:2*num_node)',0,'b-');
%     else
%         h = quiver(nodal_points(:,1),nodal_points(:,2),displacement(1,1:2:2*num_node-1)', displacement(1,2:2:2*num_node)',0,'b-');
%     end
%     
%     for i = 1:num_node
%         if isnan(displacement(1,2*i))
%             h = plot(uniform_grid(i,1),uniform_grid(i,2),'rx');
%         end
%     end
%     
%     set(h,'MarkerSize',10.5);
%     %axis([Origin(1) FarCorner(1) Origin(2) FarCorner(2)])
%     axis image;
%     %axis off
    
%     title('Displacement Vectors (Calculated)');
% 
%     if exist('uniform_displacement_field_ideal','var')
%         figure
%         hold on
%         h = quiver(uniform_grid(:,1),uniform_grid(:,2),uniform_displacement_field_ideal(:,1), uniform_displacement_field_ideal(:,2),0,'b-.');
%         set(h,'MarkerSize',10.5);
%         %axis([Origin(1) FarCorner(1) Origin(2) FarCorner(2)])
%         axis image;
%         %axis off
%         title('Displacement Vectors (Ideal)');
%     end
%     
    
%     figure
%     hold on
% 
%     if calculate_on_nodal_points == false
%         h = quiver(uniform_grid(:,1),uniform_grid(:,2),strain(1,1:2:2*num_node-1)', strain(1,2:2:2*num_node)',0,'r-');
%     else
%     	h = quiver(nodal_points(:,1),nodal_points(:,2),strain(1,1:2:2*num_node-1)', strain(1,2:2:2*num_node)',0,'r-');
%     end
%     axis image;
%     for i = 1:num_node
%         if isnan(strain(1,2*i))
%             h = plot(uniform_grid(i,1),uniform_grid(i,2),'rx');
%         end
%     end
%     set(h,'MarkerSize',10.5);
%     %axis([Origin(1) FarCorner(1) Origin(2) FarCorner(2)])
%     axis image;
%     title('Strain Vectors(Calculated)');
    
    
    
    
%     if exist('uniform_strain_field_ideal','var')
%         figure
%         hold on
%         h = quiver(uniform_grid(:,1),uniform_grid(:,2),uniform_strain_field_ideal(:,1), uniform_strain_field_ideal(:,2),0,'r-.');
%         set(h,'MarkerSize',10.5);
%         %axis([Origin(1) FarCorner(1) Origin(2) FarCorner(2)])
%         axis image;
%         %axis off
%         title('Strain Vectors(Ideal)');
%     end
%     
    
    
    
    x_axis = uniform_grid(1:floor(DimensionSize(1)/upsample_scaling_uniform_grid),1);
    y_axis = uniform_grid(1:floor(DimensionSize(1)/upsample_scaling_uniform_grid):floor(DimensionSize(1)/upsample_scaling_uniform_grid)*floor(DimensionSize(2)/upsample_scaling_uniform_grid),2);

    if calculate_on_nodal_points == false
        
        displacement_field = displacement(1,2:2:2*num_node)/units_of_measurement_adjust;
        displacement_field = vec2mat(displacement_field, floor(DimensionSize(1)/upsample_scaling_uniform_grid));
        
        strain_field = strain(1,2:2:2*num_node);
        strain_field = vec2mat(strain_field, floor(DimensionSize(1)/upsample_scaling_uniform_grid));
        
        strain_matrix = strain(1,2:2:2*num_node);
        strain_matrix = vec2mat(strain_matrix, floor(DimensionSize(1)/upsample_scaling_uniform_grid));
        
        x_array = zeros(2,ImageDimensionality);
        x_array(:,ImageDimensionality) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),2)';
        y_array = strain_eq(x_array);

        ymin_max = [(-0.5*max(y_array(:,ImageDimensionality)) + 1.5*min(y_array(:,ImageDimensionality))) (1.5*max(y_array(:,ImageDimensionality)) - 0.5*min(y_array(:,ImageDimensionality)))];
        if ymin_max(1) == ymin_max(2)
                ymin_max(1) = ymin_max(1) - 0.1;
                ymin_max(2) = ymin_max(2) + 0.1;
        end


        figure
        hold on
        imagesc(x_axis,y_axis, strain_matrix, ymin_max);
        h = plot(nodal_points(:,1),nodal_points(:,2),'w.');
        set(h,'MarkerSize',10.5);
    %     xlim([min(x_axis) max(x_axis)]);
    %     ylim([min(y_axis) max(y_axis)]);
        axis image;
        z = colorbar;
        ylabel(z, 'Strain Percentage field')
        xlabel('test x')
        ylabel('test y')
        title('Strain Percentage Field (Calculated)');
        
        
        if exist('uniform_strain_field_ideal','var')
            
            strain_matrix = uniform_strain_field_ideal(:,2);
            strain_matrix = vec2mat(strain_matrix, floor(DimensionSize(1)/upsample_scaling_uniform_grid));

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
            imagesc(x_axis,y_axis, strain_matrix, ymin_max);
            h = plot(nodal_points(:,1),nodal_points(:,2),'w.');
            set(h,'MarkerSize',10.5);
        %     xlim([min(x_axis) max(x_axis)]);
        %     ylim([min(y_axis) max(y_axis)]);
            axis image;
            z = colorbar;
            ylabel(z, 'Strain Percentage Field Ideal')
            xlabel('test x')
            ylabel('test y')
            title('Strain Percentage Field (Ideal)');
        end
        
        
        
    end
    
%     figure
%     hold on
%     imagesc(x_axis, y_axis, fixed_image_bin);
%     colormap('gray');
%     h = plot(nodal_points(:,1),nodal_points(:,2),'r.');
%     set(h,'MarkerSize',10.5);
%     axis image;
    
end

%displacement_difference = [displacement(1,1:2:2*num_node-1)' displacement(1,2:2:2*num_node)'] - displacement_vectors;
% 
% figure
% hold on
% 
% h = quiver(nodal_points(:,1),nodal_points(:,2),displacement_difference(:,1), displacement_difference(:,2),0);
% axis([Origin(1) FarCorner(1) Origin(2) FarCorner(2)])


% hold on
% h = plot(uniform_grid(:,1)+fac*disp(1,1:2:2*num_node-1)',uniform_grid(:,2)+fac*disp(1,2:2:2*num_node)','b*');
% set(h,'MarkerSize',7);
% axis off

% % Stress visualization
% % ----------------------
% % Stresses are computed at Gauss points
% % Gauss points used to build a Delaunay triangulation, then plot 
% figure
% hold on
% tri = delaunay(Q(:,1),Q(:,2));
% coord = [Q(:,1) Q(:,2)];
% plot_field(coord,tri,'T3',stress_gp(1,:));
% axis('equal');
% xlabel('X');
% ylabel('Y');
% title('Sigma XX');
% set(gcf,'color','white');
% colorbar('vert');
% opts = struct('Color','rgb','Bounds','tight');
% %exportfig(gcf,'beam_stress_x.eps',opts)
% 
% % Remove used memory
% clear coord;

% -------------------------------------------------------------------------
%                           END OF THE PROGRAM
% -------------------------------------------------------------------------




% Measurements and calculations to determine the quality of the result
    
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

ymin_max = [(-0.5*max(y_array(:,ImageDimensionality)) + 1.5*min(y_array(:,ImageDimensionality))) (1.5*max(y_array(:,ImageDimensionality)) - 0.5*min(y_array(:,ImageDimensionality)))];
if ymin_max(1) == ymin_max(2)
        ymin_max(1) = ymin_max(1) - 0.1;
        ymin_max(2) = ymin_max(2) + 0.1;
end

xlim([Origin(ImageDimensionality) FarCorner(ImageDimensionality)]);
ylim(ymin_max);
%ylim([min(y_array(:,ImageDimensionality)) max(y_array(:,ImageDimensionality))]);
title('Displacement Values (Ideal) vs. Y-Position');
xlabel('Y-Position');
ylabel('Displacement Values (Ideal)');


figure
hold on

plot(nodal_points(:,ImageDimensionality),displacement_vectors_actual(:,ImageDimensionality),'b.');


x_array = zeros(100,ImageDimensionality);
x_array(:,ImageDimensionality) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
y_array = displacement_eq(x_array);

plot(x_array(:,ImageDimensionality),y_array(:,ImageDimensionality),'r-');

xlim([Origin(ImageDimensionality) FarCorner(ImageDimensionality)]);
ylim([(-0.5*max(y_array(:,ImageDimensionality)) + 1.5*min(y_array(:,ImageDimensionality)))
      (1.5*max(y_array(:,ImageDimensionality)) - 0.5*min(y_array(:,ImageDimensionality)))]);x_array = zeros(100,ImageDimensionality);
x_array(:,ImageDimensionality) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
y_array = displacement_eq(x_array);

plot(x_array(:,ImageDimensionality),y_array(:,ImageDimensionality),'r-');

ymin_max = [(-0.5*max(y_array(:,ImageDimensionality)) + 1.5*min(y_array(:,ImageDimensionality))) (1.5*max(y_array(:,ImageDimensionality)) - 0.5*min(y_array(:,ImageDimensionality)))];
if ymin_max(1) == ymin_max(2)
        ymin_max(1) = ymin_max(1) - 0.1;
        ymin_max(2) = ymin_max(2) + 0.1;
end

xlim([Origin(ImageDimensionality) FarCorner(ImageDimensionality)]);
ylim(ymin_max);
title('Displacement Values (Actual) vs. Y-Position');
xlabel('Y-Position');
ylabel('Displacement Values (Actual)');





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

ymin_max = [(-0.5*max(y_array(:,ImageDimensionality)) + 1.5*min(y_array(:,ImageDimensionality))) (1.5*max(y_array(:,ImageDimensionality)) - 0.5*min(y_array(:,ImageDimensionality)))];
if ymin_max(1) == ymin_max(2)
        ymin_max(1) = ymin_max(1) - 0.1;
        ymin_max(2) = ymin_max(2) + 0.1;
end

xlim([Origin(ImageDimensionality) FarCorner(ImageDimensionality)]);
ylim(ymin_max);
title('Displacement Values (Calculated) vs. Y-Position');
xlabel('Y-Position');
ylabel('Displacement Values (Calculated)');










%Plot Strain Values vs Position
figure
hold on
if calculate_on_nodal_points == false
    plot(uniform_grid(:,ImageDimensionality),uniform_strain_field_ideal(:,ImageDimensionality),'b.');
else
    plot(nodal_points(:,ImageDimensionality),strain_vectors(:,ImageDimensionality),'b.');
end
%plot([Origin(ImageDimensionality) FarCorner(ImageDimensionality)], [0 linearly_increasing_strain], 'r-');

x_array = zeros(100,ImageDimensionality);
x_array(:,ImageDimensionality) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
y_array = strain_eq(x_array);
ymin_max = [(-0.5*max(y_array(:,ImageDimensionality)) + 1.5*min(y_array(:,ImageDimensionality))) (1.5*max(y_array(:,ImageDimensionality)) - 0.5*min(y_array(:,ImageDimensionality)))];

if ymin_max(1) == ymin_max(2)
        ymin_max(1) = ymin_max(1) - 0.1;
        ymin_max(2) = ymin_max(2) + 0.1;
end

plot(x_array(:,ImageDimensionality),y_array(:,ImageDimensionality),'r-');

xlim([Origin(ImageDimensionality) FarCorner(ImageDimensionality)]);
ylim(ymin_max);
title('Strain Percentage Values (Ideal) vs. Y-Position');
xlabel('Y-Position');
ylabel('Strain Percentage Values (Ideal)');




figure
hold on
if calculate_on_nodal_points == false
    plot(uniform_grid(:,ImageDimensionality),strain_reshape(:,ImageDimensionality),'b.');
else
    plot(nodal_points(:,ImageDimensionality),strain_reshape(:,ImageDimensionality),'b.');
end
%plot([Origin(ImageDimensionality) FarCorner(ImageDimensionality)], [0 linearly_increasing_strain], 'r-');

x_array = zeros(100,ImageDimensionality);
x_array(:,ImageDimensionality) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
y_array = strain_eq(x_array);
ymin_max = [(-0.5*max(y_array(:,ImageDimensionality)) + 1.5*min(y_array(:,ImageDimensionality))) (1.5*max(y_array(:,ImageDimensionality)) - 0.5*min(y_array(:,ImageDimensionality)))];

if ymin_max(1) == ymin_max(2)
        ymin_max(1) = ymin_max(1) - 0.1;
        ymin_max(2) = ymin_max(2) + 0.1;
end

plot(x_array(:,ImageDimensionality),y_array(:,ImageDimensionality),'r-');

xlim([Origin(ImageDimensionality) FarCorner(ImageDimensionality)]);
ylim(ymin_max);
title('Strain Percentage Values (Calculated) vs. Y-Position');
xlabel('Y-Position');
ylabel('Strain Percentage Values (Calculated)');




%Plot Displacement Calculated and Displacement Actual vs Displacement Ideal



if calculate_on_nodal_points == false
    figure;
    plot(uniform_displacement_field_ideal(:,ImageDimensionality), displacement_reshape(:,ImageDimensionality),'b.');
    hold on

    x_array = zeros(100,ImageDimensionality);
    x_array(:,ImageDimensionality) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
    y_array = displacement_eq(x_array);

    plot(y_array(:,ImageDimensionality),y_array(:,ImageDimensionality),'r-');

    xmin_max = [min(y_array(:,ImageDimensionality)) max(y_array(:,ImageDimensionality))];
    ymin_max = [(-0.5*max(y_array(:,ImageDimensionality)) + 1.5*min(y_array(:,ImageDimensionality))) (1.5*max(y_array(:,ImageDimensionality)) - 0.5*min(y_array(:,ImageDimensionality)))];
    if xmin_max(1) == xmin_max(2)
        xmin_max(1) = xmin_max(1) - 0.1;
        xmin_max(2) = xmin_max(2) + 0.1;
    end
    
    if ymin_max(1) == ymin_max(2)
        ymin_max(1) = ymin_max(1) - 0.1;
        ymin_max(2) = ymin_max(2) + 0.1;
    end

    
    
    title('Displacement Values (Calculated) vs. Displacement Values (Ideal)');
    xlabel('Displacement Values (Ideal)');
    ylabel('Displacement Values (Calculated)');
    xlim(xmin_max);
    ylim(ymin_max);
    %ylim([min(uniform_displacement_field_ideal(:,ImageDimensionality)) max(uniform_displacement_field_ideal(:,ImageDimensionality))]);
else
    figure;
    plot(displacement_vectors(:,ImageDimensionality), displacement_reshape(:,ImageDimensionality),'b.');
    hold on

    x_array = zeros(100,ImageDimensionality);
    x_array(:,ImageDimensionality) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
    y_array = displacement_eq(x_array);

    plot(y_array(:,ImageDimensionality),y_array(:,ImageDimensionality),'r-');

    xmin_max = [min(y_array(:,ImageDimensionality)) max(y_array(:,ImageDimensionality))];
    ymin_max = [(-0.5*max(y_array(:,ImageDimensionality)) + 1.5*min(y_array(:,ImageDimensionality))) (1.5*max(y_array(:,ImageDimensionality)) - 0.5*min(y_array(:,ImageDimensionality)))];
    if xmin_max(1) == xmin_max(2)
        xmin_max(1) = xmin_max(1) - 0.1;
        xmin_max(2) = xmin_max(2) + 0.1;
    end
    
    if ymin_max(1) == ymin_max(2)
        ymin_max(1) = ymin_max(1) - 0.1;
        ymin_max(2) = ymin_max(2) + 0.1;
    end
    
    title('Displacement Values (Calculated) vs. Displacement Values (Ideal)');
    xlabel('Displacement Values (Ideal)');
    ylabel('Displacement Values (Calculated)');
    
    xlim(xmin_max);
    ylim(ymin_max);
    %ylim([min(displacement_vectors(:,ImageDimensionality)) max(displacement_vectors(:,ImageDimensionality))]);
    
    
    
    
    figure;
    plot(displacement_vectors(:,ImageDimensionality), displacement_vectors_actual(:,ImageDimensionality),'b.');
    hold on
    
    x_array = zeros(100,ImageDimensionality);
    x_array(:,ImageDimensionality) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
    y_array = displacement_eq(x_array);

    plot(y_array(:,ImageDimensionality),y_array(:,ImageDimensionality),'r-');

    xmin_max = [min(y_array(:,ImageDimensionality)) max(y_array(:,ImageDimensionality))];
    ymin_max = [(-0.5*max(y_array(:,ImageDimensionality)) + 1.5*min(y_array(:,ImageDimensionality))) (1.5*max(y_array(:,ImageDimensionality)) - 0.5*min(y_array(:,ImageDimensionality)))];
    if xmin_max(1) == xmin_max(2)
        xmin_max(1) = xmin_max(1) - 0.1;
        xmin_max(2) = xmin_max(2) + 0.1;
    end
    
    if ymin_max(1) == ymin_max(2)
        ymin_max(1) = ymin_max(1) - 0.1;
        ymin_max(2) = ymin_max(2) + 0.1;
    end
    
    title('Displacement Values (Actual) vs. Displacement Values (Ideal)');
    xlabel('Displacement Values (Ideal)');
    ylabel('Displacement Values (Actual)');
    xlim(xmin_max);
    ylim(ymin_max);
end




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





%     if exist('linearly_increasing_strain','var') ==false
%         xlim(xmin_max)
%         ylim([min(displacement_reshape(:,ImageDimensionality)) max(displacement_reshape(:,ImageDimensionality))]);
%     else
%         xlim(xmin_max)
%         ylim([0.5*(max([0 linearly_increasing_strain]) - min([0 linearly_increasing_strain])) 1.5*(max([0 linearly_increasing_strain]) - min([0 linearly_increasing_strain]))]);
%     end



%Plot Strain Calculated vs Strain Ideal
figure;
if calculate_on_nodal_points == false
    plot(uniform_strain_field_ideal(:,ImageDimensionality), strain_reshape(:,ImageDimensionality),'b.');
    hold on

    x_array = zeros(100,ImageDimensionality);
    x_array(:,ImageDimensionality) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
    y_array = strain_eq(x_array);

    plot(y_array(:,ImageDimensionality),y_array(:,ImageDimensionality),'r-');

    xmin_max = [min(y_array(:,ImageDimensionality)) max(y_array(:,ImageDimensionality))];
    ymin_max = [(-0.5*max(y_array(:,ImageDimensionality)) + 1.5*min(y_array(:,ImageDimensionality))) (1.5*max(y_array(:,ImageDimensionality)) - 0.5*min(y_array(:,ImageDimensionality)))];
    if xmin_max(1) == xmin_max(2)
        xmin_max(1) = xmin_max(1) - 0.1;
        xmin_max(2) = xmin_max(2) + 0.1;
    end
    
    if ymin_max(1) == ymin_max(2)
        ymin_max(1) = ymin_max(1) - 0.1;
        ymin_max(2) = ymin_max(2) + 0.1;
    end
    
%     if exist('linearly_increasing_strain','var') ==false
%         xlim([min(uniform_strain_field_ideal(:,ImageDimensionality)) max(uniform_strain_field_ideal(:,ImageDimensionality))])
%         ylim([min(strain_reshape(:,ImageDimensionality)) max(strain_reshape(:,ImageDimensionality))]);
%     else
        xlim(xmin_max)
        ylim(ymin_max);
                
%     end
else
    plot(strain_vectors(:,ImageDimensionality), strain_reshape(:,ImageDimensionality),'b.');
    hold on

    x_array = zeros(100,ImageDimensionality);
    x_array(:,ImageDimensionality) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
    y_array = strain_eq(x_array);

    plot(y_array(:,ImageDimensionality),y_array(:,ImageDimensionality),'r-');

    xmin_max = [min(y_array(:,ImageDimensionality)) max(y_array(:,ImageDimensionality))];
    ymin_max = [(-0.5*max(y_array(:,ImageDimensionality)) + 1.5*min(y_array(:,ImageDimensionality))) (1.5*max(y_array(:,ImageDimensionality)) - 0.5*min(y_array(:,ImageDimensionality)))];
    if xmin_max(1) == xmin_max(2)
        xmin_max(1) = xmin_max(1) - 0.1;
        xmin_max(2) = xmin_max(2) + 0.1;
    end
    
    if ymin_max(1) == ymin_max(2)
        ymin_max(1) = ymin_max(1) - 0.1;
        ymin_max(2) = ymin_max(2) + 0.1;
    end
    
%     if exist('linearly_increasing_strain','var') ==false
%         xlim(xmin_max)
%         ylim([min(strain_reshape(:,ImageDimensionality)) max(strain_reshape(:,ImageDimensionality))]);
%     else
        xlim(xmin_max)
        ylim(ymin_max);
     %end
end

title('Strain Percentage Values (Calculated) vs. Strain Percentage Values (Ideal)');
xlabel('Strain Percentage Values (Ideal)');
ylabel('Strain Percentage Values (Calculated)');



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

disp('Strain Percentage Calculated vs. Strain Percentage Ideal');

string = sprintf('R^2: %f',r2);
disp(string);
string = sprintf('Offset: %f',c(1));
disp(string);
string = sprintf('Slope: %f',c(2));
disp(string);









% Print out difference measures for displacement and strain results  

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
        
        disp('Displacement Field Error (Calculated)');
        string = sprintf('mean: %f',nanmean(displacement_reshape(:,ImageDimensionality) - displacement_vectors(:,ImageDimensionality)));
        disp(string);
        string = sprintf('standard deviation: %f',nanstd(displacement_reshape(:,ImageDimensionality)- displacement_vectors(:,ImageDimensionality)));
        disp(string);
        string = sprintf('10 percentile: %f',prctile(displacement_reshape(:,ImageDimensionality)- displacement_vectors(:,ImageDimensionality),10));
        disp(string);
        string = sprintf('90 percentile: %f',prctile(displacement_reshape(:,ImageDimensionality)- displacement_vectors(:,ImageDimensionality),90));
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
        
        disp('Displacement Field Error (Calculated)');
        string = sprintf('mean: %f',nanmean(displacement_reshape(:,ImageDimensionality) - uniform_displacement_field_ideal(:,ImageDimensionality)));
        disp(string);
        string = sprintf('standard deviation: %f',nanstd(displacement_reshape(:,ImageDimensionality)- uniform_displacement_field_ideal(:,ImageDimensionality)));
        disp(string);
        string = sprintf('10 percentile: %f',prctile(displacement_reshape(:,ImageDimensionality)- uniform_displacement_field_ideal(:,ImageDimensionality),10));
        disp(string);
        string = sprintf('90 percentile: %f',prctile(displacement_reshape(:,ImageDimensionality)- uniform_displacement_field_ideal(:,ImageDimensionality),90));
        disp(string);
        
    end
end


disp('Strain Percentage Field Results (Calculated)');
string = sprintf('mean: %f',nanmean(strain_reshape(:,ImageDimensionality)));
disp(string);
string = sprintf('standard deviation: %f',nanstd(strain_reshape(:,ImageDimensionality)));
disp(string);

if calculate_on_nodal_points == true
    if exist('strain_vectors','var')
        disp('Strain Percentage Field Difference (Calculated)');
        directional_similarity = strain_reshape(:,ImageDimensionality).*strain_vectors(:,ImageDimensionality)./abs(strain_reshape(:,ImageDimensionality).*strain_vectors(:,ImageDimensionality));
        difference_of_magnitude = abs(strain_reshape(:,ImageDimensionality)) - abs(strain_vectors(:,ImageDimensionality));
        magnitude_of_difference = abs(strain_reshape(:,ImageDimensionality) - strain_vectors(:,ImageDimensionality));


        string = sprintf('directional similarity: %f +/- %f',nanmean(directional_similarity), nanstd(directional_similarity));
        disp(string);
        string = sprintf('difference of magnitude: %f +/- %f',nanmean(difference_of_magnitude), nanstd(difference_of_magnitude));
        disp(string);
        string = sprintf('magnitude of difference: %f +/- %f',nanmean(magnitude_of_difference), nanstd(magnitude_of_difference));
        disp(string);
        
        disp('Strain Percentage Field Error (Calculated)');
        string = sprintf('mean: %f',nanmean(strain_reshape(:,ImageDimensionality) - strain_vectors(:,ImageDimensionality)));
        disp(string);
        string = sprintf('standard deviation: %f',nanstd(strain_reshape(:,ImageDimensionality)- strain_vectors(:,ImageDimensionality)));
        disp(string);
        string = sprintf('10 percentile: %f',prctile(strain_reshape(:,ImageDimensionality)- strain_vectors(:,ImageDimensionality),10));
        disp(string);
        string = sprintf('90 percentile: %f',prctile(strain_reshape(:,ImageDimensionality)- strain_vectors(:,ImageDimensionality),90));
        disp(string)
    end
    
else
    
    if exist('uniform_strain_field_ideal','var')
    
        disp('Strain Percentage Field Difference (Calculated)');
        directional_similarity = strain_reshape(:,ImageDimensionality).*uniform_strain_field_ideal(:,ImageDimensionality)./abs(strain_reshape(:,ImageDimensionality).*uniform_strain_field_ideal(:,ImageDimensionality));
        difference_of_magnitude = abs(strain_reshape(:,ImageDimensionality)) - abs(uniform_strain_field_ideal(:,ImageDimensionality));
        magnitude_of_difference = abs(strain_reshape(:,ImageDimensionality) - uniform_strain_field_ideal(:,ImageDimensionality));


        string = sprintf('directional similarity: %f +/- %f',nanmean(directional_similarity), nanstd(directional_similarity));
        disp(string);
        string = sprintf('difference of magnitude: %f +/- %f',nanmean(difference_of_magnitude), nanstd(difference_of_magnitude));
        disp(string);
        string = sprintf('magnitude of difference: %f +/- %f',nanmean(magnitude_of_difference), nanstd(magnitude_of_difference));
        disp(string);
        
        disp('Strain Percentage Field Error (Calculated)');
        string = sprintf('mean: %f',nanmean(strain_reshape(:,ImageDimensionality) - uniform_strain_field_ideal(:,ImageDimensionality)));
        disp(string);
        string = sprintf('standard deviation: %f',nanstd(strain_reshape(:,ImageDimensionality)- uniform_strain_field_ideal(:,ImageDimensionality)));
        disp(string);
        string = sprintf('10 percentile: %f',prctile(strain_reshape(:,ImageDimensionality)- uniform_strain_field_ideal(:,ImageDimensionality),10));
        disp(string);
        string = sprintf('90 percentile: %f',prctile(strain_reshape(:,ImageDimensionality)- uniform_strain_field_ideal(:,ImageDimensionality),90));
        disp(string)
        
    end
end




