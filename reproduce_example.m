% Edited for publication (Oct 2026): recompute the seed-42 Pricer example.
% Same calculation sequence as ComputePriceButtonPushed, before plotting.
S0 = 100;
K = 102;
r = 0.05;
sigma = 0.2;
T = 1;
Npaths = 50000;
Nsteps = 252;
optionType = 'call';
addpath(fullfile(fileparts(mfilename('fullpath')), 'pricing'));
rng(42, 'twister');
bs = black_scholes_price(S0, K, r, sigma, T, optionType);
[mc, stderr, discPayoffs, paths] = mc_euro_price(S0, K, r, sigma, T, Nsteps, Npaths, optionType);
assert(abs(bs - 9.423365) <= 1e-6, 'OptionPricer:BlackScholesMismatch', ...
       'Black-Scholes differs from the recorded example.');
fprintf('Post-course example: seed 42, MATLAB R2026a\n');
fprintf('Black-Scholes value : %.6f\n', bs);
fprintf('Monte Carlo estimate: %.6f\n', mc);
fprintf('Standard error      : %.6f\n', stderr);
