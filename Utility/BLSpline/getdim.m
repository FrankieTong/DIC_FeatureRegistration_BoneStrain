function dim=getdim(s)

if isnumeric(s) % Polynomial coefficients
%     s = struct('Tag', 'poly1d',...
%         'coefs', funstruct);
    dim=1;
    return
end

if isfield(s,'nvar')
    dim=s.nvar;
    return
end
Tag=s.Tag;
if strfind(Tag, '1d') % 1D interpolation
    dim=1;
elseif strfind(Tag, '2d') % 2D interpolation
    dim=2;
elseif strfind(Tag, '3d') % 3D interpolation
    dim=3;
elseif strfind(Tag, 'splinend') % ND spline
    dim=splineinfo(s, 'ndim');
elseif strfind(Tag, 'nd')
    if isfield(s,'po') % ND interpolation
        dim=size(s.po,2);
    else
        error('getdim: unknown number of dimensions');
    end
else
    error('getdim: unknown number of dimensions');
end