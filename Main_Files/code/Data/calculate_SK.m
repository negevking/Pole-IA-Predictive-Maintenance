function [SK, F] = calculate_SK(table1, variable1, wc)
%wc 128 for vibration or 10 for acceleration/tach

data = read(table1);
v = data{:,variable1}{1,1};
fs = 97656;
[SK, F] = pkurtosis(v, fs, wc);

end