function [s,minrc] = fullfindEV(n,c,A,varstatus,pi,phase1)
% Returns the index of the entering variable and it's reduced cost,
% or returns 0 if no entering variable exists
% Input:
%   n           = number of variables
%   c           = nx1 cost vector
%   A           = mxn constraint matrix
%   varstatus   = 1xn vector, varstatus(i) = position in basis of variable i,
%               or 0 if variable i is nonbasic
%   pi          = mx1 dual vector
%   phase1      = boolean, phase1 = true if Phase 1, or false otherwise
% Output:
%   s           = index of the entering variable
%   minrc       = reduced cost of the entering variable
    
    if ~phase1
        varstatus = varstatus(1:n);
    end
    
    nonbasicvars = find(varstatus == 0);
    N = A(:,nonbasicvars); 
    
    if ~phase1
        cN = c(nonbasicvars);
    else
        cN = c;
        for i = 1:length(nonbasicvars)
            if nonbasicvars(i) <= n
                cN(nonbasicvars(i)) = 0;
            end
        end
        cN = cN(nonbasicvars);
    end   
        
    %calculate reduced cost 
    rc = cN.' - (pi).'*N;
    
    [minrc,sIndex] = min(rc);
    s = nonbasicvars(sIndex);
    
    if minrc >= 0 
        [minrc, s] = deal(0);
    end
    
end