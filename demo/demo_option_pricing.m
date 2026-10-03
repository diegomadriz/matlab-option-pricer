% demo_option_pricing.m
% Standalone demonstration of the pricing functions.
%   Returns a Black-Scholes value, Monte Carlo estimate, and the standard
%   error of the Monte Carlo estimate.
%

clear;
clc;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'pricing'));

% initial demo params
S0 = 100;
K = 100;
r = 0.05;
sigma = 0.2;
T = 1;

nSteps = 252;
nPaths = 5000;

% obtain prices
bsPrice = black_scholes_price(S0, K, r, sigma, T, 'call');
[mcPrice, mcErr] = mc_euro_price(S0, K, r, sigma, T, nSteps, nPaths, 'call');

% display results in console
fprintf('Black--Scholes price: %.4f\n', bsPrice);
fprintf('Monte Carlo estimate: %.4f\n', mcPrice);
fprintf('Standard error      : %.4f\n\n', mcErr);

% simulate the GBM paths
paths = simulate_gbm_paths(S0, r, sigma, T, nSteps, 20);

% plot GBM paths for demo, if it works it should look like spaghetti
figure;
plot(paths);
title('Sample Geometric Brownian Motion Paths');
xlabel('Time step');
ylabel('Asset price');

% terminal prices histogram
figure;
histogram(paths(end, :), 50);
title('Distribution of Terminal Asset Prices');
xlabel('Price');
ylabel('Frequency');
