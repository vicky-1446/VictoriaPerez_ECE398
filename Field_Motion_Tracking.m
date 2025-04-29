videoFile = 'Lajas_Trial_1a.mp4';
vidObj = VideoReader(videoFile);

frame = readFrame(vidObj);
imshow(frame);
fish_roi = round(getPosition(imrect)); % manually drawing rectangle over object (fish) to track, will round the elements inside the position vector to the nearest integer
bg_roi = round(getPosition(imrect)); %manually drawing rectangle over a fixed background object, will round the elements inside the position vector to the nearest integer

grayFrame = rgb2gray(frame);
fish_pts = detectMinEigenFeatures(grayFrame, 'ROI', fish_roi).Location; %Using ROI in order to determine location of fish in frame
bg_pts = detectMinEigenFeatures(grayFrame, 'ROI', bg_roi).Location;%Using ROI in order to determine the location of fixed background option

fishTracker = vision.PointTracker('MaxBidirectionalError', 2); %explained in Fish_Motion_tracking_CR
bgTracker = vision.PointTracker('MaxBidirectionalError', 2);

initialize(fishTracker, fish_pts, frame);
initialize(bgTracker, bg_pts, frame);


vidObj.CurrentTime = 0;
frameNum = 1;
positions = [];  % [Time_s, Fish_X, Fish_Y, BG_X, BG_Y, Rel_X, Rel_Y]


while hasFrame(vidObj)
    frame = readFrame(vidObj);
    
    [fish_pts, valid_fish] = fishTracker(frame);
    [bg_pts, valid_bg] = bgTracker(frame);
    
    if any(valid_fish) && any(valid_bg)% checks for valid points to track
        fish_center = mean(fish_pts(valid_fish, :), 1); % calculates average of the valid points
        bg_center = mean(bg_pts(valid_bg, :), 1); % calculates average of the valid points
        rel_position = fish_center - bg_center; %determines real position of the fish relative to the fixed background point.
        
        
        t = frameNum / vidObj.FrameRate; %time elapsed in frame
        positions = [positions; t, fish_center, bg_center, rel_position];
        
      
        frame = insertShape(frame, 'Circle', [fish_center 5], 'Color', 'green', 'LineWidth', 2); %draws circle over fish on the selected frame
        frame = insertShape(frame, 'Circle', [bg_center 5], 'Color', 'blue', 'LineWidth', 2); %draws circle over fixed background point on the selected frame
        frame = insertShape(frame, 'Line', [bg_center, fish_center], 'Color', 'yellow'); %manually draw line from the fish to the fixed background object.
    else
        frame = insertText(frame, [10, 10], 'Tracking Lost', 'FontSize', 18, 'BoxColor', 'red'); % when tracking is lot over the fish
    end
    
    imshow(frame);
    pause(0.01);
    frameNum = frameNum + 1;
end

%%Variables in Excel Sheet
T = array2table(positions, 'VariableNames', ...
    {'Time_s', 'Fish_X', 'Fish_Y', 'BG_X', 'BG_Y', 'Rel_X', 'Rel_Y'});


dx = diff(T.Rel_X); %change in x coordinate
dy = diff(T.Rel_Y); %change in y coordinate
dt = diff(T.Time_s); %change in time

speed_pixels = sqrt(dx.^2 + dy.^2) ./ dt; % Calculates the speed by dividing the Euclidian Distance over the time elapsed

pixel_to_cm = 0.0931; %scaling factor for conversion
speed_cm = speed_pixels * pixel_to_cm;

time_mid = (T.Time_s(1:end-1) + T.Time_s(2:end)) / 2; %computes average of each time stamp
SpeedTable = table(time_mid', speed_cm', 'VariableNames', {'Time_s', 'Speed_cm_per_s'});


timestamp = datestr(now, 'yyyymmdd_HHMMSS');  % generated titles for the excel sheet


trial_id = timestamp;
SpeedTable.Trial = repmat({trial_id}, height(SpeedTable), 1); %generates new file when program is ran 

filename_tracking = ['fish_tracking_relative_' timestamp '.csv'];
filename_speed = ['fish_relative_speed_' timestamp '.csv'];
writetable(T, filename_tracking);
writetable(SpeedTable, filename_speed);

%Visualizing Trajectory of Fish
figure;
plot(T.Rel_X, T.Rel_Y, '-o');
xlabel('Relative X'); ylabel('Relative Y');
title('Trajectory of Robotic Fish (Relative to Background)');
axis equal; grid on;

% Visualizing Relative speed of fish over time
figure;
plot(SpeedTable.Time_s, SpeedTable.Speed_cm_per_s, 'r');
xlabel('Time (s)');
ylabel('Speed (cm/s)');
title('Relative Swimming Speed of Robotic Fish');
grid on;
