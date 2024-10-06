clc; clear all; close all;

% Getting Window/Kernel size
disp('Enter odd integer ');
while true
    n = input('Enter window size :');
    if mod(n, 2) == 0
        disp('Number is Even.');
    else
        break
    end
end
tic
n = int32(n);
disp('Chosen window size is :');
disp(n);
m = idivide(n, 2);
q = idivide(n*n, 2) + 1;

% Image Read
a = imread('th.jpg');
a = im2gray(a);
figure; imshow(a); title('Original image');
[r, c] = size(a);
b = zeros(r, c);

% Creating Blank Canvas with padding
x = zeros(r + (2 * m), c + (2 * m));
y = x;
for i = 1:r
    for j = 1:c
        y(i + m, j + m) = a(i, j);
    end
end
y = uint8(y);
figure; imshow(y); title('Padded image');

% Median Filtering
for i = m + 1:r - m
    for j = m + 1:c - m
        mat = y(i - m:i + m, j - m:j + m);
        mat = sort(mat(:));
        b(i, j) = mat(q);
    end
end
b([1:m], :) = [];
b(:, [1:m]) = [];
b = uint8(b);
figure; imshow(b); title('Image after filtering');

% Sobel Edge Detection
k1 = double(b);
%s_msk = [-1 0 1; -2 0 2; -1 0 1];
%p_msk=[-1 0 1; -1 0 1; -1 0 1];s
%s_msk5=[-1 -2 0 2 1; -2 -3 0 3 2; -3 -5 0 5 3;-2 -3 0 3 2;-1 -2 0 2 1 ];
 s_msk7=[-1 -2 -3 0 3 2 1;
        -2 -3 -5 0 5 3 2;
        -3 -5 -7 0 7 5 3;
        -5 -7 -9 0 9 7 5;
        -1 -2 -3 0 3 2 1;
        -2 -3 -5 0 5 3 2;
        -3 -5 -7 0 7 5 3;];
kx = conv2(k1, s_msk7, 'same');
ky = conv2(k1, s_msk7', 'same');
grad = sqrt(kx.^2 + ky.^2);
ori = atan2(ky, kx);

% Edge Thinning (Non-Maximum Suppression)
[r, c] = size(grad);
thinned_edges = zeros(r, c);
ori = ori * (180 / pi);
ori(ori < 0) = ori(ori < 0) + 180;

for i = 2:r-1
    for j = 2:c-1
        if ((ori(i, j) >= 0) && (ori(i, j) < 22.5)) || ((ori(i, j) >= 157.5) && (ori(i, j) <= 180))
            neighbors = [grad(i, j+1), grad(i, j-1)];
        elseif (ori(i, j) >= 22.5) && (ori(i, j) < 67.5)
            neighbors = [grad(i+1, j-1), grad(i-1, j+1)];
        elseif (ori(i, j) >= 67.5) && (ori(i, j) < 112.5)
            neighbors = [grad(i+1, j), grad(i-1, j)];
        else
            neighbors = [grad(i-1, j-1), grad(i+1, j+1)];
        end
        if (grad(i, j) >= neighbors(1)) && (grad(i, j) >= neighbors(2))
            thinned_edges(i, j) = grad(i, j);
        else
            thinned_edges(i, j) = 0;
        end
    end
end

% Hysteresis Thresholding
high_threshold = 100; % Adjust based on your needs
low_threshold = 30;   % Adjust based on your needs
binary_edge = zeros(size(thinned_edges));
strong_edges = thinned_edges > high_threshold;
weak_edges = (thinned_edges > low_threshold) & (thinned_edges <= high_threshold);
binary_edge(strong_edges) = 1;

for i = 2:size(thinned_edges, 1)-1
    for j = 2:size(thinned_edges, 2)-1
        if weak_edges(i, j)
            if any(any(strong_edges(i-1:i+1, j-1:j+1)))
                binary_edge(i, j) = 1;
            end
        end
    end
end

% Display the final thinned and thresholded edge image
figure; imshow(binary_edge); title('Thinned and Hysteresis Thresholded Edge Detection');
toc
% Save the final output image
output_folder = 'D:\Mat_lab\output'; % Specify your output folder path
output_filename = fullfile(output_folder, 'final_output.png');
imwrite(binary_edge, output_filename);
