% CS 525 final project
% Jieru Hu
% ID:9070194544
% Semester: 2016 Spring
% files: project.m, seperation.m, misstest.m

function [ omega,gamma,minValue ] = seperation( train, mu )
% The function takes mu as an input, extracts data from the dataset and
% formulate the quadratic programming problem. Then cplexqp() function is
% called to solve the quadratic problem. omega, gamma and the minimum value
% of the LP problem is returned.

% seperate the train data set
totalsize = size(train,1);
Bset = train(train(:,1) == 66, 2:end);
Mset = train(train(:,1) == 77, 2:end);

% get size
setsize = size(Mset,2);
Msize = size(Mset,1);
Bsize = size(Bset,1);

%set up the parameters of cplexqp method
H = mu*[eye(setsize);zeros(totalsize+1,setsize)];
H = [H zeros(setsize+totalsize+1,totalsize+1)];
f = 1/Msize*[zeros(1,setsize+1) ones(1,Msize) zeros(1,Bsize)]+1/Bsize*[zeros(1,setsize+1+Msize) ones(1,Bsize)];
Aineq = [Mset -ones(Msize,1) eye(Msize) zeros(Msize,Bsize);-Bset ones(Bsize,1) zeros(Bsize,Msize) eye(Bsize)];
bineq = ones(totalsize,1);
Aineq = -Aineq;
bineq = -bineq;
ub = inf*ones(setsize+1+totalsize,1);
lb = [-inf(setsize+1,1);zeros(totalsize,1)];
Aeq = [];
beq = [];

% quadratic function
% H: the coefficient for quadratic term in the function 
% f: the coeeficcient for the linear term in the funcition
% Aineq: martrix on the lhs of the inequality
% bineq: matrix on the rhs of the inequality
% Aeq: matrix on the lhs of the equality
% beq: matrix on the rhs of the equality
% lb: lower bound of the variable
% ub: upper bound of the varaible

[x,fval,exitflag,output,lambda] = cplexqp(H,f,Aineq,bineq,Aeq,beq,lb,ub);


omega = x(1:setsize);
gamma = x(setsize+1);
minValue = fval; 


end

