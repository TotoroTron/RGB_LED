format hex;
fileID = fopen('H:\Vivado_Projects\RGB-Display\RGB-Display.srcs\sources_1\new\rainbow2.mem', 'w');
filePath = 'C:\Users\Brian\Pictures\gifs\rainbowgif2\';

for n=1:29
    fileName = [filePath 'Frame-' num2str(n) '.bmp' ];
    A = imread(fileName);
    
    for i = 1:32
        for j = 1:32
            X = ['@', dec2hex(1024*(n-1)+32*(i-1)+(j-1),8), ' ', dec2hex(A(i, j, 1),2), '', dec2hex(A(i,j,2),2), '', dec2hex(A(i,j,3),2)];
            fprintf(fileID, '%s\n', X);
        end
    end
end

fclose(fileID);
