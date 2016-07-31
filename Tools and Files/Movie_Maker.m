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


% Digital Image Correlation: Movie Maker
% Honours Thesis Research Project
% McGill University, Montreal, Quebec, Canada
% Created on:  July 16, 2007
% Modified on: July 24, 2007


-----------------------------------------------------------
|       DIGITAL IMAGE CORRELATION: MOVIE MAKER            |
-----------------------------------------------------------

This M-file will take several images and make them into a .AVI movie file. 
This program was originally designed to illustrate the evolution of strains
after having performed DIC on several images.

%}

% The image files must be placed into the proper folder and in the proper
% order.

function Movie_Maker( current_dir, image_dir, FPS, movie_folder)

% Change the current directory to the directory where the images are saved
cd(image_dir);

% The name of the movie will be the same as the directory, find the slashes
% in the full path to extract the name
slashes = strfind(image_dir, '\');

% Extracting the movie's name from the full path of the image_dir
movie_name = strcat(image_dir( slashes(end):end ), '.avi');

% Get a listing of all the files in the current directory
image_list = dir;

% Create a .avi object to form the movie. FPS = frames per second
aviobj = avifile(movie_name,'fps',FPS);

% Loop through and add each image as a frame in the movie
for i = 1:numel(image_list)
    
    if isequal(image_list(i).name, '.') == false && isequal(image_list(i).name, '..') == false
            frame = imread(image_list(i).name);
            aviobj = addframe(aviobj,frame);
    end
    
end

% Close the object when movie is completed
aviobj = close(aviobj);

% Move the file to the output folder
movefile(movie_name, movie_folder );

% Return to the original directory
cd(current_dir);

end % function