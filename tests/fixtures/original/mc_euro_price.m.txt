function [price, stderr, discountedPayoffs, paths] = mc_euro_price(S0, K, r, sigma, T, nSteps, nPaths, optionType)
%MC_EURO_PRICE Monte Carlo price for a European option using GBM.
%   Returns estimated price and standard error.
%   S0         - current underlying price
%   K          - strike price
%   r          - risk-free interest rate (annual)
%   sigma      - volatility (annual)
%   T          - time to maturity in years
%   nSteps     - number of time steps
%   nPaths     - number of paths to be calculated
%   optionType - 'call' or 'put'

    paths = simulate_gbm_paths(S0, r, sigma, T, nSteps, nPaths);
    ST = paths(end, :);  % terminal prices

    switch lower(optionType)
        case 'call'
            payoffs = max(ST - K, 0);
        case 'put'
            payoffs = max(K - ST, 0);
        otherwise
            error('optionType must be "call" or "put".');
    end

    discountedPayoffs = exp(-r * T) * payoffs;
    price = mean(discountedPayoffs);
    stderr = std(discountedPayoffs) / sqrt(nPaths);
end