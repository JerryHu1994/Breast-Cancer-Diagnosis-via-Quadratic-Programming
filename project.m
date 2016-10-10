% CS 525 final project
% Jieru Hu
% ID:9070194544
% Semester: 2016 Spring
% files: project.m, seperation.m, misstest.m

% extract the data
clear;
[train,tune,test] = getdata('wdbc.data',30);

% Part 1
[omega_a,gamma_a,minValue_a] = seperation( train,0.0001 );
fprintf('In part 1, the calculated omega is:\n');
omega_a
fprintf('In part 1, the calculated gamma is:\n');
gamma_a
fprintf('In part 1, the minimum value of the QP is:\n');
minValue_a

% Part 2
miss_part2 = misstest(omega_a, gamma_a, tune);
fprintf('In part 2, the number of misclassified points on the tuning set when using mu as 0.0001 is %d.\n\n',miss_part2);

% set up the mu variables
mu_list = zeros(1,10);
for i = 1:10
	mu_list(i) = 0.00005*i;
end

fprintf('Then we try different mu values: \n');
% test each mu
besterror = 0;
bestmu = 0;
bestmiss = inf;
besterror = inf;
for i = 1:10
    mu = mu_list(i);
    [omega, gamma, minValue] = seperation(train,mu);
    [miss,error] = misstest(omega,gamma,tune);
    wsquare = omega'*omega;
    fprintf('The number of misclassified points using %.5f as mu is %d. \n',mu,miss);
    fprintf('The miss error from the missed points is %f, and the seperating plane margin(1/w^2) is %f.\n\n',error,1/wsquare);
    %calculate the best mu
    if miss < bestmiss
        bestmu = mu;
        bestmiss = miss;
    end
    if miss == bestmiss
        if error < besterror
            bestmu = mu;
            besterror = error;
        end
    end
end

% Evaluate the missclassified points and sum of errors on the testing
% data
[omega_b,gamma_b,minValue_b] = seperation(train,bestmu);
[totalmiss_b, error_b] = misstest(omega_b,gamma_b,test);
fprintf('The mu value produces the minimum value is %.5f.\n', bestmu);
fprintf('The misclassified points on test data produced by the best mu is %.5f.\n',totalmiss_b);
fprintf('The sum of errors produced on test data by the best mu is %.5f.\n\n',error_b);


% Overall, the mu represents a weight factor between maximum (Euclidean)
% margin of the seperating plane and missing error of malignant and benign
% points. As we try mu from 5e-5 to 5e-4, the missed points for using 5e-5
% and 1e-4 are 3 and the remainings are 2. The increase on mu from 5e-5 to 5e-4, 
% results in a seperating plane with larger margin. It means that the
% seperating plane is placed at a proper angle with respect to the train
% data. Therefore, the plane is likely to seperate the tune data more
% effectively. The test shows that larger mu leads to less missed points on the tune data. 
% I calculate the error for benign points as "data(i,2:setsize)*omega-gamma+1" and the 
% error for the malignant points as "gamma - data(i,2:setsize)*omega+1", which is suggested by the QP problem formulation.
% When we use 5e-4 for the mu, we have the lowest error on missed errors which is equal to 6.2465 and the
% largest margin for the seperating hyperplane, which is equal to 0.01233. This is the best condition
% we desired, where comparatively larger weight factor is placed on the maximum (Euclidean)
% margin of the seperating plane in this minimization problem. 
% Therefore, 5e-4 is the best mu for this problem. 


% Part 3
besti = 0;
bestj = 0;
bestmiss = inf;
besterror = inf;
for i = 2:31
    for j = i+1:31
        % extract the corresponding attributes
        train_c = train(:,[1 i j]);
        tune_c = tune(:,[1 i j]);
        
        % for each pair, determine the a seperating plane
        [omega_c,gamma_c,minValue_c] = seperation(train_c,bestmu);
        % using tuning set with corresponding pair to determine number of
        % misclassified points
        [miss_c,misserror_c] = misstest(omega_c,gamma_c,tune_c);
        fprintf('atts %2d %2d: misclass %3d\n',i-1,j-1, miss_c);
        if miss_c < bestmiss
            besti = i;
            bestj = j;
            bestmiss = miss_c;
        end
        if miss_c == bestmiss
            besti = i;
            bestj = j;
            misserror = misserror_c;
        end   
    end
end


% Part 4
% From part 3, we get the besti and bestj for the best pair of attributes.
fprintf('The best atts is %2d %2d, which has a misclass of %d.\n',besti-1,bestj-1, bestmiss);
% extract the best data
train_d = train(:,[1, besti, bestj]);
test_d = test(:,[1,besti,bestj]);
[omega_d, gamma_d, min_d] = seperation(train_d,bestmu); 
xcoorb = test_d(test_d(:,1) == 66, 2);
xcoorm = test_d(test_d(:,1) == 77, 2);
% get y coordinates
ycoorb = test_d(test_d(:,1) == 66, 3);
ycoorm = test_d(test_d(:,1) == 77, 3);

% plot
figure;
x = linspace(-100,100);
y = (-omega_d(1)*x+gamma_d)/omega_d(2);

% perturb the points
% We add a random number between -0.01 and 0.01 to x and y coordinate
% of the plotted point respectively.
scale = 0.01;

xcoorb = xcoorb + scale*(-1 + 2*rand(size(xcoorb,1),1));
ycoorb = ycoorb + scale*(-1 + 2*rand(size(ycoorb,1),1));
xcoorm = xcoorm + scale*(-1 + 2*rand(size(xcoorm,1),1));
ycoorm = ycoorm + scale*(-1 + 2*rand(size(ycoorm,1),1));

plot(xcoorb,ycoorb,'o',xcoorm,ycoorm,'+',x,y,'r');
legend('benign points','malignant points','the seperating line');
title('Plot on seperation of benign and malignant poinweightts for brest cancer diagnosis');
axis([-3 4 -4 4]);

% check the solution
check = misstest(omega_d,gamma_d,test_d);
fprintf('The test function shows that the miss points for the test cases are %d, which exactly agrees with the plot.\n',check);

