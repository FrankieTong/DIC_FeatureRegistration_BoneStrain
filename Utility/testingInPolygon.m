clf; [rand_x rand_y] = ginput(10); 

% plot(rand_x,rand_y); 

% k = convhull(rand_x,rand_y);

% hold on; plot(rand_x(k),rand_y(k),'r-'); 
hold on; plot(rand_x,rand_y,'r-'); 
% hold on; plot(rand_x,rand_y,'b.');

[ran_input_x ran_input_y] = ginput(2);

inpolygon(ran_input_x(1),ran_input_y(1),rand_x,rand_y)
inpolygon(ran_input_x(2),ran_input_y(2),rand_x,rand_y)