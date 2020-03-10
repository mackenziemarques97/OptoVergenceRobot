eyePosX = 1
eyePosY = 2
figure
axis([-10 10 -10 10])
global hFix hEye
hFix = rectangle('Position', [-0.5 -0.5 1 1],'FaceColor', 'blue'); %create first rectangle
hEye = rectangle('Position', [eyePosX-0.5 eyePosY-0.5 1 1],'FaceColor','red'); %create square for eye pos

hFix = rectangle('Position', [5 -0.5 1 1],'FaceColor','magenta')
hEye = rectangle('Position', [-5 -0.5 1 1],'FaceColor','cyan')

viewingFigureRectangles(1) = rectangle('Position', [-0.5 -0.5 1 1],'FaceColor','blue');
viewingFigureRectangles(2) = rectangle('Position', [-0.5 -0.5 1 1],'FaceColor','blue');
viewingFigureRectangles(3) = rectangle('Position', [-0.5 -0.5 1 1],'FaceColor','blue');
viewingFigureRectangles(4) = rectangle('Position', [-0.5 -0.5 1 1],'FaceColor','blue');