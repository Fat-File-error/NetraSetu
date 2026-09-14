clc;
clear;
close all;

%% STEP 1: Read the APTOS CSV file

data = readtable("../data/APTOS/train.csv", ...
    "ReadVariableNames", true, ...
    "VariableNamingRule", "preserve");

disp("Column names:");
disp(data.Properties.VariableNames);

disp("First 5 rows:");
disp(head(data));


%% STEP 2: Find all fundus images

imageRoot = "../data/APTOS/images";

% Find PNG images, including images inside subfolders
files = dir(fullfile(imageRoot, "**", "*.png"));

disp("Images found:");

for k = 1:numel(files)
    fprintf("%d. %s\n", k, fullfile(files(k).folder, files(k).name));
end

fprintf("Number of images found: %d\n", numel(files));


%% STEP 3: Display the first fundus image

if numel(files) > 0

    imgPath = fullfile(files(1).folder, files(1).name);

    img = imread(imgPath);

    figure;
    imshow(img);
    title("APTOS Fundus Image");


    %% STEP 4: Display image information

    disp("Image size:");
    disp(size(img));

    disp("Image data type:");
    disp(class(img));


    %% STEP 5: Match image with its DR grade

    imageName = string(files(1).name);

    % Remove .png
    imageID = erase(imageName, ".png");

    % Find matching row in CSV
    row = string(data.id_code) == imageID;

    if any(row)

        grade = data.diagnosis(find(row, 1));

        fprintf("\nImage ID: %s\n", imageID);
        fprintf("DR Grade: %d\n", grade);

    else

        fprintf("\nImage ID %s was NOT found in train.csv\n", imageID);

    end


    %% STEP 6: Examine RGB channels

    figure;

    subplot(1,3,1);
    imshow(img(:,:,1));
    title("Red Channel");

    subplot(1,3,2);
    imshow(img(:,:,2));
    title("Green Channel");

    subplot(1,3,3);
    imshow(img(:,:,3));
    title("Blue Channel");


    %% STEP 7: Green channel

    green = img(:,:,2);

    figure;
    imshow(green);
    title("Green Channel");


    %% STEP 8: CLAHE Enhancement

    % Convert green channel to double
    green = im2double(green);

    % Apply CLAHE
    enhancedGreen = adapthisteq(green, ...
        "NumTiles", [8 8], ...
        "ClipLimit", 0.01);

    % Display comparison
    figure;

    subplot(1,2,1);
    imshow(green);
    title("Original Green Channel");

    subplot(1,2,2);
    imshow(enhancedGreen);
    title("CLAHE Enhanced Green Channel");

end
%% STEP 9: Illumination Normalization

% Estimate the smooth background illumination
background = imgaussfilt(enhancedGreen, 30);

% Remove uneven illumination
normalizedGreen = enhancedGreen - background;

% Rescale intensity for display
normalizedGreen = mat2gray(normalizedGreen);

% Display comparison
figure;

subplot(1,3,1);
imshow(enhancedGreen);
title("CLAHE Enhanced");

subplot(1,3,2);
imshow(background);
title("Estimated Illumination");

subplot(1,3,3);
imshow(normalizedGreen);
title("Illumination Normalized");