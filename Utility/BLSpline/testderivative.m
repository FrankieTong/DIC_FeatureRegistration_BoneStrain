function s=testderivative
% function s=testderivative

[p n ext] = fileparts(which('findidxmex'));
if strcmp(ext,'.m')
    BLspline_install();
end

nx = 5;
ny = 7;

x = rand(1,nx); x=cumsum(0.2+0.5*x);
y = rand(1,ny); y=cumsum(0.2+0.5*y);
z = randn(ny,nx);

theta=5/180*pi;
xi=linspace(min(x),max(x),257);
yi=linspace(min(y),max(y),250);
[X Y]=meshgrid(xi,yi);
xc = mean(xi([1 end]));
yc = mean(xi([1 end]));
[X Y] = deal(xc + cos(theta)*(X - xc) + sin(theta)*(Y - yc), ...
             yc - sin(theta)*(X - xc) + cos(theta)*(Y - yc));

options = struct('economy', 0, ...
                 'leftnotaknot',1, 'rightnotaknot',1,...
                 'zndgrid', 0);

fprintf('splinend 2D\n')

% equivalent to this
zi2 = interp2(x,y,z,X,Y,'spline')';

s = splinend(2, x, y, z, xi, yi', 'InitOnly', options);
X = X.'; Y = Y';
zi1 = evalfct(s, X, Y);

fig=figure(4);
clf(fig);
ax=subplot(1,2,1,'Parent',fig);
imagesc(yi,xi,zi1,'Parent',ax);
title(ax,'spline function f (splinend)');
ax=subplot(1,2,2);
imagesc(yi,xi,zi2,'Parent',ax);
title(ax,'spline function f (Matlab)');

fig=figure(5);
clf(fig);
s.dorder=[0 1];
dz1=evalfct(s, X, Y);
ax=subplot(3,3,1,'Parent',fig);
imagesc(yi,xi,dz1,'Parent',ax);
title(ax,'\partialf/\partialx');

s.dorder=[1 0];
dz1=evalfct(s, X, Y);
ax=subplot(3,3,2,'Parent',fig);
imagesc(yi,xi,dz1,'Parent',ax);
title(ax,'\partialf/\partialy');

s.dorder=[1 1];
dz1=evalfct(s, X, Y);
ax=subplot(3,3,3,'Parent',fig);
imagesc(yi,xi,dz1,'Parent',ax);
title(ax,'\partial^2f/\partialx\partialy');

s.dorder=[1 2];
dz1=evalfct(s, X, Y);
ax=subplot(3,3,4,'Parent',fig);
imagesc(yi,xi,dz1,'Parent',ax);
title(ax,'\partial^3f/\partialx^2\partialy');

s.dorder=[2 1];
dz1=evalfct(s, X, Y);
ax=subplot(3,3,5,'Parent',fig);
imagesc(yi,xi,dz1,'Parent',ax);
title(ax,'\partial^3f/\partialx\partialy^2');

s.dorder=[2 2];
dz1=evalfct(s, X, Y);
ax=subplot(3,3,6,'Parent',fig);
imagesc(yi,xi,dz1,'Parent',ax);
title(ax,'\partial^4f/\partialx^2\partialy^2');

s.dorder=[2 3];
dz1=evalfct(s, X, Y);
ax=subplot(3,3,7,'Parent',fig);
imagesc(yi,xi,dz1,'Parent',ax);
title(ax,'\partial^5f/\partialx^3\partialy^2');

s.dorder=[3 2];
dz1=evalfct(s, X, Y);
ax=subplot(3,3,8,'Parent',fig);
imagesc(yi,xi,dz1,'Parent',ax);
title(ax,'\partial^5f/\partialx^2\partialy^3');

s.dorder=[3 3];
dz1=evalfct(s, X, Y);
ax=subplot(3,3,9,'Parent',fig);
imagesc(yi,xi,dz1,'Parent',ax);
title(ax,'\partial^6f/\partialx^3\partialy^3');

end
