function validate_simulation_sizes(nSteps, nPaths)
    % VALIDATE_SIMULATION_SIZES Require positive integer simulation sizes.
    values = {nSteps, nPaths};
    for k = 1:numel(values)
        x = values{k};
        if ~(isnumeric(x) && isscalar(x) && isreal(x) && isfinite(x) && ...
             x >= 1 && x == fix(x))
            error('OptionPricer:InvalidInput', 'Steps and paths must be positive integers.');
        end
    end
end
