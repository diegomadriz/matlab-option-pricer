function price = black_scholes_price(S0, K, r, sigma, T, optionType)
%BLACK_SCHOLES_PRICE Computes the Black-Scholes price of a European call or put.
%   S0         - current underlying price
%   K          - strike price
%   r          - risk-free interest rate (annual)
%   sigma      - volatility (annual)
%   T          - time to maturity in years
%   optionType - 'call' or 'put'

    % d1 and d2
    d1 = (log(S0 ./ K) + (r + 0.5 * sigma.^2) .* T) ./ (sigma .* sqrt(T));
    d2 = d1 - sigma .* sqrt(T);

    % normal cdf using the statistics toolbox
    if strcmpi(optionType, "call")
        price = S0 .* normcdf(d1) - K .* exp(-r .* T) .* normcdf(d2);
    elseif strcmpi(optionType, "put")
        price = K .* exp(-r .* T) .* normcdf(-d2) - S0 .* normcdf(-d1);
    else
        error('optionType must be "call" or "put".');
    end
end