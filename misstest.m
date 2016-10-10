% CS 525 final project
% Jieru Hu
% ID:9070194544
% Semester: 2016 Spring
% files: project.m, seperation.m, misstest.m

function [ totalmiss,error ] = misstest( omega, gamma, data )
%The function receive coefficeint of omega and gamma and test on the tune
%data test. At last, it return the number of misclassified point.

lines = size(data,1);
setsize = size(data,2);
totalmiss = 0;
error = 0;

for i = 1:lines
    %if the tuning set is B set
    if (data(i,1) == 66)
        % check if it is misclassified points
        if (data(i,2:setsize)*omega-gamma >= 0)
            totalmiss = totalmiss+1;
           
        end
        if (data(i,2:setsize)*omega-gamma >= -1)
            
            error = error + (data(i,2:setsize)*omega-gamma+1);
        end
    end
    
    %if the tuning set is M set
    if (data(i,1) ==77)
        % check if it is misclassified points
        if (data(i,2:setsize)*omega-gamma <= 0)
            totalmiss = totalmiss + 1;
        end
        if (data(i,2:setsize)*omega-gamma <= 1)
      
            error = error + (gamma - data(i,2:setsize)*omega+1);
        end
    end
end

end

