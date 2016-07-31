function P=scalefun(P, S)
% function P=scalefun(P, S);
%
% Multiply one Function P by a scalar S
%

if isstruct(P)
    switch P.Tag
        case 'spline1d structure',
            P.zz=S*P.zz;
            P.zzxx=P.zzxx*S;
        otherwise
            P.coefs=P.coefs*S;
    end
elseif isnumeric(P)
    P=P*S;
end