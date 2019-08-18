%% Problem Definition

%This script solves questions 4, 5 and 6 of the assignment. It calls
%'fullrsm' function as well as the 'build' function which is defined at the
%bottom of the file. All of the required information to answer the
%questions are stored the variable workspace.

clear; clc;

% The problem defines the following vectors
price = [45; 60; 50; 50; 55; 65; 40; 30; 30];
G = [1000; 430; 400; 1085; 387; 640; 1750; 800; 885];
K = [500; 600; 500; 800; 600; 1000; 300; 200; 800; 300; 850];
d = [1952; 722; 60; 284; 855; 0; 1078; 225; 617; 0];

%% Question 4

% Build the LP
[A, b, c] = build(price, G, K, d);

[m,n] = size(A);

% Solve
[result,z,x,pi]  =  fullrsm(m,n,c,A,b);

% Required information
xQ4 = x(23:31);
flowsQ4 = x(1:11) - x(12:22);
energyPriceQ4 = pi(1:10);
totalCostQ4 = z;


%% Question 5

% Add Kirchhoff's Law constraints to model
newRows = zeros(2,n); 
newRows(1, [2 4 14 16]) = -1;
newRows(1, [3 5 13 15]) = 1;    
newRows(2, [7 19]) = 1;
newRows(2, [18 8]) = -1;
newRows(2, 9) = 0.4;
newRows(2, 20) = -0.4;
    
A = [A; newRows];
b = [b; 0; 0];

% Solve
[m,n] = size(A);
[result,z,x,pi]  =  fullrsm(m,n,c,A,b);

% Required information
xQ5 = x(23:31);
flowsQ5 = x(1:11) - x(12:22);
energyPriceQ5 = pi(1:10);
totalCostQ5 = z;

%% Question 6 

% Add B-W line loss constraints to model
[m,~] = size(A);
A(:,[6,17]) = 0; 
newArcs = zeros(m,8);

[newArcs(5,1),newArcs(6,2),newArcs(5,3),newArcs(6,4)] = deal(-1);    
[newArcs(6,1),newArcs(5,2)] = deal(0.95);
[newArcs(6,3),newArcs(5,4)] = deal(0.85); 

bottom = [zeros(4,62) eye(4) eye(4)];

A = [A newArcs; bottom];
b = [b; 500; 500; 500; 500];
c = [c; zeros(8,1)];

% Solve
[m,n] = size(A);
[result,z,x,pi]  =  fullrsm(m,n,c,A,b);

%Required information
xQ6 = x(23:31);
flowsQ6 = x(1:11) - x(12:22);
flowsQ6(6) = -x(64)-x(66);
energyPriceQ6 = pi(1:10);
totalCostQ6 = z;

%% Functions

function [A, b, c] = build(price, G, K, d)
% This function builds the constraint matrix for the simplified electricity
% network. 
% Inputs: 
%   price = hourly cost of generating power at each generator
%       G = capacities of generators
%       K = capacities of network arcs
%       d = demand at network nodes (cities)
% Outputs:
%       A = constraint matrix
%       b = right-hand side
%       c = cost vector

    % Connections between cities
    arcs = [ 1 2; % A - H
             2 3; % H - NP
             2 4; % H - N  
             3 5; % NP - W
             4 5; % N - W
             5 6; % W - B
             6 7; % B - C
             6 8; % B - D
             7 8; % C - D
             9 8; % T - D
            10 9  % M - T
            ];
    
    % Generator connections to cities
    g = [1; 1; 1; 2; 3; 4; 6; 8; 10];
    
    nArcs = size(arcs, 1);
    nNodes = length(d);
    nGenerators = length(G);
    
    A = zeros(nNodes, nArcs);
    b = d;
    
    % Make node-arc incidence matrix 
    for i = 1:nArcs
        A(arcs(i,1),i) = -1;
        A(arcs(i,2),i) = 1;
    end
    
    % Add generator arcs
    genArcs = zeros(nNodes, nGenerators);
    for i = 1:nGenerators
        genArcs(g(i), i) = 1;
    end
    
    %Define LP
    A = [A -A genArcs];
    [m,n] = size(A);
    A = [A zeros(m,n); eye(n) eye(n)];
    b = [b; K; K; G]; 
    c = [zeros(22,1); price; zeros(n,1)];
    
end