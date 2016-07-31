%% Copied out as an individual function from POST_GUI function.

% Compute_Strains will crunch all the numbers and find the Strains. It
% outputs three cell matrices that contain all the crunched data.
function [Results, Xgrids, Ygrids] = Compute_Strains(total_or_increm, RD, handles)

% Retrieve the user inputs
Compute_Strain  = get(handles.CompStrain_DropBox,           'Value');
Filter_uv       = get(handles.Filter_uv_CheckBox,           'Value');
Conv1           = str2double(get(handles.Conv1Edit,         'string'));
Filter_strains  = get(handles.Filter_strains_CheckBox,      'Value');
Conv2           = str2double(get(handles.Conv2Edit,         'string'));
tol             = str2double(get(handles.SplineTolEdit,     'string'));

% Are we using total or incremental deformations?
if strcmpi('Increm', total_or_increm) == true
    DEFORMATIONS = RD.INCREM_DEFORMATIONS;
else
    DEFORMATIONS = RD.TOTAL_DEFORMATIONS;
end


% Define the original grid for plotting the Correlation Quality
Xgrid_C = RD.orig_gridX;
Ygrid_C = RD.orig_gridY;
CorrQual = DEFORMATIONS(:,:,end);

% If uv need to be filtered, we do that right away
if Filter_uv == true
    
    % Make sure that the size of the convolution matrix is not bigger than
    % the displacement matrix itself
    if any(Conv1 >= size(DEFORMATIONS(:,:,1))+1)
        Conv1 = floor( min(size(DEFORMATIONS(:,:,1)))/4 ) - 1;
        if mod(Conv1,2) == 0
            Conv1 = Conv1 - 1;
        end
        % The size must never be less than 1
        if Conv1 < 1
            Conv1 = 1;
        end
        warndlg(sprintf('The selected UV convolution matrix size is too large.\n %g will be used instead', Conv1), ...
                        'UV Convolution Matrix too large', 'modal');
        set(handles.Conv1Edit, 'string', num2str(Conv1));
    end
    
    % Define the convolution matrix and filter the displacements
    Pillbox1 = ones(Conv1, Conv1)./(Conv1.^2);
    DISP_U = conv2(DEFORMATIONS(:,:,1), Pillbox1, 'valid');
    DISP_V = conv2(DEFORMATIONS(:,:,2), Pillbox1, 'valid');
    
    % edge1 will define the border which was chopped off as a result of
    % doing a 'valid' convolution.
    edge1 = floor(Conv1/2);
    
    % Define the modified grid for plotting the filtered U and V
    Xgrid_UV = RD.orig_gridX(1+edge1:end-edge1, 1+edge1:end-edge1);
    Ygrid_UV = RD.orig_gridY(1+edge1:end-edge1, 1+edge1:end-edge1);
    
else % Don't filter UV
    % For clarity, define variables that represent the displacement results
    DISP_U = DEFORMATIONS(:,:,1);
    DISP_V = DEFORMATIONS(:,:,2);
    
    % Define the original grid for plotting the U and V
    Xgrid_UV = RD.orig_gridX;
    Ygrid_UV = RD.orig_gridY;
    
end

% Check that the user hasn't selected the DIC gradients for strains if the
% method was 0th order
if RD.Subset_Deform_Order == 0 && Compute_Strain == 3
    % We can not be here... using finite difference instead
    warndlg(sprintf(strcat('This data was obtained with zeroth order subset deformations.\n', ...
                           'Using Finite Differences to compute strains, instead of DIC gradients')), ...
                           'No DIC gradient strain data', 'modal');
    Compute_Strain = 1;
    set(handles.CompStrain_DropBox, 'Value', 1);
end
        

% Compute the strain matrices:
if Compute_Strain == 1              % -> Finite Differences
    
    % Find the size of the displacement matrices
    [m,n] = size(DISP_U);
    
    % Preallocate some matrices for the first order terms
    EPSxx = zeros(m,n-1);
    DV_DX = zeros(m,n-1);
    EPSyy = zeros(m-1,n);
    DU_DY = zeros(m-1,n);

    % Approximate the strains using finite differences of displacements rather than displacement derivatives
    for ii = 2:n
        EPSxx(:,(ii-1)) = (DISP_U(:,ii) - DISP_U(:,(ii-1))) / RD.subset_space; 
        DV_DX(:,(ii-1)) = (DISP_V(:,ii) - DISP_V(:,(ii-1))) / RD.subset_space;
    end

    for jj = 2:m
        EPSyy((jj-1),:) = (DISP_V(jj,:) - DISP_V((jj-1),:)) / RD.subset_space;
        DU_DY((jj-1),:) = (DISP_U(jj,:) - DISP_U((jj-1),:)) / RD.subset_space;
    end

    % EPSxy is the shear strain, and OMxy is the rotation
    EPSxy             = 0.5*( DU_DY(:,1:end-1) + DV_DX(1:end-1,:) );
    OMxy              = 0.5*( DU_DY(:,1:end-1) - DV_DX(1:end-1,:) );
    
    % Define the modified grid for plotting the finite differences strain
    Xgrid_EPSxx = Xgrid_UV(:, 1:end-1);
    Ygrid_EPSxx = Ygrid_UV(:, 1:end-1);
    Xgrid_EPSyy = Xgrid_UV(1:end-1, :);
    Ygrid_EPSyy = Ygrid_UV(1:end-1, :);
    Xgrid_EPS_OMxy = Xgrid_UV(1:end-1, 1:end-1);
    Ygrid_EPS_OMxy = Ygrid_UV(1:end-1, 1:end-1);
    
elseif Compute_Strain == 2          % -> Smoothing Spline
    
    % Define the spline coordinates
    X_coord = Xgrid_UV;
    Y_coord = Ygrid_UV;
    
    % Reshape the grid into vectors
    X_vect = X_coord(1,:);
    Y_vect = Y_coord(:,1);
    
    % Define the smoothing spline's weight matrix
    WX = ones(size(X_vect));
    WY = ones(size(Y_vect));
    
    % Define the order of the spline (3 = quintic)
    order = 3;
    
    % Compute the splines, (tol is chosen tolerance)
    spline_U = spaps({Y_vect,X_vect}, DISP_U, tol, {WY,WX}, order);
    spline_V = spaps({Y_vect,X_vect}, DISP_V, tol, {WY,WX}, order);
    
    % Extract the smooth function values at the points of interest
    DISP_U = fnval(spline_U, {Y_vect, X_vect});
    DISP_V = fnval(spline_V, {Y_vect, X_vect});
    
    % Differentiate the displacement splines to get the strain splines
    spline_DU_DX = fnder(spline_U, [0,1]);
    spline_DV_DY = fnder(spline_V, [1,0]);
    spline_DU_DY = fnder(spline_U, [1,0]);
    spline_DV_DX = fnder(spline_V, [0,1]);
    
    % Extract the function values at the points of interest
    EPSxx = fnval(spline_DU_DX, {Y_vect, X_vect});
    EPSyy = fnval(spline_DV_DY, {Y_vect, X_vect});
    EPSxy = 0.5.*( fnval(spline_DU_DY, {Y_vect, X_vect}) + fnval(spline_DV_DX, {Y_vect, X_vect}) );
    OMxy = 0.5.*( fnval(spline_DU_DY, {Y_vect, X_vect}) - fnval(spline_DV_DX, {Y_vect, X_vect}) );
    
    % Define the same grid for plotting the smoothed spline strains
    Xgrid_EPSxx = Xgrid_UV;
    Ygrid_EPSxx = Ygrid_UV;
    Xgrid_EPSyy = Xgrid_UV;
    Ygrid_EPSyy = Ygrid_UV;
    Xgrid_EPS_OMxy = Xgrid_UV;
    Ygrid_EPS_OMxy = Ygrid_UV;
    
elseif Compute_Strain == 3          % -> Use gradients obtained with DIC
    
    % Define the strains directly from the deformations obtained by DIC
    EPSxx = DEFORMATIONS(:,:,3);
    EPSyy = DEFORMATIONS(:,:,4);
    DU_DY = DEFORMATIONS(:,:,5);
    DV_DX = DEFORMATIONS(:,:,6);
    EPSxy = 0.5.*(DU_DY + DV_DX);
    OMxy = 0.5.*(DU_DY - DV_DX);
    
    % Define the original grid for plotting the strains
    Xgrid_EPSxx = RD.orig_gridX;
    Ygrid_EPSxx = RD.orig_gridY;
    Xgrid_EPSyy = RD.orig_gridX;
    Ygrid_EPSyy = RD.orig_gridY;
    Xgrid_EPS_OMxy = RD.orig_gridX;
    Ygrid_EPS_OMxy = RD.orig_gridY;
    
end


% If strains need to be filtered, do that now
if Filter_strains == true
    
    % Make sure that the size of the convolution matrix is not bigger than
    % the strain matrix itself (EPSxy and OMxy are the smallest strain matrices)
    if any(Conv2 >= size(EPSxy)+1)
        Conv2 = floor( min(size(EPSxy))/4 ) - 1;
        if mod(Conv2,2) == 0
            Conv2 = Conv2 - 1;
        end
        % The size must never be less than 1
        if Conv2 < 1
            Conv2 = 1;
        end
        warndlg(sprintf('The selected Strain convolution matrix size is too large.\n %g will be used instead', Conv2), ...
                        'Strain Convolution Matrix too large', 'modal');
        set(handles.Conv2Edit, 'string', num2str(Conv2));            
    end
    
    % Define the convolution matrix and filter the displacements
    Pillbox2 = ones(Conv2, Conv2)./(Conv2.^2);
    EPSxx_filtered = conv2(EPSxx, Pillbox2, 'valid');
    EPSyy_filtered = conv2(EPSyy, Pillbox2, 'valid');
    EPSxy_filtered = conv2(EPSxy, Pillbox2, 'valid');
    OMxy_filtered  = conv2(OMxy, Pillbox2,  'valid');
    
    % edge2 will define the border which was chopped off as a result of
    % doing a 'valid' convolution.
    edge2 = floor(Conv2/2);
    
    % Define the modified grid for plotting the filtered strains
    Xgrid_EPSxx = Xgrid_EPSxx(1+edge2:end-edge2, 1+edge2:end-edge2);
    Ygrid_EPSxx = Ygrid_EPSxx(1+edge2:end-edge2, 1+edge2:end-edge2);
    Xgrid_EPSyy = Xgrid_EPSyy(1+edge2:end-edge2, 1+edge2:end-edge2);
    Ygrid_EPSyy = Ygrid_EPSyy(1+edge2:end-edge2, 1+edge2:end-edge2);
    Xgrid_EPS_OMxy = Xgrid_EPS_OMxy(1+edge2:end-edge2, 1+edge2:end-edge2);
    Ygrid_EPS_OMxy = Ygrid_EPS_OMxy(1+edge2:end-edge2, 1+edge2:end-edge2);
    
else % Don't filter strains
    % Even though they weren't filtered, give them the same name for
    % upcoming plotting
    EPSxx_filtered = EPSxx;
    EPSyy_filtered = EPSyy;
    EPSxy_filtered = EPSxy;
    OMxy_filtered  = OMxy;
    
end

% Compute the principle strains, the rotation angle, and the volumetric strain using the above
[mm, nn] = size(EPSxy_filtered);
EPS1                       = 0.5*(EPSxx_filtered(1:mm, :) + EPSyy_filtered(:, 1:nn)) + ...
                             sqrt( ( EPSxx_filtered(1:mm, :)-EPSyy_filtered(:, 1:nn) ).^2/4 + EPSxy_filtered.^2 );
EPS2                       = 0.5*(EPSxx_filtered(1:mm, :) + EPSyy_filtered(:, 1:nn)) - ...
                             sqrt( ( EPSxx_filtered(1:mm, :)-EPSyy_filtered(:, 1:nn) ).^2/4 + EPSxy_filtered.^2 );
THETA                      = 0.5*atan( 2*EPSxy_filtered ./ (EPSxx_filtered(1:mm, :) - EPSyy_filtered(:, 1:nn)) );
Vol_Strain                 = (1 + EPS1).*(1 + EPS2).^2 - 1;

Xgrids = {Xgrid_C; Xgrid_UV; Xgrid_EPSxx; Xgrid_EPSyy; Xgrid_EPS_OMxy};
Ygrids = {Ygrid_C; Ygrid_UV; Ygrid_EPSxx; Ygrid_EPSyy; Ygrid_EPS_OMxy};
Results = {DISP_U; DISP_V; CorrQual; EPSxx_filtered; EPSyy_filtered; EPSxy_filtered; OMxy_filtered; EPS1; EPS2; THETA; Vol_Strain};


end % function
