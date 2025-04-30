# VictoriaPerez_ECE398

**Project Title**: Designing Fish-like Robot Swarms for Environmental Monitoring

**Project Description**: In the following code files and documentation, you will find the programs that allowed me to collect data on the relative speed and trajectory of the BlueGuppy. To calculate this information, I chose to use the ROI-Based Processing. ROI (also known as Region-of-Interest) allows the user to select a specific area or component in the selected frame that will continuously be tracked throughout the video. ROI can be represented as a binary mask image. The pixels that are selected within the ROI are set to the value of 1, and any pixels that fall outside of it are set to 0. 

**Files & Descriptions**
- <u>Field_Motion_Tracking.m</u>: program developed to evaluate the trial videos and analyze the trajectory and speed caught on camera. This file was used to collect information on the Lajas Trial.
- <u>Field_Motion_tracking_CR.m</u>: program developed to evaluate the trial videos and analyze the trajectory and speed caught on camera. The file was used to collect information on the Cabo Rojo Trial. Unlike the Lajas Trial, this program required subtracting the position of a fixed background object from the position of the robotic fish because of the lack of camera stability (as the camera was moving along with the fish, which could have influenced the final result.
- <u>Recallibration_scaling.m</u>: program developed to calculate the scaling factor used in both above files to convert the units from pixels/s to cm/s. The program simply takes two points delimiting the size of the fish and uses the value and compares it with the real length of the BlueGuppy (9.5cm).
- Current_Rec.ino: Program developed in collaboration with SSR Undergraduate Researcher Brian Mmari. The program gives the BlueGuppy a 20-minute delay until starting the operation and 20 minutes of operation in order to evaluate its straight-line swimming behavior. The BlueGuppy keeps a constant speed during the entire run since the BLE characteristics were unable to be activated during both trials. 

**Functions & Atrributes Used: (Field_Motion_Tracking.m & Field_Motion_Tracking_CR.m)**
- <u>imrect</u>: an interactive drawing tool that allows drawing, specifically a rectangle in the frame provided (usually at the very beginning of the selected video).
-  <u>getPosition(h)</u>: will determine the position of the object found in the rectangle. This will return a 4-element vector [ xmin, ymin, width, height]. The values of this vector will be used as the argument when using the function detectMinEigenFeatures.
-  <u>detectMinEigenFeatures</u>: will help detect corners using the minimum eigenvalue algorithm. In the case of ROI, it will help produce a rectangular region for corner detection, whose calculation should return a vector [x y width height], which will determine the upper left corner of the edge and the length and width of the rectangle. Once the program calculates the minimum Eigenvalue, it will then determine whether or not the value is large enough to mark as a good feature to track.
- <u>vision.PointTracker</u>: will help track points in a video using the Kanade-Lucas-Tomasi (KLT) algorithm. For this program, I used the property of MaxBidirectionalError, which, if int follows the correct condition, it will track each point from the previous to the current frame of the video and then track the same point back to the previous frame. The value will calculate the distance between pixels from where it started tracking to where it stopped tracking. For the program I wrote, (MaxBidirectionalError, 2), which essentially sets the maximum bidirectional error to 2 pixels (recommended is 0 to 3 pixels). Choosing 2 as a parameter would help reduce the risk of selecting invalid points.

**Functions & Attributes Used: (Recallibration_Scaling.m)**
- <u>[x, y] = ginput(2)</u>: the user must select two points on the frame

# Bibliography

![image](https://github.com/user-attachments/assets/32bbf865-7477-4296-b16d-be6b99645697)


