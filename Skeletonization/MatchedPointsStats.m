if exist('calculate_strain','var') == false || calculate_strain == false
    %clear all
    %clc
    
    %Additional Inputs for testing purposes
    %standardResampleScaleMatch_WithOriginal_5offedge_BoundaryBox %Input point information from external source
    

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
    %linearly02_zeroStrain_Deconv_Trabeculae_NoGrowthPlates
    
    standardResampleScaleMatch_1p1and2_subpixel_alligned
    
end

%%
tic;           % help us to see the time required for each step

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


displacement_vectors_actual = moving_points(:,1:ImageDimensionality) - fixed_points(:,1:ImageDimensionality);


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
    figure
    hold on
    h = quiver(nodal_points(:,1),nodal_points(:,2),strain_vectors(:,1), strain_vectors(:,2),0,'r-');
    set(h,'MarkerSize',10.5);
    axis image;
    %axis off  
    title('Strain Vectors (Ideal)');
    
end





% +++++++++++++++++++++++++++++++++++++
%          DOMAIN ASSEMBLY
% +++++++++++++++++++++++++++++++++++++




%Reshaping the resulting vectors from MLS for easier handilng
displacement_reshape = displacement_vectors_actual;
%strain_reshape = reshape(strain, ImageDimensionality, [])';


% -------------------------------------------------------------------------
%                           END OF THE PROGRAM
% -------------------------------------------------------------------------




% Measurements and calculations to determine the quality of the result
    
%Plot Displacement Values vs Position
figure
hold on

plot(nodal_points(:,ImageDimensionality),displacement_vectors(:,ImageDimensionality),'b.');

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
plot(nodal_points(:,ImageDimensionality),displacement_reshape(:,ImageDimensionality),'b.');



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


















%Plot Displacement Calculated and Displacement Actual vs Displacement Ideal



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





%Caculate line of best fit for Displacement Calculated vs Displacement Ideal and
%identify zero offset and slope

%Calculate R^2 with Displacement Calculated vs Displacement Ideal



F = [displacement_vectors(:,ImageDimensionality).^0 displacement_vectors(:,ImageDimensionality)];           % make design matrix [1,x]
displacement_no_nan = displacement_reshape;

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














% Print out difference measures for displacement and strain results  

disp('Displacement Field Results (Calculated)');
string = sprintf('mean: %f',nanmean(displacement_reshape(:,ImageDimensionality)));
disp(string);
string = sprintf('standard deviation: %f',nanstd(displacement_reshape(:,ImageDimensionality)));
disp(string);



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

