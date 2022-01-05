close all;
clc;
clear all;

stddev = sqrt(.002);
cropped_pic = double(imread("noisy_cropped.png"));

user_input = input("gauss, anisotropic, tv, bilat, matnlm, nlm\nchoose filter: ");

switch user_input
    case 'gauss'
        % matlab's guassian filter
        denoised_img = imgaussfilt(cropped_pic, 1);
    case 'anisotropic'
        % matlab's anisotropic filter
        denoised_img = imdiffusefilt(cropped_pic, "GradientThreshold", [39   34   31   28   26]);
    case 'tv'
        % Magiera & Löndahl's matlab implementation of
        % Total Variation minimization
        denoised_img = rof_denoise(cropped_pic, 15);
        
    case 'bilat'
       % neighbourhood filtering instead of yaroslavsky
       denoised_img = imbilatfilt(cropped_pic, 1); 
    case 'matnlm'
       % matlab non-local means function for comparison
       denoised_img = imnlmfilt(cropped_pic, "DegreeOfSmoothing", 10);
    case 'nlm'
       % my implementation of non-local means (img, swind, frame, sigma)
       denoised_img = nl_means(cropped_pic, 5, 2, 10);
end

% method noise is the difference between noisy image and denoised image
diff = cropped_pic - denoised_img;

imwrite(mat2gray(cropped_pic), "output/original_img.png")
imwrite(mat2gray(denoised_img), "output/denoised_img.png")
imwrite(mat2gray(diff), "output/method_noise.png")

imshow(mat2gray(cropped_pic))
title("Original Image");

figure,
imshow(mat2gray(denoised_img))
title("Filtered Image");

figure,
imshow(mat2gray(diff));
title("Method Noise");
