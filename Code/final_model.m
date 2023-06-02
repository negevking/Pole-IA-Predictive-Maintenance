%we load our wind turbine condition indicator
%we want to implement unsupervised learning - we do not pre train the model
load('test_data.mat')
conditions = table2array(test_data);

%we initialise an exponential model with arbitary values for theta and
%beta. The day 0 value = phi + theta*1. Therefore to match the starting value of
%our indicator, we set phi appropriately.
%If we had historical fleet data we could put a better estimate of theta
%and beta
phi = conditions(1) - 1;
disp(phi)

%this is an overfitted bit - really we should calculate a threshold
%from a fleet history - here we assume it breaks on the last day
threshold = conditions(end); 
disp(conditions(end))

model = exponentialDegradationModel('Theta', 1, 'ThetaVariance', 10, 'Beta', 1, ...
    'BetaVariance', 10, 'Phi', phi, 'NoiseVariance', threshold*0.001);% 'LifeTimeUnit', "days");

%% 
%preparing to plot with the helper function
ax1 = subplot(1, 1, 1);
n_days = length(conditions);% - 1;
estimatedRULs = zeros(n_days, 1);

%for each day of the turbines life, it adjusts the model parameters to map
%its up to date data. This means in the first few days the model is not
%good as it is adjusting, then its performance improves

for t = 1:n_days
    %update the model with todays recorded data sample
    update(model, conditions(t)) 

    %predict the estimated RUL remaining
    estimatedRUL = predictRUL(model, conditions(t), threshold);

    estimatedRULs(t) = day(estimatedRUL);
    helperPlotTrend(ax1, t, conditions, model, threshold, 'Days'); 

    %fprintf('Condition value: %f, RUL: %f\n', conditions(t), days(estimatedRUL)); 
    %pause(0.5)
end 

%% 

days_left = linspace(n_days -1 , 0, n_days);

times = linspace(1, n_days, n_days);
figure
plot(times, estimatedRULs) %we plot the calculated RUL at each day
hold on
plot(times, days_left) %we plot the actual RUL at each day to compare the results
legend('Predicted Days Remaining', 'Actual Days Remaining');
xlabel('Day of Calculation')
ylabel('Days Remaining')
title('RUL Performance - PCA')
%% 

indicator = 0;
for i = 1:n_days
    indicator = indicator + abs(estimatedRULs(i) - days_left(i))/ ((days_left(i)+1));
end

disp(indicator)



