function [joyX, joyY] = peekJoyPos(ai)
%returns x, y, and button values for joystick
    global joy
    joypos = axis(joy, [1, 2]);
    joyX = -50*joypos(1); %check on this
    joyY = 50*joypos(2); %check on this
end