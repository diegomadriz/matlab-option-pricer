function validate_model_inputs(S0, r, sigma, T)
    % Edited for publication (Oct 2026): new finite real scalar input validation.
    % VALIDATE_MODEL_INPUTS Check scalar assumptions used by the interface.
    values = {S0, r, sigma, T};
    for k = 1:numel(values)
        x = values{k};
        if ~(isnumeric(x) && isscalar(x) && isreal(x) && isfinite(x))
            error('OptionPricer:InvalidInput', 'Model inputs must be finite real numeric scalars.');
        end
    end
    if S0 <= 0 || sigma < 0 || T < 0
        error('OptionPricer:InvalidInput', 'Require S0 > 0, sigma >= 0 and T >= 0.');
    end
end
