function testspline
% function testspline

[p n ext] = fileparts(which('findidxmex'));
if strcmp(ext,'.m')
    BLspline_install();
end

x=pi*(cumsum(rand(1,4))-rand*2);

y=rand(size(x));

P = polyfit(x,y,3);

P1 = polyderiv(P); 
P2 = polyderiv(P1);
P3 = polyderiv(P2);

% Provide first or second derivatives at the boundary
options = struct('leftzxx', polyval(P2,x(1)), ...
                 'rightzxx', polyval(P2,x(end)), ...
                 'leftzx', polyval(P1,x(1)), ...
                 'rightzx', polyval(P1,x(end)));
             
s =  spline1d(x,y,[],'InitOnly',options);

xi = linspace(min(x),max(x),129); % fine grid
xii = xi(1:5:end); % less fine

figure(1);
clf;
% Spline must match exactly the input Polynomial
subplot(2,2,1);
plot(x,y,'or',... 
     xii,polyval(P,xii),'g+',...
     xi,spline1d([],[],xi,s),'b');
title('Interpolation');  
subplot(2,2,2);
plot(xii,polyval(P1,xii),'g+',...
     xi,spline1d([],[],xi,s,struct('dorder',1)),'b');
title('First derivative'); 
subplot(2,2,3);
plot(xii,polyval(P2,xii),'g+',...
     xi,spline1d([],[],xi,s,struct('dorder',2)),'b');
title('Second derivative'); 
subplot(2,2,4);
plot(xii,polyval(P3,xii),'g+',...
     xi,spline1d([],[],xi,s,struct('dorder',3)),'b');
title('Third derivative'); 
 
x=cumsum(rand(1,6)); y=randn(size(x)); xi = linspace(min(x),max(x),513);
figure(2);
clf;
plot(x,y,'or',...
    xi,spline1d(x,y,xi,[],struct('leftnotaknot',1,'rightnotaknot',1)),'b', ...
    xi,interp1(x,y,xi,'spline'),'g');

% A test program

x=(0:60:330)/180*pi;
x = x + ((rand(size(x))-2)*20)/180*pi;
x = x(randperm(length(x)));

z=randn(size(x));
options=struct('periodic',1);

xi = (-720:1:1080)/180*pi;
zi = spline1d(x,z,xi,[],options);

figure(3);
plot(unwrap([x x(1)]),[z z(1)],'or',...
     xi,zi,'b');

testderivative();
% Bruno
