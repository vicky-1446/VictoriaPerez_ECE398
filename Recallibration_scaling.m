vidObj = VideoReader('Lajas_Trial_1a.mp4'); %reads video
frame = readFrame(vidObj);

imshow(frame);
[x, y] = ginput(2);  % Must click two points in the frame in order to identify lenth of the fish in the video

pixel_dist = sqrt((x(2) - x(1))^2 + (y(2) - y(1))^2);
fprintf('Measured pixel distance: %.2f pixels\n', pixel_dist); % calculates the euclidian distance between the two selected points

body_length = 9.5; %Real-lenght of the BlueGuppy in cm

pixel_to_cm = body_length_ / pixel_dist; %pixel to cm calculation
fprintf('Pixel-to-cm scalibility: %.4f cm per pixel\n', pixel_to_cm);
