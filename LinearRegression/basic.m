%% Basic Matlab commands
clear all; clc;
% Row vector
a = [1 2 3];
% Column vector
b = [1;2;3];
% Matrix
A = [2 3; 5 8];
% Transpose
C = A';
% Recall elements of Matrix
A(1,2) % element of matrix A for row 1 and column 2
A(:,2) % all elements of column 2 for matrix A

%% Matrix operations
A + A % Addition
A - A % Subtraction
A*C' % Multiplication
A^2 % Power to 2
% Inverse of a Matrix
inv(A) 
A\speye(2); % speye(n) is sparse identity matrix

%% functions
% if function
u = rand;
if u <= .25
disp('1');
elseif u <= .5
disp('2');
elseif u <= .75
disp('3');
else
disp('4');
end

% for loop function
store_num = zeros(10,1); %% create a storage vector
for i = 1:10
  store_num(i,:) = rand;  
end
store_num

% while function
u = randn;
while u <= 0
u = randn;
end

% Combination of all functions
x = zeros(1,5); %% create a storage vector
for i=1:5
u = randn;
while u <= 0
u = randn;
end
x(i)=u;
end
x

  
