%DIEGO THIS IS THE RIGHT FILE
features = readtable("brutefeatures.txt"); %raw features - CURRENTLY ONLY USING VIBRATION - need to ADD DERIVED TACHOMETER AS WELL
featureTable = table2timetable(features);
clear features
variableNames = featureTable.Properties.VariableNames;
featureTableSmooth = varfun(@(x) movmean(x, [5 0]), featureTable); %smoothes features with moving average
featureTableSmooth.Properties.VariableNames = variableNames;
%% 
figure
times = linspace(1, 50, 50);
plot(featureTable.Date, featureTable.vibration_res_sigstatsClearanceFactor) %plots a raw feature agaisnt the smoothed feature
hold on
plot(featureTableSmooth.Date, featureTableSmooth.vibration_res_sigstatsClearanceFactor)
legend('Raw signal', 'Smooth signal')
xlabel('Date')
ylabel('Amplitude')
title('Comparison of vibration-res-sigstatsClearanceFactor before and after smoothing')
hold off

%% 
featureImportance = monotonicity(featureTableSmooth, 'WindowSize', 0); %calcualtes importance of smoothed features
helperSortedBarPlot(featureImportance, 'Monotonicity');
%% 
featureSelected = featureTableSmooth(:, featureImportance{:,:}>0.3); %only takes important ones
featureSelected = timetable2table(featureSelected);
n_features = size(featureSelected);
n_features = n_features(2);
%% 

features_normalised = zeros(size(featureSelected));
featureSelected1 = removevars(featureSelected, 'Date');
featuresSelected = table2array(featureSelected1);
n_features = size(featuresSelected);
n_features = n_features(2);
for i = 1:n_features
    for d = 1:50
        features_normalised(d, i) = (featuresSelected(d, i) - featuresSelected(1,i)); %normalies features between 0 and 1
    end
    for d = 1:50
        features_normalised(d, i) = features_normalised(d, i)/features_normalised(50, i);
    end
end
plot(times, features_normalised(:,1))
%% 
condition_indicator = zeros(50,1);
for i = 1:50
    condition_indicator(i) = sum(features_normalised(i,:)); %creates condition indicator by summing the features with equal weighting - ADD PRINCIPAL COMPONENT ANALYSIS
end

for i = 1:n_features
    plot(times, features_normalised(:,i), 'DisplayName', 'off')
    hold on
end
plot(times, condition_indicator/18, 'DisplayName', 'Combined Indicator', 'LineWidth', 4) %plots indicator
hold off

split_day = 40;
times = linspace(1, 50, 50);
times = times.';
train_data = table(times(1:split_day), condition_indicator(1:split_day)); %
test_data = table(times(split_day+1:end), condition_indicator(split_day+1:end));
save('Test_data.mat', "test_data")
save('train_data.mat', "train_data")
title('Comparision of features and indicator')
xlabel('Day')
ylabel('Condition')





%% 
