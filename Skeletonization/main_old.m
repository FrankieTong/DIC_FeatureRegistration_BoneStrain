
clear all
clc
state = 0;
tic;           % help us to see the time required for each step

% Inputs special to meshless methods, domain of influence

shape = 'circle' ;         % shape of domain of influence
form  = 'cubic_spline' ;   % using cubic spline weight function
downsample_scaling = 2;
PixelWidthMin = 5;
PixelWidthMax = 10000;

neighbouring_points_min = 5;
domain_influence_variable = true;

calculate_on_nodal_points = false;

ideal_case = true;


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
linearly20_diffoctave



%More reorganization of information

if ideal_case == false
    displacement_vectors = moving_points(:,1:ImageDimensionality) - fixed_points(:,1:ImageDimensionality);
else
    if exist('displacement_vectors_ideal','var')
        displacement_vectors = displacement_vectors_ideal; 
    elseif exist('displacement_eq','var') 
        displacement_vectors = displacement_eq(fixed_points(:,1:ImageDimensionality));
    else
        disp('Can not compute ideal case. Lacking information from setup files for ideal displacement field.');
        return
    end
end

if exist('strain_vectors_ideal','var')
    strain_vectors = strain_vectors_ideal;
elseif exist('strain_eq', 'var')
    strain_vectors = strain_eq(fixed_points(:,1:ImageDimensionality));
else
    disp('Can not compute ideal case. Lacking information from setup files for ideal strain field.');
    return
end

u = displacement_vectors;

%displacement_vectors(60,2) = displacement_vectors(60,2)*100;




nodal_points = fixed_points(:,1:ImageDimensionality);
FarCorner = Origin + SpacingSize.*DimensionSize;

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
    h = plot(nodal_points(:,1),nodal_points(:,2),'b.');
    set(h,'MarkerSize',10.5);
    axis image;
    title('Fixed Image');
    
    
    
    figure
    hold on
    imagesc(image_x_axis, image_y_axis, moving_image)
    colormap('gray')
    h = plot(moving_points(:,1),moving_points(:,2),'b.');
    set(h,'MarkerSize',10.5);
    axis image;
    title('Moving Image');

    figure
    hold on
    h = quiver(nodal_points(:,1),nodal_points(:,2),displacement_vectors(:,1), displacement_vectors(:,2),0,'b');
    set(h,'MarkerSize',10.5);
    axis image;
    %axis off
    title('SIFT Displacement Vectors');
    
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
end





% +++++++++++++++++++++++++++++++++++++
%          DOMAIN ASSEMBLY
% +++++++++++++++++++++++++++++++++++++
disp([num2str(toc),'   DOMAIN ASSEMBLY'])
% Initialisation
%di = ones(1,numnode)* dmax * (L/(nnx-1));

%Generate grid points
%uniform_grid = square_node_array([Origin(1) Origin(1)],[FarCorner(1) Origin(2)],[FarCorner(1) FarCorner(2)],[Origin(1) FarCorner(2)],floor(DimensionSize(1)/downsample_scaling),floor(DimensionSize(2)/downsample_scaling));


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
   
        %uniform_grid(index,i) = matrix_index(i);
        uniform_grid(index,i) = (matrix_index(i)-1)*uniform_grid_spacing(i) + Origin(i);
        
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
        di = define_minimum_support2(uniform_grid, nodal_points, SpacingSize(1) * PixelWidthMin, neighbouring_points_min);
    else
    	di = define_minimum_support2(nodal_points, nodal_points, SpacingSize(1) * PixelWidthMin, neighbouring_points_min);
    end
else
    di = ones(1,size(nodal_points,1)) *  SpacingSize(1) * PixelWidthMin;
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

ND = true;

%for i = 1 : num_node
for i = 1 : num_node
    
    if calculate_on_nodal_points == false
        [index] = define_support(nodal_points, uniform_grid(i,:),di);
        [index_defined] = define_support(nodal_points, uniform_grid(i,:),di_max);
    else
        [index] = define_support(nodal_points, nodal_points(i,:),di);
        [index_defined] = define_support(nodal_points, nodal_points(i,:),di_max);
    end
    
    nodal_points_in_range_num = size(index,2);
    
    if di_max > 0
        nodal_points_in_range_num = size(index_defined,2);
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
                    if (phi(j)*u(index(j),1)' ~= 0 ||  phi(j)*u(index(j),2)' ~= 0)
                        displacement_effected_by(1,2*i-1) = displacement_effected_by(1,2*i-1) + 1;
                        displacement_effected_by(1,2*i) = displacement_effected_by(1,2*i) + 1;
                    end
                    
                    displacement(1,2*i-1) = displacement(1,2*i-1) + phi(j)*u(index(j),1)'; % x nodal displacement
                    displacement(1,2*i)   = displacement(1,2*i) + phi(j)*u(index(j),2)'; % y nodal displacement
                else
                    for k = 1 : ImageDimensionality
                        if (phi(j)*u(index(j),k)' ~= 0)
                            displacement_effected_by(1,ImageDimensionality*(i-1)+k) = displacement_effected_by(1,ImageDimensionality*(i-1)+k) + 1;
                        end
                        displacement(1,ImageDimensionality*(i-1)+k) = displacement(1,ImageDimensionality*(i-1)+k) + phi(j)*u(index(j),k)';
                    end
                end
                
            end
            
            %Stress generated at each point
            
            for j = 1 : size(index,2)
                
                if ND == false
                    strain(1,2*i-1) = strain(1,2*i-1) + dphidx(j)*u(index(j),1)'; % x nodal displacement
                    strain(1,2*i)   = strain(1,2*i) + dphidy(j)*u(index(j),2)'; % y nodal displacement
                else
                    
                    for k = 1 : ImageDimensionality
                        strain(1,ImageDimensionality*(i-1)+k) = strain(1,ImageDimensionality*(i-1)+k) + dphidn(j,k)*u(index(j),k)';
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
        title('Strain Vectors(Ideal)');
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
        imagesc(x_axis,y_axis, strain_matrix, [-0.5,0.5]);
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
            imagesc(x_axis,y_axis, strain_matrix, [-0.5,0.5]);
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
    
%     figure
%     hold on
%     imagesc(x_axis, y_axis, fixed_image_bin);
%     colormap('gray');
%     h = plot(nodal_points(:,1),nodal_points(:,2),'b.');
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

disp('Displacement Field Results');
string = sprintf('mean: %f',nanmean(displacement(1,2:2:2*num_node)'));
disp(string);
string = sprintf('standard deviation: %f',nanstd(displacement(1,2:2:2*num_node)'));
disp(string);

if calculate_on_nodal_points == true
    if exist('displacement_vectors','var')
        disp('Displacement Field Difference');
        directional_similarity = displacement(1,2:2:2*num_node)'.*displacement_vectors(:,2)./abs(displacement(1,2:2:2*num_node)'.*displacement_vectors(:,2));
        difference_of_magnitude = abs(displacement(1,2:2:2*num_node)') - abs(displacement_vectors(:,2));
        magnitude_of_difference = abs(displacement(1,2:2:2*num_node)' - displacement_vectors(:,2));

        string = sprintf('directional similarity: %f +/- %f',nanmean(directional_similarity), nanstd(directional_similarity));
        disp(string);
        string = sprintf('difference of magnitude: %f +/- %f',nanmean(difference_of_magnitude), nanstd(difference_of_magnitude));
        disp(string);
        string = sprintf('magnitude of difference: %f +/- %f',nanmean(magnitude_of_difference), nanstd(magnitude_of_difference));
        disp(string);
    end
    
else
    
    if exist('uniform_displacement_field_ideal','var')
    
        disp('Displacement Field Difference');
        directional_similarity = displacement(1,2:2:2*num_node)'.*uniform_displacement_field_ideal(:,2)./abs(displacement(1,2:2:2*num_node)'.*uniform_displacement_field_ideal(:,2));
        difference_of_magnitude = abs(displacement(1,2:2:2*num_node)') - abs(uniform_displacement_field_ideal(:,2));
        magnitude_of_difference = abs(displacement(1,2:2:2*num_node)' - uniform_displacement_field_ideal(:,2));


        string = sprintf('directional similarity: %f +/- %f',nanmean(directional_similarity), nanstd(directional_similarity));
        disp(string);
        string = sprintf('difference of magnitude: %f +/- %f',nanmean(difference_of_magnitude), nanstd(difference_of_magnitude));
        disp(string);
        string = sprintf('magnitude of difference: %f +/- %f',nanmean(magnitude_of_difference), nanstd(magnitude_of_difference));
        disp(string);
        
    end
end


disp('Strain Field Results');
string = sprintf('mean: %f',nanmean(strain(1,2:2:2*num_node)'));
disp(string);
string = sprintf('standard deviation: %f',nanstd(strain(1,2:2:2*num_node)'));
disp(string);

if calculate_on_nodal_points == true
    if exist('strain_vectors','var')
        disp('Strain Field Difference');
        directional_similarity = strain(1,2:2:2*num_node)'.*strain_vectors(:,2)./abs(strain(1,2:2:2*num_node)'.*strain_vectors(:,2));
        difference_of_magnitude = abs(strain(1,2:2:2*num_node)') - abs(strain_vectors(:,2));
        magnitude_of_difference = abs(strain(1,2:2:2*num_node)' - strain_vectors(:,2));


        string = sprintf('directional similarity: %f +/- %f',nanmean(directional_similarity), nanstd(directional_similarity));
        disp(string);
        string = sprintf('difference of magnitude: %f +/- %f',nanmean(difference_of_magnitude), nanstd(difference_of_magnitude));
        disp(string);
        string = sprintf('magnitude of difference: %f +/- %f',nanmean(magnitude_of_difference), nanstd(magnitude_of_difference));
        disp(string);
    end
    
else
    
    if exist('uniform_strain_field_ideal','var')
    
        disp('Strain Field Difference');
        directional_similarity = strain(1,2:2:2*num_node)'.*uniform_strain_field_ideal(:,2)./abs(strain(1,2:2:2*num_node)'.*uniform_strain_field_ideal(:,2));
        difference_of_magnitude = abs(strain(1,2:2:2*num_node)') - abs(uniform_strain_field_ideal(:,2));
        magnitude_of_difference = abs(strain(1,2:2:2*num_node)' - uniform_strain_field_ideal(:,2));


        string = sprintf('directional similarity: %f +/- %f',nanmean(directional_similarity), nanstd(directional_similarity));
        disp(string);
        string = sprintf('difference of magnitude: %f +/- %f',nanmean(difference_of_magnitude), nanstd(difference_of_magnitude));
        disp(string);
        string = sprintf('magnitude of difference: %f +/- %f',nanmean(magnitude_of_difference), nanstd(magnitude_of_difference));
        disp(string);
        
    end
end
