% ----------------------------------------
% Main program for the solution of Poisson's equation
%  - a laplace = f in 2D using iterative   Gauss-Seidel method
% ----------------------------------------

close all
clc
clear
clf
%Define input parameters
n=20; % number of inner nodes in one direction.
a_amp = 12; %  amplitude for the function a(x_1,x_2)
f_amp = 1; %  we can choose f=1, 50, 100
x_0=0.5;
y_0=0.5;
c_x=1;
c_y=1;

h = 1/(n+1); % define step length

% ----------------------------------------
% Computing all matrices and vectors
% ----------------------------------------
% Generate a n*n by n*n stiffness matrix
S = DiscretePoisson2D(n);

%% generate coefficient matrix of a((x_1)_i,(x_2)_j) = a(i*h,j*h)
C = zeros(n,n);
for i=1:n
  for j=1:n
    C(i,j) = 1 + a_amp*exp(-((i*h-x_0)^2/(2*c_x^2)...
    +(j*h-y_0)^2/(2*c_y^2)));
  end
end
% create diagonal matrix from C
D = zeros(n^2,n^2);
for i=1:n
  for j=1:n
    D(j+n*(i-1),j+n*(i-1)) = C(i,j);
  end
end

% If f is constant.
% f = f_amp*ones(n^2,1);

% If f is Gaussian function.
f=zeros(n^2,1);
for i=1:n
  for j=1:n
    f(n*(i-1)+j)=f_amp*exp(-((i*h-x_0)^2/(2*c_x^2)...
    +(j*h-y_0)^2/(2*c_y^2)));
  end
end

%  Compute vector of right hand side
%  b = D^(-1)*f   computed as b(i,j)=f(i,j)/a(i,j)

b=zeros(n^2,1);
for i=1:n
  for j=1:n
    b(n*(i-1)+j)=  h^2*(f(n*(i-1)+j))/C(i,j); % Use coefficient matrix C or
    % diagonal matrix D to get a(i,j)
    
  end
end

% ----------------------------------------
% Solution of  S*u = b  using iterative Gauss-Seidel method
% ----------------------------------------

residual = 1;  k=0;  tol=10^(-9);

u = zeros(n^2,1);
u_old = u;

% use  Gauss-Seidel  algorithm without red-black ordering:
% values u(1:(j-1)) are already updated, and u_old((j+1):n^2)
% are older, computed on the previous iteration

while (norm(residual)> tol)
  for j = 1:n^2
    u(j) = 1/S(j,j) * (b(j)  ...
    - S(j,1:(j-1))*u(1:(j-1)) - S(j,(j+1):n^2)*u_old((j+1):n^2));
  end
  u_old = u;
  residual = S*u- b;
  k = k+1;
end

disp('-- Number of iterations in Gauss-Seidel method ----------')
k

% ----------------------------------------
% Plots and figures for Gauss-Seidel method
% ----------------------------------------
% sort the data in u into the mesh-grid, the boundary nodes are zero.
Z = zeros(n+2,n+2);
for i=1:n
  for j=1:n
    Z(i+1,j+1) = u(j+n*(i-1));
  end
end

%% plotting
x1=0:h:1;
y1=0:h:1;

subplot (2,2,1)
surf(x1,y1, Z) % same plot as above, (x1, y1 are vectors)
view(2)
colorbar
xlabel('x_1')
ylabel('x_2')
zlabel('u(x_1,x_2)')
title( ['solution u(x_1,x_2) Gauss-Seidel method ',...
',  N = ',num2str(n),', iter. = ',num2str(k)])

subplot (2,2,2)

surf(x1,y1, Z) % same plot as above
colorbar
xlabel('x_1')
ylabel('x_2')
zlabel('u(x_1,x_2)')

title( ['solution u(x_1,x_2)  Gauss-Seidel method',...
',  N = ',num2str(n),', iter. = ',num2str(k)])

% Plotting a(x,y)
Z_a= zeros(n+2);
for i=1:(n+2)
  for j=1:(n+2)
    Z_a(i,j)= 1 + a_amp*exp(-((i*h-x_0)^2/(2*c_x^2)...
    +(j*h-y_0)^2/(2*c_y^2)));
  end
end

subplot (2,2,3)
surf(x1,y1,Z_a)
xlabel('x_1')
ylabel('x_2')
zlabel('a(x_1,x_2)')
title( ['coefficient a(x_1,x_2) with A = ',num2str(a_amp)])

%  plott the function f(x,y)
Z_f= zeros(n+2);
for i=1:(n+2)
  for j=1:(n+2)
    Z_f(i,j)=f_amp*exp(-((x1(i)-x_0)^2/(2*c_x^2)...
    +(y1(j)-y_0)^2/(2*c_y^2)));
  end
end

subplot (2,2,4)
surf(x1,y1,Z_f)
xlabel('x_1')
ylabel('x_2')
zlabel('f(x_1,x_2)')
title( ['f(x_1,x_2) with A_f = ',num2str(f_amp)])

