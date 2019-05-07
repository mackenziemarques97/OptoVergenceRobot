%% speedToDelay() test 
R = [-0.00310475347419085,-0.116112927462384,-2.44799451310981,216.172160299009;1.21799237587833e-08,9.16317492615761e-07,4.63515765928607e-05,-0.00578290070267847;-0.000295817957430916,-0.00108864813659789,-0.785207066418310,78.3812615783097;-6.43734869909407e-10,1.34771061636333e-07,1.57878651175107e-05,-0.00137954587415307];
Delay = speedToDelay(750,40)

               %% Calculating input speed to a delay sent to Arduino
        % coeff_array is a 4x4 array - rows representing exp2, columns representing
        % poly3
function [delay] = speedToDelay(R,speed,angle)
            complex_coeffs = zeros(size(R));
            for i = 1:length(R(:,1))
                complex_coeffs(i) = poly3(R(i,:),angle);
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