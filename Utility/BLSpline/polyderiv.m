function DP=polyderiv(P, ivar)
% function DP=polyderiv(P, ivar);
%
% Return the derivative structure of a function structure P
% with respect to variable #ivar
%
% Last update: 06/August/2008: spline ND
%              23/Oct/2008: extendedfun_nd
%

if isstruct(P)
    nd=getdim(P);
    if nd>1
        % Order of the variable, by default same order when building structure
        varorder=getoption(P,'varorder',(1:nd));
        ivar=varorder(ivar);
    else % force ivar to 1 in 1D case
        ivar=1;
    end
    switch P.Tag
        case 'poly1d',
            DP=struct('Tag','poly1d',...
                'order', max(P.order-1,0),...
                'coefs', polyderiv1(P.coefs));
        case {'poly2d' 'poly3d' 'polynd'}
            DP=P;
            DP.order=max(DP.order-1,0);
            k=DP.po(:,ivar);
            if any(k)
                % Remove constant term
                DP.po(k==0,:)=[];
                DP.coefs(k==0,:)=[];
                k(k==0)=[];
                % New coefs and order
                DP.coefs=DP.coefs.*k;
                DP.po(:,ivar)=k-1;
            else % special case where all derivatives vanish
                DP.po=zeros(1,nd);
                DP.coefs=0;
            end
        case 'spline1d structure',
            DP=ppderiv1(spline2pp(P)); % convert to pp, call nested function
        case 'pp1d',
            DP=ppderiv1(P); % call nested function below
        case 'polyspline2d',
            if ivar==1 % derivative of spline (wrt first var)
                DP=P;
                CellDeriv=arrayfun(@polyderiv,P.PolycoefFct,...
                                   'UniformOutput',false);
                DP.PolycoefFct=[CellDeriv{:}];
            else %if ivar==2, derivative of polynomial (wrt second var)
                DP=P;
                DP.order=max(DP.order-1,0);
                DP.PolycoefFct=polyderiv1(DP.PolycoefFct);
            end
        case {'splinend structure'}
            DP = P;
            % Get the derivative order
            if isfield(DP,'dorder')
                tot_order=DP.dorder;
            else
                tot_order=zeros(1,nd);
            end
            % One mor order on the variable ivar
            tot_order(ivar) = tot_order(ivar) + 1;
            DP.dorder = tot_order;
        case {'extendedfun_nd'}
            DP = P;
            DP.derivevar = ivar;
        otherwise
            error('polyderiv: unknown Tag')
    end
else % Polynomial coeffcients
    DP=polyderiv1(P);
end

end

function DP=polyderiv1(P) % Derivative polynomial

if numel(P)==1 % constant
    DP=scalefun(P,0); % returns zero
else
    DP=arrayfun(@scalefun, P(1:end-1), (length(P)-1:-1:1), ...
                'UniformOutput',false); % cell form
    DP=[DP{:}]; % structure array, or numerical array
end

end

function DP=ppderiv1(P) % Derivative piecewise-polynomial

DP=P;
DP.order=max(P.order-1,1);
DP.coefs=zeros(DP.pieces,DP.order);
if P.order<=1
    return
end
% Derivative on each interval
for n=1:size(DP.coefs,1)
    DP.coefs(n,:)=polyderiv1(P.coefs(n,:));
end

end