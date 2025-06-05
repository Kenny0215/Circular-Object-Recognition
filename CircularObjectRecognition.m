clear all, close all, clc

%% Load image
I = imread('fruits.jpg');

%% Sharpen each channel (Process each color independently to avoid distortion)
R = imsharpen(I(:,:,1), 'Radius', 2, 'Amount', 1.5, 'Threshold', 0.01);
G = imsharpen(I(:,:,2), 'Radius', 2, 'Amount', 1.5, 'Threshold', 0.01);
B = imsharpen(I(:,:,3), 'Radius', 2, 'Amount', 1.5, 'Threshold', 0.01);

% Combine sharpened channels into one RGB image
sharpenedRGB = cat(3, R, G, B);
%% Adaptive Histogram Equalization
Radhist = adapthisteq(R);
Gadhist = adapthisteq(G);
Badhist = adapthisteq(B);

%% Display Adaptive Histogram Equalization Images
figure('Name', 'Adaptive Histogram Equalized Channels', 'NumberTitle', 'off');
subplot(1, 3, 1); imshow(Radhist); title('Red Channel (Equalized)');
subplot(1, 3, 2); imshow(Gadhist); title('Green Channel (Equalized)');
subplot(1, 3, 3); imshow(Badhist); title('Blue Channel (Equalized)');

%% Show histogram of enhanced channels to understand intensity distribution, evaluate enhancement effects
figure('Name','Histogram RGB Plotting');
subplot(1, 3, 1); imhist(Radhist); title('Histogram (Red Channel)');
subplot(1, 3, 2); imhist(Gadhist); title('Histogram (Green Channel)');
subplot(1, 3, 3); imhist(Badhist); title('Histogram (Blue Channel)');

%% Convert to binary using a threshold of 0.8
Rbw = imbinarize(Radhist, 0.8);
Gbw = imbinarize(Gadhist, 0.8);
Bbw = imbinarize(Badhist, 0.8);

% Median Filtering for Salt & Pepper noise
RKmedian = medfilt2(Rbw, [14 14]);
GKmedian = medfilt2(Gbw, [14 14]);
BKmedian = medfilt2(Bbw, [14 14]);

%% Display binary images after filtering
figure ('Name','Filtered Binary Images');
subplot(1, 3, 1); imshow(RKmedian); title('Red Channel');
subplot(1, 3, 2); imshow(GKmedian); title('Green Channel');
subplot(1, 3, 3); imshow(BKmedian); title('Blue Channel');

%% Convert to grayscale and enhance contrast
Igray = rgb2gray(sharpenedRGB);
Ienhanced = adapthisteq(Igray);

%% Circle detection
minRadius = 5;
maxRadius = 50;

[centers, radii] = imfindcircles(Igray, [minRadius maxRadius], ...
    'ObjectPolarity', 'dark', 'Sensitivity', 0.9);

%% Filter overlapping circles (you must define this function separately)
[fcenters, fradii] = filter_overlapping_circles(centers, radii);

%% Count circles
num_circles = size(fcenters, 1);

%% Display circle detection results
figure('Name','Circle Detection Results');
subplot(1, 3, 1); imshow(I); title('Original Image');
subplot(1, 3, 2); imshow(Igray); title('Grayscale Enhanced Image'); % Display grayscale with sharpened images
subplot(1, 3, 3); imshow(Igray); 
viscircles(fcenters, fradii, 'EdgeColor', 'b');
title(['Detected Circles: ', num2str(num_circles)]);
hold off;

%% Print total circles
disp(['Total number of detected circles: ', num2str(num_circles)]);