function [joyX, joyY] = peekJoyPos(ai)
%returns x, y, and button values for joystick
    global joy
    joypos = axis(joy, [1, 2]);
    joyX = -800*joypos(1); %check on this
    joyY = 800*joypos(2); %check on this
end