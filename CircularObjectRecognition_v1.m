clear all, close all, clc

%% Step 1 : Load image
I = imread('oil.jpg');

%% Step 2 : Split into R, G, B channels
R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);

%% Step 3 : Sharpen each channel (Process each color independently to avoid distortion)
R = imsharpen(R, 'Radius', 2, 'Amount', 1.5, 'Threshold', 0.01);
G = imsharpen(G, 'Radius', 2, 'Amount', 1.5, 'Threshold', 0.01);
B = imsharpen(B, 'Radius', 2, 'Amount', 1.5, 'Threshold', 0.01);

% Combine sharpened channels into one RGB image
sharpenedRGB = cat(3, R, G, B);
%% Step 4 : Adaptive Histogram Equalization
Radhist = adapthisteq(R);
Gadhist = adapthisteq(G);
Badhist = adapthisteq(B);

%% Display Adaptive Histogram Equalization Images
figure('Name', 'Adaptive Histogram Equalized Channels', 'NumberTitle', 'off');
subplot(1, 3, 1); imshow(Radhist); title('Red Channel');
subplot(1, 3, 2); imshow(Gadhist); title('Green Channel');
subplot(1, 3, 3); imshow(Badhist); title('Blue Channel');

%% Show histogram of enhanced channels to understand intensity distribution, evaluate enhancement effects
figure('Name','Histogram RGB Plotting');
subplot(1, 3, 1); imhist(Radhist); title('Red Channel');
subplot(1, 3, 2); imhist(Gadhist); title('Green Channel');
subplot(1, 3, 3); imhist(Badhist); title('Blue Channel');

%% Step 5 : Convert to binary using a threshold of 0.8
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

%% Step 6 : Convert to grayscale and enhance contrast
Igray = rgb2gray(sharpenedRGB);
Ienhanced = adapthisteq(Igray);

%% Step 7 : Circle detection

% Adjustable radius
minRadius = 6;
maxRadius = 50;

[centers, radii] = imfindcircles(Ienhanced, [minRadius maxRadius], ...
    'ObjectPolarity', objectPolarity, ...
    'Sensitivity', 0.85, ...
    'ObjectPolarity','bright', ... % Bright circles on dark background or dark circles on bright background
    'EdgeThreshold', 0.05);

%% Step 8 : Filter overlapping circles 
[fcenters, fradii] = filter_overlapping_circles(centers, radii);

%% Step 9 : Count circles
num_circles = size(fcenters, 1);

%% Step 10 : Display circle detection results
figure('Name','Circle Detection Results');
subplot(1, 3, 1); imshow(I); title('Original Image');
subplot(1, 3, 2); imshow(Ienhanced); title('Grayscale Enhanced Image'); % Display grayscale with sharpened images
subplot(1, 3, 3); imshow(Ienhanced); 
viscircles(fcenters, fradii, 'EdgeColor', 'b');
title(['Detected Circles: ', num2str(num_circles)]);
hold off;

%% Step 11 : Print total circles
disp(['Total number of detected circles: ', num2str(num_circles)]);