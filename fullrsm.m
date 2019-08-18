function [result,z,x,pi]  =   fullrsm(m,n,c,A,b)
% Solves a linear program using Gauss-Jordon updates
% Assumes standard computational form
% Performs a Phase I procedure starting from an artificial basis
% Input:
%   m,n     = number of constraints and variables
%   c       = nx1 cost vector
%   A       = mxn constraint matrix
%   b       = mx1 rhs vector
% Output:
%   result  = 1 if problem optimal, 0 if infeasible, -1 if unbounded
%   z       = objective function value
%   x       = nx1 solution vector
%   pi      = mx1 dual vector
    
    %INITIALISATION
    result = 2;
    phase1 = 1;
    
    basicvars = n+1 : n+m;      %indicies of basic variables 
    [B, Binv] = deal(eye(m)); 
    N = A; 
    A = [N,B];
    xB = Binv * b;              %basic variable values
    cB = ones(m,1);             %cost of each artificial variable is one
    c = [c;cB];                 %new c vector with artifical variables 
    
    varstatus = zeros(1,n+m);
    for i =1:n+m
        if ismember(i, basicvars)
            varstatus(i) = find(basicvars==i);
        end
    end   

    %ITERATIONS
    
    while result == 2 
        
        pi = (cB.'*Binv).';
        
        %find minimum reduced cost
        [s, ~] = fullfindEV(n,c,A,varstatus,pi,phase1);
        
        %If at optimality
        if s==0
            if ~phase1
                result = 1;
                varstatus = varstatus(1:n);
            end
            
            %Compute solution and objective
            x = zeros(n,1);
            for i=1:length(varstatus)
                if varstatus(i) ~= 0
                    x(i) = xB(varstatus(i));
                end
            end
            z = cB.'*xB;    
            
            if phase1
                %Positive objective = infeasibility
                if z > 0
                    result = 0;
                    z = NaN;
                    [x,pi] = deal([]);
                    break;
            
                else
                    %End of phase 1
                    phase1 = 0;
                    
                    %Remove all artificial variables not in the basis
                    nonbasicvars = find(varstatus == 0);
                    varstatus(nonbasicvars(nonbasicvars > n)) = [];
           
                end
 
            end
            
        else
            
            %find leaving variable
            BinvAs = Binv*A(:,s);
            [r,~] = fullfindLV(n,xB,BinvAs, phase1, basicvars);
            
            %check for unboundedness
            if r == 0
                result = -1;
                z = NaN;
                pi = [];
                x = [];
                break;
                
            else
                
                [varstatus,basicvars, cB, Binv, xB]  =  fullupdate(m, c, s, r, BinvAs, phase1, varstatus, basicvars, cB, Binv, xB);
                z = cB.'*xB; 
                %End phase 1 if no art variables in basis
                if z == 0 && phase1
                   phase1 = 0;
                   %define cB again
                   cB = c(basicvars);
                end
                    
            end
            
        end
        
    end
     
end                