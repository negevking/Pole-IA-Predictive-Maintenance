load('train_data.mat')
mdl = exponentialDegradationModel('LifeTimeUnit',"days");
train_data = renamevars(train_data, {'Var1', 'Var2'}, {'Days', 'Condition'});
train = {train_data};
fit(mdl, train, 'Days', 'Condition')%train the model on the first 40 days
%% 
load('test_data.mat')
threshold = 18; %we need to update this as we change the condition indicator
test_data = renamevars(test_data, {'Var1', 'Var2'}, {'Days', 'Condition'});
days_left = linspace(height(test_data), 1, height(test_data));
RULs = zeros(height(test_data),1);
for t = 1:height(test_data) %for each day of the remaining 10 days, we update the model and calculate RUL
    update(mdl,test_data(t,:)) 
    estRUL = predictRUL(mdl,threshold);
    RULs(t) = days(estRUL);
end 
times = linspace(50 - height(test_data), 50, height(test_data));
figure
plot(times, RULs) %we plot the calculated RUL at each day
hold on
plot(times, days_left) %we plot the actual RUL at each day to compare the results
legend('Predicted Days Remaining', 'Actual Days Remaining');
xlabel('Day of Calculation')
ylabel('Days Remaining')
title('RUL Performance')
