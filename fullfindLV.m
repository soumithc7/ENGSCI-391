function [r, minratio]  =  fullfindLV(n, xB, BinvAs, phase1, basicvars)
% Returns the position in the basis of the leaving variable,
% or returns 0 if no leaving variable exists
% Input:
%   m           = number of constraints
%   n           = number of variables 
%   xB          = mx1 basic variable vector
%   BinvAs      = mx1 vector of Binv*As
%   phase1      = boolean, phase1 = true if Phase 1, or false otherwise
%   basicvars   = 1xm vector of indices of basic variables
% Output:
%   r           = position in the basis of the leaving variable
%   minratio    = minimum ratio from ratio test
    
    %Check for unboundedness
    if BinvAs <= 0
        [r,minratio] = deal(0);
    else
        
        %EXTENDED LEAVING VARIABLE CRITERION
        i = find(basicvars > n);
        arti = find(BinvAs(i) ~= 0);
        
        if ~phase1 && ~isempty(arti)
            r = i(1);
            minratio = 0;
        else
            ratioMatrix = [xB BinvAs];
            for i = 1:size(ratioMatrix, 1)
                if ratioMatrix(i,2) <= 0
                    ratioMatrix(i,:) = NaN;
                end
            end
            ratios = ratioMatrix(:,1)./ratioMatrix(:,2);
            [minratio, r] = min(ratios);
        end
        
    end
    
end