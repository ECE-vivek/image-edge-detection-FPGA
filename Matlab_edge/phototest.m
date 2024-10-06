a=[255,255,255,255,255,255,255,255;
    255,255,255,255,255,255,255,255;
    255,255,255,255,255,255,255,255;
    255,255,255,255,0,255,255,255;
    255,255,255,255,255,255,255,255;
    255,255,255,255,255,255,255,255;
    255,255,255,255,255,255,255,255;
    255,255,255,255,255,255,255,255;
    ];
imshow(a);

% input_folder = 'D:\Mat_lab\img\fundus'; % Specify your input folder path
output_folder = 'D:\Mat_lab\output\'; % Specify your output folder path

% Get a list of all image files in the input folder
%image_files = dir(fullfile(input_folder)); % Adjust the file extension if needed
output_filename = fullfile(output_folder, ['final_output_.tiff']);
imwrite(a, output_filename,'tiff');
