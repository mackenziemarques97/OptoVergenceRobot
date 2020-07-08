function drawPhase(trial, phase)
     color = trial(phase).color;   
    % determine color of target for this phase
    red = [1 0 0];
    green = [0 1 0];
    blue = [0 0 1];
    black = [0 0 0];
    white = [1 1 1];
    yellow = [1 1 0];
    gray = [.5 .5 .5];
    
    switch color
        case 'red'
            c = red;
        case 'green'
            c = green;
        case 'blue'
            c = blue;
        case 'black'
            c = black;
        case 'white'
            c = white;
        case 'yellow'
            c = yellow;
        case 'gray'
            c = gray;
    end
    
    shape = trial(phase).shape;           
    % determine shape of target for this phase
    switch shape
        case 'cross' %2 pixels wide
            % cue cross
            fixCrossDimPix = trial(phase).size*0.5;
            xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
            yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
            allCoords = [xCoords; yCoords];
            lineWidthPix = 2;
            Screen('DrawLines', window, allCoords, lineWidthPix, c, [trial(phase).xLoc trial(phase).yLoc], 2, 1);
        case 'square'
            square = CenterRectOnPointd(trial(phase).size,trial(phase).xLoc,trial(phase).yLoc);          
            Screen(window,'FillRect', c, square); % dummy line           
        case 'circle'
            Screen(window,'DrawDots', [trial(phase).xLoc trial(phase).yLoc], trial(phase).size, c, [], 2);
    end
end
    