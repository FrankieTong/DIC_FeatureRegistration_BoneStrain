%scripting McGill DIC
test0000_histeq = imread('D:\Users\hardisty\Data\Mike\Dropbox\DIC_Test\Enhanced_Images\test0000_histeq.tif');
test0250_histeq = imread('D:\Users\hardisty\Data\Mike\Dropbox\DIC_Test\Enhanced_Images\test0250_histeq.tif');

%global ref_image;
%global def_image;

ref_image = test0000_histeq;
def_image = test0250_histeq;

%global subset_size;
%global subset_space;

subset_size = 35;
subset_space = 2;

%global qo;

qo = [0;0;0;0;0;0];

%global Xp_first;
%global Yp_first;
%global Xp_last;
%global Yp_last;
%global Xp;
%global Yp;

Xp_first =	143;
Yp_first =	229;
Xp_last =	188;
Yp_last =	290;
Xp=Xp_first;
Yp=Yp_first;

%global interp_order;

interp_order = 'Quintic (5th order)';

%global TOL;

TOL = [1.00E-08, 5.00E-06];

%global optim_method;

optim_method = 'Newton Raphson';

%global Max_num_iter;

Max_num_iter = 40;

GUI_DIC_Computations_J( 'First' );