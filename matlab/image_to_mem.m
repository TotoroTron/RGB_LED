format hex;
fileID = fopen('C:\Vivado_Projects\RGB-Display\RGB-Display.srcs\sources_1\new\image_memfiles\rainbow3.mem', 'w');
filePath = 'C:\Users\brian\OneDrive\Pictures\extracted4\';

for n=1:23
    fileName = [filePath 'Frame' num2str(n) '.bmp' ];
    A = imread(fileName);
    
    for i = 1:32
        for j = 1:32
            X = ['@', dec2hex(1024*(n-1)+32*(i-1)+(j-1),8), ' ', dec2hex(A(i, j, 1),2), '', dec2hex(A(i,j,2),2), '', dec2hex(A(i,j,3),2)];
            %.mem output format: @AAAAAAAA DDDDDD
            fprintf(fileID, '%s\n', X);
        end
    end
end

fclose(fileID);