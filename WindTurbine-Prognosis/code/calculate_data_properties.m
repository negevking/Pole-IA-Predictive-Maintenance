function [Max, Mean, SD, DI] = calculate_data_properties(Y, X)
%Max, Mean, standard deviation, dominant index

Mean = mean(Y);
SD = std(Y);
[Max, DI] = max(Y);
DI = X(DI);

end
