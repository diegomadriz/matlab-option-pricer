function price = black_scholes_price(S0, K, r, sigma, T, optionType)
    % Edited for publication (Oct 2026): scalar input guards and formatting; pricing formulas retained.
    % BLACK_SCHOLES_PRICE Computes the Black-Scholes price of a European call or put.
    %   S0         - current underlying price
    %   K          - strike price
    %   r          - risk-free interest rate (annual)
    %   sigma      - volatility (annual)
    %   T          - time to maturity in years
    %   optionType - 'call' or 'put'

    validate_model_inputs(S0, r, sigma, T);
    if ~(isnumeric(K) && isscalar(K) && isreal(K) && isfinite(K) && K > 0)
        error('OptionPricer:InvalidInput', 'K must be a finite positive scalar.');
    end
    validate_option_type(optionType);

    % [post-course fix 2026-07-09] Deterministic zero-maturity/volatility payoff.
    if T == 0 || sigma == 0
        forwardPrice = S0 .* exp(r .* T);
        if strcmpi(optionType, "call")
            price = exp(-r .* T) .* max(forwardPrice - K, 0);
        elseif strcmpi(optionType, "put")
            price = exp(-r .* T) .* max(K - forwardPrice, 0);
        else
            error('optionType must be "call" or "put".');
        end
        return
    end

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
