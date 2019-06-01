clc;
clear all;
addpath('C:\Program Files\MATLAB\R2012a\toolbox\TOOLBOX_calib')
cd C:\Users\Nitish\Desktop\SEM7\COL780\Project
img = imread('Tennis.png');
%img = edge(img, 'canny');
%cor = corner(img, 500);
nx = size(img, 2);
ny = size(img, 1);

% imshow(img, []);

x = [
   407   142
   470   142
   656   144
   842   145
   905   145
   443   186
   657   187
   869   187
   305   254
   395   255
   656   258
   918   259
   1007  259
   322   370
   657   371
   993   372
    57   534
   211   536
   658   536
  1104   539
  1258   542
   306   191
   398   194
   657   202
   918   198
  1008   195
   ]';

y = [
   0 0 0
   4.5 0 0
   18 0 0
   31.5 0 0
   36 0 0
   4.5 18 0
   18 18 0
   31.5 18 0
   0 39 0
   4.5 39 0
   18 39 0
   31.5 39 0
   36 39 0
   4.5 60 0
   18 60 0
   31.5 60 0
   0 78 0
   4.5 78 0
   18 78 0
   31.5 78 0
   36 78 0
   0 39 3.2
   4.5 39 3.2
   18 39 3
   31.5 39 3.2
   36 39 3.2
]';

num_pts = size(y, 2);

% Required by camera calibration toolbox
x_1 = x;
X_1 = y;

% Setting up calibration parameters
n_ima = 1;
est_aspect_ratio = 0;
est_dist = zeros(5, 1);
% check_cond = 0;

% Run calibration
go_calib_optim;

%% Estimate original points
P = [Rc_1 Tc_1];
L = KK * P;
M = [L(:, 1 : 2) L(:, 4)];
a = ones(3, nx * ny);
for i = 1 : nx
    for j = 1 : ny
        a(1 : 2, (i - 1) * ny + j) = [i; j];
    end
end
A = inv(M) * a;
P(1, 4) = P(1, 4) - 0.4;
L = KK * P;
M = [L(:, 1 : 2) L(:, 4)];
for i = 1 : size(a, 2)
    A(:, i) = A(:, i) / A(3, i);
end
a = M * A;
for i = 1 : size(a, 2)
    a(:, i) = a(:, i) / a(3, i);
end
img2 = img;
for i = 1 : nx
    for j = 1 : ny
        i2 = round(a(1, (i - 1) * ny + j));
        i1 = round(a(2, (i - 1) * ny + j));
        if i1 > 0 & i1 <= ny
            %if i2 > 0 & i2 <= nx & ~(i1 > 400 & i1 < 640 & i2 > 800 & i2 < 960)
            if i2 > 0 & i2 <= nx
                img2(j, i) = img(i1, i2);
            else
                if i2 <= 0
                    img2(j, i) = img(i1, 1);
                else
                    img2(j, i) = img(i1, nx);
                end
            end
        else            
            if i1 <= 0
                if i2 > 0 & i2 <= nx
                    img2(j, i) = img(1, i2);
                else
                    if i2 <= 0
                        img2(j, i) = img(1, 1);
                    else
                        img2(j, i) = img(1, nx);
                    end
                end
            else
                if i2 > 0 & i2 <= nx
                    img2(j, i) = img(ny, i2);
                else
                    if i2 <= 0
                        img2(j, i) = img(ny, 1);
                    else
                        img2(j, i) = img(ny, nx);
                    end
                end
            end
        end
    end
end
est_x_1 = L * [X_1; ones(1, size(X_1, 2))];
repmat(est_x_1(3, :), 3, 1);
est_x_1 = est_x_1 ./ repmat(est_x_1(3, :), 3, 1);

%% Plot results
figure
imshow(img, []);
figure
imshow(img2, []);
imwrite(img2, 'Tennis3.png');
%plot(cor(:, 1), cor(:, 2), 'gs');
KK
P
L
