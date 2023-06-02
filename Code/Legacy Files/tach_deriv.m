function [speed, acceleration] = tach_deriv(tach)
time_period = 6/length(tach);
speed = diff(tach)/time_period;
speed = smoothdata(speed,'movmean');
acceleration = diff(speed)/time_period;
acceleration = smoothdata(acceleration,'movmean');
end