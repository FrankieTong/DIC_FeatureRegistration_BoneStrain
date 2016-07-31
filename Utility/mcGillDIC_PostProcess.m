function outputFileList = mcGillDIC_PostProcess(ouputDirectory, inputFileList, computeStrainsMethod, displacementMatrixSize, strainMatrixSize, splineTolerance, total_deformation_flag, incremental_deformation_flag,workspace_flag, report_flag, total_deformation_plots, total_movies, incremental_deformation_plots, incremental_movies)

ouputFileList = 1; % needs to be tested

% total_deformation_plots = 0 nothing, 1 reference, 2 deformaed
% incremental_deformation_plots = 0 nothing, 1 reference, 2 deformaed
% movies = 0 nothing, >0 frames per second

% taken from within POSTPRO_GUI_May_01_2008.m - function RunPostProcess_Button_Callback(hObject, eventdata, handles)

% Record the date and time that the run button was pushed, for naming the output folder
date_time_pstprs_run = now;
date_time_pstprs_folder = datestr(date_time_pstprs_run, 'yyyy-mm-dd_HH_MM_SS');

% Define the path where new outputs will be saved
PostProcess_folder_path = sprintf('%s\\Post-Process_Outputs_for_%s', ouputDirectory, date_time_pstprs_folder);

% Start by retrieving the workspace files from the data application struct
%rawdata = getappdata(handles.figure1, 'rawdata_files');
rawdata = struct('files', inputFileList);

% Find out how many files there are to work with, and what directory there are in
if iscell(rawdata.files) == false
    NN = 1; % only 1 file
else
    NN = numel(rawdata.files);  % many files
end

% Define the workspace directory
%workspace_dir = workspaces.filePaths;

% Save the current directory so that we can return to it at the end
current_dir = pwd;

% Retrieve the user inputs
%Compute_Strain  = get(handles.CompStrain_DropBox,           'Value');
Compute_Strain = computeStrainsMethod;

%SaveResults     = get(handles.SaveResults_CheckBox,         'Value');
SaveResults = true;

%TotalData       = get(handles.TotalData_CheckBox,           'Value');
TotalData = total_deformation_flag;

%IncremData      = get(handles.IncremData_CheckBox,          'Value');
IncremData = incremental_deformation_flag;

%WORKSAVE        = get(handles.Workspace_Save_CheckBox,      'Value');
WORKSAVE = workspace_flag;

%SaveReport      = get(handles.SaveReport_CheckBox,          'Value');
SaveReport = report_flag;

%SaveTotalPlots  = get(handles.SaveTotalPlots_CheckBox,      'Value');
%PlotTotalRef    = get(handles.PlotTotalRef_RadioButton,     'Value');
if total_deformation_plots>0
	SaveTotalPlots  = true;
	PlotTotalRef    = total_deformation_plots -1;
else
	SaveTotalPlots  = false;
	PlotTotalRef = 1;
end

%SaveTotalMovie  = get(handles.SaveTotalMovie_CheckBox,      'Value');
%FPS_Total       = str2double(get(handles.FPS_TotalEdit,     'string'));
if total_movies>0
	SaveTotalMovie  = true;
	FPS_Total       = total_movies;
else
	SaveTotalMovie  = false;
	FPS_Total       = 1;
end

%SaveIncremPlots = get(handles.SaveIncremPlots_CheckBox,     'Value');
%PlotIncremRef   = get(handles.PlotIncremRef_RadioButton,    'Value');
if incremental_deformation_plots>0
	SaveIncremPlots  = true;
	PlotIncremRef = incremental_deformation_plots -1;
else
	SaveIncremPlots = false;
	PlotIncremRef = 1;
end

%SaveIncremMovie = get(handles.SaveIncremMovie_CheckBox,     'Value');
%FPS_Increm      = str2double(get(handles.FPS_IncremEdit,    'string'));
if incremental_movies>0
	SaveIncremMovie =  true;
	FPS_Increm       = incremental_movies;
else
	SaveIncremMovie  = false;
	FPS_Increm      = 1;
end

%Need to define handles for compute_strains

handles = actxserver('matlab.application');

handles = struct('CompStrain_DropBox', Compute_Strain,...
    'Filter_uv_CheckBox', (displacementMatrixSize>0),...
    'Conv1Edit', displacementMatrixSize,...
    'Filter_strains_CheckBox', (strainMatrixSize>0),...
    'Conv2Edit', strainMatrixSize,...
    'SplineTolEdit',splineTolerance...
    );







if SaveResults == false && SaveReport == false && ...
   SaveTotalPlots == false && SaveTotalMovie == false && ...
   SaveIncremPlots == false && SaveIncremMovie == false && WORKSAVE == false
    warndlg('No Options were selected, so nothing was saved to disk', 'Nothing To Do', 'modal');
    return;
end


% MAIN COMPUTATION LOOP --> Compute and save all data
for ii = 1:NN
    
    % Change the directory to find the workspace files
    %cd(workspace_dir);
    
    % The current workspace can now be stored
    if iscell(rawdata.files) == false
        RD = Load_Data( rawdata.files );
    else
        RD = Load_Data( rawdata.files{ii} );
    end
    
    % Return to the root directory
    % cd(current_dir);

    
    % Define the outputs folder
    RD.PostProcess_folder_path = PostProcess_folder_path;
    
    [Results_total, Xgrids, Ygrids] = Compute_Strains('Total', RD, handles);
    [Results_increm, Xgrids, Ygrids] = Compute_Strains('Increm', RD, handles);

    
    % -------------RESULT DATA SAVING----------------------------------
    if SaveResults == true
        % Save the outputs for the two types of data, total and incremental deformations
        if  TotalData == true
            Save_Output_Data( 'Total', RD, Results_total, Compute_Strain );
        end
        if IncremData == true
            Save_Output_Data( 'Increm', RD, Results_increm, Compute_Strain );
        end
    end
    
    % -------------END RAW DATA SAVING----------------------------------
    
    
    
    % -------------WORKSPACE SAVING----------------------------------
    if WORKSAVE == true
        % Save a special workspace for Reza's J-integral program
        % The current workspace can now be stored
        if iscell(rawdata.files) == false
            RD_filename = rawdata.fileNames;
        else
            RD_filename = rawdata.fileNames{ii};
        end
            Compute_Strains_Special( RD_filename, RD, handles );
    end
    
    % -------------END RAW DATA SAVING-------------------------------
    
    
    
    
    
    

    % -------------REPORT SAVING----------------------------------
    if SaveReport == true
        % Start by computing some statistics for the total deformations
        tMEAN(1) = mean(mean(  Results_total{1} ));             % mean of u
        tMEAN(2) = mean(mean(  Results_total{2} ));             % mean of v
        tMEAN(3) = mean(mean(  Results_total{3} ));             % mean of C 
        tMEAN(4) = mean(mean(  Results_total{4} ));             % mean of EPSxx 
        tMEAN(5) = mean(mean(  Results_total{5} ));             % mean of EPSyy 
        tMEAN(6) = mean(mean(  Results_total{6} ));             % mean of EPSxy 
        tMEAN(7) = mean(mean(  Results_total{7} ));             % mean of OMxy
        tMEAN(8) = mean(mean(  Results_total{8} ));             % mean of EPS1
        tMEAN(9) = mean(mean(  Results_total{9} ));             % mean of EPS2
        tMEAN(10)= mean(mean(  Results_total{10} ));            % mean of THETA
        tMEAN(11)= mean(mean(  Results_total{11} ));            % mean of VolStrain
        
        tSTD(1) = std(std(  Results_total{1} ));                % stand. dev. of u
        tSTD(2) = std(std(  Results_total{2} ));                % stand. dev. of v
        tSTD(3) = std(std(  Results_total{3} ));                % stand. dev. of C 
        tSTD(4) = std(std(  Results_total{4} ));                % stand. dev. of EPSxx
        tSTD(5) = std(std(  Results_total{5} ));                % stand. dev. of EPSyy
        tSTD(6) = std(std(  Results_total{6} ));                % stand. dev. of EPSxy 
        tSTD(7) = std(std(  Results_total{7} ));                % stand. dev. of OMxy
        tSTD(8) = std(std(  Results_total{8} ));                % stand. dev. of EPS1
        tSTD(9) = std(std(  Results_total{9} ));                % stand. dev. of EPS2
        tSTD(10)= std(std(  Results_total{10} ));               % stand. dev. of THETA
        tSTD(11)= std(std(  Results_total{11} ));               % stand. dev. of VolStrain
        
        % Compute the same statistics for the incremental deformations        
        iMEAN(1) = mean(mean(  Results_increm{1} ));            % mean of u  
        iMEAN(2) = mean(mean(  Results_increm{2} ));            % mean of v
        iMEAN(3) = mean(mean(  Results_increm{3} ));            % mean of C 
        iMEAN(4) = mean(mean(  Results_increm{4} ));            % mean of EPSxx
        iMEAN(5) = mean(mean(  Results_increm{5} ));            % mean of EPSyy
        iMEAN(6) = mean(mean(  Results_increm{6} ));            % mean of EPSxy 
        iMEAN(7) = mean(mean(  Results_increm{7} ));            % mean of OMxy
        iMEAN(8) = mean(mean(  Results_increm{8} ));            % mean of EPS1
        iMEAN(9) = mean(mean(  Results_increm{9} ));            % mean of EPS2
        iMEAN(10)= mean(mean(  Results_increm{10} ));           % mean of THETA
        iMEAN(11)= mean(mean(  Results_increm{11} ));           % mean of VolStrain
        
        iSTD(1) = std(std(  Results_increm{1} ));               % stand. dev. of u
        iSTD(2) = std(std(  Results_increm{2} ));               % stand. dev. of v
        iSTD(3) = std(std(  Results_increm{3} ));               % stand. dev. of EPSxx
        iSTD(4) = std(std(  Results_increm{4} ));               % stand. dev. of EPSyy
        iSTD(5) = std(std(  Results_increm{5} ));               % stand. dev. of EPSxy
        iSTD(6) = std(std(  Results_increm{6} ));               % stand. dev. of OMxy
        iSTD(7) = std(std(  Results_increm{7} ));             	% stand. dev. of C
        iSTD(8) = std(std(  Results_increm{8} ));               % stand. dev. of EPS1
        iSTD(9) = std(std(  Results_increm{9} ));               % stand. dev. of EPS2
        iSTD(10)= std(std(  Results_increm{10} ));              % stand. dev. of THETA
        iSTD(11)= std(std(  Results_increm{11} ));              % stand. dev. of VolStrain
        
        % Start writing the report: create a new directory and open the total stats files
        [tmp1, tmp2, tmp3] = mkdir(PostProcess_folder_path, 'Report');
        Output_file_total   = strcat(PostProcess_folder_path, '\Report\Report_Total', '.txt');
        Output_file_increm  = strcat(PostProcess_folder_path, '\Report\Report_Increm', '.txt');
        file_id_total = fopen(Output_file_total, 'at');
        file_id_increm = fopen(Output_file_increm, 'at');
        
        if ii == 1
            % Place a title for the total deformation report
            fprintf(file_id_total, 'Total Deformation Report\n\n');
            fprintf(file_id_total, strcat('Average EPSxx, Average EPSyy, Average EPSxy, Average OMExy,', ...
                                          'Average u, Average v, Average C, Average EPS1, Average EPS2,', ...
                                          'Average Theta, Average Vol. Strain,', ...
                                          'St. Dev. EPSxx, St. Dev. EPSyy, St. Dev. EPSxy, St. Dev. OMExy,', ...
                                          'St. Dev. u, St. Dev. v, St. Dev. C, St. Dev. EPS1, St. Dev. EPS2,', ...
                                          'St. Dev. Theta, St. Dev. Vol. Strain\n' ) );
                                      
            % Place a title for the incremental deformation report
            fprintf(file_id_increm, 'Incremental Deformation Report\n\n');
            fprintf(file_id_increm, strcat('Average EPSxx, Average EPSyy, Average EPSxy, Average OMExy,', ...
                                           'Average u, Average v, Average C, Average EPS1, Average EPS2,', ...
                                           'Average Theta, Average Vol. Strain,', ...
                                           'St. Dev. EPSxx, St. Dev. EPSyy, St. Dev. EPSxy, St. Dev. OMExy,', ...
                                           'St. Dev. u, St. Dev. v, St. Dev. C, St. Dev. EPS1, St. Dev. EPS2,', ...
                                           'St. Dev. Theta, St. Dev. Vol. Strain\n' ) );
                                       
        end
        
        % Print the stats results to the report 
        fprintf(file_id_total, '%g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g\n', ...
                               tMEAN(4), tMEAN(5), tMEAN(6), tMEAN(7), tMEAN(1), tMEAN(2), tMEAN(3), tMEAN(8), tMEAN(9), tMEAN(10), tMEAN(11), ...
                               tSTD(4), tSTD(5), tSTD(6), tSTD(7), tSTD(1), tSTD(2), tSTD(3), tSTD(8), tSTD(9), tSTD(10), tSTD(11) );
                           
        fprintf(file_id_increm, '%g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g\n', ...
                                iMEAN(4), iMEAN(5), iMEAN(6), iMEAN(7), iMEAN(1), iMEAN(2), iMEAN(3), iMEAN(8), iMEAN(9), iMEAN(10), iMEAN(11), ...
                                iSTD(4), iSTD(5), iSTD(6), iSTD(7), iSTD(1), iSTD(2), iSTD(3), iSTD(8), iSTD(9), iSTD(10), iSTD(11) );
        
        fclose(file_id_total);
        fclose(file_id_increm);
    end % Save Report
    % -------------END REPORT SAVING----------------------------------
    %}
    
    
    % -------------TOTAL PLOT SAVING----------------------------------
    if SaveTotalPlots == true
        Save_Plots(Results_total, Xgrids, Ygrids, RD, handles, 'Total', PlotTotalRef);
        
        if SaveTotalMovie == true
            
            % Change to the Tools and Files directory to make the movies
            cd('Tools and Files');            
            ToolsFiles_dir = cd;
            
            % Define the movie_folder directory
            movie_folder = strcat(PostProcess_folder_path, '\Movies\Total Deformations');
            [tmp1, tmp2, tmp3] = mkdir(movie_folder);
            
            
            % Define the directories where the images were stored
            if PlotTotalRef == true
                u_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Displacement u');
                v_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Displacement v');
                C_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Correlation Quality');
                EpsXX_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Epsilon xx');
                EpsYY_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Epsilon yy');
                EpsXY_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Epsilon xy');
                OmeXY_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Omega xy');
                EPS1_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Epsilon 1');
                EPS2_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Epsilon 2');
                Theta_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Theta');
                VolStrain_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Vol_Strain');
            else
                u_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Displacement u (on def object)');
                v_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Displacement v (on def object)');
                C_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Correlation Quality (on def object)');
                EpsXX_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Epsilon xx (on def object)');
                EpsYY_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Epsilon yy (on def object)');
                EpsXY_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Epsilon xy (on def object)');
                OmeXY_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Omega xy (on def object)');
                EPS1_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Epsilon 1 (on def object)');
                EPS2_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Epsilon 2 (on def object)');
                Theta_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Theta (on def object)');
                VolStrain_dir = strcat(PostProcess_folder_path, '\Total Deformation Plots\Total Vol_Strain (on def object)');
            end
                
        
            % Call the movie_maker to make all the movies
            Movie_Maker( ToolsFiles_dir, u_dir, FPS_Total, movie_folder);
            Movie_Maker( ToolsFiles_dir, v_dir, FPS_Total, movie_folder);
            Movie_Maker( ToolsFiles_dir, C_dir, FPS_Total, movie_folder);
            Movie_Maker( ToolsFiles_dir, EpsXX_dir, FPS_Total, movie_folder);
            Movie_Maker( ToolsFiles_dir, EpsYY_dir, FPS_Total, movie_folder);
            Movie_Maker( ToolsFiles_dir, EpsXY_dir, FPS_Total, movie_folder);
            Movie_Maker( ToolsFiles_dir, OmeXY_dir, FPS_Total, movie_folder);
            Movie_Maker( ToolsFiles_dir, EPS1_dir, FPS_Total, movie_folder);
            Movie_Maker( ToolsFiles_dir, EPS2_dir, FPS_Total, movie_folder);
            Movie_Maker( ToolsFiles_dir, Theta_dir, FPS_Total, movie_folder);
            Movie_Maker( ToolsFiles_dir, VolStrain_dir, FPS_Total, movie_folder);
            
            % Return to the main directory
            cd('..');
            
        end % if SaveTotalMovie
            
    end % if SaveTotalPlots
    % -------------END TOTAL PLOT SAVING----------------------------------
    
    
    
    
    
    % -------------INCREM PLOT SAVING----------------------------------
    if SaveIncremPlots == true
        Save_Plots(Results_increm, Xgrids, Ygrids, RD, handles, 'Increm', PlotIncremRef);
        
        if SaveIncremMovie == true
            
            % Change to the Tools and Files directory to make the movies
            cd('Tools and Files');            
            ToolsFiles_dir = cd;
            
            % Define the movie_folder directory
            movie_folder = strcat(PostProcess_folder_path, '\Movies\Incremental Deformations');
            [tmp1, tmp2, tmp3] = mkdir(movie_folder);
            
            % Define the directories where the images were stored
            if PlotIncremRef == true
                u_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Displacement u');
                v_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Displacement v');
                C_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Correlation Quality');
                EpsXX_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Epsilon xx');
                EpsYY_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Epsilon yy');
                EpsXY_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Epsilon xy');
                OmeXY_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Omega xy');
                EPS1_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Epsilon 1');
                EPS2_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Epsilon 2');
                Theta_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Theta');
                VolStrain_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Vol_Strain');
            else
                u_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Displacement u (on def object)');
                v_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Displacement v (on def object)');
                C_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Correlation Quality (on def object)');
                EpsXX_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Epsilon xx (on def object)');
                EpsYY_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Epsilon yy (on def object)');
                EpsXY_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Epsilon xy (on def object)');
                OmeXY_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Omega xy (on def object)');
                EPS1_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Epsilon 1 (on def object)');
                EPS2_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Epsilon 2 (on def object)');
                Theta_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Theta (on def object)');
                VolStrain_dir = strcat(PostProcess_folder_path, '\Incremental Deformation Plots\Incremental Vol_Strain (on def object)');
            end
                
        
            % Call the movie_maker to make all the movies
            Movie_Maker( ToolsFiles_dir, u_dir, FPS_Increm, movie_folder);
            Movie_Maker( ToolsFiles_dir, v_dir, FPS_Increm, movie_folder);
            Movie_Maker( ToolsFiles_dir, C_dir, FPS_Increm, movie_folder);
            Movie_Maker( ToolsFiles_dir, EpsXX_dir, FPS_Increm, movie_folder);
            Movie_Maker( ToolsFiles_dir, EpsYY_dir, FPS_Increm, movie_folder);
            Movie_Maker( ToolsFiles_dir, EpsXY_dir, FPS_Increm, movie_folder);
            Movie_Maker( ToolsFiles_dir, OmeXY_dir, FPS_Increm, movie_folder);
            Movie_Maker( ToolsFiles_dir, EPS1_dir, FPS_Total, movie_folder);
            Movie_Maker( ToolsFiles_dir, EPS2_dir, FPS_Total, movie_folder);
            Movie_Maker( ToolsFiles_dir, Theta_dir, FPS_Total, movie_folder);
            Movie_Maker( ToolsFiles_dir, VolStrain_dir, FPS_Total, movie_folder);
            
            % Return to the main directory
            cd('..');
            
        end % if SaveTotalMovie
    end % if SaveIncremPlots
    % -------------END INCREM PLOT SAVING----------------------------------
    
    clc;
    fprintf(1, '\n\n%g out of %g raw data files have finished being post-processed\n', ii, NN);
    
end % Main Computational "for" loop

% Change back to the original directory
cd(current_dir);

cd('Tools and Files');
icon = load('smiley_icon.mat');
cd('..');
msgbox('The Post-Processing Run has finished successfully!','Post-Processing Complete','custom', icon.smiley);


end % function