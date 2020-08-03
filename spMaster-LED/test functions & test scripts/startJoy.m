%% Function to create object for use of the joystick device to simulate eye movements
function [] = startJoy()
    global joy
    joy = vrjoystick(1,'forcefeedback');
end