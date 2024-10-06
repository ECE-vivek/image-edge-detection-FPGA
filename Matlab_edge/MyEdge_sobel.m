clc; clear all; close all;


%%%%%%% Getting Window/Kernel size %%%%%%%%%

disp('Enter odd integer ');
a=1;
while a==1
    n = input('Enter window size :');
    if mod(n,2) == 0 
        
        disp('Number is Even.');
    else
        break
    end
end
tic
n=int32(n);
disp('Choosen window size is :');
disp(n);
m= idivide(n,2);
q=idivide(n*n,2)+1;
% disp(m);
%%%%%%%%%%% Image Read %%%%%%%%
a = imread('plane.tif');
%a = imnoise(a,'salt & pepper', 0.02);
a=im2gray(a);
ref = a;
figure;
imshow(a);
title('Original image');
[r, c]=size(a);
b=zeros(r,c);

%%% Creating Blank Canvas with padding %%%%%
x=zeros(r+(2.*m),c+(2.*m));
y=x;
figure;
imshow(x);
title('Blank image ');


%%%%% Putting image back in canvas with padding "m"   %%%%%
for i=1:r
    
    for j=1:c
        l=a(i,j);
        y(i+m,j+m)=l;
    end
end
y=uint8(y);
figure;
imshow(y);
title('Paded image ');

[r,c]=size(y);
% b=zeros(a);
for i=m+1:r-m
    for j=m+1:c-m
       
        % Define the neighborhood 
         mat=y(i-m:i+m,j-m:j+m);
              
        
        mat=sort(mat(:));
        b(i,j)=mat(q);
    end
end
b([1:m], :) = [];
b(:, [1:m]) = [];
b = uint8(b);
figure;
imshow(b);
title('image after filtering W 5');


%%%%% MATLAB code for sobel%%%%%%
% operator edge detection
k=b;
% k=im2gray(k);
k1=double(k);
%p_msk=[-1 0 1; -1 0 1; -1 0 1];
s_msk=[-1 0 1; -2 0 2; -1 0 1];
% s_msk5=[-1 -2 0 2 1; -2 -3 0 3 2; -3 -5 0 5 3;-2 -3 0 3 2;-1 -2 0 2 1 ];
% s_msk7=[-1 -2 -3 0 3 2 1;
%         -2 -3 -5 0 5 3 2;
%         -3 -5 -7 0 7 5 3;
%         -5 -7 -9 0 9 7 5;
%         -1 -2 -3 0 3 2 1;
%         -2 -3 -5 0 5 3 2;
%         -3 -5 -7 0 7 5 3;];
kx=conv2(k1, s_msk, 'same');

ky=conv2(k1, s_msk', 'same');


grad=sqrt(kx.^2 + ky.^2);

%%%%%%%%%%% Edge orientation
ori = atan2(ky, kx);
figure;
imagesc(ori);
colorbar;
title('Edge Orientation');
% ori=uint8(ori *255);
% figure;
% imshow(ori);
% title('Edge Orientation');


%%%%%% non Maximum supression %%%%%%%%%%%%%%%%
% ked=uint8(ked);
% [r,c]=size(ked);
% c=zeros(r,c);
% q=10;
% for j=2:r-2
%    
%     for i=2:c-2
%         if (ked(i,j)>= q) 
%             c(i,j)=ked(i,j);
%         else
%             c(i,j)=0;
%         end
%             
%     end
% end
% c = uint8(c);
% figure;
% imshow(c);
% title('image after non-maximum supression');
% ked=c;
% display the images.
imtool(k,[]);

% display the edge detection along x-axis.
imtool(abs(kx), []);

% display the edge detection along y-axis.
 imtool(abs(ky),[]);

% display the full edge detection.
imtool(abs(grad),[]);
grad=uint8(grad);
% % After calculating the gradient magnitude (grad)
% threshold = 100; % You can adjust this value based on your needs
% binary_edge = grad > threshold;
% 
% % Display the thresholded image
% figure;
% imshow(binary_edge);
%title('Thresholded Edge Detection');
% Define high and low thresholds
% high_threshold = 100; % Adjust based on your needs
% low_threshold = 50;   % Adjust based on your needs
% 
% % Initialize the output binary edge map
% binary_edge = zeros(size(grad));
% 
% % Strong edges (above high threshold)
% strong_edges = grad > high_threshold;
% 
% % Weak edges (between low and high thresholds)
% weak_edges = (grad > low_threshold) & (grad <= high_threshold);
% 
% % Set strong edges in the binary edge map
% binary_edge(strong_edges) = 1;
% 
% % Perform hysteresis: retain weak edges connected to strong edges
% for i = 2:size(grad, 1)-1
%     for j = 2:size(grad, 2)-1
%         if weak_edges(i, j)
%             % Check 8-connected neighborhood for strong edges
%             if any(any(strong_edges(i-1:i+1, j-1:j+1)))
%                 binary_edge(i, j) = 1;
%             end
%         end
%     end
% end
% 
% % Display the thresholded image
% figure;
% imshow(binary_edge);
%title('Hysteresis Thresholded Edge Detection');
% After calculating the gradient magnitude (grad) and orientation (ori)
[r, c] = size(grad);
thinned_edges = zeros(r, c);

% Convert orientation to degrees
ori = ori * (180 / pi);
ori(ori < 0) = ori(ori < 0) + 180;

% Non-maximum suppression
for i = 2:r-1
    for j = 2:c-1
        % Determine the direction of the edge
        if ((ori(i, j) >= 0) && (ori(i, j) < 22.5)) || ((ori(i, j) >= 157.5) && (ori(i, j) <= 180))
            neighbors = [grad(i, j+1), grad(i, j-1)];
        elseif (ori(i, j) >= 22.5) && (ori(i, j) < 67.5)
            neighbors = [grad(i+1, j-1), grad(i-1, j+1)];
        elseif (ori(i, j) >= 67.5) && (ori(i, j) < 112.5)
            neighbors = [grad(i+1, j), grad(i-1, j)];
        else
            neighbors = [grad(i-1, j-1), grad(i+1, j+1)];
        end
        
        % Suppress non-maximum pixels
        if (grad(i, j) >= neighbors(1)) && (grad(i, j) >= neighbors(2))
            thinned_edges(i, j) = grad(i, j);
        else
            thinned_edges(i, j) = 0;
        end
    end
end

% Apply hysteresis thresholding
high_threshold = 100; % Adjust based on your needs
low_threshold = 50;   % Adjust based on your needs

% Initialize the output binary edge map
binary_edge = zeros(size(thinned_edges));

% Strong edges (above high threshold)
strong_edges = thinned_edges > high_threshold;

% Weak edges (between low and high thresholds)
weak_edges = (thinned_edges > low_threshold) & (thinned_edges <= high_threshold);

% Set strong edges in the binary edge map
binary_edge(strong_edges) = 1;

% Perform hysteresis: retain weak edges connected to strong edges
for i = 2:size(thinned_edges, 1)-1
    for j = 2:size(thinned_edges, 2)-1
        if weak_edges(i, j)
            % Check 8-connected neighborhood for strong edges
            if any(any(strong_edges(i-1:i+1, j-1:j+1)))
                binary_edge(i, j) = 1;
            end
        end
    end
end

% Display the final thinned and thresholded edge image
figure;
imshow(binary_edge);
title('Thinned and Hysteresis Thresholded Edge Detection');


figure;
imshow(grad);
title('final image');
toc
figure;
mesh(grad);
title('3D visual of intensity');