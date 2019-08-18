function [varstatus,basicvars,cB,Binv,xB] = fullupdate(m,c,s,r,BinvAs,phase1,varstatus,basicvars,cB,Binv,xB)
% Updates the basis representation.
%
%   Input:
%       m = number of constraints
%       c = nx1 cost vector
%       s = index of entering variable
%       r = position in the basis of the leaving variable
%       BinvAs = mx1 Binv*As vector
%       phase1 = boolean, phase1 = true if Phase 1, or false otherwise
%       varstatus = 1xn vector, varstatus(i) = position in basis of variable i,
%                   or 0 if variable i is nonbasic
%       basicvars = 1xm vector of indices of basic variables
%       cB = mx1 basic cost vector
%       Binv = mxm basis inverse matrix
%       xB = mx1 basic variable vector
%
%   Output:
%       varstatus = 1xn updated varstatus vector
%       basicvars = 1xm updated basicvars vector
%       cB = mx1 updated basic cost vector
%       Binv = mxm updated basis inverse matrix
%       xB = mx1 updated basic variable vector%

    n = length(varstatus) - m;
    nonbasicvars = find(varstatus == 0);
    aug = [xB Binv BinvAs];
    cols = size(aug,2);
    aug(r,:) = aug(r,:)/aug(r,cols);
    
    %GJ Pivot
    for i = 1:m
        if i ~= r && BinvAs(i) ~= 0
            aug(i,:) = aug(i,:) - (aug(i,cols)/aug(r,cols))*(aug(r,:));
        end
    end
    
    if basicvars(r) > n
        %move entering and leaving variables
        arti = basicvars(r);
        basicvars(r) = s;
        nonbasicvars(nonbasicvars == s) = basicvars(r);
        varstatus(arti) = 0;
        varstatus(s) = r;
    else
        varstatus(basicvars(r)) = 0;
        varstatus(s) = r;
        basicvars(r) = s;
        nonbasicvars(nonbasicvars == s) = basicvars(r);
    end
    
    if phase1 && isempty(basicvars(basicvars>n))
        %remove artifical variables not in the basis
        varstatus(nonbasicvars(nonbasicvars > n)) = [];
    end
    
    %update function outputs
    if phase1
        cB(r) = 0;
    else
        cB(r) = c(s);
    end
    Binv = aug(:,2:cols-1);
    xB = aug(:,1);
  
    
end