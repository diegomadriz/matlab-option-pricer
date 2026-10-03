function paths = simulate_gbm_paths(S0, r, sigma, T, nSteps, nPaths)
    % Edited for publication (Oct 2026): input guards and formatting; GBM update retained.
    % SIMULATE_GBM_PATHS Simulates GBM paths for an underlying asset.
    %   S0      - initial price
    %   r       - risk-free rate (drift under risk-neutral measure)
    %   sigma   - volatility
    %   T       - time horizon in years
    %   nSteps  - number of time steps
    %   nPaths  - number of simulated paths
    %
    %   paths   - (nSteps+1) x nPaths matrix with simulated prices

    validate_model_inputs(S0, r, sigma, T);
    validate_simulation_sizes(nSteps, nPaths);

    dt = T / nSteps;
    paths = zeros(nSteps + 1, nPaths);
    paths(1, :) = S0;

    for t = 2:(nSteps + 1)
        Z = randn(1, nPaths); % standard normals
        paths(t, :) = paths(t - 1, :) .* exp((r - 0.5 * sigma^2) * dt + sigma * sqrt(dt) .* Z);
    end
end
