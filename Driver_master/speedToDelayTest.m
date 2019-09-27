load('parameters.mat');
[d, c] = speedToDelay(reverse_coeffs,50,20);


%% Calculating a delay given speed and angle
        % reverse_coeffs is a 4x4 array 
        % input speed & angle
        % output delay
        % inner function uses poly3
        % outer function uses exp2
        function [delay, complex_coeffs] = speedToDelay(reverse_coeffs,speed,angle)
            %initialize matrix that is same size as forward_coeffs
            complex_coeffs = zeros(length(reverse_coeffs(1,:)),1);
            for i = 1:length(reverse_coeffs(1,:))
                complex_coeffs(i) = poly3(reverse_coeffs(i,:),angle);
            end
            delay = exp2(complex_coeffs,speed);
        end
                %% 3rd Degree Polynomial
        function [output] = poly3(coeffs,x)
            output = coeffs(1).*x.^3 + coeffs(2).*x.^2 + coeffs(3).*x + coeffs(4);
        end
                %% Two-Term Exponential Function
        function [output] = exp2(coeffs,x)
            output = coeffs(1).*exp(coeffs(2).*x) + coeffs(3).*exp(coeffs(4).*x);
        end
        