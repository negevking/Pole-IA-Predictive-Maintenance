features = readtable("brutefeatures.txt");
top5 = [features.vibration_res_sigstatsShapeFactor, features.vibration_tsproc_tsfeatMinimum, features.vibration_res_sigstatsKurtosis, features.vibration_tsproc_sigstatsCrestFactor, features.vibration_res_sigstatsPeakValue];
%weighting = [1, 0.9, 0.7, 0.6, 0.5];
weighting = [1, 1, 1, 1, 1];
clear features
top5_normalised = zeros(size(top5));
for i = 1:5
    top5_normalised(:, i) = (top5(:, i) - top5(1,i));
    top5_normalised(:, i) = top5_normalised(:, i)/top5_normalised(50, i);
end
%top5_normalised(:, 2) = ones(50, 1) - top5_normalised(:,2);
weighted_features = zeros(size(top5));
for i = 1:5
    weighted_features(:, i) = weighting(i)*top5_normalised(:, i);
end
condition_indicator = zeros(50,1);
for i = 1:50
    condition_indicator(i) = sum(weighted_features(i,:));
end
condition_indicators = zeros(50, 2);
condition_indicators(:, 1) = linspace(1, 50, 50);
condition_indicators(:, 2) = condition_indicator;
writematrix(condition_indicators);
for i = 1:5
    plot(condition_indicators(:, 1), weighted_features(:, i))
    hold on
end
plot(condition_indicators(:, 1), condition_indicators(:, 2))
hold off
xlabel('Day')
ylabel('Condition')

test_days = [1, 11, 22, 33, 45];
condition_indicators_test = condition_indicators(test_days, :);
train_days = setdiff(condition_indicators(:,1), test_days);
condition_indicators_train = condition_indicators(train_days, :);
%% 
condition_indicators_train = array2table(condition_indicators_train, 'VariableNames',{'Time','Condition'});
condition_indicators_test = array2table(condition_indicators_test, 'VariableNames',{'Time','Condition'});
%% 
save('train_data.mat', "condition_indicators_train");
save('test_data.mat', "condition_indicators_test");