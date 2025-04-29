videoFile = 'CaboRojo_Trial_1a.mp4'; 
vidObj = VideoReader(videoFile);

%% Reading the video
frame = readFrame(vidObj);
imshow(frame);

%%  Using ROI (Region of Interest) in order to detect feature
grayFrame = rgb2gray(frame);
points = detectMinEigenFeatures(grayFrame, 'ROI', round(getPosition(imrect)));
%% According to MATLAB, the function will use eigenvalues in order to measure intensity changes (will compute structure tensors)
points = points.Location;

tracker = vision.PointTracker('MaxBidirectionalError', 2); %% Bidirectional error represents the discrepancy between the forward and backward tracking
initialize(tracker, points, frame);

vidObj.CurrentTime = 0;  % Reset to beginning
positions = zeros(0, 3);  % Initializes empty matrix
frameNum = 1; % counter 

while hasFrame(vidObj) %% serves to evaluate each frame in a continuous loop
    frame = readFrame(vidObj);
    [points, validity] = tracker(frame); %%updates location of tracked points
    
    if any(validity)
        centroid = mean(points(validity, :), 1);  % Uses centroid averaging in order to determine the mean of all valid points, the result should be a single point for the position of the fish in the current frame 
        positions = [positions; frameNum / vidObj.FrameRate, centroid]; 
        % frameNum / vidObj.FrameRate will calculate the elapsed time of
        % the frame 

        imshow(frame);
        hold on;
        x = centroid(1);
        y = centroid(2);
        plot(x, y, 'ro', 'MarkerSize', 10, 'LineWidth', 2); %%after selecting region of interest, it will draw a red circle around the centroid 
        hold off;
        pause(0.01);  
    end
    
    frameNum = frameNum + 1;
end


T = array2table(positions, 'VariableNames', {'Time_s', 'Rel_X', 'Rel_Y'});
writetable(T, 'fish_trajectory_CR.csv'); %% writes excel sheet with data

%%Calculates trajectory of the fish
figure;
plot(T.Rel_X, T.Rel_Y, '-o');
xlabel('Relative X (pixels)');
ylabel('Relative Y (pixels)');
title('Trajectory of Robotic Fish');
axis equal;
grid on;

dx = diff(T.Rel_X); %change in x coordinate 
dy = diff(T.Rel_Y); %change in y coordinate
dt = diff(T.Time_s); %change in time

speed_pixels = sqrt(dx.^2 + dy.^2) ./ dt;  % Calculates the speed by dividing the Euclidian Distance over the time elapsed

%%Converting to cm/s
pixel_to_cm = 0.0931;  %% scaling number for conversion (Recallibration_scaling.m)
speed_cm = speed_pixels * pixel_to_cm;

% Create time vector between frames
time_mid = (T.Time_s(1:end-1) + T.Time_s(2:end)) / 2; %computes average of each time stamp

SpeedTable = table(time_mid', speed_cm', 'VariableNames', {'Time_s', 'Speed_cm_per_s'});
writetable(SpeedTable, 'fish_speed_CR.csv'); %% creates excel sheet with data from video

%% Plotting relative swimming speed 
figure;
plot(SpeedTable.Time_s, SpeedTable.Speed_cm_per_s, 'r-');
xlabel('Time (s)');
ylabel('Speed (cm/s)');
title('Relative Swimming Speed of Robotic Fish');
grid on;

