del = speedToDelay(reverse_coeffs,1327,45);
reverse_coeffs(2)

%% Calculating a delay given speed and angle
        % reverse_coeffs is a 4x4 array 
        % input speed & angle
        % output delay
        % inner function uses poly3
        % outer function uses exp2
        function [delay] = speedToDelay(reverse_coeffs,speed,angle)
            %initialize matrix that is 4x1, for coeffs of outer func
            complex_coeffs = zeros(length(reverse_coeffs(1,:)),1);
            %for i = 1:4 (length of the first row of forward_coeffs)
            for i = 1:length(reverse_coeffs(1,:))
                %calculate outer func coeffs using reverse_coeffs
                %as coeffs for poly3 and the angle as an input
                complex_coeffs(i) = poly3(reverse_coeffs(i,:),...
                    angle);
            end
            %use the outer func coeffs and the speed as an input to
            %calculate the delay
            delay = exp2(complex_coeffs,speed);
        end
        
                %% 3rd Degree Polynomial
        function [output] = poly3(coeffs,x)
            output = coeffs(1).*x.^3 + coeffs(2).*x.^2 +...
                coeffs(3).*x + coeffs(4);
        end
        
        %% Two-Term Exponential Function
        function [output] = exp2(coeffs,x)
            output = coeffs(1).*exp(coeffs(2).*x) +...
                coeffs(3).*exp(coeffs(4).*x);
        end