%this file takes a feature set, then combines then into a condition
%indicator. It then saves this as a table

features = readtable("featureSets/cleanFeat_04.txt"); %raw features - CURRENTLY ONLY USING VIBRATION - need to ADD DERIVED TACHOMETER AS WELL
featureTable = table2timetable(features);
clear features
variableNames = featureTable.Properties.VariableNames;
featureTableSmooth = varfun(@(x) movmean(x, [5 0]), featureTable); %smoothes features with moving average
featureTableSmooth.Properties.VariableNames = variableNames;
%% 
%figure
times = linspace(1, 50, 50);

%% 
featureImportance = monotonicity(featureTableSmooth, 'WindowSize', 0); %calcualtes importance of smoothed features
helperSortedBarPlot(featureImportance, 'Monotonicity');
%% 
%featureSelected = featureTableSmooth(:, featureImportance{:,:}>0); %only takes important ones
featureSelected = timetable2table(featureTableSmooth);
n_features = size(featureSelected);
disp(n_features)
%% 

features_normalised = zeros(size(featureSelected));
featureSelected1 = removevars(featureSelected, 'Date');
featuresSelected = table2array(featureSelected1);
n_features = size(featuresSelected);
n_features = n_features(2);

% we are going to calculate and subtract the mean of each column to have
% the data centered on zero for pca to work well
means = mean(featuresSelected);
featuresCentered = bsxfun(@minus, featuresSelected, means);

sdTrain = std(featuresSelected);
featuresCentered = featuresCentered./sdTrain;
%% 

covariance = cov(featuresSelected);
[coeff, score, latent] = pca(covariance, 'NumComponents', 1);
coeff = ones(size(coeff)); %simple sum
condition_indicator = featuresCentered * coeff;

for i = 1:n_features
    plot(times, featuresCentered(:,i), 'DisplayName', 'off')
    hold on
end
plot(times, condition_indicator, 'DisplayName', 'Combined Indicator', 'LineWidth', 4) %plots indicator


condition_smooth = movmean(condition_indicator, 3 );
plot(times, condition_smooth, 'DisplayName', 'Combined Indicator', 'LineWidth', 4)

hold off


split_day = 0;
times = linspace(1, 50, 50);
times = times.';
% train_data = table(times(1:split_day), condition_indicator(1:split_day)); %
% test_data = table(times(split_day+1:end), condition_indicator(split_day+1:end));

train_data = table(condition_indicator(1:split_day)); %
test_data = table(condition_indicator(split_day+1:end));


save('Test_data.mat', "test_data")
save('train_data.mat', "train_data")
title('Condition Indicator Monotonicity = ?')
xlabel('Day')
ylabel('Condition')

disp(condition_indicator(end))





%% 
