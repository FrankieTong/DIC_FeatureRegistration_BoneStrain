%{
This file is part of the McGill Digital Image Correlation Research Tool (MDICRT).
Copyright © 2008, Jeffrey Poissant, Francois Barthelat

MDICRT is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

MDICRT is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with MDICRT.  If not, see <http://www.gnu.org/licenses/>.



Digital Image Correlation: Post-Processing
Honours Thesis Research Project
McGill University, Montreal, Quebec, Canada
Created on:  May 31, 2007
Modified on: May 1, 2008

--------------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: POST-PROCESSING               |
--------------------------------------------------------------

This M-file, along with the figure file of the same name are responsible 
for generating the GUI for the Post-Processing program.

RUN THIS FILE TO START THE POST-PROCESSING PROGRAM!

DO NOT MODIFY THE FUNCTION varargout!!!
%}

function varargout = POSTPRO_GUI_May_01_2008(varargin)
% POSTPRO_GUI_May_01_2008 M-file for POSTPRO_GUI_May_01_2008.fig
%      POSTPRO_GUI_May_01_2008, by itself, creates a new POSTPRO_GUI_May_01_2008 or raises the existing
%      singleton*.
%
%      H = POSTPRO_GUI_May_01_2008 returns the handle to a new POSTPRO_GUI_May_01_2008 or the handle to
%      the existing singleton*.
%
%      POSTPRO_GUI_May_01_2008('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POSTPRO_GUI_May_01_2008.M with the given input arguments.
%
%      POSTPRO_GUI_May_01_2008('Property','Value',...) creates a new POSTPRO_GUI_May_01_2008 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before POSTPRO_GUI_May_01_2008_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to POSTPRO_GUI_May_01_2008_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help
% POSTPRO_GUI_May_01_2008

% Last Modified by GUIDE v2.5 06-Feb-2008 11:47:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @POSTPRO_GUI_May_01_2008_OpeningFcn, ...
                   'gui_OutputFcn',  @POSTPRO_GUI_May_01_2008_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end % function




% --- Executes just before POSTPRO_GUI_May_01_2008 is made visible.
function POSTPRO_GUI_May_01_2008_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to POSTPRO_GUI_May_01_2008 (see VARARGIN)

%{
***************************************************************************************
*JEFF: The following lines are my own edits.                                          *
*      This section initializes the program just before the GUI appears on screen     *
***************************************************************************************
%}

% Load the default image for the welcome message and the preview axes
axes(handles.WelcomeImage);
image(imread('Tools and Files\DICWelcomeImage.TIF'), 'CDataMapping', 'scaled');
set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
axes(handles.DispU_Plot);
image(imread('Tools and Files\EmptyImage.TIF'), 'CDataMapping', 'scaled');
set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
axes(handles.DispV_Plot);
image(imread('Tools and Files\EmptyImage.TIF'), 'CDataMapping', 'scaled');
set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
axes(handles.CorrQual_Plot);
image(imread('Tools and Files\EmptyImage.TIF'), 'CDataMapping', 'scaled');
set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
axes(handles.EpsXX_Plot);
image(imread('Tools and Files\EmptyImage.TIF'), 'CDataMapping', 'scaled');
set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
axes(handles.EpsYY_Plot);
image(imread('Tools and Files\EmptyImage.TIF'), 'CDataMapping', 'scaled');
set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
axes(handles.EpsXY_Plot);
image(imread('Tools and Files\EmptyImage.TIF'), 'CDataMapping', 'scaled');
set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
axes(handles.OmeXY_Plot);
image(imread('Tools and Files\EmptyImage.TIF'), 'CDataMapping', 'scaled');
set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);


% Load the workspace "postprocess_defaults" to set the program's default values
cd('Tools and Files');
WS = load('postprocess_defaults.mat');
cd('..');
postprocess_defaults = WS.postprocess_defaults;
clear WS;
% Save the default values as application data for use in error checking
setappdata(hObject, 'defaults', postprocess_defaults);

% Add a struct that will track the raw data files that the user selects
% Start by loading the default ref and def images
rawdata.files = postprocess_defaults.files;
rawdata.fileNames = postprocess_defaults.fileNames;
rawdata.filePaths = postprocess_defaults.filePaths;

% Check that the raw data are valid
valid = Check_RawData(rawdata, handles);
if valid == true
    % Save the changes to the rawdata_files struct
    setappdata(handles.figure1, 'rawdata_files', rawdata);
else
    clear rawdata
    rawdata.files = '';
    setappdata(handles.figure1, 'rawdata_files', rawdata);
end


% Set all the fields to the default values
% Strain Options
set(handles.CompStrain_DropBox,             'Value',    postprocess_defaults.CompStrain);
set(handles.Filter_uv_CheckBox,             'Value',    postprocess_defaults.Filter_uv);
set(handles.Conv1Edit,                      'string',   postprocess_defaults.Conv1);
set(handles.Filter_strains_CheckBox,        'Value',    postprocess_defaults.Filter_strains);
set(handles.Conv2Edit,                      'string',   postprocess_defaults.Conv2);
set(handles.SplineTolEdit,                  'string',   postprocess_defaults.SplineTol);

% Preview Options
if postprocess_defaults.PreviewTotal == 0
    PreviewIncrem_RadioButton_Callback( handles.PreviewIncrem_RadioButton, eventdata, handles );
else
    PreviewTotal_RadioButton_Callback( handles.PreviewTotal_RadioButton, eventdata, handles );
end
if postprocess_defaults.PreviewOnRef == 0
    PreviewOnDef_RadioButton_Callback( handles.PreviewOnDef_RadioButton, eventdata, handles );
else
    PreviewOnRef_RadioButton_Callback( handles.PreviewOnRef_RadioButton, eventdata, handles );
end


% Output Options
set(handles.SaveResults_CheckBox,           'Value',	postprocess_defaults.SaveResults);
set(handles.TotalData_CheckBox,             'Value',    postprocess_defaults.TotalData);
set(handles.IncremData_CheckBox,            'Value',    postprocess_defaults.IncremData);

set(handles.Workspace_Save_CheckBox,        'Value',    postprocess_defaults.WorkSave);

set(handles.SaveReport_CheckBox,            'Value',    postprocess_defaults.SaveReport);
set(handles.SaveTotalPlots_CheckBox,        'Value',    postprocess_defaults.SaveTotalPlots);
set(handles.PlotTotalRef_RadioButton,        'Value',    postprocess_defaults.PlotTotalRef);
if postprocess_defaults.PlotTotalRef == 0
    PlotTotalDef_RadioButton_Callback(handles.PlotTotalDef_RadioButton, eventdata, handles);
else
    PlotTotalRef_RadioButton_Callback(handles.PlotTotalRef_RadioButton, eventdata, handles);
end
set(handles.SaveTotalMovie_CheckBox,        'Value',    postprocess_defaults.SaveTotalMovie);
set(handles.FPS_TotalEdit,                  'string',   postprocess_defaults.FPS_Total);

set(handles.SaveIncremPlots_CheckBox,       'Value',    postprocess_defaults.SaveIncremPlots);
set(handles.PlotIncremRef_RadioButton,      'Value',    postprocess_defaults.PlotIncremRef);
if postprocess_defaults.PlotIncremRef == 0
    PlotIncremDef_RadioButton_Callback(handles.PlotIncremDef_RadioButton, eventdata, handles);
else
    PlotIncremRef_RadioButton_Callback(handles.PlotIncremRef_RadioButton, eventdata, handles);
end
set(handles.SaveIncremMovie_CheckBox,       'Value',    postprocess_defaults.SaveIncremMovie);
set(handles.FPS_IncremEdit,                 'string',   postprocess_defaults.FPS_Increm);

% Refresh the preview plots if the file is valid
if valid == true
    Preview_Button_Callback(handles.Preview_Button, eventdata, handles);
end

% Add a new struct to track errors in the inputs before post-processing runs
error_tracker.error_found = false;
setappdata(hObject, 'tracker', error_tracker);

%---MATLAB CODE-----------------------------------
% Choose default command line output for POSTPRO_GUI_May_01_2008
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes POSTPRO_GUI_May_01_2008 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end % function





% --- Outputs from this function are returned to the command line.
function varargout = POSTPRO_GUI_May_01_2008_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end % function


%{
***************************************************************************************
*JEFF: The following functions define the creation and changes that occur for the.    *
*      various objects in the GUI. The common inputs are:                             *
*         hObject   --> Represents the handle of the current function.                *
*                       Use this to modify properties using "set" and "get"           *
*         eventdata --> this is isn't used??? --> according to Matlab                 *
*                       "reserved - to be defined in a future version of MATLAB"      *
*         handles   --> Represents the handle of every function.                      *
*                       Use this to modify properties of anything with "set" and "get"*
***************************************************************************************
%}



%___________________________MENUS SECTION_____________________________________________


%**********OPTION MENU AND CONTEXT MENU****************************


% --------------------------------------------------------------------
function Options_Menu_Callback(hObject, eventdata, handles)
% Do nothing
end % function

% --------------------------------------------------------------------
function Save_Default_SubMenu_Callback(hObject, eventdata, handles)

% To save the current values as defaults, start by loading the postprocess_defaults struct
postprocess_defaults = getappdata(handles.figure1, 'defaults');

% Now, get the current values and store them into program_defaults
postprocess_defaults.CompStrain                  = get(handles.CompStrain_DropBox,           'Value');
postprocess_defaults.Filter_uv                   = get(handles.Filter_uv_CheckBox,           'Value');
postprocess_defaults.Conv1                       = get(handles.Conv1Edit,                    'string');
postprocess_defaults.Filter_strains              = get(handles.Filter_strains_CheckBox,      'Value');
postprocess_defaults.Conv2                       = get(handles.Conv2Edit,                    'string');
postprocess_defaults.SplineTol                   = get(handles.SplineTolEdit,                'string');
postprocess_defaults.PreviewTotal                = get(handles.PreviewTotal_RadioButton,    'Value');
postprocess_defaults.PreviewOnRef                = get(handles.PreviewOnRef_RadioButton,    'Value');


postprocess_defaults.SaveResults                 = get(handles.SaveResults_CheckBox,         'Value');
postprocess_defaults.TotalData                   = get(handles.TotalData_CheckBox,           'Value');
postprocess_defaults.IncremData                  = get(handles.IncremData_CheckBox,          'Value');

postprocess_defaults.WorkSave                    = get(handles.Workspace_Save_CheckBox,      'Value');

postprocess_defaults.SaveReport                  = get(handles.SaveReport_CheckBox,          'Value');
postprocess_defaults.SaveTotalPlots              = get(handles.SaveTotalPlots_CheckBox,      'Value');
postprocess_defaults.PlotTotalRef                = get(handles.PlotTotalRef_RadioButton,     'Value');
postprocess_defaults.SaveTotalMovie              = get(handles.SaveTotalMovie_CheckBox,      'Value');
postprocess_defaults.FPS_Total                   = get(handles.FPS_TotalEdit,                'string');
postprocess_defaults.SaveIncremPlots             = get(handles.SaveIncremPlots_CheckBox,     'Value');
postprocess_defaults.PlotIncremRef               = get(handles.PlotIncremRef_RadioButton,    'Value');
postprocess_defaults.SaveIncremMovie             = get(handles.SaveIncremMovie_CheckBox,     'Value');
postprocess_defaults.FPS_Increm                  = get(handles.FPS_IncremEdit,               'string');


% To save the images, and the initial guess, get their respective data structs...
rawdata = getappdata(handles.figure1, 'rawdata_files');

% ... and store them into postprocess_defaults
postprocess_defaults.files = rawdata.files;
postprocess_defaults.fileNames = rawdata.fileNames;
postprocess_defaults.filePaths = rawdata.filePaths;

% Save the changes to the postprocess_defaults struct
setappdata(handles.figure1, 'defaults', postprocess_defaults);

% Save these new values as a workspace in the "Tools and Files" folder
cd('Tools and Files');
save('postprocess_defaults.mat', 'postprocess_defaults');

% Return to the original folder
cd('..');

end % function
% --------------------------------------------------------------------
function Start_DIC_SubMenu_Callback(hObject, eventdata, handles)
DIC_GUI_May_01_2008;
end % function

% --------------------------------------------------------------------
function Exit_SubMenu_Callback(hObject, eventdata, handles)
clear;
close('all');
end % function


%**********END OPTION MENU AND CONTEXT MENU****************************



%_________________________________________________________________________________________













%___________________________POST-PROCESSING_____________________________________________


%******************INPUT WORKSPACE PANEL********************************

% --- Executes on button press in SelectRawData_Button.
function SelectRawData_Button_Callback(hObject, eventdata, handles)
% Open Matlab's GUI to select the rawdata file(s)
[RD_file, RDfile_path] = uigetfile('*.txt', 'MultiSelect','on');

% If the user didn't cancel, save the selected files
if ~isequal(RD_file, 0)
    
    % Open the rawdata_files struct and store the selected file paths
    rawdata = getappdata(handles.figure1, 'rawdata_files');
    rawdata.files = strcat(RDfile_path, RD_file);
    rawdata.fileNames = RD_file;
    rawdata.filePaths = RDfile_path;

    % Check that the rawdata files are valid
    valid = Check_RawData(rawdata, handles);
    
    if valid == true
        % Save the changes to the rawdata_files struct
        setappdata(handles.figure1, 'rawdata_files', rawdata);
    end
end

end % function



% --- Executes on selection change in RawDataFilename_DropBox.
function RawDataFilename_DropBox_Callback(hObject, eventdata, handles)
% Refresh the preview plots
Preview_Button_Callback(handles.Preview_Button, eventdata, handles);
end % function
% --- Executes during object creation, after setting all properties.
function RawDataFilename_DropBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function



function [valid] = Check_RawData(rawdata, handles)

good_ext = 0;
if isequal(rawdata.files, '') == false
    % iscell is to check if there is more than 1 file selected
    if iscell(rawdata.files) == true
        N = numel(rawdata.files);
        good_ext = zeros(N,1);
        for i = 1:N
            good_ext(i) = strcmpi( '.txt', rawdata.files{i}(end-3:end) );
        end
    else
        good_ext = strcmpi( '.txt', rawdata.files(end-3:end) );
    end
end

% Check to see that the rawdata files are really .txt files
if all(good_ext) == true
    % The files are good
    Enable_Disable_Main(1, handles);
    valid = true;
    
    % Write the name(s) to the DropBox, I want to show only 2 folder.
    slashspots = strfind(rawdata.files, '\');

    if iscell(rawdata.files) == false        % if == false, 1 file, else, many files
        file_name = strcat( '...', rawdata.files(slashspots(end-1):end) );

        % Set the box text to be the path and name of the file.
        set(handles.RawDataFilename_DropBox, 'string', file_name);

    else    % If there are multiple workspace files

        % Define a cell array to hold all the modified names
        file_name = cell(numel(rawdata.files), 1);

        % Modify each file name
        for ii = 1:numel(rawdata.files)
            tmp_string = rawdata.files{ii}(slashspots{ii}(end-1):end);
            file_name(ii,:) = {strcat( '...', tmp_string )};
        end

        % Set the box text to be the path and name of the file.
        set(handles.RawDataFilename_DropBox, 'string', file_name);
    end
    
elseif isequal(rawdata.files, '') == true
    Enable_Disable_Main(0, handles);
    valid = false;
    set(handles.RawDataFilename_DropBox, 'string', ' ');
else
    Enable_Disable_Main(0, handles);
    valid = false;
    errordlg('One or more selected files are not valid Matlab workspaces', 'Invalid Matlab Workspace', 'modal');
    set(handles.RawDataFilename_DropBox, 'string', ' ');
end


end % function



function Enable_Disable_Main(Enable_Disable, handles)
% This is my own function which will enable/disable the main options in the
% GUI when the selected workspaces are changed.

if Enable_Disable == true
    set(handles.CompStrain_DropBox,             'Enable',    'on');
    set(handles.Filter_uv_CheckBox,             'Enable',    'on');
    if get(handles.Filter_uv_CheckBox, 'Value') == true
        set(handles.Conv1Edit,                  'Enable',    'on');
    else
        set(handles.Conv1Edit,                  'Enable',    'off');
    end
    set(handles.Filter_strains_CheckBox,        'Enable',    'on');
    if get(handles.Filter_strains_CheckBox, 'Value') == true
        set(handles.Conv2Edit,                  'Enable',    'on');
    else
        set(handles.Conv2Edit,                  'Enable',    'off');
    end
    set(handles.SaveResults_CheckBox,               'Enable',	 'on');
    if get(handles.SaveResults_CheckBox, 'Value') == true
        set(handles.TotalData_CheckBox,         'Enable',    'on');
        set(handles.IncremData_CheckBox,        'Enable',    'on');
    else
        set(handles.TotalData_CheckBox,         'Enable',    'off');
        set(handles.IncremData_CheckBox,        'Enable',    'off');
    end 
    set(handles.SaveReport_CheckBox,            'Enable',    'on');
    set(handles.SaveTotalPlots_CheckBox,        'Enable',    'on');
    if get(handles.SaveTotalPlots_CheckBox, 'Value') == true
        set(handles.PlotTotalDef_RadioButton,   'Enable',    'on');
        set(handles.PlotTotalRef_RadioButton,   'Enable',    'on');
        set(handles.SaveTotalMovie_CheckBox,    'Enable',    'on');
        set(handles.FPS_TotalEdit,              'Enable',    'on');
    else
        set(handles.PlotTotalDef_RadioButton,   'Enable',    'off');
        set(handles.PlotTotalRef_RadioButton,   'Enable',    'off');
        set(handles.SaveTotalMovie_CheckBox,    'Enable',    'off');
        set(handles.FPS_TotalEdit,              'Enable',    'off');
    end
    if get(handles.SaveTotalMovie_CheckBox, 'Value') == true && isequal( get(handles.SaveTotalMovie_CheckBox, 'Enable'), 'on' )
        set(handles.FPS_TotalEdit,              'Enable',    'on');
    else
        set(handles.FPS_TotalEdit,              'Enable',    'off');
    end
    set(handles.SaveIncremPlots_CheckBox,       'Enable',    'on');
    if get(handles.SaveIncremPlots_CheckBox, 'Value') == true
        set(handles.PlotIncremDef_RadioButton,  'Enable',    'on');
        set(handles.PlotIncremRef_RadioButton,  'Enable',    'on');
        set(handles.SaveIncremMovie_CheckBox,   'Enable',    'on');
        set(handles.FPS_IncremEdit,             'Enable',    'on');
    else
        set(handles.PlotIncremDef_RadioButton,  'Enable',    'off');
        set(handles.PlotIncremRef_RadioButton,  'Enable',    'off');
        set(handles.SaveIncremMovie_CheckBox,   'Enable',    'off');
        set(handles.FPS_IncremEdit,             'Enable',    'off');
    end
    if get(handles.SaveIncremMovie_CheckBox, 'Value') == true && isequal( get(handles.SaveIncremMovie_CheckBox, 'Enable'), 'on' )
        set(handles.FPS_IncremEdit,             'Enable',    'on');
    else
        set(handles.FPS_IncremEdit,             'Enable',    'off');
    end
    set(handles.Preview_Button,                 'Enable',    'on');
    set(handles.RunPostProcess_Button,          'Enable',    'on');
    set(handles.PreviewTotal_RadioButton,       'Enable',    'on');
    set(handles.PreviewIncrem_RadioButton,      'Enable',    'on');
    set(handles.PreviewOnRef_RadioButton,       'Enable',    'on');
    set(handles.PreviewOnDef_RadioButton,       'Enable',    'on');
    
    set(handles.Workspace_Save_CheckBox,        'Enable',    'on');
else
    set(handles.CompStrain_DropBox,             'Enable',    'off');
    set(handles.Filter_uv_CheckBox,             'Enable',    'off');
    set(handles.Conv1Edit,                      'Enable',    'off');
    set(handles.Filter_strains_CheckBox,        'Enable',    'off');
    set(handles.Conv2Edit,                      'Enable',    'off');
    set(handles.SaveResults_CheckBox,           'Enable',	 'off');
    set(handles.TotalData_CheckBox,             'Enable',    'off');
    set(handles.IncremData_CheckBox,            'Enable',    'off');
    set(handles.SaveReport_CheckBox,            'Enable',    'off');
    set(handles.SaveTotalPlots_CheckBox,        'Enable',    'off');
    set(handles.PlotTotalDef_RadioButton,       'Enable',    'off');
    set(handles.PlotTotalRef_RadioButton,       'Enable',    'off');
    set(handles.SaveTotalMovie_CheckBox,        'Enable',    'off');
    set(handles.FPS_TotalEdit,                  'Enable',    'off');
    set(handles.SaveIncremPlots_CheckBox,       'Enable',    'off');
    set(handles.PlotIncremDef_RadioButton,      'Enable',    'off');
    set(handles.PlotIncremRef_RadioButton,      'Enable',    'off');
    set(handles.SaveIncremMovie_CheckBox,       'Enable',    'off');
    set(handles.FPS_IncremEdit,                 'Enable',    'off');
    set(handles.Preview_Button,                 'Enable',    'off');
    set(handles.RunPostProcess_Button,          'Enable',    'off');
    set(handles.PreviewTotal_RadioButton,       'Enable',    'off');
    set(handles.PreviewIncrem_RadioButton,      'Enable',    'off');
    set(handles.PreviewOnRef_RadioButton,       'Enable',    'off');
    set(handles.PreviewOnDef_RadioButton,       'Enable',    'off');
    
    set(handles.Workspace_Save_CheckBox,        'Enable',    'off');
end

end % function


%******************END INPUT WORKSPACE PANEL****************************









%******************STRAIN OPTIONS PANEL****************************



% --- Executes on selection change in CompStrain_DropBox.
function CompStrain_DropBox_Callback(hObject, eventdata, handles)
val = get(hObject, 'Value');
if val == 2
    set(handles.SplineTolEdit, 'Enable', 'on');
else
    set(handles.SplineTolEdit, 'Enable', 'off');
end
end % function
% --- Executes during object creation, after setting all properties.
function CompStrain_DropBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function



% --- Executes on button press in Filter_uv_CheckBox.
function Filter_uv_CheckBox_Callback(hObject, eventdata, handles)
value = get(hObject, 'Value');
if value == true
    set(handles.Conv1Edit, 'Enable', 'on');
else
    set(handles.Conv1Edit, 'Enable', 'off');
end
end % function

% --- Executes on button press in Filter_strains_CheckBox.
function Filter_strains_CheckBox_Callback(hObject, eventdata, handles)
value = get(hObject, 'Value');
if value == true
    set(handles.Conv2Edit, 'Enable', 'on');
else
    set(handles.Conv2Edit, 'Enable', 'off');
end
end % function



function Conv1Edit_Callback(hObject, eventdata, handles)
% Determine the value that was input by the user and make sure it's a positive integer
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry) || user_entry < 1 || user_entry ~= floor(user_entry)
    errordlg('The Convolution Size for U, V filtering must be a positive integer value','Invalid Convolution Size','modal')
    postprocess_defaults = getappdata(handles.figure1, 'defaults');
    set(hObject, 'string', postprocess_defaults.Conv1);
    error_tracker.error_found = true;
    setappdata(handles.figure1, 'tracker', error_tracker);
    return;
end

% If the size is not odd, make it odd
if mod(user_entry,2) == 0
    odd_value = num2str(user_entry + 1);
    warndlg( sprintf('The UV convolution matrix size must be odd.\nThe value %s was replaced by %s',...
                                                                    num2str(user_entry), odd_value), 'Warning', 'modal');
    set(hObject, 'string', odd_value);
end
end % function
% --- Executes during object creation, after setting all properties.
function Conv1Edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function



function Conv2Edit_Callback(hObject, eventdata, handles)
% Determine the value that was input by the user and make sure it's a positive integer
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry) || user_entry < 1 || user_entry ~= floor(user_entry)
    errordlg('The Convolution Size for strain filtering must be a positive integer value','Invalid Convolution Size','modal')
    postprocess_defaults = getappdata(handles.figure1, 'defaults');
    set(hObject, 'string', postprocess_defaults.Conv1);
    error_tracker.error_found = true;
    setappdata(handles.figure1, 'tracker', error_tracker);
    return;
end

% If the size is not odd, make it odd
if mod(user_entry,2) == 0
    odd_value = num2str(user_entry + 1);
    warndlg( sprintf('The Strain convolution matrix size must be odd.\nThe value %s was replaced by %s',...
                                                                    num2str(user_entry), odd_value), 'Warning', 'modal');
    set(hObject, 'string', odd_value);
end
end % function
% --- Executes during object creation, after setting all properties.
function Conv2Edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function



function SplineTolEdit_Callback(hObject, eventdata, handles)
% Determine the value that was input by the user and make sure it's a positive integer
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry) || user_entry <= 0
    errordlg('The Tolerance for the smoothing spline must be a positive real value','Invalid Spline Tolerance','modal')
    postprocess_defaults = getappdata(handles.figure1, 'defaults');
    set(hObject, 'string', postprocess_defaults.SplineTol);
    error_tracker.error_found = true;
    setappdata(handles.figure1, 'tracker', error_tracker);
    return;
end

end % function
% --- Executes during object creation, after setting all properties.
function SplineTolEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end % function



%******************END STRAIN OPTIONS PANEL****************************






%*********************OUTPUT OPTIONS PANEL*******************************

% --- Executes on button press in SaveResults_CheckBox.
function SaveResults_CheckBox_Callback(hObject, eventdata, handles)
value = get(hObject, 'Value');
if value == true
    set(handles.TotalData_CheckBox,  'Enable', 'on');
    set(handles.IncremData_CheckBox, 'Enable', 'on');
else
    set(handles.TotalData_CheckBox,  'Enable', 'off');
    set(handles.IncremData_CheckBox, 'Enable', 'off');
end
end % function

% --- Executes on button press in TotalData_CheckBox.
function TotalData_CheckBox_Callback(hObject, eventdata, handles)
end % function

% --- Executes on button press in IncremData_CheckBox.
function IncremData_CheckBox_Callback(hObject, eventdata, handles)
end % function





% --- Executes on button press in Workspace_Save_Checkbox.
function Workspace_Save_CheckBox_Callback(hObject, eventdata, handles)
end % function




% --- Executes on button press in SaveReport_CheckBox.
function SaveReport_CheckBox_Callback(hObject, eventdata, handles)
end % function




% --- Executes on button press in SaveTotalPlots_CheckBox.
function SaveTotalPlots_CheckBox_Callback(hObject, eventdata, handles)
value = get(hObject, 'Value');
if value == true
    set(handles.PlotTotalRef_RadioButton, 'Enable', 'on');
    set(handles.PlotTotalDef_RadioButton, 'Enable', 'on');
    set(handles.SaveTotalMovie_CheckBox,  'Enable', 'on');
    if get(handles.SaveTotalMovie_CheckBox, 'Value') == true
        set(handles.FPS_TotalEdit,            'Enable', 'on');
    else
        set(handles.FPS_TotalEdit,            'Enable', 'off');
    end
else
    set(handles.PlotTotalRef_RadioButton, 'Enable', 'off');
    set(handles.PlotTotalDef_RadioButton, 'Enable', 'off');
    set(handles.SaveTotalMovie_CheckBox,  'Enable', 'off');
    set(handles.FPS_TotalEdit,            'Enable', 'off');
end
end % function



% --- Executes on button press in PlotTotalRef_RadioButton.
function PlotTotalRef_RadioButton_Callback(hObject, eventdata, handles)
set(handles.PlotTotalDef_RadioButton, 'Value', 0);
set(hObject, 'Value', 1);
end % function



% --- Executes on button press in PlotTotalDef_RadioButton.
function PlotTotalDef_RadioButton_Callback(hObject, eventdata, handles)
set(handles.PlotTotalRef_RadioButton, 'Value', 0);
set(hObject, 'Value', 1);
end % function



% --- Executes on button press in SaveTotalMovie_CheckBox.
function SaveTotalMovie_CheckBox_Callback(hObject, eventdata, handles)
value = get(hObject, 'Value');
if value == true
    set(handles.FPS_TotalEdit, 'Enable', 'on');
else
    set(handles.FPS_TotalEdit, 'Enable', 'off');
end
end % function



function FPS_TotalEdit_Callback(hObject, eventdata, handles)
% Determine the value that was input by the user and make sure it's a positive number
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry) || user_entry <= 0
    errordlg('The FPS of the total deformation movie must be a postive number','Invalid Total Deformation FPS','modal');
    postprocess_defaults = getappdata(handles.figure1, 'defaults');
    set(hObject, 'string', postprocess_defaults.FPS_Total);
    error_tracker.error_found = true;
    setappdata(handles.figure1, 'tracker', error_tracker);
    return;
end
end % function
% --- Executes during object creation, after setting all properties.
function FPS_TotalEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function



% --- Executes on button press in SaveIncremPlots_CheckBox.
function SaveIncremPlots_CheckBox_Callback(hObject, eventdata, handles)
value = get(hObject, 'Value');
if value == true
    set(handles.PlotIncremRef_RadioButton, 'Enable', 'on');
    set(handles.PlotIncremDef_RadioButton, 'Enable', 'on');
    set(handles.SaveIncremMovie_CheckBox,  'Enable', 'on');
    if get(handles.SaveIncremMovie_CheckBox, 'Value') == true
        set(handles.FPS_IncremEdit,            'Enable', 'on');
    else
        set(handles.FPS_IncremEdit,            'Enable', 'off');
    end
else
    set(handles.PlotIncremRef_RadioButton, 'Enable', 'off');
    set(handles.PlotIncremDef_RadioButton, 'Enable', 'off');
    set(handles.SaveIncremMovie_CheckBox,  'Enable', 'off');
    set(handles.FPS_IncremEdit,            'Enable', 'off');
end
end % function


% --- Executes on button press in PlotIncremRef_RadioButton.
function PlotIncremRef_RadioButton_Callback(hObject, eventdata, handles)
set(handles.PlotIncremDef_RadioButton, 'Value', 0);
set(hObject, 'Value', 1);
end % function


% --- Executes on button press in PlotIncremDef_RadioButton.
function PlotIncremDef_RadioButton_Callback(hObject, eventdata, handles)
set(handles.PlotIncremRef_RadioButton, 'Value', 0);
set(hObject, 'Value', 1);
end % function



% --- Executes on button press in SaveIncremMovie_CheckBox.
function SaveIncremMovie_CheckBox_Callback(hObject, eventdata, handles)
value = get(hObject, 'Value');
if value == true
    set(handles.FPS_IncremEdit, 'Enable', 'on');
else
    set(handles.FPS_IncremEdit, 'Enable', 'off');
end
end % function


function FPS_IncremEdit_Callback(hObject, eventdata, handles)
% Determine the value that was input by the user and make sure it's a positive number
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry) || user_entry <= 0
    errordlg('The FPS of the incremental deformation movie must be a postive number','Invalid Total Deformation FPS','modal');
    postprocess_defaults = getappdata(handles.figure1, 'defaults');
    set(hObject, 'string', postprocess_defaults.FPS_Increm);
    error_tracker.error_found = true;
    setappdata(handles.figure1, 'tracker', error_tracker);
    return;
end
end % function
% --- Executes during object creation, after setting all properties.
function FPS_IncremEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function



%*********************END OUTPUT OPTIONS PANEL*******************************










%*********************PLOT PREVIEW PANEL*******************************


% --- Executes on button press in Preview_Button.
function Preview_Button_Callback(hObject, eventdata, handles)

% Start by retrieving the rawdata files from the data application struct
rawdata = getappdata(handles.figure1, 'rawdata_files');

% Retrieve the current file in the workspace dropbox
val = get(handles.RawDataFilename_DropBox, 'Value');

% Define the rawdata file name(s)
if iscell(rawdata.files) == true
    rawdata_FileName = rawdata.files{val};
else
    rawdata_FileName = rawdata.files;
end

% The relevant workspace can now be found
RD = Load_Data( rawdata_FileName );

% Get the selected options for the plots
if get(handles.PreviewTotal_RadioButton, 'Value') == true
    Total_or_Increm = 'Total';
else
    Total_or_Increm = 'Increm';
end

if get(handles.PreviewOnRef_RadioButton, 'Value') == true
    Ref_or_Def = 'Ref';
else
    Ref_or_Def = 'Def';
end

[Results, Xgrids, Ygrids] = Compute_Strains(Total_or_Increm, RD, handles);

Show_Plots(Ref_or_Def, Results, Xgrids, Ygrids, handles, RD);


end % function



% --- Executes on button press in PreviewTotal_RadioButton.
function PreviewTotal_RadioButton_Callback(hObject, eventdata, handles)
set(handles.PreviewIncrem_RadioButton, 'Value', 0);
set(hObject, 'Value', 1);
end % function


% --- Executes on button press in PreviewIncrem_RadioButton.
function PreviewIncrem_RadioButton_Callback(hObject, eventdata, handles)
set(handles.PreviewTotal_RadioButton, 'Value', 0);
set(hObject, 'Value', 1);
end % function


% --- Executes on button press in PreviewOnRef_RadioButton.
function PreviewOnRef_RadioButton_Callback(hObject, eventdata, handles)
set(handles.PreviewOnDef_RadioButton, 'Value', 0);
set(hObject, 'Value', 1);
end % function


% --- Executes on button press in PreviewOnDef_RadioButton.
function PreviewOnDef_RadioButton_Callback(hObject, eventdata, handles)
set(handles.PreviewOnRef_RadioButton, 'Value', 0);
set(hObject, 'Value', 1);
end % function




%*********************END PLOT PREVIEW PANEL*******************************






%*********************RUN POST-PROCESSING BUTTON*******************************

% --- Executes on button press in RunPostProcess_Button.
function RunPostProcess_Button_Callback(hObject, eventdata, handles)

% Record the date and time that the run button was pushed, for naming the output folder
date_time_pstprs_run = now;
date_time_pstprs_folder = datestr(date_time_pstprs_run, 'yyyy-mm-dd_HH_MM_SS');

% Define the path where new outputs will be saved
PostProcess_folder_path = sprintf('%s\\Post-Process_Outputs_for_%s', cd, date_time_pstprs_folder);

% Start by retrieving the workspace files from the data application struct
rawdata = getappdata(handles.figure1, 'rawdata_files');

% Find out how many files there are to work with, and what directory there are in
if iscell(rawdata.files) == false
    NN = 1; % only 1 file
else
    NN = numel(rawdata.files);  % many files
end

% Define the workspace directory
%workspace_dir = workspaces.filePaths;

% Save the current directory so that we can return to it at the end
current_dir = cd;

% Retrieve the user inputs
Compute_Strain  = get(handles.CompStrain_DropBox,           'Value');

SaveResults     = get(handles.SaveResults_CheckBox,         'Value');
TotalData       = get(handles.TotalData_CheckBox,           'Value');
IncremData      = get(handles.IncremData_CheckBox,          'Value');

WORKSAVE        = get(handles.Workspace_Save_CheckBox,      'Value');

SaveReport      = get(handles.SaveReport_CheckBox,          'Value');
SaveTotalPlots  = get(handles.SaveTotalPlots_CheckBox,      'Value');
PlotTotalRef    = get(handles.PlotTotalRef_RadioButton,     'Value');
SaveTotalMovie  = get(handles.SaveTotalMovie_CheckBox,      'Value');
FPS_Total       = str2double(get(handles.FPS_TotalEdit,     'string'));
SaveIncremPlots = get(handles.SaveIncremPlots_CheckBox,     'Value');
PlotIncremRef   = get(handles.PlotIncremRef_RadioButton,    'Value');
SaveIncremMovie = get(handles.SaveIncremMovie_CheckBox,     'Value');
FPS_Increm      = str2double(get(handles.FPS_IncremEdit,    'string'));

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



%*********************END RUN POST-PROCESSING BUTTON*******************************



%************************************************
%************************************************
%************************************************
%************************************************
%************************************************
%************************************************
%************************************************
%************************************************
%************************************************
%************************************************
%************************************************
%************************************************
%************************************************
%************************************************




%*********************EXTRA FUNCTION FOR PREVIEW AND RUN BUTTONS*******************************

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






% Save_Plots will use the results from Compute_Strains and display, format,
% and save the graphs as .jpg files. This function is what causes windows
% to pop-up during the Post-Processing "RUN"
function Save_Plots(Results, Xgrids, Ygrids, RD, handles, total_or_increm, PLOT_on_REF)

% Rename the inputs for clarity
Xgrid_C         = Xgrids{1};
Xgrid_UV        = Xgrids{2};
Xgrid_EPSxx     = Xgrids{3};
Xgrid_EPSyy     = Xgrids{4};
Xgrid_EPS_OMxy  = Xgrids{5};
clear Xgrids

Ygrid_C         = Ygrids{1};
Ygrid_UV        = Ygrids{2};
Ygrid_EPSxx     = Ygrids{3};
Ygrid_EPSyy     = Ygrids{4};
Ygrid_EPS_OMxy  = Ygrids{5};
clear Ygrids

DISP_U          = Results{1};
DISP_V          = Results{2};
CorrQual        = Results{3};
EPSxx_filtered  = Results{4};
EPSyy_filtered  = Results{5};
EPSxy_filtered  = Results{6};
OMxy_filtered   = Results{7};
EPS1            = Results{8};
EPS2            = Results{9};
THETA           = Results{10};
VolStrain       = Results{11};
clear Results


if strcmpi('Increm', total_or_increm) == true
    s = 'Incremental';
else
    s = 'Total';
end

output_folder_path = strcat(RD.PostProcess_folder_path, '\', s, ' Deformation Plots');

if PLOT_on_REF == true
    
    % Plot all the graphs on the reference image
    % u
    figure; surf(Xgrid_UV, Ygrid_UV, DISP_U, 'LineStyle', 'none');
    s_tmp = sprintf('%s Displacement u', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([Xgrid_UV(1,1), Xgrid_UV(end,end)]);    ylim([Ygrid_UV(1,1), Ygrid_UV(end,end)]);
    xlabel('x (pixels)', 'FontName', 'Arial', 'FontSize', 14); ylabel('y (pixels)', 'FontName', 'Arial', 'FontSize', 14);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, s_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', s_tmp, '\u', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % v
    figure; surf(Xgrid_UV, Ygrid_UV, DISP_V, 'LineStyle', 'none');
    s_tmp = sprintf('%s Displacement v', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([Xgrid_UV(1,1), Xgrid_UV(end,end)]);    ylim([Ygrid_UV(1,1), Ygrid_UV(end,end)]);
    xlabel('x (pixels)', 'FontName', 'Arial', 'FontSize', 14); ylabel('y (pixels)', 'FontName', 'Arial', 'FontSize', 14);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, s_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', s_tmp, '\v', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % C
    figure; surf(Xgrid_C, Ygrid_C, CorrQual, 'LineStyle', 'none');
    s_tmp = sprintf('%s Correlation Quality', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([Xgrid_C(1,1), Xgrid_C(end,end)]);    ylim([Ygrid_C(1,1), Ygrid_C(end,end)]);
    xlabel('x (pixels)', 'FontName', 'Arial', 'FontSize', 14); ylabel('y (pixels)', 'FontName', 'Arial', 'FontSize', 14);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, s_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', s_tmp, '\C', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
 
    % EPSxx
    figure; surf(Xgrid_EPSxx, Ygrid_EPSxx, EPSxx_filtered, 'LineStyle', 'none');
    s_tmp = strcat( s, '  \epsilon_x_x');
    ss_tmp = sprintf('%s Epsilon xx', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([Xgrid_EPSxx(1,1), Xgrid_EPSxx(end,end)]);    ylim([Ygrid_EPSxx(1,1), Ygrid_EPSxx(end,end)]);
    xlabel('x (pixels)', 'FontName', 'Arial', 'FontSize', 14); ylabel('y (pixels)', 'FontName', 'Arial', 'FontSize', 14);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, ss_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', ss_tmp, '\EpsXX', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % EPSyy
    figure; surf(Xgrid_EPSyy, Ygrid_EPSyy, EPSyy_filtered, 'LineStyle', 'none');
    s_tmp = strcat( s, '  \epsilon_y_y');
    ss_tmp = sprintf('%s Epsilon yy', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([Xgrid_EPSyy(1,1), Xgrid_EPSyy(end,end)]);    ylim([Ygrid_EPSyy(1,1), Ygrid_EPSyy(end,end)]);
    xlabel('x (pixels)', 'FontName', 'Arial', 'FontSize', 14); ylabel('y (pixels)', 'FontName', 'Arial', 'FontSize', 14);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, ss_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', ss_tmp, '\EpsYY', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % EPSxy
    figure; surf(Xgrid_EPS_OMxy, Ygrid_EPS_OMxy, EPSxy_filtered, 'LineStyle', 'none');
    s_tmp = strcat( s, '  \epsilon_x_y');
    ss_tmp = sprintf('%s Epsilon xy', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([Xgrid_EPS_OMxy(1,1), Xgrid_EPS_OMxy(end,end)]);    ylim([Ygrid_EPS_OMxy(1,1), Ygrid_EPS_OMxy(end,end)]);
    xlabel('x (pixels)', 'FontName', 'Arial', 'FontSize', 14); ylabel('y (pixels)', 'FontName', 'Arial', 'FontSize', 14);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, ss_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', ss_tmp, '\EpsXY', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % OMExy
    figure; surf(Xgrid_EPS_OMxy, Ygrid_EPS_OMxy, OMxy_filtered, 'LineStyle', 'none');
    s_tmp = strcat( s, '  \omega_x_y');
    ss_tmp = sprintf('%s Omega xy', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([Xgrid_EPS_OMxy(1,1), Xgrid_EPS_OMxy(end,end)]);    ylim([Ygrid_EPS_OMxy(1,1), Ygrid_EPS_OMxy(end,end)]);
    xlabel('x (pixels)', 'FontName', 'Arial', 'FontSize', 14); ylabel('y (pixels)', 'FontName', 'Arial', 'FontSize', 14);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, ss_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', ss_tmp, '\OmeXY', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % EPS1
    figure; surf(Xgrid_EPS_OMxy, Ygrid_EPS_OMxy, EPS1, 'LineStyle', 'none');
    s_tmp = strcat( s, '  \epsilon_1');
    ss_tmp = sprintf('%s Epsilon 1', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([Xgrid_EPS_OMxy(1,1), Xgrid_EPS_OMxy(end,end)]);    ylim([Ygrid_EPS_OMxy(1,1), Ygrid_EPS_OMxy(end,end)]);
    xlabel('x (pixels)', 'FontName', 'Arial', 'FontSize', 14); ylabel('y (pixels)', 'FontName', 'Arial', 'FontSize', 14);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, ss_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', ss_tmp, '\EPS1', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % EPS2
    figure; surf(Xgrid_EPS_OMxy, Ygrid_EPS_OMxy, EPS2, 'LineStyle', 'none');
    s_tmp = strcat( s, '  \epsilon_2');
    ss_tmp = sprintf('%s Epsilon 2', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([Xgrid_EPS_OMxy(1,1), Xgrid_EPS_OMxy(end,end)]);    ylim([Ygrid_EPS_OMxy(1,1), Ygrid_EPS_OMxy(end,end)]);
    xlabel('x (pixels)', 'FontName', 'Arial', 'FontSize', 14); ylabel('y (pixels)', 'FontName', 'Arial', 'FontSize', 14);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, ss_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', ss_tmp, '\EPS2', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % THETA
    figure; surf(Xgrid_EPS_OMxy, Ygrid_EPS_OMxy, THETA, 'LineStyle', 'none');
    s_tmp = strcat( s, '  \theta');
    ss_tmp = sprintf('%s Theta', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([Xgrid_EPS_OMxy(1,1), Xgrid_EPS_OMxy(end,end)]);    ylim([Ygrid_EPS_OMxy(1,1), Ygrid_EPS_OMxy(end,end)]);
    xlabel('x (pixels)', 'FontName', 'Arial', 'FontSize', 14); ylabel('y (pixels)', 'FontName', 'Arial', 'FontSize', 14);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, ss_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', ss_tmp, '\Theta', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % VolStrain
    figure; surf(Xgrid_EPS_OMxy, Ygrid_EPS_OMxy, VolStrain, 'LineStyle', 'none');
    s_tmp = strcat( s, '  \epsilon_v');
    ss_tmp = sprintf('%s Vol_Strain', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([Xgrid_EPS_OMxy(1,1), Xgrid_EPS_OMxy(end,end)]);    ylim([Ygrid_EPS_OMxy(1,1), Ygrid_EPS_OMxy(end,end)]);
    xlabel('x (pixels)', 'FontName', 'Arial', 'FontSize', 14); ylabel('y (pixels)', 'FontName', 'Arial', 'FontSize', 14);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, ss_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', ss_tmp, '\VolStrain', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));

else % PLOT_on_DEF
    
    % First, begin by defining the grid points on the deformed object
    % Define the deformed positions
    X_star_C = reshape( Xgrid_C + RD.TOTAL_DEFORMATIONS(:,:,1), numel(Xgrid_C), 1 );
    Y_star_C = reshape( Ygrid_C + RD.TOTAL_DEFORMATIONS(:,:,2), numel(Ygrid_C), 1 );
    [defXgrid_C, defYgrid_C] = Define_Deformed_Grid(X_star_C, Y_star_C, RD);
    
    X_star_UV = reshape( Xgrid_UV + DISP_U, numel(Xgrid_UV), 1 );
    Y_star_UV = reshape( Ygrid_UV + DISP_V, numel(Ygrid_UV), 1 );
    [defXgrid_UV, defYgrid_UV] = Define_Deformed_Grid(X_star_UV, Y_star_UV, RD);
    [M,N] = size(Xgrid_UV);
    
    % EPSxx
    [m,n] = size(Xgrid_EPSxx);
    if all( [M,N] == [m,n] ) % spline strains, with no strain filtering
        X_star_EPSxx = X_star_UV;
        Y_star_EPSxx = Y_star_UV;
        defXgrid_EPSxx = defXgrid_UV;
        defYgrid_EPSxx = defYgrid_UV;
    elseif all( mod([M,N], 2) == mod([m,n], 2) ) % spline strains, with strain filtering
        edge = floor((M-m)/2);
        X_star_EPSxx = reshape( Xgrid_EPSxx + DISP_U(1+edge:end-edge, 1+edge:end-edge), numel(Xgrid_EPSxx), 1);
        Y_star_EPSxx = reshape( Ygrid_EPSxx + DISP_V(1+edge:end-edge, 1+edge:end-edge), numel(Ygrid_EPSxx), 1);
        [defXgrid_EPSxx, defYgrid_EPSxx] = Define_Deformed_Grid(X_star_EPSxx, Y_star_EPSxx, RD);
    else % finite diff strains, with/without strain filtering
        edge = floor((M-m)/2);
        X_star_EPSxx = reshape( Xgrid_EPSxx + DISP_U(1+edge:end-edge, 1+edge:end-edge-1), numel(Xgrid_EPSxx), 1);
        Y_star_EPSxx = reshape( Ygrid_EPSxx + DISP_V(1+edge:end-edge, 1+edge:end-edge-1), numel(Ygrid_EPSxx), 1);
        [defXgrid_EPSxx, defYgrid_EPSxx] = Define_Deformed_Grid(X_star_EPSxx, Y_star_EPSxx, RD);
    end
    
    % EPSyy
    [m,n] = size(Xgrid_EPSyy);
    if all( [M,N] == [m,n] ) % spline strains, with no strain filtering
        X_star_EPSyy = X_star_UV;
        Y_star_EPSyy = Y_star_UV;
        defXgrid_EPSyy = defXgrid_UV;
        defYgrid_EPSyy = defYgrid_UV;
    elseif all( mod([M,N], 2) == mod([m,n], 2) ) % spline strains, with strain filtering
        edge = floor((M-m)/2);
        X_star_EPSyy = reshape( Xgrid_EPSyy + DISP_U(1+edge:end-edge, 1+edge:end-edge), numel(Xgrid_EPSyy), 1);
        Y_star_EPSyy = reshape( Ygrid_EPSyy + DISP_V(1+edge:end-edge, 1+edge:end-edge), numel(Ygrid_EPSyy), 1);
        [defXgrid_EPSyy, defYgrid_EPSyy] = Define_Deformed_Grid(X_star_EPSyy, Y_star_EPSyy, RD);
    else % finite diff strains, with/without strain filtering
        edge = floor((M-m)/2);
        X_star_EPSyy = reshape( Xgrid_EPSyy + DISP_U(1+edge:end-edge-1, 1+edge:end-edge), numel(Xgrid_EPSyy), 1);
        Y_star_EPSyy = reshape( Ygrid_EPSyy + DISP_V(1+edge:end-edge-1, 1+edge:end-edge), numel(Ygrid_EPSyy), 1);
        [defXgrid_EPSyy, defYgrid_EPSyy] = Define_Deformed_Grid(X_star_EPSyy, Y_star_EPSyy, RD);
    end
    
    % EPSxy and OMxy
    [m,n] = size(Xgrid_EPS_OMxy);
    if all( [M,N] == [m,n] ) % spline strains, with no strain filtering
        X_star_EPS_OMxy = X_star_UV;
        Y_star_EPS_OMxy = Y_star_UV;
        defXgrid_EPS_OMxy = defXgrid_UV;
        defYgrid_EPS_OMxy = defYgrid_UV;
    elseif all( mod([M,N], 2) == mod([m,n], 2) ) % spline strains, with strain filtering
        edge = floor((M-m)/2);
        X_star_EPS_OMxy = reshape( Xgrid_EPS_OMxy + DISP_U(1+edge:end-edge, 1+edge:end-edge), numel(Xgrid_EPS_OMxy), 1);
        Y_star_EPS_OMxy = reshape( Ygrid_EPS_OMxy + DISP_V(1+edge:end-edge, 1+edge:end-edge), numel(Ygrid_EPS_OMxy), 1);
        [defXgrid_EPS_OMxy, defYgrid_EPS_OMxy] = Define_Deformed_Grid(X_star_EPS_OMxy, Y_star_EPS_OMxy, RD);
    else % finite diff strains, with/without strain filtering
        edge = floor((M-m)/2);
        X_star_EPS_OMxy = reshape( Xgrid_EPS_OMxy + DISP_U(1+edge:end-edge-1, 1+edge:end-edge-1), numel(Xgrid_EPS_OMxy), 1);
        Y_star_EPS_OMxy = reshape( Ygrid_EPS_OMxy + DISP_V(1+edge:end-edge-1, 1+edge:end-edge-1), numel(Ygrid_EPS_OMxy), 1);
        [defXgrid_EPS_OMxy, defYgrid_EPS_OMxy] = Define_Deformed_Grid(X_star_EPS_OMxy, Y_star_EPS_OMxy, RD);
    end
    
    % Reshape the Results into vectors
    vCorrQual           = reshape(CorrQual, numel(CorrQual), 1);
    vDISP_U             = reshape(DISP_U, numel(DISP_U), 1);
    vDISP_V             = reshape(DISP_V, numel(DISP_V), 1);
    vEPSxx_filtered     = reshape(EPSxx_filtered, numel(EPSxx_filtered), 1);
    vEPSyy_filtered     = reshape(EPSyy_filtered, numel(EPSyy_filtered), 1);
    vEPSxy_filtered     = reshape(EPSxy_filtered, numel(EPSxy_filtered), 1);
    vOMxy_filtered      = reshape(OMxy_filtered, numel(OMxy_filtered), 1);
    vEPS1               = reshape(EPS1, numel(EPS1), 1);
    vEPS2               = reshape(EPS2, numel(EPS2), 1);
    vTHETA              = reshape(THETA, numel(THETA), 1);
    vVolStrain          = reshape(VolStrain, numel(VolStrain), 1);
    
    % Now, using the function griddata, establish grid values for the deformed object
    
    % C
    def_CorrQual        = griddata(X_star_C,        Y_star_C,       vCorrQual,       defXgrid_C,         defYgrid_C );
    % U
    def_DISP_U          = griddata(X_star_UV,       Y_star_UV,      vDISP_U,         defXgrid_UV,        defYgrid_UV );
    % V
    def_DISP_V          = griddata(X_star_UV,       Y_star_UV,      vDISP_V,         defXgrid_UV,        defYgrid_UV );
    % EPSxx
    def_EPSxx_filtered  = griddata(X_star_EPSxx,    Y_star_EPSxx,   vEPSxx_filtered, defXgrid_EPSxx,     defYgrid_EPSxx );
    % EPSyy
    def_EPSyy_filtered  = griddata(X_star_EPSyy,    Y_star_EPSyy,   vEPSyy_filtered, defXgrid_EPSyy,     defYgrid_EPSyy );
    % EPSxy
    def_EPSxy_filtered  = griddata(X_star_EPS_OMxy, Y_star_EPS_OMxy,vEPSxy_filtered, defXgrid_EPS_OMxy,  defYgrid_EPS_OMxy );
    % OMxy
    def_OMxy_filtered   = griddata(X_star_EPS_OMxy, Y_star_EPS_OMxy,vOMxy_filtered,  defXgrid_EPS_OMxy,  defYgrid_EPS_OMxy );
    % EPS1
    def_EPS1            = griddata(X_star_EPS_OMxy, Y_star_EPS_OMxy,vEPS1,           defXgrid_EPS_OMxy,  defYgrid_EPS_OMxy );
    % EPS2
    def_EPS2            = griddata(X_star_EPS_OMxy, Y_star_EPS_OMxy,vEPS2,           defXgrid_EPS_OMxy,  defYgrid_EPS_OMxy );
    % THETA
    def_THETA           = griddata(X_star_EPS_OMxy, Y_star_EPS_OMxy,vTHETA,          defXgrid_EPS_OMxy,  defYgrid_EPS_OMxy );
    % VolStrain
    def_VolStrain       = griddata(X_star_EPS_OMxy, Y_star_EPS_OMxy,vVolStrain,      defXgrid_EPS_OMxy,  defYgrid_EPS_OMxy );
    
    
    % Plot all the graphs on the deformed image
    % u
    figure; surf(defXgrid_UV, defYgrid_UV, def_DISP_U, 'LineStyle', 'none');
    s_tmp = sprintf('%s Displacement u (on def object)', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([defXgrid_UV(1,1), defXgrid_UV(end,end)]);    ylim([defYgrid_UV(1,1), defYgrid_UV(end,end)]);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, s_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', s_tmp, '\u', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % v
    figure; surf(defXgrid_UV, defYgrid_UV, def_DISP_V, 'LineStyle', 'none');
    s_tmp = sprintf('%s Displacement v (on def object)', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([defXgrid_UV(1,1), defXgrid_UV(end,end)]);    ylim([defYgrid_UV(1,1), defYgrid_UV(end,end)]);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, s_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', s_tmp, '\v', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % C
    figure; surf(defXgrid_C, defYgrid_C, def_CorrQual, 'LineStyle', 'none');
    s_tmp = sprintf('%s Correlation Quality (on def object)', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([defXgrid_C(1,1), defXgrid_C(end,end)]);    ylim([defYgrid_C(1,1), defYgrid_C(end,end)]);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, s_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', s_tmp, '\C', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
 
    % EPSxx
    figure; surf(defXgrid_EPSxx, defYgrid_EPSxx, def_EPSxx_filtered, 'LineStyle', 'none');
    s_tmp = strcat( s, '  \epsilon_x_x (on def object)');
    ss_tmp = sprintf('%s Epsilon xx (on def object)', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([defXgrid_EPSxx(1,1), defXgrid_EPSxx(end,end)]);    ylim([defYgrid_EPSxx(1,1), defYgrid_EPSxx(end,end)]);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, ss_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', ss_tmp, '\EpsXX', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % EPSyy
    figure; surf(defXgrid_EPSyy, defYgrid_EPSyy, def_EPSyy_filtered, 'LineStyle', 'none');
    s_tmp = strcat( s, '  \epsilon_y_y (on def object)');
    ss_tmp = sprintf('%s Epsilon yy (on def object)', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([defXgrid_EPSyy(1,1), defXgrid_EPSyy(end,end)]);    ylim([defYgrid_EPSyy(1,1), defYgrid_EPSyy(end,end)]);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, ss_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', ss_tmp, '\EpsYY', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % EPSxy
    figure; surf(defXgrid_EPS_OMxy, defYgrid_EPS_OMxy, def_EPSxy_filtered, 'LineStyle', 'none');
    s_tmp = strcat( s, '  \epsilon_x_y (on def object)');
    ss_tmp = sprintf('%s Epsilon xy (on def object)', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([defXgrid_EPS_OMxy(1,1), defXgrid_EPS_OMxy(end,end)]);    ylim([defYgrid_EPS_OMxy(1,1), defYgrid_EPS_OMxy(end,end)]);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, ss_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', ss_tmp, '\EpsXY', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % OMExy
    figure; surf(defXgrid_EPS_OMxy, defYgrid_EPS_OMxy, def_OMxy_filtered, 'LineStyle', 'none');
    s_tmp = strcat( s, '  \omega_x_y (on def object)');
    ss_tmp = sprintf('%s Omega xy (on def object)', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([defXgrid_EPS_OMxy(1,1), defXgrid_EPS_OMxy(end,end)]);    ylim([defYgrid_EPS_OMxy(1,1), defYgrid_EPS_OMxy(end,end)]);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, ss_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', ss_tmp, '\OmeXY', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % EPS1
    figure; surf(defXgrid_EPS_OMxy, defYgrid_EPS_OMxy, def_EPS1, 'LineStyle', 'none');
    s_tmp = strcat( s, '  \epsilon_1 (on def object)');
    ss_tmp = sprintf('%s Epsilon 1 (on def object)', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([defXgrid_EPS_OMxy(1,1), defXgrid_EPS_OMxy(end,end)]);    ylim([defYgrid_EPS_OMxy(1,1), defYgrid_EPS_OMxy(end,end)]);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, ss_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', ss_tmp, '\EPS1', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % EPS2
    figure; surf(defXgrid_EPS_OMxy, defYgrid_EPS_OMxy, def_EPS2, 'LineStyle', 'none');
    s_tmp = strcat( s, '  \epsilon_2 (on def object)');
    ss_tmp = sprintf('%s Epsilon 2 (on def object)', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([defXgrid_EPS_OMxy(1,1), defXgrid_EPS_OMxy(end,end)]);    ylim([defYgrid_EPS_OMxy(1,1), defYgrid_EPS_OMxy(end,end)]);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, ss_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', ss_tmp, '\EPS2', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % THETA
    figure; surf(defXgrid_EPS_OMxy, defYgrid_EPS_OMxy, def_THETA, 'LineStyle', 'none');
    s_tmp = strcat( s, '  \theta (on def object)');
    ss_tmp = sprintf('%s Theta (on def object)', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([defXgrid_EPS_OMxy(1,1), defXgrid_EPS_OMxy(end,end)]);    ylim([defYgrid_EPS_OMxy(1,1), defYgrid_EPS_OMxy(end,end)]);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, ss_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', ss_tmp, '\Theta', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
    % VolStrain
    figure; surf(defXgrid_EPS_OMxy, defYgrid_EPS_OMxy, def_VolStrain, 'LineStyle', 'none');
    s_tmp = strcat( s, '  \epsilon_v (on def object)');
    ss_tmp = sprintf('%s Vol_Strain (on def object)', s);
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([defXgrid_EPS_OMxy(1,1), defXgrid_EPS_OMxy(end,end)]);    ylim([defYgrid_EPS_OMxy(1,1), defYgrid_EPS_OMxy(end,end)]);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
    [tmp1, tmp2, tmp3] = mkdir(output_folder_path, ss_tmp); 
    Output_pic_name = strcat(output_folder_path, '\', ss_tmp, '\VolStrain', RD.date_time_short, '.jpg');
    saveas(gcf, Output_pic_name);
    close(findobj('Name',''));
    
end % if PLOT_on_REF

end % function




% This function will help define a deformed grid on which to use griddata
% for plotting results on the deformed object, rather than the reference.
function [defXgrid, defYgrid] = Define_Deformed_Grid(X_star, Y_star, RD)

% Define a grid based on the deformed positions
%(use + - 1 to safely contain all points within the grid)
Xp_first = floor(min(min( X_star ))) - 1;
Xp_last  = floor(max(max( X_star ))) + 1;
Yp_first = floor(min(min( Y_star ))) - 1;
Yp_last  = floor(max(max( Y_star ))) + 1;

% Compute number of subsets
num_subsets_X = floor( (Xp_last-Xp_first)/RD.subset_space ) + 1;
num_subsets_Y = floor( (Yp_last-Yp_first)/RD.subset_space ) + 1;

% Define the X and Y coordinates of each subset center
mesh_col = Xp_first:RD.subset_space:(num_subsets_X-1)*RD.subset_space+Xp_first;
mesh_row = Yp_first:RD.subset_space:(num_subsets_Y-1)*RD.subset_space+Yp_first;

% Create a grid to represent the subset centers of the current correlation
[defXgrid, defYgrid] = meshgrid( mesh_col, mesh_row );

end % function







% This function will take a raw data text file and load the values stored
% within into a struct named RD ("Raw Data"). This struct is used in many
% other functions.
function RD = Load_Data(file_name)

% Open the raw data file
file_id = fopen(file_name, 'rt');

% The first lines of the raw data file should be dates with the following formats
% "July 20, 2007 - 18:24:55"   and  " 2007-07-20, 18'24'55
reader = textscan(file_id, '%s%s%s%s', 1, 'delimiter', '"');
RD.date_time_long = cell2mat(reader{2});
RD.date_time_short = cell2mat(reader{4});
clear reader

% The next raw file line says how the images were compared (Regular DIC, or Incremental DIC)
reader = textscan(file_id, '%s', 1);
if isequal(cell2mat(reader{1}), 'Regular')
    RD.do_incremental = 0;
elseif isequal(cell2mat(reader{1}), 'Incremental')
    RD.do_incremental = 1;
end
clear reader

% The raw file then writes a row with all the names of the variables.
reader = textscan(file_id, '%s', 3, 'delimiter', '\n');
var_names = textscan(reader{1,1}{3,1}, '%s', 'delimiter', ',');
clear reader

% Now the values for all these are stored in the rest of the file create a
% format based on how many variables were saved
var_format = '';
for i = 1:numel(var_names{1})
    var_format = strcat(var_format, '%n');
end
reader = textscan(file_id, var_format, 'delimiter', ',');

% Since the first column can be shorter than later ones, define when the NaNs start appearing
orig_end = numel( find(isfinite( reader{1,1} )));


% Now we can redefine values we had before
xp_first = reader{1,1}(1,1); 
xp_last = reader{1,1}(orig_end,1);
yp_first = reader{1,2}(1,1);
yp_last = reader{1,2}(orig_end, 1);

subset_space = reader{1,1}(2) - reader{1,1}(1);
if subset_space < 1
    subset_space = reader{1,2}(2) - reader{1,2}(1);
end

% Compute useful values
num_subsets_X = floor( (xp_last-xp_first)/subset_space ) + 1;
num_subsets_Y = floor( (yp_last-yp_first)/subset_space ) + 1;

if numel(var_names{1}) < 20 % 0th order raw data file
    % Retrieve the results for the original grid and make them into matrices (not vectors)
    RD.orig_gridX = reshape( reader{1,1}(1:orig_end), num_subsets_Y, num_subsets_X);
    RD.orig_gridY = reshape( reader{1,2}(1:orig_end), num_subsets_Y, num_subsets_X);
    TOTAL_DEFORMATIONS(:,:,1) = reshape( reader{1,3}(1:orig_end), num_subsets_Y, num_subsets_X );
    TOTAL_DEFORMATIONS(:,:,2) = reshape( reader{1,4}(1:orig_end), num_subsets_Y, num_subsets_X );
    TOTAL_DEFORMATIONS(:,:,3) = reshape( reader{1,5}(1:orig_end), num_subsets_Y, num_subsets_X );
    RD.TOTAL_DEFORMATIONS = TOTAL_DEFORMATIONS;
    INCREM_DEFORMATIONS(:,:,1) = reshape( reader{1,6}(1:orig_end), num_subsets_Y, num_subsets_X );
    INCREM_DEFORMATIONS(:,:,2) = reshape( reader{1,7}(1:orig_end), num_subsets_Y, num_subsets_X );
    INCREM_DEFORMATIONS(:,:,3) = reshape( reader{1,5}(1:orig_end), num_subsets_Y, num_subsets_X );
    RD.INCREM_DEFORMATIONS = INCREM_DEFORMATIONS;

    % Do the current values - NOTE, the following are not always the same as above
    Xp_first = reader{1,9}(1,1); 
    Xp_last = reader{1,9}(end,end);
    Yp_first = reader{1,10}(1,1);
    Yp_last = reader{1,10}(end, end);

    % Compute useful values
    num_subsets_X = floor( (Xp_last-Xp_first)/subset_space ) + 1;
    num_subsets_Y = floor( (Yp_last-Yp_first)/subset_space ) + 1;

    % Retrieve the results for the latest grid and make them into matrices (not vectors)
    RD.X_def_grid = reshape( reader{1,9}, num_subsets_Y, num_subsets_X );
    RD.Y_def_grid = reshape( reader{1,10}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,1) = reshape( reader{1,11}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,2) = reshape( reader{1,12}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,3) = reshape( reader{1,13}, num_subsets_Y, num_subsets_X );
    RD.DEFORMATION_PARAMETERS = DEFORMATION_PARAMETERS;
    
    % Store that this is a zeroth order DIC
    RD.Subset_Deform_Order = 0;
    
else % 1st order raw data file
    % Retrieve the results for the original grid and make them into matrices (not vectors)
    RD.orig_gridX = reshape( reader{1,1}(1:orig_end), num_subsets_Y, num_subsets_X);
    RD.orig_gridY = reshape( reader{1,2}(1:orig_end), num_subsets_Y, num_subsets_X);
    TOTAL_DEFORMATIONS(:,:,1) = reshape( reader{1,3}(1:orig_end), num_subsets_Y, num_subsets_X );
    TOTAL_DEFORMATIONS(:,:,2) = reshape( reader{1,4}(1:orig_end), num_subsets_Y, num_subsets_X );  
    TOTAL_DEFORMATIONS(:,:,3) = reshape( reader{1,6}(1:orig_end), num_subsets_Y, num_subsets_X );
    TOTAL_DEFORMATIONS(:,:,4) = reshape( reader{1,7}(1:orig_end), num_subsets_Y, num_subsets_X );
    TOTAL_DEFORMATIONS(:,:,5) = reshape( reader{1,8}(1:orig_end), num_subsets_Y, num_subsets_X );
    TOTAL_DEFORMATIONS(:,:,6) = reshape( reader{1,9}(1:orig_end), num_subsets_Y, num_subsets_X );
    TOTAL_DEFORMATIONS(:,:,7) = reshape( reader{1,5}(1:orig_end), num_subsets_Y, num_subsets_X );
    RD.TOTAL_DEFORMATIONS = TOTAL_DEFORMATIONS;
    INCREM_DEFORMATIONS(:,:,1) = reshape( reader{1,10}(1:orig_end), num_subsets_Y, num_subsets_X );
    INCREM_DEFORMATIONS(:,:,2) = reshape( reader{1,11}(1:orig_end), num_subsets_Y, num_subsets_X );
    INCREM_DEFORMATIONS(:,:,3) = reshape( reader{1,12}(1:orig_end), num_subsets_Y, num_subsets_X );
    INCREM_DEFORMATIONS(:,:,4) = reshape( reader{1,13}(1:orig_end), num_subsets_Y, num_subsets_X );
    INCREM_DEFORMATIONS(:,:,5) = reshape( reader{1,14}(1:orig_end), num_subsets_Y, num_subsets_X );
    INCREM_DEFORMATIONS(:,:,6) = reshape( reader{1,15}(1:orig_end), num_subsets_Y, num_subsets_X );
    INCREM_DEFORMATIONS(:,:,7) = reshape( reader{1,5}(1:orig_end), num_subsets_Y, num_subsets_X );
    RD.INCREM_DEFORMATIONS = INCREM_DEFORMATIONS;

    % Do the current values - NOTE, the following are not always the same as above
    Xp_first = reader{1,17}(1,1); 
    Xp_last = reader{1,17}(end,end);
    Yp_first = reader{1,18}(1,1);
    Yp_last = reader{1,18}(end, end);

    % Compute useful values
    num_subsets_X = floor( (Xp_last-Xp_first)/subset_space ) + 1;
    num_subsets_Y = floor( (Yp_last-Yp_first)/subset_space ) + 1;

    % Retrieve the results for the latest grid and make them into matrices (not vectors)
    RD.X_def_grid = reshape( reader{1,17}, num_subsets_Y, num_subsets_X );
    RD.Y_def_grid = reshape( reader{1,18}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,1) = reshape( reader{1,19}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,2) = reshape( reader{1,20}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,3) = reshape( reader{1,22}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,4) = reshape( reader{1,23}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,5) = reshape( reader{1,24}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,6) = reshape( reader{1,25}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,7) = reshape( reader{1,21}, num_subsets_Y, num_subsets_X );
    RD.DEFORMATION_PARAMETERS = DEFORMATION_PARAMETERS;
    
    % Store that this is a 1st order DIC
    RD.Subset_Deform_Order = 1;
end

% Compute the subset spacing using two points
RD.subset_space = subset_space;

fclose(file_id);

end % function



% Show_Plots prepares and displays the plots in the Preview Panel. This allows for
% qualitativly reviewing the effects of filters/tolerances on the strain
% computations
function Show_Plots(Ref_or_Def, Results, Xgrids, Ygrids, handles, RD)

% Rename the outputs for clarity
Xgrid_C         = Xgrids{1};
Xgrid_UV        = Xgrids{2};
Xgrid_EPSxx     = Xgrids{3};
Xgrid_EPSyy     = Xgrids{4};
Xgrid_EPS_OMxy  = Xgrids{5};
clear Xgrids

Ygrid_C         = Ygrids{1};
Ygrid_UV        = Ygrids{2};
Ygrid_EPSxx     = Ygrids{3};
Ygrid_EPSyy     = Ygrids{4};
Ygrid_EPS_OMxy  = Ygrids{5};
clear Ygrids

DISP_U          = Results{1};
DISP_V          = Results{2};
CorrQual        = Results{3};
EPSxx_filtered  = Results{4};
EPSyy_filtered  = Results{5};
EPSxy_filtered  = Results{6};
OMxy_filtered   = Results{7};
clear Results

if isequal(Ref_or_Def, 'Ref') == true

    % Plot all the graphs
    axes(handles.DispU_Plot);
    surf(Xgrid_UV, Ygrid_UV, DISP_U, 'LineStyle', 'none');
    view(0,90); 
    xlim([Xgrid_UV(1,1), Xgrid_UV(end,end)]);    ylim([Ygrid_UV(1,1), Ygrid_UV(end,end)]);
    set(gca,'Visible', 'off', 'YDir', 'reverse', 'DataAspectRatio', [10000 10000 1]);
    

    axes(handles.DispV_Plot);
    surf(Xgrid_UV, Ygrid_UV, DISP_V, 'LineStyle', 'none');
    view(0,90);
    xlim([Xgrid_UV(1,1), Xgrid_UV(end,end)]);    ylim([Ygrid_UV(1,1), Ygrid_UV(end,end)]);
    set(gca,'Visible', 'off', 'YDir', 'reverse', 'DataAspectRatio', [10000 10000 1]);
    

    axes(handles.CorrQual_Plot);
    surf(Xgrid_C, Ygrid_C, CorrQual, 'LineStyle', 'none');
    view(0,90);
    xlim([Xgrid_C(1,1), Xgrid_C(end,end)]);    ylim([Ygrid_C(1,1), Ygrid_C(end,end)]);
    set(gca,'Visible', 'off', 'YDir', 'reverse', 'DataAspectRatio', [10000 10000 1]);
    
    
    axes(handles.EpsXX_Plot);
    surf(Xgrid_EPSxx, Ygrid_EPSxx, EPSxx_filtered, 'LineStyle', 'none');
    view(0,90);
    xlim([Xgrid_EPSxx(1,1), Xgrid_EPSxx(end,end)]);    ylim([Ygrid_EPSxx(1,1), Ygrid_EPSxx(end,end)]);
    set(gca,'Visible', 'off', 'YDir', 'reverse', 'DataAspectRatio', [10000 10000 1]);
    

    axes(handles.EpsYY_Plot);
    surf(Xgrid_EPSyy, Ygrid_EPSyy, EPSyy_filtered, 'LineStyle', 'none');
    view(0,90);
    xlim([Xgrid_EPSyy(1,1), Xgrid_EPSyy(end,end)]);    ylim([Ygrid_EPSyy(1,1), Ygrid_EPSyy(end,end)]);
    set(gca,'Visible', 'off', 'YDir', 'reverse', 'DataAspectRatio', [10000 10000 1]);
    
    
    axes(handles.EpsXY_Plot);
    surf(Xgrid_EPS_OMxy, Ygrid_EPS_OMxy, EPSxy_filtered, 'LineStyle', 'none');
    view(0,90);
    xlim([Xgrid_EPS_OMxy(1,1), Xgrid_EPS_OMxy(end,end)]);    ylim([Ygrid_EPS_OMxy(1,1), Ygrid_EPS_OMxy(end,end)]);
    set(gca,'Visible', 'off', 'YDir', 'reverse', 'DataAspectRatio', [10000 10000 1]);
    

    axes(handles.OmeXY_Plot);
    surf(Xgrid_EPS_OMxy, Ygrid_EPS_OMxy, OMxy_filtered, 'LineStyle', 'none');
    view(0,90);
    xlim([Xgrid_EPS_OMxy(1,1), Xgrid_EPS_OMxy(end,end)]);    ylim([Ygrid_EPS_OMxy(1,1), Ygrid_EPS_OMxy(end,end)]);
    set(gca,'Visible', 'off', 'YDir', 'reverse', 'DataAspectRatio', [10000 10000 1]);
    
    
else % plot on the deformed object
    
    % First, begin by defining the grid points on the deformed object
    % Define the deformed positions
    X_star_C = reshape( Xgrid_C + RD.TOTAL_DEFORMATIONS(:,:,1), numel(Xgrid_C), 1 );
    Y_star_C = reshape( Ygrid_C + RD.TOTAL_DEFORMATIONS(:,:,2), numel(Ygrid_C), 1 );
    [defXgrid_C, defYgrid_C] = Define_Deformed_Grid(X_star_C, Y_star_C, RD);
    
    X_star_UV = reshape( Xgrid_UV + DISP_U, numel(Xgrid_UV), 1 );
    Y_star_UV = reshape( Ygrid_UV + DISP_V, numel(Ygrid_UV), 1 );
    [defXgrid_UV, defYgrid_UV] = Define_Deformed_Grid(X_star_UV, Y_star_UV, RD);
    [M,N] = size(Xgrid_UV);
    
    % EPSxx
    [m,n] = size(Xgrid_EPSxx);
    if all( [M,N] == [m,n] ) % spline strains, with no strain filtering
        X_star_EPSxx = X_star_UV;
        Y_star_EPSxx = Y_star_UV;
        defXgrid_EPSxx = defXgrid_UV;
        defYgrid_EPSxx = defYgrid_UV;
    elseif all( mod([M,N], 2) == mod([m,n], 2) ) % spline strains, with strain filtering
        edge = floor((M-m)/2);
        X_star_EPSxx = reshape( Xgrid_EPSxx + DISP_U(1+edge:end-edge, 1+edge:end-edge), numel(Xgrid_EPSxx), 1);
        Y_star_EPSxx = reshape( Ygrid_EPSxx + DISP_V(1+edge:end-edge, 1+edge:end-edge), numel(Ygrid_EPSxx), 1);
        [defXgrid_EPSxx, defYgrid_EPSxx] = Define_Deformed_Grid(X_star_EPSxx, Y_star_EPSxx, RD);
    else % finite diff strains, with/without strain filtering
        edge = floor((M-m)/2);
        X_star_EPSxx = reshape( Xgrid_EPSxx + DISP_U(1+edge:end-edge, 1+edge:end-edge-1), numel(Xgrid_EPSxx), 1);
        Y_star_EPSxx = reshape( Ygrid_EPSxx + DISP_V(1+edge:end-edge, 1+edge:end-edge-1), numel(Ygrid_EPSxx), 1);
        [defXgrid_EPSxx, defYgrid_EPSxx] = Define_Deformed_Grid(X_star_EPSxx, Y_star_EPSxx, RD);
    end
    
    % EPSyy
    [m,n] = size(Xgrid_EPSyy);
    if all( [M,N] == [m,n] ) % spline strains, with no strain filtering
        X_star_EPSyy = X_star_UV;
        Y_star_EPSyy = Y_star_UV;
        defXgrid_EPSyy = defXgrid_UV;
        defYgrid_EPSyy = defYgrid_UV;
    elseif all( mod([M,N], 2) == mod([m,n], 2) ) % spline strains, with strain filtering
        edge = floor((M-m)/2);
        X_star_EPSyy = reshape( Xgrid_EPSyy + DISP_U(1+edge:end-edge, 1+edge:end-edge), numel(Xgrid_EPSyy), 1);
        Y_star_EPSyy = reshape( Ygrid_EPSyy + DISP_V(1+edge:end-edge, 1+edge:end-edge), numel(Ygrid_EPSyy), 1);
        [defXgrid_EPSyy, defYgrid_EPSyy] = Define_Deformed_Grid(X_star_EPSyy, Y_star_EPSyy, RD);
    else % finite diff strains, with/without strain filtering
        edge = floor((M-m)/2);
        X_star_EPSyy = reshape( Xgrid_EPSyy + DISP_U(1+edge:end-edge-1, 1+edge:end-edge), numel(Xgrid_EPSyy), 1);
        Y_star_EPSyy = reshape( Ygrid_EPSyy + DISP_V(1+edge:end-edge-1, 1+edge:end-edge), numel(Ygrid_EPSyy), 1);
        [defXgrid_EPSyy, defYgrid_EPSyy] = Define_Deformed_Grid(X_star_EPSyy, Y_star_EPSyy, RD);
    end
    
    % EPSxy and OMxy
    [m,n] = size(Xgrid_EPS_OMxy);
    if all( [M,N] == [m,n] ) % spline strains, with no strain filtering
        X_star_EPS_OMxy = X_star_UV;
        Y_star_EPS_OMxy = Y_star_UV;
        defXgrid_EPS_OMxy = defXgrid_UV;
        defYgrid_EPS_OMxy = defYgrid_UV;
    elseif all( mod([M,N], 2) == mod([m,n], 2) ) % spline strains, with strain filtering
        edge = floor((M-m)/2);
        X_star_EPS_OMxy = reshape( Xgrid_EPS_OMxy + DISP_U(1+edge:end-edge, 1+edge:end-edge), numel(Xgrid_EPS_OMxy), 1);
        Y_star_EPS_OMxy = reshape( Ygrid_EPS_OMxy + DISP_V(1+edge:end-edge, 1+edge:end-edge), numel(Ygrid_EPS_OMxy), 1);
        [defXgrid_EPS_OMxy, defYgrid_EPS_OMxy] = Define_Deformed_Grid(X_star_EPS_OMxy, Y_star_EPS_OMxy, RD);
    else % finite diff strains, with/without strain filtering
        edge = floor((M-m)/2);
        X_star_EPS_OMxy = reshape( Xgrid_EPS_OMxy + DISP_U(1+edge:end-edge-1, 1+edge:end-edge-1), numel(Xgrid_EPS_OMxy), 1);
        Y_star_EPS_OMxy = reshape( Ygrid_EPS_OMxy + DISP_V(1+edge:end-edge-1, 1+edge:end-edge-1), numel(Ygrid_EPS_OMxy), 1);
        [defXgrid_EPS_OMxy, defYgrid_EPS_OMxy] = Define_Deformed_Grid(X_star_EPS_OMxy, Y_star_EPS_OMxy, RD);
    end
    
    % Reshape the Results into vectors
    vCorrQual           = reshape(CorrQual, numel(CorrQual), 1);
    vDISP_U             = reshape(DISP_U, numel(DISP_U), 1);
    vDISP_V             = reshape(DISP_V, numel(DISP_V), 1);
    vEPSxx_filtered     = reshape(EPSxx_filtered, numel(EPSxx_filtered), 1);
    vEPSyy_filtered     = reshape(EPSyy_filtered, numel(EPSyy_filtered), 1);
    vEPSxy_filtered     = reshape(EPSxy_filtered, numel(EPSxy_filtered), 1);
    vOMxy_filtered      = reshape(OMxy_filtered, numel(OMxy_filtered), 1);
    
    % Now, using the function griddata, establish grid values for the deformed object
    
    % C
    def_CorrQual        = griddata(X_star_C,        Y_star_C,       vCorrQual,       defXgrid_C,         defYgrid_C );
    % U
    def_DISP_U          = griddata(X_star_UV,       Y_star_UV,      vDISP_U,         defXgrid_UV,        defYgrid_UV );
    % V
    def_DISP_V          = griddata(X_star_UV,       Y_star_UV,      vDISP_V,         defXgrid_UV,        defYgrid_UV );
    % EPSxx
    def_EPSxx_filtered  = griddata(X_star_EPSxx,    Y_star_EPSxx,   vEPSxx_filtered, defXgrid_EPSxx,     defYgrid_EPSxx );
    % EPSyy
    def_EPSyy_filtered  = griddata(X_star_EPSyy,    Y_star_EPSyy,   vEPSyy_filtered, defXgrid_EPSyy,     defYgrid_EPSyy );
    % EPSxy
    def_EPSxy_filtered  = griddata(X_star_EPS_OMxy, Y_star_EPS_OMxy,vEPSxy_filtered, defXgrid_EPS_OMxy,  defYgrid_EPS_OMxy );
    % OMxy
    def_OMxy_filtered   = griddata(X_star_EPS_OMxy, Y_star_EPS_OMxy,vOMxy_filtered,  defXgrid_EPS_OMxy,  defYgrid_EPS_OMxy );
    
    % Plot all the graphs
    axes(handles.DispU_Plot);
    surf(Xgrid_UV, Ygrid_UV, DISP_U, 'LineStyle', 'none');
    view(0,90); 
    xlim([Xgrid_UV(1,1), Xgrid_UV(end,end)]);    ylim([Ygrid_UV(1,1), Ygrid_UV(end,end)]);
    set(gca,'Visible', 'off', 'DataAspectRatio', [10000 10000 1]);
    
    
    % Plot all the graphs on the deformed image
    % u
    axes(handles.DispU_Plot);
    surf(defXgrid_UV, defYgrid_UV, def_DISP_U, 'LineStyle', 'none');
    view(0,90);
    xlim([defXgrid_UV(1,1), defXgrid_UV(end,end)]);    ylim([defYgrid_UV(1,1), defYgrid_UV(end,end)]);
    set(gca,'Visible', 'off', 'YDir', 'reverse', 'DataAspectRatio', [10000 10000 1]);
    
    
    % v
    axes(handles.DispV_Plot);
    surf(defXgrid_UV, defYgrid_UV, def_DISP_V, 'LineStyle', 'none');
    view(0,90);
    xlim([defXgrid_UV(1,1), defXgrid_UV(end,end)]);    ylim([defYgrid_UV(1,1), defYgrid_UV(end,end)]);
    set(gca,'Visible', 'off', 'YDir', 'reverse', 'DataAspectRatio', [10000 10000 1]);
    

    % C
    axes(handles.CorrQual_Plot);
    surf(defXgrid_C, defYgrid_C, def_CorrQual, 'LineStyle', 'none');
    view(0,90);
    xlim([defXgrid_C(1,1), defXgrid_C(end,end)]);    ylim([defYgrid_C(1,1), defYgrid_C(end,end)]);
    set(gca,'Visible', 'off', 'YDir', 'reverse', 'DataAspectRatio', [10000 10000 1]);
    

 
    % EPSxx
    axes(handles.EpsXX_Plot);
    surf(defXgrid_EPSxx, defYgrid_EPSxx, def_EPSxx_filtered, 'LineStyle', 'none');
    view(0,90);
    xlim([defXgrid_EPSxx(1,1), defXgrid_EPSxx(end,end)]);    ylim([defYgrid_EPSxx(1,1), defYgrid_EPSxx(end,end)]);
    set(gca,'Visible', 'off', 'YDir', 'reverse', 'DataAspectRatio', [10000 10000 1]);
    

    
    % EPSyy
    axes(handles.EpsYY_Plot);
    surf(defXgrid_EPSyy, defYgrid_EPSyy, def_EPSyy_filtered, 'LineStyle', 'none');
    view(0,90);
    xlim([defXgrid_EPSyy(1,1), defXgrid_EPSyy(end,end)]);    ylim([defYgrid_EPSyy(1,1), defYgrid_EPSyy(end,end)]);
    set(gca,'Visible', 'off', 'YDir', 'reverse', 'DataAspectRatio', [10000 10000 1]);
    
    
    % EPSxy
    axes(handles.EpsXY_Plot);
    surf(defXgrid_EPS_OMxy, defYgrid_EPS_OMxy, def_EPSxy_filtered, 'LineStyle', 'none');
    view(0,90);
    xlim([defXgrid_EPS_OMxy(1,1), defXgrid_EPS_OMxy(end,end)]);    ylim([defYgrid_EPS_OMxy(1,1), defYgrid_EPS_OMxy(end,end)]);
    set(gca,'Visible', 'off', 'YDir', 'reverse', 'DataAspectRatio', [10000 10000 1]);
    

    
    % OMExy
    axes(handles.OmeXY_Plot);
    surf(defXgrid_EPS_OMxy, defYgrid_EPS_OMxy, def_OMxy_filtered, 'LineStyle', 'none');
    view(0,90);
    xlim([defXgrid_EPS_OMxy(1,1), defXgrid_EPS_OMxy(end,end)]);    ylim([defYgrid_EPS_OMxy(1,1), defYgrid_EPS_OMxy(end,end)]);
    set(gca,'Visible', 'off', 'YDir', 'reverse', 'DataAspectRatio', [10000 10000 1]);
    

end % if

end % function



% Save_Output_Data writes a text file containing all the results of the
% function Compute_Strain. This should be useful for exporting results.
function Save_Output_Data( Total_or_Increm, RD, Results, Compute_Strain )

% Rename the inputs for clarity
Xgrid_C         = RD.orig_gridX;
Ygrid_C         = RD.orig_gridY;

% Rename the results values to avoid confusion
U           = Results{1};
V           = Results{2};
C           = Results{3};
EPSxx       = Results{4};
EPSyy       = Results{5};
EPSxy       = Results{6};
OMxy        = Results{7};
EPS1        = Results{8};
EPS2        = Results{9};
THETA       = Results{10};
VolStrain   = Results{11};


if isequal(Total_or_Increm, 'Total') == true
    s_tmp = sprintf('Total_Data_');
else
    s_tmp = sprintf('Incremental_Data_');
end

[tmp1, tmp2, tmp3] = mkdir(RD.PostProcess_folder_path, 'Processed_Data');
Output_file_name = strcat(RD.PostProcess_folder_path, '\Processed_Data\', s_tmp, RD.date_time_short, '.txt');
file_id = fopen(Output_file_name, 'at');

% Start by reshaping some matrices into vectors
Xvect   = reshape(Xgrid_C, numel(Xgrid_C), 1);
Yvect   = reshape(Ygrid_C, numel(Ygrid_C), 1);
C       = reshape(C,  numel(C),  1);

% Get the size of the full set of coordinates for use later
[M,N] = size(Xgrid_C);

% Fill a vector with "NaN" (this will represent points where
% displacements/strains can't be found because of convolution)
NaN_Matrix  = NaN.*ones(M,N);

% Get the size of the smaller displacement matrices
[m,n] = size(U);

% Find out the difference in size between the vectors for correct storing
edge_uv = floor( (M - m)/2 );    % for displacements M - m == N - n

% Create the fully sized vectors
tmp_mat = NaN_Matrix;
tmp_mat(1+edge_uv:end-edge_uv, 1+edge_uv:end-edge_uv) = U;
u = reshape(tmp_mat, numel(tmp_mat), 1);

tmp_mat(1+edge_uv:end-edge_uv, 1+edge_uv:end-edge_uv) = V;
v = reshape(tmp_mat, numel(tmp_mat), 1);    

% Strains can differ in size depending on how they were computed
if Compute_Strain == 1 % Finite Diff

    % Get the size of the smaller displacement matrices
    [m,n] = size(EPSxx);

    % Find out the difference in size between the vectors for correct storing
    edge = floor( (N - n)/2 );

    % Create the fully sized vectors
    tmp_mat = NaN_Matrix;
    tmp_mat(1+edge:end-edge, 1+edge:end-edge-1) = EPSxx;
    epsXX = reshape(tmp_mat, numel(tmp_mat), 1);

    % Create the fully sized vectors
    tmp_mat = NaN_Matrix;
    tmp_mat(1+edge:end-edge-1, 1+edge:end-edge) = EPSyy;
    epsYY = reshape(tmp_mat, numel(tmp_mat), 1);

    % Create the fully sized vectors
    tmp_mat = NaN_Matrix;
    tmp_mat(1+edge:end-edge-1, 1+edge:end-edge-1) = EPSxy;
    epsXY = reshape(tmp_mat, numel(tmp_mat), 1);

    % Create the fully sized vectors
    tmp_mat = NaN_Matrix;
    tmp_mat(1+edge:end-edge-1, 1+edge:end-edge-1) = OMxy;
    omeXY = reshape(tmp_mat, numel(tmp_mat), 1);
    
    % Create the fully sized vectors
    tmp_mat = NaN_Matrix;
    tmp_mat(1+edge:end-edge-1, 1+edge:end-edge-1) = EPS1;
    eps1 = reshape(tmp_mat, numel(tmp_mat), 1);
    
    % Create the fully sized vectors
    tmp_mat = NaN_Matrix;
    tmp_mat(1+edge:end-edge-1, 1+edge:end-edge-1) = EPS2;
    eps2 = reshape(tmp_mat, numel(tmp_mat), 1);
    
    % Create the fully sized vectors
    tmp_mat = NaN_Matrix;
    tmp_mat(1+edge:end-edge-1, 1+edge:end-edge-1) = THETA;
    theta = reshape(tmp_mat, numel(tmp_mat), 1);
    
    % Create the fully sized vectors
    tmp_mat = NaN_Matrix;
    tmp_mat(1+edge:end-edge-1, 1+edge:end-edge-1) = VolStrain;
    epsV = reshape(tmp_mat, numel(tmp_mat), 1);

else  % Spline

    % Get the size of the smaller displacement matrices
    [m,n] = size(EPSxx);

    % Find out the difference in size between the vectors for correct storing
    edge = floor( (N - n)/2 );

    % Create the fully sized vectors
    tmp_mat = NaN_Matrix;
    tmp_mat(1+edge:end-edge, 1+edge:end-edge) = EPSxx;
    epsXX = reshape(tmp_mat, numel(tmp_mat), 1);

    tmp_mat(1+edge:end-edge, 1+edge:end-edge) = EPSyy;
    epsYY = reshape(tmp_mat, numel(tmp_mat), 1);


    tmp_mat(1+edge:end-edge, 1+edge:end-edge) = EPSxy;
    epsXY = reshape(tmp_mat, numel(tmp_mat), 1);


    tmp_mat(1+edge:end-edge, 1+edge:end-edge) = OMxy;
    omeXY = reshape(tmp_mat, numel(tmp_mat), 1);
    
    tmp_mat(1+edge:end-edge, 1+edge:end-edge) = EPS1;
    eps1 = reshape(tmp_mat, numel(tmp_mat), 1);
    
    tmp_mat(1+edge:end-edge, 1+edge:end-edge) = EPS2;
    eps2 = reshape(tmp_mat, numel(tmp_mat), 1);
    
    tmp_mat(1+edge:end-edge, 1+edge:end-edge) = THETA;
    theta = reshape(tmp_mat, numel(tmp_mat), 1);

    tmp_mat(1+edge:end-edge, 1+edge:end-edge) = VolStrain;
    epsV = reshape(tmp_mat, numel(tmp_mat), 1);


end


% Print out the date and time when rawdata was saved
header_string = sprintf('\n\n''Results of processing raw data from %s''', RD.date_time_long );
fprintf(file_id, '%s', header_string);

s_tmp = sprintf(strcat('\n\nx, y, u, v, C, EPSxx, EPSyy, EPSxy, OMEGAxy, EPS1, EPS2, THETA, Vol_Strain\n') );
fprintf(file_id, s_tmp );
% Print out the values for each of these in a nice grid
for iii = 1:(M.*N)
    output_string = sprintf('%g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g', ...
       Xvect(iii),  Yvect(iii),  u(iii),  v(iii), C(iii), epsXX(iii), epsYY(iii), epsXY(iii), omeXY(iii), ...
       eps1(iii), eps2(iii), theta(iii), epsV(iii) );
    fprintf(file_id, '%s\n', output_string);
end
fclose(file_id);

end % function

%*********************END EXTRA FUNCTION FOR PREVIEW AND RUN BUTTONS*******************************




% Special Functions... for now
% Compute_Strains_Special will do the same as Compute_Stains, however, it
% will save a workspace file for Reza's J-integrals program.
function Compute_Strains_Special(RD_filename, RD, handles)

% Retrieve the user inputs
Compute_Strain  = get(handles.CompStrain_DropBox,           'Value');
Filter_uv       = get(handles.Filter_uv_CheckBox,           'Value');
Conv1           = str2double(get(handles.Conv1Edit,         'string'));
Filter_strains  = get(handles.Filter_strains_CheckBox,      'Value');
Conv2           = str2double(get(handles.Conv2Edit,         'string'));
tol             = str2double(get(handles.SplineTolEdit,     'string'));

% Are we using total or incremental deformations?
%if strcmpi('Increm', total_or_increm) == true
%    DEFORMATIONS = RD.INCREM_DEFORMATIONS;
%else
    DEFORMATIONS = RD.TOTAL_DEFORMATIONS;
%end


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

DU_DX_filtered = EPSxx_filtered; 
DV_DY_filtered = EPSyy_filtered;
Pillbox2 = ones(Conv2, Conv2)./(Conv2.^2);
DU_DY_filtered = conv2(DU_DY, Pillbox2, 'valid');
DV_DX_filtered = conv2(DV_DX, Pillbox2, 'valid');
Xgrid_Strains = Xgrid_EPSxx;
Ygrid_Strains = Ygrid_EPSxx;
Xgrid_Disp = Xgrid_UV;
Ygrid_Disp = Ygrid_UV;
Conversion_mm_per_pixel = 27.14/441;

% Determine where the periods are placed in the raw data file name
periods = strfind(RD_filename, '.');

% Determine where the 'Data ' strings are placed in the raw data file name
data_spots = strfind(RD_filename, 'Data ');

% If there is more than 1 value in the above variables it's a cell array
if iscell(periods) == true
    periods = periods{end};
    data_spots = data_spots{1};
end

% Save the string between 'Raw Data ' and '.txt' in the file name
mod_name = sprintf('%s', RD_filename(data_spots+5:periods-1) );


WS_Filename = sprintf('DIC_%s_FilterBy%g.mat', mod_name, Conv2);

[m,n] = size(DISP_U);
TOTAL_DEF(1:m,1:n,1) = DISP_U;
[m,n] = size(DISP_V);
TOTAL_DEF(1:m,1:n,2) = DISP_V;
[m,n] = size(DU_DX_filtered);
TOTAL_DEF(1:m,1:n,3) = DU_DX_filtered;
[m,n] = size(DV_DY_filtered);
TOTAL_DEF(1:m,1:n,4) = DV_DY_filtered;
[m,n] = size(DU_DY_filtered);
TOTAL_DEF(1:m,1:n,5) = DU_DY_filtered;
[m,n] = size(DV_DX_filtered);
TOTAL_DEF(1:m,1:n,6) = DV_DX_filtered;
TOTAL_DEF(1:m,1:n,7) = 0;
TOTAL_DEF(1:m,1:n,8) = 0;
TOTAL_DEF(1:m,1:n,9) = 0;
TOTAL_DEF(1:m,1:n,10) = 0;
TOTAL_DEF(1:m,1:n,11) = 0;
TOTAL_DEF(1:m,1:n,12) = 0;
TOTAL_DEF(1:m,1:n,13) = 0;
TOTAL_DEF(1:m,1:n,14) = 0;
[m,n] = size(CorrQual);
TOTAL_DEF(1:m,1:n,15) = CorrQual;

save(WS_Filename, 'Xgrid_Disp', 'Ygrid_Disp', 'Xgrid_Strains', 'Ygrid_Strains', 'DISP_U', ...
                              'DISP_V', 'DU_DX_filtered', 'DV_DY_filtered', 'DU_DY_filtered', 'DV_DX_filtered', ...
                              'EPSxx_filtered', 'EPSyy_filtered', 'EPSxy_filtered', 'Conversion_mm_per_pixel', ...
                              'CorrQual', 'TOTAL_DEF');
                              
end % function











