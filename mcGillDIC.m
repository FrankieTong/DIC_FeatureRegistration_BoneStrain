%need to make this a function
                  
function [success, total_deformation_parameters] = mcGillDIC(ref_image_fileNameP,def_image_fileListP,subset_sizeP,subset_spaceP,qoP,Xp_firstP,Yp_firstP, Xp_lastP,Yp_lastP,interp_orderP,TOLP,optim_methodP,Max_num_iterP,incremental_flag,incremental_List)
    %scripting McGill DIC
	%
	%Parameters refer to ascpects of the McGill DIC code, futher documentation about the specifics of the parameters can be located in the documentation of the original DIC source
	%
	%ref_image_fileNameP : path to the reference image
	%def_image_fileListP : list of the path to the deformed images
	%subset_sizeP : the subset size used in the DIC
	%subset_spaceP : The spaceing between the subset centres or nodes within the DIC algorithm
	%qoP : DIC variable named to be consisten with DIC code.  needs to be a column vector such as [0;0;0;0;0;0].  Where the first two entries are the u, and v componenets of the original guess.  The other entries should be left as zero
	%Xp_firstP : X Cooridante of the upper left corner of the region within the image that will be used for DIC
	%Yp_firstP : Y Cooridante of the upper left corner of the region within the image that will be used for DIC
	%Xp_lastP : X Cooridante of the lower right corner of the region within the image that will be used for DIC
	%Yp_lastP : Y Cooridante of the lower right corner of the region within the image that will be used for DIC
	%interp_orderP : defines the interpolation that will be  used within the DIC algorithm.  It needs to be one of the followiing strings:
	%				'Linear (1st order)'
	%				'Cubic (3rd order)'
	%				'Quintic (5th order)'
	%				'(7th Order)'
	%				'(9th Order)'
	%				'(11th Order)'
	%TOLP : [delta_c, delta_q] which represetn stopping considitions for the optimizations used in the registrations.  
	%						delta_c is how smalll the change in the correlation coeffecient between iteratiions is before the optimisation is stopped
	%       			    delta_q is how small the change in the step size for the parameters IS before the opimisation is stopped
	%						reasonable values and those used by default in the GUI are the following: [1.00E-08, 5.00E-06]
	%optim_methodP : The optimisation method used during the optimization of the registration. Two valid options.  'Newton Raphson' is the default used in the GUI and suggested by the author
	%			 	 'Newton Raphson'
	%				 'fmincon' - see matlab documentation for explanation http://www.mathworks.com/help/toolbox/optim/ug/fmincon.html
	%Max_num_iterP : The maximum number of iterations used in each individual registration.
	%incremental_flag : Determines whether the registrations are run incrementally/iteratively (true), where registrations are run relative to previously registered frames as opposed to 
	%																 regular (false) where all registrations are run relative to the reference frame.
	%incremental_List : currently this in an experimental parameter.  It has no effect in incremental_flag is set to false.
	%					if incremental_flag=true then to get standarad behaviour of the incremental algorithm set incremental_List=1:(size(def_image_fileListP,1)-1)
	%					Experimental Functionality: The list allows a hybrid method of incremental and absolute, where groups of frames are defined.  
	%					Frames within the group are registered to the first frame within the group.  
	%					The first frames within groups are registered incrementally to the first frames of other groups in accordince with there order
	%					Frames are defined by labelling with integeters in the list.
	%					eg: 	incremental_List 	=		[1,   2,    2,   3,   3,  4,   5]
	%							corrisponding Frame Numbers	 1    2     3    4    5   6    7
	%							This defines 5 groups.
	%							Frames 2,4,6,7 will be registered incrementaly
	%							Frame 3 will be registered to frame 2
	%							Frame 5 will be registered to frame 4
	
    global do_incremental;
    
    do_incremental=incremental_flag;
    
    global ref_image;
    global def_image;
    ref_image = im2double(imread(ref_image_fileNameP));
    def_image_FileList = def_image_fileListP;
   

    global subset_size;
    global subset_space;

    %subset_size = 35;
    %subset_space = 2;
    
    subset_size = subset_sizeP;
    subset_space = subset_spaceP;
    
    global qo;

    %qo = [0;0;0;0;0;0];
    qo = qoP;

    global Xp_first;
    global Yp_first;
    global Xp_last;
    global Yp_last;
    global Xp;
    global Yp;

    %Xp_first =	143;
    %Yp_first =	229;
    %Xp_last =	188;
    %Yp_last =	290;
    Xp_first =	Xp_firstP;
    Yp_first =	Yp_firstP;
    Xp_last =	Xp_lastP;
    Yp_last =	Yp_lastP;

    Xp=Xp_first;
    Yp=Yp_first;

    global interp_order;

    %interp_order = 'Quintic (5th order)';
    interp_order = interp_orderP;

    global TOL;

    %TOL = [1.00E-08, 5.00E-06];
    TOL = TOLP;

    global optim_method;

    %optim_method = 'Newton Raphson';
    optim_method = optim_methodP;

    global Max_num_iter;

    %Max_num_iter = 40;
    Max_num_iter = Max_num_iterP;
    
    global last_WS;
    global Input_info;
    Input_info = cell(3,1);
    Input_info(1) = {ref_image_fileNameP};

    %********* code taken from DIC McGill Code
    % Initialize a previous workspace for later computations
    num_subsets_X = floor( (Xp_last-Xp_first)/subset_space ) + 1;
    num_subsets_Y = floor( (Yp_last-Yp_first)/subset_space ) + 1;
    mesh_gridX = Xp_first:subset_space:(num_subsets_X-1)*subset_space+Xp_first;
    mesh_gridY = Yp_first:subset_space:(num_subsets_Y-1)*subset_space+Yp_first;
    [last_WS.orig_gridX, last_WS.orig_gridY] = meshgrid( mesh_gridX, mesh_gridY);
    last_WS.TOTAL_DEFORMATIONS = zeros(num_subsets_Y, num_subsets_X, 20);
    current_TOTAL_DEFORMATIONS = last_WS.TOTAL_DEFORMATIONS;

    % Record the date and time of the current run.
    global date_time_run;
    date_time_run = now;
    %********* code taken from DIC McGill Code

    % N = number of images to pass through DIC
    N=size(def_image_fileListP);
    
    for ii = 1:N

        %do_incremental=incremental_flag(ii);
        
        %if ii > 1
            % Get the next deformed image file if there's more than 1 def image
        def_image = im2double(imread(def_image_FileList{ii}));
        Input_info(2) = {def_image_FileList{ii}};
        %end
        if do_incremental == true && ii > 1
            
             %if incremental_List(ii) ~= incremental_List(ii-1)
                % The last deformed image becomes the new reference image this
                % implies that the area of interest may warp with the object.
             %   ref_image = im2double(imread(def_image_FileList{ii-1}));
             %   Input_info(1) = {def_image_FileList{ii-1}};
             %end       
             Xp_first = floor(min(min( last_WS.orig_gridX + last_WS.TOTAL_DEFORMATIONS(:,:,1) ))) - 2;
             Xp_last  = ceil(max(max( last_WS.orig_gridX + last_WS.TOTAL_DEFORMATIONS(:,:,1) ))) + subset_space;
             Yp_first = floor(min(min( last_WS.orig_gridY + last_WS.TOTAL_DEFORMATIONS(:,:,2) ))) - 2;
             Yp_last  = ceil(max(max( last_WS.orig_gridY + last_WS.TOTAL_DEFORMATIONS(:,:,2) ))) + subset_space;
         
         
        end

        SubsetDef = 2;
    cd('Tools and Files');

        % Use "try-catch" so that if an error occurs, the program returns to the main directory
        %try
            % Choose which DIC method to perform
            switch SubsetDef
                case 1
                    Input_info(3) = {'Zeroth Order'};
                    GUI_DIC_Computations_J( 'Zeroth' );

                case 2
                    Input_info(3) = {'First Order'};
                    GUI_DIC_Computations_J( 'First' );

                case 3
                    Input_info(3) = {'Zeroth Order with Subset Slicing'};
                    GUI_DIC_Computations_J( 'Zeroth Split' );

                case 4
                    Input_info(3) = {'First Order with Subset Slicing'};
                    GUI_DIC_Computations_J( 'First Split' );
            end
        if do_incremental == true
            if ii > 1
                if incremental_List(ii) ~= incremental_List(ii-1)
                    % The last deformed image becomes the new reference image this
                    % implies that the area of interest may warp with the object.
                    %ref_image = im2double(imread(def_image_FileList{ii}));
                    %Input_info(1) = {def_image_FileList{ii}};

                    current_TOTAL_DEFORMATIONS = last_WS.TOTAL_DEFORMATIONS;
                    %current_ref_image = ref_image;
                    ref_image = im2double(imread(def_image_FileList{ii}));
                    Input_info(1) = {def_image_FileList{ii}};
                else

                    last_WS.TOTAL_DEFORMATIONS = current_TOTAL_DEFORMATIONS;
                    %ref_image = current_ref_image;
                end
            else
                if size(incremental_List,1) < 2
                    if incremental_List(2) ~= 1
                        % The last deformed image becomes the new reference image this
                        % implies that the area of interest may warp with the object.
                        %ref_image = im2double(imread(def_image_FileList{ii}));
                        %Input_info(1) = {def_image_FileList{ii}};

                        current_TOTAL_DEFORMATIONS = last_WS.TOTAL_DEFORMATIONS;
                        %current_ref_image = ref_image;
                        ref_image = im2double(imread(def_image_FileList{ii}));
                        Input_info(1) = {def_image_FileList{ii}};
                    else

                        last_WS.TOTAL_DEFORMATIONS = current_TOTAL_DEFORMATIONS;
                        %ref_image = current_ref_image;
                    end
                else

                    last_WS.TOTAL_DEFORMATIONS = current_TOTAL_DEFORMATIONS;
                    %ref_image = current_ref_image;
                end
            end
        end
    end
    
    total_deformation_parameters = last_WS.DEFORMATION_PARAMETERS;
    success = date_time_run;
end