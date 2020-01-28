function [] = startJoy()
    global joy
    joy = vrjoystick(1,'forcefeedback');
end