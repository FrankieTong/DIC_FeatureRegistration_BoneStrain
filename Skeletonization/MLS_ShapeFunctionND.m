% Modified from:

% *************************************************************************
%                 TWO DIMENSIONAL ELEMENT FREE GALERKIN CODE
%                            Nguyen Vinh Phu
%                        LTDS, ENISE, Juillet 2006
% *************************************************************************

function [phi,dphidn] = MLS_ShapeFunctionND(pt,index,node,di,form, lambda)

% Compute the MLS shape function at point pt for all nodes within the
% support of this point pt.
% Basis used is linear basis pT = [1 x y]

% --------------------------------------
%      compute the moment matrix A
% --------------------------------------

dimension = size(node,2);

A    = zeros(1 + dimension,1 + dimension) ;
dAdn = cell(1,dimension);

for i = 1:dimension
    dAdn{1,i} = zeros(1 + dimension,1 + dimension);
end

dwdn = zeros(size(index,2),size(node,2));

for m = 1 : size(index,2)
    xi = node(index(m),:) ;
    [wi,dwidn] = circle_splineND(pt,xi,di(index(m)),form);
    
    p = [1 xi];
    pTp = p'*p;
    
    A    = A    + wi*pTp ;
    
    for i = 1:dimension
        dAdn{1,i} = dAdn{1,i} + dwidn(i)*pTp;       
    end
    
    % store weight function and its derivative at node I for later use
    w(m)    = wi ;
    dwdn(m,:) = dwidn ;
end

clear wi; clear dwidn; clear xi;

%Adjust the dampening factor if needed
if exist('lambda','var')
    A = A + lambda*diag(diag(A));
    
    for i = 1:dimension
        dAdn{1,i} = dAdn{1,i} + lambda * diag(diag(dAdn{1,i}));
    end
end
    

p  = [1 pt]';

% --------------------------------------
%         compute  matrix c(x)
% --------------------------------------

% A(x)c(x)   = p(x)
% A(x)c,k(x) = b,k(x)
% Backward substitutions, two times for c(x), two times for c,k(x) k
% =1,2



% Using LU factorization for A
[L,U,PERM] = lu(A) ;

for i = 1 : 1+dimension
   
    s = zeros(1,1+dimension);
    s(i) = 1;
    
    if i == 1
        C = PERM*p;
    else
        C = PERM*(s'-dAdn{1,i-1}*c(1:1+dimension,1));
    end
    
    for j = 1: 1+dimension
       
        D(:,j) = C(j);
        
        for k = j-1:-1:1
            D(:,j) = D(:,j) - L(j,k)*D(:,k);
        end
        
    end
    
    for j = 1+dimension:-1:1
       
        c(j,i) = D(:,j);
        
        for k = 1+dimension:-1:j+1
            c(j,i) = c(j,i) - U(j,k)*c(k,i);
        end
        
        c(j,i) = c(j,i) / U(j,j);
        
    end
    
end

for m = 1 : size(index,2)
    xi = node(index(m),:) ;
    piT = [1 xi]';
    phi(m) = c(:,1)'* piT*w(m) ;
    
    for i = 1:dimension
        dphidn(m,i) = c(:,i+1)'*piT*w(m) + c(:,1)'*piT*dwdn(m,i);
    end
    
end






% for i = 1 : 3
%     if i == 1         % backward substitution for c(x)
%         C = PERM*p;
%     elseif i == 2     % backward substitution for c,x(x)
%         C = PERM*([0 1 0]' - dAdx*c(1:3,1));
%     elseif i == 3     % backward substitution for c,y(x)
%         C = PERM*([0 0 1]' - dAdy*c(1:3,1));
%     end
% 
%     D1 = C(1);
%     D2 = C(2) - L(2,1)*D1;
%     D3 = C(3) - L(3,1)*D1 - L(3,2)*D2 ;
% 
%     c(3,i) = D3/U(3,3) ;
%     c(2,i) = (D2 - U(2,3)*c(3,i))/(U(2,2));
%     c(1,i) = (D1 - U(1,2)*c(2,i) - U(1,3)*c(3,i))/(U(1,1));
%     
% end
% 
% for m = 1 : size(index,2)
%     xi = node(index(m),:) ;
%     piT = [1 xi(1,1) xi(1,2)]';
%     %piT = [1 xi(1,1) xi(1,2) xi(1,2)^2 xi(1,2)^2]';
%     phi(m) = c(:,1)'* piT*w(m) ;
%     dphidx(m) = c(:,2)'*piT*w(m) + c(:,1)'*piT*dwdx(m) ;
%     dphidy(m) = c(:,3)'*piT*w(m) + c(:,1)'*piT*dwdy(m);
% end




