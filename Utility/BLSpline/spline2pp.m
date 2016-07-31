function pp=spline2pp(sp)
% function pp=spline2pp(sp);
%
% Convert spline1D structure into pp structure
%

zz=sp.zz;
zzxx=sp.zzxx;

dx=reshape(sp.dx,[],1);
zcol=zeros(size(dx));

BX=[zcol zcol 1./dx zcol];
AX=[zcol zcol -1./dx 1+zcol];
CX=[-1./dx 3+zcol -2*dx zcol];
DX=[1./dx zcol -dx zcol];

% if datenum(version('-date')) <= datenum('August 03, 2006')
%     mybsxfun=@(f,C,z) (f(C,repmat(z,1,size(C,2))));
% else
%     mybsxfun=@(f,C,z) (bsxfun(f,C,z));
% end

coefs=(bsxfun2006(@times,AX,zz(1:end-1)) + bsxfun2006(@times,BX,zz(2:end))) + ...
      (bsxfun2006(@times,CX,zzxx(1:end-1)) + bsxfun2006(@times,DX,zzxx(2:end)));

pp=struct('Tag', 'pp1d', ...
    'form', 'pp', ...
    'breaks', sp.xgrid, ...
    'coefs', coefs, ...
    'pieces', sp.nx-1, ...
    'order', 4, ...
    'dim', 1);

if isfield(sp,'Pname')
    pp.Pname=sp.Pname;
end

if isfield(sp,'Vname')
    pp.Pname=sp.Vname;
end

end

function C=polyprod(A,B)
%
% Product of polomial A and B
%
    C=zeros(size(A));
    order=size(C,2)-1;
    k2i=@(k) (order-k+1);
    for n=0:order
        imin=0;
        imax=n;
        iA=imin:imax;
        iB=n-iA;
        C(:,k2i(n))=sum(A(:,k2i(iA)).*B(:,k2i(iB)),2);
    end
end