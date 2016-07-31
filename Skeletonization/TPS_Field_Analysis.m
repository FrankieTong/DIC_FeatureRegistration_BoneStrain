clear;
clc;

%load in setup file
linearly02_zeroStrain_Deconv_Trabeculae_NoGrowthPlates_Analysis

segment_refine = 1000;
FarCorner = Origin + SpacingSize.*(DimensionSize-1);

%Setup active contour such that we only get region of interest. The region
%of interest is based off of the files we used for segmentation.

mask = zeros(size(fixed_image_skeletonize));
mask( 5:end-5, 5:end-5) = 1;

%fixed_image_segment = activecontour(fixed_image_skeletonize, mask, segment_refine); %generates a binary mask
%fixed_image_segment = fixed_image_segment + 0; %convert from logical matrix to double matrix
%fixed_image_segment(fixed_image_segment==0) = NaN; %change all segmented out values to NaN


fixed_image_segment = fixed_image_skeletonize;
fixed_image_segment(fixed_image_segment ~= 0) = 1;
fixed_image_segment(fixed_image_segment==0) = NaN;


figure
hold on
imagesc(image_x_axis, image_y_axis, fixed_image_skeletonize)
colormap('gray')
if exist('fixed_points','var') == true
    h = plot(fixed_points(:,1),fixed_points(:,2),'r.');
    set(h,'MarkerSize',8);
end
axis image;
title('Fixed Image Segmented');
xlabel('Image Dimension (um)');
ylabel('Image Direction (um)');

figure
hold on
imagesc(image_x_axis, image_y_axis, fixed_image_segment)
colormap('gray')
axis image;
title('Fixed Image Segmentation');
xlabel('Image Dimension (um)');
ylabel('Image Direction (um)');

%%

%Cut off all readings outside fixed_image_segment for displacement field
%and strain field
displacement_field = displacement_field.*fixed_image_segment;
strain_field = strain_field.*fixed_image_segment;



%Generate the ideal displacement and strain vector fields

%Generate uniform grid of position values
matrix_size = DimensionSize-1;

for i = 1:ImageDimensionality
    matrix_size(i) = DimensionSize(i);
    uniform_grid_spacing(i) = (FarCorner(i) - Origin(i))./(matrix_size(i)-1);
    if matrix_size(i) < 1
        matrix_size(i) = 1;
        uniform_grid_spacing(i) = FarCorner(i) - Origin(i);
    end
    
end


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

%Throw the uniform grid of position values into the ideal displacement and
%strain equations

displacement_field_ideal = displacement_eq(uniform_grid);
strain_field_ideal = strain_eq(uniform_grid);

   


%Rearrange ideal displacement and strain field into proper image indexes
uniform_grid_vector = uniform_grid(:,ImageDimensionality);
uniform_grid_vector = vec2mat(uniform_grid_vector, DimensionSize(1));

displacement_field_ideal_vector = displacement_field_ideal(:,ImageDimensionality);
displacement_field_ideal_vector = vec2mat(displacement_field_ideal_vector, DimensionSize(1));

strain_field_ideal_vector = strain_field_ideal(:,ImageDimensionality);
strain_field_ideal_vector = vec2mat(strain_field_ideal_vector, DimensionSize(1));

displacement_field_vector = displacement_field;
strain_field_vector = strain_field;

%Segment out values that should not be evaluated
uniform_grid_vector = uniform_grid_vector.*fixed_image_segment;
displacement_field_ideal_vector = displacement_field_ideal_vector.*fixed_image_segment;
strain_field_ideal_vector = strain_field_ideal_vector.*fixed_image_segment;


%Plot the values of strain onto the image
x_axis = uniform_grid(1:DimensionSize(1),1);
y_axis = uniform_grid(1:DimensionSize(1):DimensionSize(1)*DimensionSize(2),2);

x_array = zeros(2,ImageDimensionality);
x_array(:,ImageDimensionality) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),2)';
y_array = strain_eq(x_array);

ymin_max = [(-0.5*max(y_array(:,ImageDimensionality)) + 1.5*min(y_array(:,ImageDimensionality))) (1.5*max(y_array(:,ImageDimensionality)) - 0.5*min(y_array(:,ImageDimensionality)))];
if ymin_max(1) == ymin_max(2)
        ymin_max(1) = ymin_max(1) - 0.1;
        ymin_max(2) = ymin_max(2) + 0.1;
end


strain_matrix = strain_field_ideal_vector;


figure
hold on
imagesc(x_axis,y_axis, strain_matrix, ymin_max);
axis image;
z = colorbar;
ylabel(z, 'Strain Percentage')
title('Strain Percentage Field (Ideal)');
xlabel('Image Dimension (um)');
ylabel('Image Direction (um)');



strain_matrix = strain_field;

figure
hold on
imagesc(x_axis,y_axis, strain_matrix, ymin_max);
if exist('fixed_points','var') == true
    h = plot(fixed_points(:,1),fixed_points(:,2),'r.');
    set(h,'MarkerSize',8);
end
axis image;
z = colorbar;
ylabel(z, 'Strain Percentage')
title('Strain Percentage Field (Calculated)');
xlabel('Image Dimension (um)');
ylabel('Image Direction (um)');

strain_matrix = strain_field - strain_field_ideal_vector;

figure
hold on

ymin(1) = min(strain_matrix(:));
ymin(2) = max(strain_matrix(:));
if ymin_max(1) == ymin_max(2)
        ymin_max(1) = ymin_max(1) - 0.1;
        ymin_max(2) = ymin_max(2) + 0.1;
end

imagesc(x_axis,y_axis, strain_matrix, ymin_max);
axis image;
z = colorbar;
ylabel(z, 'Strain Percentage')
title('Strain Percentage Field (Error)');
xlabel('Image Dimension (um)');
ylabel('Image Direction (um)');




%Rearrange all relevant values to be plotted back into vector format
uniform_grid_vector = reshape(uniform_grid_vector,[],1);
displacement_field_ideal_vector = reshape(displacement_field_ideal_vector,[],1);
strain_field_ideal_vector = reshape(strain_field_ideal_vector,[],1);
displacement_field_vector = reshape(displacement_field_vector,[],1);
strain_field_vector = reshape(strain_field_vector,[],1);






%Run analysis to compare resutling displacement and strain fields with the
%actual ideal values
%Plot Displacement Values vs Position

figure
hold on

plot(uniform_grid_vector,displacement_field_ideal_vector,'b.');


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
title('Displacement Values (Ideal) vs. Y-Position (um)');
xlabel('Y-Position (um)');
ylabel('Displacement Values (Ideal)');
            


figure
hold on

plot(uniform_grid_vector,displacement_field_vector,'b.');


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
title('Displacement Values (Calculated) vs. Y-Position (um)');
xlabel('Y-Position (um)');
ylabel('Displacement Values (Calculated)');


%Caculate line of best fit for Displacement Calculated vs Displacement Ideal and
%identify zero offset and slope



%Calculate R^2 with Displacement Calculated vs Displacement Ideal

%Need to recalculate uniform_displacement_field_ideal and
%displacement_vectors to remove NaNs from the list
count = 1;
for i = 1:size(displacement_field_ideal_vector,1)

    if isfinite(displacement_field_ideal_vector(i)) == true
       displacement_field_ideal_vector_no_nan(count,:) = displacement_field_ideal_vector(i,:);
       displacement_field_vector_no_nan(count,:) = displacement_field_vector(i,:);
       count = count + 1;
    end
end

F = [displacement_field_ideal_vector_no_nan.^0 displacement_field_ideal_vector_no_nan];           % make design matrix [1,x]

c = F\displacement_field_vector_no_nan;                  % get least-squares fit
res = displacement_field_vector_no_nan - F*c;           % calculate residuals
r2 = 1 - nanvar(res)/nanvar(displacement_field_vector_no_nan);  % calculate R^2

disp('Displacement Calculated vs. Displacement Ideal');

string = sprintf('R^2: %f',r2);
disp(string);
string = sprintf('Offset: %f',c(1));
disp(string);
string = sprintf('Slope: %f',c(2));
disp(string);


%Plot displacement calculated versus displacement ideal
figure
plot(displacement_field_ideal_vector, displacement_field_vector,'b.');
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

xlim(xmin_max)
ylim(ymin_max);

title('Displacement Values (Calculated) vs. Displacement Values (Ideal)');
xlabel('Displacement Values (Ideal)');
ylabel('Displacement Values (Calculated)');





%Plot Strain Values vs Position

figure
hold on

plot(uniform_grid_vector,strain_field_ideal_vector,'b.');


x_array = zeros(100,ImageDimensionality);
x_array(:,ImageDimensionality) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
y_array = strain_eq(x_array);

plot(x_array(:,ImageDimensionality),y_array(:,ImageDimensionality),'r-');

ymin_max = [(-0.5*max(y_array(:,ImageDimensionality)) + 1.5*min(y_array(:,ImageDimensionality))) (1.5*max(y_array(:,ImageDimensionality)) - 0.5*min(y_array(:,ImageDimensionality)))];
if ymin_max(1) == ymin_max(2)
        ymin_max(1) = ymin_max(1) - 0.1;
        ymin_max(2) = ymin_max(2) + 0.1;
end

xlim([Origin(ImageDimensionality) FarCorner(ImageDimensionality)]);
ylim(ymin_max);
%ylim([min(y_array(:,ImageDimensionality)) max(y_array(:,ImageDimensionality))]);
title('Strain Percentage Values (Ideal) vs. Y-Position (um)');
xlabel('Y-Position (um)');
ylabel('Strain Percentage Values (Ideal)');
            


figure
hold on

plot(uniform_grid_vector,strain_field_vector,'b.');


x_array = zeros(100,ImageDimensionality);
x_array(:,ImageDimensionality) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
y_array = strain_eq(x_array);

plot(x_array(:,ImageDimensionality),y_array(:,ImageDimensionality),'r-');

xlim([Origin(ImageDimensionality) FarCorner(ImageDimensionality)]);
ylim([(-0.5*max(y_array(:,ImageDimensionality)) + 1.5*min(y_array(:,ImageDimensionality)))
      (1.5*max(y_array(:,ImageDimensionality)) - 0.5*min(y_array(:,ImageDimensionality)))]);x_array = zeros(100,ImageDimensionality);
x_array(:,ImageDimensionality) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
y_array = strain_eq(x_array);

plot(x_array(:,ImageDimensionality),y_array(:,ImageDimensionality),'r-');

ymin_max = [(-0.5*max(y_array(:,ImageDimensionality)) + 1.5*min(y_array(:,ImageDimensionality))) (1.5*max(y_array(:,ImageDimensionality)) - 0.5*min(y_array(:,ImageDimensionality)))];
if ymin_max(1) == ymin_max(2)
        ymin_max(1) = ymin_max(1) - 0.1;
        ymin_max(2) = ymin_max(2) + 0.1;
end

xlim([Origin(ImageDimensionality) FarCorner(ImageDimensionality)]);
ylim(ymin_max);
title('Strain Percentrage Values (Calculated) vs. Y-Position (um)');
xlabel('Y-Position (um)');
ylabel('Strain Percentrage Values (Calculated)');


%Caculate line of best fit for Strain Calculated vs Strain Ideal and
%identify zero offset and slope



%Calculate R^2 with Strain Calculated vs Strain Ideal

%Need to recalculate uniform_Strain_field_ideal and
%Strain_vectors to remove NaNs from the list
count = 1;
for i = 1:size(strain_field_ideal_vector,1)

    if isfinite(strain_field_ideal_vector(i)) == true
       strain_field_ideal_vector_no_nan(count,:) = strain_field_ideal_vector(i,:);
       strain_field_vector_no_nan(count,:) = strain_field_vector(i,:);
       count = count + 1;
    end
end

F = [strain_field_ideal_vector_no_nan.^0 strain_field_ideal_vector_no_nan];           % make design matrix [1,x]

c = F\strain_field_vector_no_nan;                  % get least-squares fit
res = strain_field_vector_no_nan - F*c;           % calculate residuals
r2 = 1 - nanvar(res)/nanvar(strain_field_vector_no_nan);  % calculate R^2

disp('Strain Calculated vs. Strain Ideal');

string = sprintf('R^2: %f',r2);
disp(string);
string = sprintf('Offset: %f',c(1));
disp(string);
string = sprintf('Slope: %f',c(2));
disp(string);


%Plot strain calculated versus strain ideal
figure
plot(strain_field_ideal_vector, strain_field_vector,'b.');
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

xlim(xmin_max)
ylim(ymin_max);

title('Strain Percentage Values (Calculated) vs. Strain Percentage Values (Ideal)');
xlabel('Strain Percentage Values (Ideal)');
ylabel('Strain Percentage Values (Calculated)');



% Print out difference measures for displacement and strain results  

disp('Displacement Field Results (Calculated)');
string = sprintf('mean: %f',nanmean(displacement_field_vector));
disp(string);
string = sprintf('standard deviation: %f',nanstd(displacement_field_vector));
disp(string);

disp('Displacement Field Difference (Calculated)');
directional_similarity = displacement_field_vector.*displacement_field_ideal_vector./abs(displacement_field_vector.*displacement_field_ideal_vector);
difference_of_magnitude = abs(displacement_field_vector) - abs(displacement_field_ideal_vector);
magnitude_of_difference = abs(displacement_field_vector - displacement_field_ideal_vector);


string = sprintf('directional similarity: %f +/- %f',nanmean(directional_similarity), nanstd(directional_similarity));
disp(string);
string = sprintf('difference of magnitude: %f +/- %f',nanmean(difference_of_magnitude), nanstd(difference_of_magnitude));
disp(string);
string = sprintf('magnitude of difference: %f +/- %f',nanmean(magnitude_of_difference), nanstd(magnitude_of_difference));
disp(string);

disp('Displacement Field Error (Calculated)');
string = sprintf('mean: %f',nanmean(displacement_field_vector - displacement_field_ideal_vector));
disp(string);
string = sprintf('standard deviation: %f',nanstd(displacement_field_vector- displacement_field_ideal_vector));
disp(string);
string = sprintf('10 percentile: %f',prctile(displacement_field_vector- displacement_field_ideal_vector,10));
disp(string);
string = sprintf('90 percentile: %f',prctile(displacement_field_vector- displacement_field_ideal_vector,90));
disp(string);


disp('Strain Percentage Field Results (Calculated)');
string = sprintf('mean: %f',nanmean(strain_field_vector));
disp(string);
string = sprintf('standard deviation: %f',nanstd(strain_field_vector));
disp(string);


disp('Strain Percentage Field Difference (Calculated)');
directional_similarity = strain_field_vector.*strain_field_ideal_vector./abs(strain_field_vector.*strain_field_ideal_vector);
difference_of_magnitude = abs(strain_field_vector) - abs(strain_field_ideal_vector);
magnitude_of_difference = abs(strain_field_vector - strain_field_ideal_vector);


string = sprintf('directional similarity: %f +/- %f',nanmean(directional_similarity), nanstd(directional_similarity));
disp(string);
string = sprintf('difference of magnitude: %f +/- %f',nanmean(difference_of_magnitude), nanstd(difference_of_magnitude));
disp(string);
string = sprintf('magnitude of difference: %f +/- %f',nanmean(magnitude_of_difference), nanstd(magnitude_of_difference));
disp(string);

disp('Strain Percentage Field Error (Calculated)');
string = sprintf('mean: %f',nanmean(strain_field_vector - strain_field_ideal_vector));
disp(string);
string = sprintf('standard deviation: %f',nanstd(strain_field_vector- strain_field_ideal_vector));
disp(string);
string = sprintf('10 percentile: %f',prctile(strain_field_vector- strain_field_ideal_vector,10));
disp(string);
string = sprintf('90 percentile: %f',prctile(strain_field_vector- strain_field_ideal_vector,90));
disp(string)



