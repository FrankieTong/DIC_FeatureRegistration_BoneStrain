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



Digital Image Correlation: Graphical User Interface
Honours Thesis Research Project
McGill University, Montreal, Quebec, Canada
Created on:  May 31, 2007
Modified on: May 1, 2008

--------------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: GRAPHICAL USER INTERFACE      |
--------------------------------------------------------------

This M-file, along with the figure file of the same name are responsible 
for generating the GUI for the DIC program.

RUN THIS FILE TO START THE DIC PROGRAM!

DO NOT MODIFY THE FUNCTION varargout!!!
%}

function varargout = DIC_GUI_May_01_2008_MH(varargin)
% DIC_GUI_May_01_2008 M-file for DIC_GUI_May_01_2008.fig
%      DIC_GUI_May_01_2008, by itself, creates a new DIC_GUI_May_01_2008 or raises the existing
%      singleton*.
%
%      H = DIC_GUI_May_01_2008 returns the handle to a new DIC_GUI_May_01_2008 or the handle to
%      the existing singleton*.
%
%      DIC_GUI_May_01_2008('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIC_GUI_May_01_2008.M with the given input arguments.
%
%      DIC_GUI_May_01_2008('Property','Value',...) creates a new DIC_GUI_May_01_2008 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DIC_GUI_May_01_2008_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DIC_GUI_May_01_2008_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DIC_GUI_May_01_2008

% Last Modified by GUIDE v2.5 28-Apr-2008 16:09:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DIC_GUI_May_01_2008_OpeningFcn, ...
                   'gui_OutputFcn',  @DIC_GUI_May_01_2008_OutputFcn, ...
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



% --- Executes just before DIC_GUI_May_01_2008 is made visible.
function DIC_GUI_May_01_2008_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DIC_GUI_May_01_2008 (see VARARGIN)

%{
***************************************************************************************
*JEFF: The following lines are my own edits.                                          *
*      This section initializes the program just before the GUI appears on screen     *
***************************************************************************************
%}
% Load the default image for the welcome message
axes(handles.WelcomeImage);
image(imread('Tools and Files\DICWelcomeImage.TIF'), 'CDataMapping', 'scaled');
colormap('gray');
set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);

% Load the workspace "DIC_defaults" to set the program's default values
cd('Tools and Files');
WS = load('DIC_defaults.mat');
cd('..');
DIC_defaults = WS.DIC_defaults;
clear WS;
% Save the default values as application data for use in error checking
setappdata(hObject, 'defaults', DIC_defaults);

% Add a struct that will track the image files that the user selects
% Start by loading the default ref and def images
image_files.ref_image = DIC_defaults.ref_image;
image_files.def_image = DIC_defaults.def_image;
setappdata(hObject, 'image_files', image_files);

% Show the default ref image.
if isequal(image_files.ref_image, '') == false
    axes(handles.RefImage);
    image(imread(image_files.ref_image),'CDataMapping', 'scaled');
    set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
    colormap('gray');
    RefImage_NameBox_Callback(handles.RefImage_NameBox, eventdata, handles);
else
    axes(handles.RefImage);
    image(imread('Tools and Files\EmptyImage.TIF'), 'CDataMapping', 'scaled');
    colormap('gray');
    set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
end

% Show the default def image and write the name in the dropbox. 
% If there is more than 1 file, show the first image in the list and write all the names in the dropbox
if isequal(image_files.def_image, '') == false && iscell(image_files.def_image) == false  % Case when there's 1 file
    axes(handles.DefImage);
    image(imread(image_files.def_image), 'CDataMapping', 'scaled');
    colormap('gray');
    set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
    
    % Write the name to the DropBox, I want to show only 1 folder in the name.
    slashspots = strfind(image_files.def_image, '\');
    def_name = strcat( '...', image_files.def_image(slashspots(end-1):end) );

    % Set the box text to be the path and name of the file.
    set(handles.DefImage_DropList, 'string', def_name);
    
    % Allow the user access to the DropList
    set(handles.DefImage_DropList, 'Enable', 'on');
    
elseif isequal(image_files.def_image, '') == false && iscell(image_files.def_image) == true % Case when there's many files
    axes(handles.DefImage);
    image(imread(image_files.def_image{1}), 'CDataMapping', 'scaled');
    colormap('gray');
    set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
    
    % Write the names to the DropBox, I want to show only 1 folder.
    slashspots = strfind(image_files.def_image, '\');

    % Define a cell array to hold all the modified names
    def_name = cell(numel(image_files.def_image), 1);

    % Modify each file name
    for ii = 1:numel(image_files.def_image)
        tmp_string = image_files.def_image{ii}(slashspots{ii}(end-1):end);
        def_name(ii,:) = {strcat( '...', tmp_string )};
    end

    % Set the box text to be the path and name of the file.
    set(handles.DefImage_DropList, 'string', def_name);
    
    % Allow the user access to the DropList
    set(handles.DefImage_DropList, 'Enable', 'on');
else % No default file
    axes(handles.DefImage);
    image(imread('Tools and Files\EmptyImage.TIF'), 'CDataMapping', 'scaled');
    colormap('gray');
    set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
end

% Set all the fields to the default values
set(handles.SubsetSizeEdit,                 'string',   DIC_defaults.SubsetSize);
set(handles.SubsetSpacingEdit,              'string',   DIC_defaults.SubsetSpace);
set(handles.FirstPointEditX,                'string',	DIC_defaults.FirstPointX);
set(handles.FirstPointEditY,                'string',   DIC_defaults.FirstPointY);
set(handles.FinalPointEditX,                'string',   DIC_defaults.FinalPointX);
set(handles.FinalPointEditY,                'string',   DIC_defaults.FinalPointY);
set(handles.Interp_Method_DropBox,          'Value',    DIC_defaults.PolySplineOrder);
set(handles.Image_Comp_DropBox,             'Value',    DIC_defaults.ImageComp);
set(handles.Subset_Deformations_DropBox,    'Value',    DIC_defaults.SubsetDef);
        

% Add a new struct to track errors in the inputs before correlation runs
error_tracker.error_found = false;
setappdata(hObject, 'tracker', error_tracker);
% Add a struct to track the Initial Guess chosen by the user.
initial_guess.u = DIC_defaults.initialU;
initial_guess.v = DIC_defaults.initialV;
setappdata(hObject, 'initial_guess', initial_guess);

% Write the values of the guesses in the edit boxes
set(handles.u_guessEdit, 'string', num2str(initial_guess.u));
set(handles.v_guessEdit, 'string', num2str(initial_guess.v));
 

%---MATLAB CODE-----------------------------------
% Choose default command line output for DIC_GUI_May_01_2008
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DIC_GUI_May_01_2008 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end % function



% --- Outputs from this function are returned to the command line.
function varargout = DIC_GUI_May_01_2008_OutputFcn(hObject, eventdata, handles) 
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
function Save_Defaults_SubMenu_Callback(hObject, eventdata, handles)

% To save the current values as defaults, start by loading the DIC_defaults struct
DIC_defaults = getappdata(handles.figure1, 'defaults');

% Now, get the current values and store them into DIC_defaults
DIC_defaults.SubsetSize         = get(handles.SubsetSizeEdit,               'string');
DIC_defaults.SubsetSpace        = get(handles.SubsetSpacingEdit,            'string');
DIC_defaults.FirstPointX        = get(handles.FirstPointEditX,              'string');
DIC_defaults.FirstPointY        = get(handles.FirstPointEditY,              'string');
DIC_defaults.FinalPointX        = get(handles.FinalPointEditX,              'string');
DIC_defaults.FinalPointY        = get(handles.FinalPointEditY,              'string');
DIC_defaults.PolySplineOrder    = get(handles.Interp_Method_DropBox,        'Value');
DIC_defaults.ImageComp          = get(handles.Image_Comp_DropBox,           'Value');
DIC_defaults.SubsetDef          = get(handles.Subset_Deformations_DropBox,	'Value');


% To save the images, and the initial guess, get their respective data structs...
image_files     = getappdata(handles.figure1, 'image_files');
initial_guess   = getappdata(handles.figure1, 'initial_guess');

% ... and store them into DIC_defaults
DIC_defaults.ref_image = image_files.ref_image;
DIC_defaults.def_image = image_files.def_image;
DIC_defaults.initialU  = initial_guess.u;
DIC_defaults.initialV  = initial_guess.v;

% Save the changes to the program_default struct
setappdata(handles.figure1, 'defaults', DIC_defaults);

% Save these new values as a workspace in the "Tools and Files" folder
cd('Tools and Files');
save('DIC_defaults.mat', 'DIC_defaults');

% Return to the original folder
cd('..');

end % function

% --------------------------------------------------------------------
function Start_PostProcess_SubMenu_Callback(hObject, eventdata, handles)
POSTPRO_GUI_May_01_2008;
end % function


% --------------------------------------------------------------------
function Exit_SubMenu_Callback(hObject, eventdata, handles)
clear;
close('all');
end % function




%**********END OPTION MENU AND CONTEXT MENU************************


%__________________________________________________________________________________________






% --- Executes during object creation, after setting all properties.
function WelcomeImage_CreateFcn(hObject, eventdata, handles)
end % function



%___________________________USER INPUTS SECTION_____________________________________________


%**********IMAGE OPTIONS****************************

% --- Executes on button press in Open_Ref_Button.
function Open_Ref_Button_Callback(hObject, eventdata, handles)
% Open Matlab's GUI to select the reference image file
[ref_imfile, did_the_user_cancel] = imgetfile;

% If the user didn't cancel, and the file is valid, load the image
if did_the_user_cancel == false && ~isequal(ref_imfile, 0)
    
    % Set RefImage as the current axes and load the image into it
    try                             % Use "try" to see if the file selected is a valid image file
    	axes(handles.RefImage);
        image(imread(ref_imfile), 'CDataMapping', 'scaled');
        colormap('gray');
        set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
    catch                           % If the file is not valid, issue an error window.
        errordlg('The reference image is invalid','Invalid reference image','modal');
        return;
    end
        
    
    % Make sure to save the path of the new reference image file
    image_files = getappdata(handles.figure1, 'image_files');
    image_files.ref_image = ref_imfile;
    setappdata(handles.figure1, 'image_files', image_files);
    
    RefImage_NameBox_Callback(handles.RefImage_NameBox, eventdata, handles);
end
end % function



function RefImage_NameBox_Callback(hObject, eventdata, handles)
% Get the image data struct
image_files = getappdata(handles.figure1, 'image_files');

% I want to show only 1 folder. Find the slashes
slashspots = strfind(image_files.ref_image, '\');
ref_name = strcat( '...', image_files.ref_image(slashspots(end-1):end) );

% Set the path and name of the file as the text in the box
set(hObject, 'string', ref_name);

end % function
% --- Executes during object creation, after setting all properties.
function RefImage_NameBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function


% --- Executes on mouse press over axes background.
function RefImage_ButtonDownFcn(hObject, eventdata, handles)
end % function


% --- Executes during object creation, after setting all properties.
function RefImage_CreateFcn(hObject, eventdata, handles)
end % function




% --- Executes on button press in RefSelectButton.
function RefSelectButton_Callback(hObject, eventdata, handles)
% This button will create a new figure where you can click to select the
% values for the bounding box (First and Final Point)
% Open a new figure
figure;

% Get the file paths of the image chosen by the user
image_files = getappdata(handles.figure1, 'image_files');
if isequal(image_files.ref_image, '')
    close;
    errordlg('The reference image is invalid','Invalid reference image','modal');
    return;
end

image(imread(image_files.ref_image), 'CDataMapping', 'scaled');
colormap('gray');
set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);

rect = getrect;
set(handles.FirstPointEditX, 'String', num2str(round(rect(1))) );
set(handles.FirstPointEditY, 'String', num2str(round(rect(2))) );
set(handles.FinalPointEditX, 'String', num2str(round(rect(1)+rect(3))) );
set(handles.FinalPointEditY, 'String', num2str(round(rect(2)+rect(4))) );
close;
end % function




% --- Executes on button press in Open_Def_Button.
function Open_Def_Button_Callback(hObject, eventdata, handles)
% Open Matlab's GUI to select the reference image file
[def_imfile, imfile_path] = uigetfile('*.*', 'MultiSelect','on');

% If the user didn't cancel, and the file is valid, load the image
if ~isequal(def_imfile, 0)
    
    % Set DefImage as the current axes
    axes(handles.DefImage);
    
    % def_imfile is a cell array only if there's more than 1 file selected
    if iscell(def_imfile) == false
        
        try                             % Use "try" to see if the file selected is a valid image file
            % Show the image in the Def axes
            image(imread(strcat(imfile_path,def_imfile)), 'CDataMapping', 'scaled');
            colormap('gray');
            set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
        catch                           % If the file is not valid, issue an error window.
            errordlg('The deformed image is invalid','Invalid deformed image','modal');
            return;
        end
        
        % Make sure to save the path of the new deformed image file
        image_files = getappdata(handles.figure1, 'image_files');
        image_files.def_image = strcat(imfile_path, def_imfile);
        setappdata(handles.figure1, 'image_files', image_files);
        
        % Write the name to the DropBox, I want to show only 1 folder.
        slashspots = strfind(image_files.def_image, '\');
        def_name = strcat( '...', image_files.def_image(slashspots(end-1):end) );
    
        % Set the box text to be the path and name of the file.
        set(handles.DefImage_DropList, 'string', def_name);
    else
        try                             % Use "try" to see if the file selected is a valid image file
            % Show the first image in the list in the Def axes
            image(imread(strcat(imfile_path,def_imfile{1})), 'CDataMapping', 'scaled');
            colormap('gray');
            set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
        catch                           % If the first file is not valid, issue an error window.
            errordlg('The deformed image is invalid','Invalid deformed image','modal');
            return;
        end

        % Make sure to save the path of the new deformed image file
        image_files = getappdata(handles.figure1, 'image_files');
        image_files.def_image = strcat(imfile_path, def_imfile);
        setappdata(handles.figure1, 'image_files', image_files);
        
        % Write the names to the DropBox, I want to show only 1 folder.
        slashspots = strfind(image_files.def_image, '\');
        
        % Define a cell array to hold all the modified names
        def_name = cell(numel(image_files.def_image), 1);
        
        % Modify each file name
        for ii = 1:numel(image_files.def_image)
            tmp_string = image_files.def_image{ii}(slashspots{ii}(end-1):end);
            def_name(ii,:) = {strcat( '...', tmp_string )};
        end
        
        % Set the box text to be the path and name of the file.
        set(handles.DefImage_DropList, 'string', def_name);
    end
    
    % Allow the user access to the DropList
    set(handles.DefImage_DropList, 'Enable', 'on');
    
end % if ~isequal
end % function


% --- Executes on selection change in DefImage_DropList.
function DefImage_DropList_Callback(hObject, eventdata, handles)
% Get the image chosen by the user
val = get(hObject, 'Value');

% Get the image_files struct
image_files = getappdata(handles.figure1, 'image_files');

% If there is more than one image in the list...
if iscell(image_files.def_image) == true
    try                             % Use "try" to see if the file selected is a valid image file
        % ...Set the def image axes as current and...
        axes(handles.DefImage);
    
        % ...Show the image in the Def axes
        image(imread(image_files.def_image{val}), 'CDataMapping', 'scaled');
        colormap('gray');
        set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
    catch
        errordlg('The deformed image is invalid','Invalid deformed image','modal');
        axes(handles.DefImage);
        image(imread('Tools and Files\EmptyImage.TIF'), 'CDataMapping', 'scaled');
        colormap('gray');
        set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
        return;
    end
    
end

end % function
% --- Executes during object creation, after setting all properties.
function DefImage_DropList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function


% --- Executes on mouse press over axes background.
function DefImage_ButtonDownFcn(hObject, eventdata, handles)
end % function


% --- Executes during object creation, after setting all properties.
function DefImage_CreateFcn(hObject, eventdata, handles)
end % function



function SubsetSizeEdit_Callback(hObject, eventdata, handles)
% Determine the value that was input by the user and make sure it's a positive integer
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry) || user_entry <= 5 || user_entry ~= floor(user_entry)
    errordlg('The subset size must be a positive integer value, greater than 5','Invalid Subset Size','modal')
    DIC_defaults = getappdata(handles.figure1, 'defaults');
    set(hObject, 'string', DIC_defaults.SubsetSize);
    error_tracker.error_found = true;
    setappdata(handles.figure1, 'tracker', error_tracker);
    return
end

% If the subset size is not odd, make it odd
if mod(user_entry,2) == 0
    odd_value = num2str(user_entry + 1);
    warndlg( sprintf('The subset size must be odd.\nThe value %s was replaced by %s',...
                                                                    num2str(user_entry), odd_value), 'Warning', 'modal');
    set(hObject, 'string', odd_value);
end
end % function

% --- Executes during object creation, after setting all properties.
function SubsetSizeEdit_CreateFcn(hObject, eventdata, handles)
% Matlab code to ensure white background in edit box
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function



function SubsetSpacingEdit_Callback(hObject, eventdata, handles)
% Determine the value that was input by the user and make sure it's a positive integer
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry) || user_entry < 1 || user_entry ~= floor(user_entry)
    errordlg('The subset spacing must be a positive integer value','Invalid Subset Spacing','modal')
    DIC_defaults = getappdata(handles.figure1, 'defaults');
    set(hObject, 'string', DIC_defaults.SubsetSpace);
    error_tracker.error_found = true;
    setappdata(handles.figure1, 'tracker', error_tracker);
    return
end
end % function

% --- Executes during object creation, after setting all properties.
function SubsetSpacingEdit_CreateFcn(hObject, eventdata, handles)
% Matlab code to ensure white background in edit box
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function



function FirstPointEditX_Callback(hObject, eventdata, handles)
% Determine the value that was input by the user and make sure it's a positive integer
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry) || user_entry < 0 || user_entry ~= floor(user_entry)
    errordlg('The X Coordinate of the First Point must be a positive integer value','Invalid First Point X Coordinate','modal')
    DIC_defaults = getappdata(handles.figure1, 'defaults');
    set(hObject, 'string', DIC_defaults.FirstPointX);
    error_tracker.error_found = true;
    setappdata(handles.figure1, 'tracker', error_tracker);
    return
end
end % function

% --- Executes during object creation, after setting all properties.
function FirstPointEditX_CreateFcn(hObject, eventdata, handles)
% Matlab code to ensure white background in edit box
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function



function FirstPointEditY_Callback(hObject, eventdata, handles)
% Determine the value that was input by the user and make sure it's a positive integer
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry) || user_entry < 0 || user_entry ~= floor(user_entry)
    errordlg('The Y Coordinate of the First Point must be a positive integer value','Invalid First Point Y Coordinate','modal')
    DIC_defaults = getappdata(handles.figure1, 'defaults');
    set(hObject, 'string', DIC_defaults.FirstPointY);
    error_tracker.error_found = true;
    setappdata(handles.figure1, 'tracker', error_tracker);
    return
end
end % function

% --- Executes during object creation, after setting all properties.
function FirstPointEditY_CreateFcn(hObject, eventdata, handles)
% Matlab code to ensure white background in edit box
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function



function FinalPointEditX_Callback(hObject, eventdata, handles)
% Determine the value that was input by the user and make sure it's a positive integer
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry) || user_entry < 0 || user_entry ~= floor(user_entry)
    errordlg('The X Coordinate of the Final Point must be a positive integer value','Invalid Final Point X Coordinate','modal')
    DIC_defaults = getappdata(handles.figure1, 'defaults');
    set(hObject, 'string', DIC_defaults.FinalPointX);
    error_tracker.error_found = true;
    setappdata(handles.figure1, 'tracker', error_tracker);
    return
end

% Make sure that the Final Point > First Point
if user_entry < str2double(get(handles.FirstPointEditX, 'String'))
    errordlg(sprintf('The X Coordinate of the Final Point must be larger than the X Coordinate\n of the First Point'), ...
             'Invalid Final Point X Coordinate','modal')
    new_value = num2str(str2double(get(handles.FirstPointEditX, 'String')) + 1);
    set(hObject, 'string', new_value);
    error_tracker.error_found = true;
    setappdata(handles.figure1, 'tracker', error_tracker);
    return
end
end % function

% --- Executes during object creation, after setting all properties.
function FinalPointEditX_CreateFcn(hObject, eventdata, handles)
% Matlab code to ensure white background in edit box
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function



function FinalPointEditY_Callback(hObject, eventdata, handles)
% Determine the value that was input by the user and make sure it's a positive integer
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry) || user_entry < 0 || user_entry ~= floor(user_entry)
    errordlg('The Y Coordinate of the Final Point must be a positive integer value','Invalid Final Point Y Coordinate','modal')
    DIC_defaults = getappdata(handles.figure1, 'defaults');
    set(hObject, 'string', DIC_defaults.FinalPointY);
    error_tracker.error_found = true;
    setappdata(handles.figure1, 'tracker', error_tracker);
    return
end

% Make sure that the Final Point > First Point
if user_entry < str2double(get(handles.FirstPointEditY, 'String'))
    errordlg(sprintf('The Y Coordinate of the Final Point must be larger than the Y Coordinate\n of the First Point'), ...
             'Invalid Final Point Y Coordinate','modal')
    new_value = num2str(str2double(get(handles.FirstPointEditY, 'String')) + 1);
    set(hObject, 'string', new_value);
    error_tracker.error_found = true;
    setappdata(handles.figure1, 'tracker', error_tracker);
    return
end
end % function

% --- Executes during object creation, after setting all properties.
function FinalPointEditY_CreateFcn(hObject, eventdata, handles)
% Matlab code to ensure white background in edit box
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function




%-_-_-_-_-INITIAL GUESS BUTTON-_-_-_-_-_-_

% --- Executes on button press in InitialGuessButton.
function InitialGuessButton_Callback(hObject, eventdata, handles)
% This button will open one window with the reference image zoomed near the first point.
% Another window will open next to it showing the deformed image. 
% The user must then draw a box around the section that represents a good initial displacement

% Get the file path of the images chosen by the user
image_files = getappdata(handles.figure1, 'image_files');
if isequal(image_files.ref_image, '')
    errordlg('The reference image is invalid','Invalid reference image','modal');
    return;
elseif isequal(image_files.def_image, '')
    errordlg('The deformed image is invalid','Invalid deformed image','modal');
    return;
end

% Load the reference image into a matrix as part of the preview
ref = imread(image_files.ref_image);

if iscell(image_files.def_image) == true
    % Get the first deformed image file for the initial guess
    def = im2double(imread(image_files.def_image{1}));
else
    def = imread(image_files.def_image);
end


% Using the user inputs, define the First and Final point Coordinates, the subset size and the subset spacing
Xmin = str2double( get(handles.FirstPointEditX, 'String') );
Ymin = str2double( get(handles.FirstPointEditY, 'String') );
HalfSubSize = floor( str2double( get(handles.SubsetSizeEdit, 'String') ) / 2 );
SubSpace = str2double( get(handles.SubsetSpacingEdit, 'String') );

% Zoom in on an area near the first point
Y_refcoord = Ymin-5*HalfSubSize:Ymin+5*HalfSubSize;
Yshift = 0;
if Y_refcoord(1) < 1
    Y_refcoord = 1:Ymin+5*HalfSubSize;
    Yshift = -(Ymin-5*HalfSubSize);
end
X_refcoord = Xmin-5*HalfSubSize:Xmin+5*HalfSubSize;
Xshift = 0;
if X_refcoord(1) < 1
    X_refcoord = 1:Xmin+5*HalfSubSize;
    Xshift = -(Xmin-5*HalfSubSize);
end
ref_zone = ref(Y_refcoord, X_refcoord);

% Open and prepare a new figure window, then show the subset at the first point
figure; rax = axes; image(ref_zone, 'CDataMapping', 'scaled');
colormap('gray'); set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
set(gcf, 'Name', 'First Subset Correlated', 'Units', 'normalized', 'Position', [0.01 0.02 0.45 0.85]);
rectangle('Position',[4*HalfSubSize-Xshift,4*HalfSubSize-Yshift,2*HalfSubSize,2*HalfSubSize], ...
          'LineWidth',2,'EdgeColor','red', 'Parent', rax);
hold on;      
scatter(5*HalfSubSize-Xshift,5*HalfSubSize-Yshift, '+r');
hold off;
annotation('textbox', 'String', 'The red rectangle represents the first subset to be correlated', ...
                      'Position', [0.175 0.95 0.4 0.01], ...
                      'HorizontalAlignment', 'center', ...
                      'FitHeightToText', 'on', ...
                      'FontWeight', 'bold', ...
                      'BackgroundColor', [0.05, 1, 0.9], ...
                      'LineStyle', 'none');


% Open and prepare a new figure window, then show the deformed image
figure; image(def, 'CDataMapping', 'scaled');
colormap('gray'); set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
set(gcf, 'Name', 'Deformed Image', 'Units', 'normalized', 'Position', [0.54 0.02 0.45 0.85]);
str = {'Searching for where the subset was displaced:','Select a rectangular region to zoom into'};
annotation('textbox', 'String', str, ...
                      'Position', [0.25 0.95 0.4 0.01], ...
                      'HorizontalAlignment', 'center', ...
                      'FitHeightToText', 'on', ...
                      'FontWeight', 'bold', ...
                      'BackgroundColor', [0.05, 1, 0.9], ...
                      'LineStyle', 'none');
rect1 = round(getrect);
def_zone = def(rect1(2):rect1(2)+rect1(4), rect1(1):rect1(1)+rect1(3));
close(gcf);

% Open and prepare a new figure window, then show the zoomed in deformed zone
figure; dax = axes; image(def_zone, 'CDataMapping', 'scaled');
colormap('gray'); set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
set(gcf, 'Name', 'Closer Look at Deformed Image', 'Units', 'normalized', 'Position', [0.54 0.02 0.45 0.85]);
str = {'Searching for where the subset was displaced:','Draw a rectangle on what most resembles the first subset'};
annotation('textbox', 'String', str, ...
                      'Position', [0.175 0.95 0.4 0.01], ...
                      'HorizontalAlignment', 'center', ...
                      'FitHeightToText', 'on', ...
                      'FontWeight', 'bold', ...
                      'BackgroundColor', [0.05, 1, 0.9], ...
                      'LineStyle', 'none');
rect2 = round(getrect);

% sub_u and sub_v are in the zooomed in reference frame
sub_u = rect2(1)+floor(rect2(3)/2);
sub_v = rect2(2)+floor(rect2(4)/2);

% rect1 + sub_uv gives the center of the deformed subset in the absolute reference frame
initial_guess.u = (rect1(1)+sub_u)-Xmin;
initial_guess.v = (rect1(2)+sub_v)-Ymin;

% Set the changes
setappdata(handles.figure1, 'initial_guess', initial_guess);

% Write the results of the initial guess in the edit boxes
set(handles.u_guessEdit, 'string', num2str(initial_guess.u));
set(handles.v_guessEdit, 'string', num2str(initial_guess.v));

% Close the two open figures
close(gcf);
close(findobj('Name','First Subset Correlated'));

end % function





function u_guessEdit_Callback(hObject, eventdata, handles)
end % function
% --- Executes during object creation, after setting all properties.
function u_guessEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function


function v_guessEdit_Callback(hObject, eventdata, handles)
end % function
% --- Executes during object creation, after setting all properties.
function v_guessEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function



%**********END IMAGE OPTIONS****************************




%**********SUBSET DEFORMATIONS OPTIONS****************************

% --- Executes on selection change in Subset_Deformations_DropBox.
function Subset_Deformations_DropBox_Callback(hObject, eventdata, handles)
end % function

% --- Executes during object creation, after setting all properties.
function Subset_Deformations_DropBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function

%**********END SUBSET DEFORMATIONS OPTIONS************************




%**********INTERPOLATION OPTIONS************************

% --- Executes on selection change in Interp_Method_DropBox.
function Interp_Method_DropBox_Callback(hObject, eventdata, handles)
end % function

% --- Executes during object creation, after setting all properties.
function Interp_Method_DropBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function


%**********END INTERPOLATION OPTIONS************************





%**********IMAGE COMPARISON OPTIONS************************

% --- Executes on selection change in Image_Comp_DropBox.
function Image_Comp_DropBox_Callback(hObject, eventdata, handles)
end % function

% --- Executes during object creation, after setting all properties.
function Image_Comp_DropBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % function

%**********END IMAGE COMPARISON OPTIONS************************






%**********PREVIEW BUTTONS************************

% --- Executes on button press in PreviewButton.
function RefPreviewButton_Callback(hObject, eventdata, handles)
% The preview button will display the reference image and illustrate the input values

% Get the file path of the images chosen by the user
image_files = getappdata(handles.figure1, 'image_files');
if isequal(image_files.ref_image, '')
    errordlg('The reference image is invalid','Invalid reference image','modal');
    return;
end

% Load the reference image into a matrix as part of the preview
I = imread(image_files.ref_image);

% Using the user inputs, define the First and Final point Coordinates, the subset size and the subset spacing
Xmin = str2double( get(handles.FirstPointEditX, 'String') );
Ymin = str2double( get(handles.FirstPointEditY, 'String') );
Xmax = str2double( get(handles.FinalPointEditX, 'String') );
Ymax = str2double( get(handles.FinalPointEditY, 'String') );
HalfSubSize = floor( str2double( get(handles.SubsetSizeEdit, 'String') ) / 2 );
SubSpace = str2double( get(handles.SubsetSpacingEdit, 'String') );

% Darken outside the area of interest
I(:,1:Xmin) = I(:,1:Xmin) - 100;
I(1:Ymin, Xmin:Xmax) = I(1:Ymin, Xmin:Xmax) - 100;
I(Ymax:end, Xmin:Xmax) = I(Ymax:end, Xmin:Xmax) - 100;
I(:,Xmax:end) = I(:,Xmax:end) - 100;

% Display the image, draw a blue rectangle around the useful pixels, draw a red square to represent the subset size
axes(handles.RefImage);
image(I, 'CDataMapping', 'scaled');
colormap('gray');
set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
rectangle('Position',[Xmin,Ymin,Xmax-Xmin,Ymax-Ymin], 'LineWidth',2,'EdgeColor','blue');
rectangle('Position',[Xmin-HalfSubSize,Ymin-HalfSubSize, 2*HalfSubSize, 2*HalfSubSize], 'LineWidth',2,'EdgeColor','red');

%{
% Create a grid showing all the points to correlate in green
num_subsets_X = floor( (Xmax-Xmin)/SubSpace );
num_subsets_Y = floor( (Ymax-Ymin)/SubSpace );

% Define the X and Y coordinates of each subset center
mesh_X = Xmin:SubSpace:(num_subsets_X-1)*SubSpace+Xmin;
mesh_Y = Ymin:SubSpace:(num_subsets_Y-1)*SubSpace+Ymin;
[Xgrid, Ygrid] = meshgrid( mesh_X, mesh_Y );
XVect = reshape(Xgrid,numel(Xgrid),1);
YVect = reshape(Ygrid,numel(Ygrid),1);
hold on;
scatter(XVect, YVect, '.g');
hold off;
%}

end % function







% --- Executes on button press in DefPreviewButton.
function DefPreviewButton_Callback(hObject, eventdata, handles)
% The preview button will display the reference image and illustrate the input values


% Get the file path of the images chosen by the user
image_files = getappdata(handles.figure1, 'image_files');
if isequal(image_files.def_image, '')
    errordlg('The deformed image is invalid','Invalid deformed image','modal');
    return;
end

% Load the deformed image into a matrix as part of the preview
% The if is placed depending on if multiple def images were chosen.
if iscell(image_files.def_image) == true
    I = imread(image_files.def_image{1});
else
    I = imread(image_files.def_image);
end

% Load the Initial Guess
initial_guess = getappdata(handles.figure1, 'initial_guess');

% Using the user inputs, define the First and Final point Coordinates, the subset size and the subset spacing
Xmin = str2double( get(handles.FirstPointEditX, 'String') );
Ymin = str2double( get(handles.FirstPointEditY, 'String') );
HalfSubSize = floor( str2double( get(handles.SubsetSizeEdit, 'String') ) / 2 );

% Display the image, draw a green subset around at the initial displacement
axes(handles.DefImage);
image(I, 'CDataMapping', 'scaled');
colormap('gray');
set(gca, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1]);
rectangle('Position',[Xmin+initial_guess.u-HalfSubSize,Ymin+initial_guess.v-HalfSubSize, ...
                      2*HalfSubSize, 2*HalfSubSize], 'LineWidth',2,'EdgeColor','green');
                  
% Write the results of the initial guess in the edit boxes
set(handles.u_guessEdit, 'string', num2str(initial_guess.u));
set(handles.v_guessEdit, 'string', num2str(initial_guess.v));

end % function


%**********END PREVIEW BUTTONS************************







%**********RUN BUTTON************************

% --- Executes on button press in RunCorrButton.
function RunCorrButton_Callback(hObject, eventdata, handles)

% The RUN CORRELATION button begins the entire correlation process
% Perform initial input check to make sure nothing absurb has happened with the inputs
SubsetSizeEdit_Callback(handles.SubsetSizeEdit, eventdata, handles);
SubsetSpacingEdit_Callback(handles.SubsetSpacingEdit, eventdata, handles);
FirstPointEditX_Callback(handles.FirstPointEditX, eventdata, handles);
FirstPointEditY_Callback(handles.FirstPointEditY, eventdata, handles);
FinalPointEditX_Callback(handles.FinalPointEditX, eventdata, handles);
FinalPointEditY_Callback(handles.FinalPointEditY, eventdata, handles);

% If an error was found somewhere in these initial checks, stop the program
error_tracker = getappdata(handles.figure1, 'tracker');
if error_tracker.error_found == true
    error_tracker.error_found = false;
    setappdata(handles.figure1, 'tracker', error_tracker);
    errordlg('One of the Inputs was incorrect, Correlation Stopped','Invalid User Input','modal');
    return;
end

% Get the file paths of the images chosen by the user, check to see if they're valid
image_files = getappdata(handles.figure1, 'image_files');
if isequal(image_files.ref_image, '')
    errordlg('The reference image is invalid','Invalid reference image','modal');
    return;
elseif isequal(image_files.def_image, '')
    errordlg('The deformed image is invalid','Invalid deformed image','modal');
    return;
end




%_________If no errors were detected, start storing the inputs___________


% ---------Image Options-------------------

% Get the reference image file
global ref_image;
ref_image = im2double(imread(image_files.ref_image));

% Input_info will be used in Saving Data after Correlation. Store the ref image file path
global Input_info;
Input_info = cell(3, 1);
Input_info(1) = {image_files.ref_image};

% Get the deformed image file (there are two cases: either 1 or several images)
global def_image;
if iscell(image_files.def_image) == false     % only 1 image --> iscell = false
    def_image = im2double(imread(image_files.def_image));
    Input_info(2) = {image_files.def_image};
    N = 1;
else                                          % more than 1 image --> iscell = true
    def_image = im2double(imread(image_files.def_image{1}));
    Input_info(2) = {image_files.def_image{1}};
    N = numel(image_files.def_image);
end

% Using the user inputs, define the First and Final point Coordinates, the
% subset size and spacing, and the initial guesses for U and V.
global Xp_first;
global Yp_first;
global Xp_last;
global Yp_last;
Xp_first = str2double( get(handles.FirstPointEditX, 'String') );
Yp_first = str2double( get(handles.FirstPointEditY, 'String') );
Xp_last = str2double( get(handles.FinalPointEditX, 'String') );
Yp_last = str2double( get(handles.FinalPointEditY, 'String') );

global subset_space;
subset_space = str2double( get(handles.SubsetSpacingEdit, 'String') );

global subset_size;
subset_size = floor( str2double( get(handles.SubsetSizeEdit, 'String') ) );

% What was the inital guess?
global qo;
initial_guess = getappdata(handles.figure1, 'initial_guess');
qo = zeros(6, 1);
qo(1) = initial_guess.u;
qo(2) = initial_guess.v;

% ----------------------------------------





% ---------Subset Deformation Options-------------------

% Determine the selected order for the interpolation
SubsetDef = get(handles.Subset_Deformations_DropBox, 'Value');

% ------------------------------------------------------



% ---------Interpolation Options-------------------

% Determine the selected order for the interpolation
global interp_order;
str = get(handles.Interp_Method_DropBox, 'String');
val = get(handles.Interp_Method_DropBox, 'Value');
interp_order = str{val};

% Find the buffer selected for the interpolation sector
global interp_buffer;
interp_buffer = 3; % This value was found to be optimal

% ----------------------------------------



% ---------Image Comparison Options-------------------

% Determine the selected order for the interpolation
ImageComp = get(handles.Image_Comp_DropBox, 'Value');

% ------------------------------------------------------




% ---------Optimization Options-------------------

% Determine which optimization scheme to use
global optim_method;
optim_method = strcat('Newton Raphson');
%optim_method = strcat('fmincon');

% These stopping conditions are ideal
global TOL;
TOL(1) = 10^(-8);%10^(-7);       % TOL(1) = Delta_C
TOL(2) = 10^(-5)/2;%10^(-4)/2;     % TOL(2) = Delta_q

% Set the max number of iterations for each optimization
global Max_num_iter;
%Max_num_iter = 10;      % Iterations should remain below 5, but to be safe let's put 10
%Max_num_iter = 20;
Max_num_iter = 40;
% ----------------------------------------



% ---------Regular or Iterative DIC-------------------

% Use consecutive method?
global last_WS;
global do_incremental;
if ImageComp == 1
    do_incremental = false;
else
    do_incremental = true;
end

% ----------------------------------------------------



% Perform final checks before passing inputs to the main computational function
% Make sure that the subset is within the limits of the image
[endY,endX] = size(ref_image);
if Xp_first-floor(subset_size/2) < 1 || Yp_first-floor(subset_size/2) < 1 || Xp_last+floor(subset_size/2) > endX || Yp_last+floor(subset_size/2) > endY
    errordlg(strcat(sprintf('The subset size and given coordinates are such that some of the subset\n'), ...
                    sprintf('values are outside the image boundaries\nPlease verify your'), ...
                            'Subset values are outside the image' ), 'modal');
   return
end



% Initialize a previous workspace for later computations
num_subsets_X = floor( (Xp_last-Xp_first)/subset_space ) + 1;
num_subsets_Y = floor( (Yp_last-Yp_first)/subset_space ) + 1;
mesh_gridX = Xp_first:subset_space:(num_subsets_X-1)*subset_space+Xp_first;
mesh_gridY = Yp_first:subset_space:(num_subsets_Y-1)*subset_space+Yp_first;
[last_WS.orig_gridX, last_WS.orig_gridY] = meshgrid( mesh_gridX, mesh_gridY);
last_WS.TOTAL_DEFORMATIONS = zeros(num_subsets_Y, num_subsets_X, 20);


% Record the date and time of the current run.
global date_time_run;
date_time_run = now;

    
% N = number of images to pass through DIC
for ii = 1:N

    
    if do_incremental == true && ii > 1
        % The last deformed image becomes the new reference image this
        % implies that the area of interest may warp with the object.
        ref_image = im2double(imread(image_files.def_image{ii-1}));
        Input_info(1) = {image_files.def_image{ii-1}};
        
        Xp_first = floor(min(min( last_WS.orig_gridX + last_WS.TOTAL_DEFORMATIONS(:,:,1) ))) - 2;
        Xp_last  = ceil(max(max( last_WS.orig_gridX + last_WS.TOTAL_DEFORMATIONS(:,:,1) ))) + subset_space;
        Yp_first = floor(min(min( last_WS.orig_gridY + last_WS.TOTAL_DEFORMATIONS(:,:,2) ))) - 2;
        Yp_last  = ceil(max(max( last_WS.orig_gridY + last_WS.TOTAL_DEFORMATIONS(:,:,2) ))) + subset_space;
            
    end

    
    if ii > 1
        % Get the next deformed image file if there's more than 1 def image
        def_image = im2double(imread(image_files.def_image{ii}));
        Input_info(2) = {image_files.def_image{ii}};
    end
    
    % Enter the "Tools and Files" directory
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
    %catch
    %    le = lasterror;
    %    cd('..');
    %    errordlg(sprintf('An error occurred during correlation:\n%s', le.message),'Error during Correlation','modal');
    %    rethrow(le);
    %    return;
    %end
    
    
    
end % for
cd('Tools and Files');
icon = load('smiley_icon.mat');
cd('..');
msgbox(sprintf('The images were correlated successfully \nand are ready for Post-Processing!'),...
       'Correlation Complete','custom', icon.smiley);

end % function

%**********END RUN BUTTON************************
%_______________________________________________________________________________________________________________________
















% --- Executes on button press in ExtraButton.
function ExtraButton_Callback(hObject, eventdata, handles)
% hObject    handle to ExtraButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end % function

