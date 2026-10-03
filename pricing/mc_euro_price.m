function [price, stderr, discountedPayoffs, paths] = mc_euro_price(S0, K, r, sigma, T, nSteps, nPaths, optionType)
    % Edited for publication (Oct 2026): input guards and estimate wording; computation retained.
    % MC_EURO_PRICE Monte Carlo estimate for a European option using GBM.
    %   Returns estimated price and standard error.
    %   S0         - current underlying price
    %   K          - strike price
    %   r          - risk-free interest rate (annual)
    %   sigma      - volatility (annual)
    %   T          - time to maturity in years
    %   nSteps     - number of time steps
    %   nPaths     - number of paths to be calculated
    %   optionType - 'call' or 'put'

    validate_model_inputs(S0, r, sigma, T);
    if ~(isnumeric(K) && isscalar(K) && isreal(K) && isfinite(K) && K > 0)
        error('OptionPricer:InvalidInput', 'K must be a finite positive scalar.');
    end
    validate_option_type(optionType);
    validate_simulation_sizes(nSteps, nPaths);
    if nPaths < 2
        error('OptionPricer:InvalidInput', 'Monte Carlo standard error requires at least two paths.');
    end

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
