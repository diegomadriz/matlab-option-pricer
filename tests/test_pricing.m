function tests = test_pricing
    % TEST_PRICING Core mathematics, input rejection and source fidelity.
    tests = functiontests(localfunctions);
end

function setupOnce(testCase)
    root = fileparts(fileparts(mfilename('fullpath')));
    testCase.TestData.root = root;
    testCase.TestData.oldPath = path;
    testCase.TestData.oldRng = rng;
    addpath(root);
    addpath(fullfile(root, 'pricing'));
    referenceDir = tempname;
    mkdir(referenceDir);
    names = {'black_scholes_price', 'mc_euro_price', 'simulate_gbm_paths'};
    for k = 1:numel(names)
        source = fileread(fullfile(root, 'tests', 'fixtures', 'original', [names{k} '.m.txt']));
        for j = 1:numel(names)
            source = strrep(source, names{j}, ['reference_' names{j}]);
        end
        file = fopen(fullfile(referenceDir, ['reference_' names{k} '.m']), 'w');
        assert(file >= 0, 'Could not write reference function.');
        cleanup = onCleanup(@() fclose(file));
        fprintf(file, '%s', source);
        clear cleanup;
    end
    addpath(referenceDir);
    testCase.TestData.referenceDir = referenceDir;
end

function teardownOnce(testCase)
    path(testCase.TestData.oldPath);
    rng(testCase.TestData.oldRng);
    rmdir(testCase.TestData.referenceDir, 's');
end

function testPutCallParity(testCase)
    call = black_scholes_price(100, 102, 0.05, 0.2, 1, 'call');
    put = black_scholes_price(100, 102, 0.05, 0.2, 1, 'put');
    testCase.verifyEqual(call - put, 100 - 102 * exp(-0.05), 'AbsTol', 1e-12);
end

function testDeterministicLimits(testCase)
    testCase.verifyEqual(black_scholes_price(100, 102, 0.05, 0.2, 0, 'put'), 2);
    testCase.verifyEqual(black_scholes_price(100, 102, 0.05, 0, 1, 'call'), ...
                         max(100 - 102 * exp(-0.05), 0), 'AbsTol', 1e-12);
    paths = simulate_gbm_paths(100, 0.05, 0, 1, 4, 3);
    expected = repmat(100 * exp(0.05 * (0:4)' / 4), 1, 3);
    testCase.verifyEqual(paths, expected, 'AbsTol', 1e-12);
    paths = simulate_gbm_paths(100, 0.05, 0.2, 0, 4, 3);
    testCase.verifyEqual(paths, 100 * ones(5, 3));
end

function testPayoffAndStandardError(testCase)
    for optionType = {'call', 'put'}
        rng(1, 'twister');
        [estimate, stderr, payoffs, paths] = mc_euro_price(100, 102, 0.05, 0.2, 1, 12, 1000, optionType{1});
        if strcmp(optionType{1}, 'call')
            expected = exp(-0.05) * max(paths(end, :) - 102, 0);
        else
            expected = exp(-0.05) * max(102 - paths(end, :), 0);
        end
        testCase.verifyEqual(payoffs, expected);
        testCase.verifyEqual(estimate, mean(expected));
        testCase.verifyEqual(stderr, std(expected) / sqrt(1000));
        testCase.verifySize(paths, [13, 1000]);
        testCase.verifyGreaterThan(paths, 0);
    end
end

function testConvergenceWithinTolerance(testCase)
    % Fixed-seed convergence diagnostic.
    % Require error <= five sample standard errors + roundoff allowance.
    % A single stochastic estimate is not required to improve monotonically.
    for optionType = {'call', 'put'}
        rng(1, 'twister');
        [~, smallError] = mc_euro_price(100, 102, 0.05, 0.2, 1, 12, 1000, optionType{1});
        rng(1, 'twister');
        [estimate, largeError] = mc_euro_price(100, 102, 0.05, 0.2, 1, 12, 50000, optionType{1});
        baseline = black_scholes_price(100, 102, 0.05, 0.2, 1, optionType{1});
        testCase.verifyLessThanOrEqual(abs(estimate - baseline), 5 * largeError + 1e-12);
        testCase.verifyLessThan(largeError, smallError);
    end
end

function testMatchesOriginalImplementation(testCase)
    % Original implementation (tests/fixtures/original): compare for T > 0 and sigma > 0.
    for optionType = {'call', 'put'}
        for volatility = [0.2, 0.4]
            actual = black_scholes_price(100, 102, 0.05, volatility, 1, optionType{1});
            expected = reference_black_scholes_price(100, 102, 0.05, volatility, 1, optionType{1});
            testCase.verifyEqual(actual, expected);
        end
        rng(1, 'twister');
        [a, b, c, d] = mc_euro_price(100, 102, 0.05, 0.2, 1, 252, 1000, optionType{1});
        rng(1, 'twister');
        [w, x, y, z] = reference_mc_euro_price(100, 102, 0.05, 0.2, 1, 252, 1000, optionType{1});
        testCase.verifyEqual(a, w);
        testCase.verifyEqual(b, x);
        testCase.verifyEqual(c, y);
        testCase.verifyEqual(d, z);
    end
end

function testInvalidInputs(testCase)
    badValues = {NaN, Inf, -Inf, 1i, [], [1, 2], 'bad'};
    for k = 1:numel(badValues)
        value = badValues{k};
        testCase.verifyError(@() black_scholes_price(value, 102, 0.05, 0.2, 1, 'call'), ...
                             'OptionPricer:InvalidInput');
        testCase.verifyError(@() simulate_gbm_paths(100, value, 0.2, 1, 12, 10), ...
                             'OptionPricer:InvalidInput');
        testCase.verifyError(@() mc_euro_price(100, 102, 0.05, 0.2, 1, 12, value, 'call'), ...
                             'OptionPricer:InvalidInput');
    end
    testCase.verifyError(@() black_scholes_price(0, 102, 0.05, 0.2, 1, 'call'), 'OptionPricer:InvalidInput');
    testCase.verifyError(@() black_scholes_price(100, 0, 0.05, 0.2, 1, 'call'), 'OptionPricer:InvalidInput');
    testCase.verifyError(@() black_scholes_price(100, 102, 0.05, -0.2, 1, 'call'), 'OptionPricer:InvalidInput');
    testCase.verifyError(@() black_scholes_price(100, 102, 0.05, 0.2, -1, 'call'), 'OptionPricer:InvalidInput');
    testCase.verifyError(@() mc_euro_price(100, 0, 0.05, 0.2, 1, 12, 10, 'call'), 'OptionPricer:InvalidInput');
    testCase.verifyError(@() mc_euro_price(100, 102, 0.05, 0.2, 1, 12, 10, 'other'), 'OptionPricer:InvalidInput');
    testCase.verifyError(@() mc_euro_price(100, 102, 0.05, 0.2, 1, 0, 10, 'call'), 'OptionPricer:InvalidInput');
    testCase.verifyError(@() simulate_gbm_paths(100, 0.05, 0.2, 1, 1.5, 10), 'OptionPricer:InvalidInput');
    testCase.verifyError(@() simulate_gbm_paths(100, 0.05, 0.2, 1, 12, -10), 'OptionPricer:InvalidInput');
    testCase.verifyError(@() mc_euro_price(100, 102, 0.05, 0.2, 1, 12, 1, 'call'), 'OptionPricer:InvalidInput');
end

function testRecordedSeed42Example(testCase)
    % Reproduction uses the Pricer callback's rng -> analytical -> MC sequence.
    reproduce_example;
    testCase.verifyEqual(bs, 9.423365, 'AbsTol', 1e-6);
    testCase.verifyEqual(mc, 9.414263, 'AbsTol', 1e-6);
    testCase.verifyEqual(stderr, 0.062853, 'AbsTol', 1e-6);
end

function testMonteCarloPutCallParity(testCase)
    rng(1, 'twister');
    [call, ~, ~, paths] = mc_euro_price(100, 102, 0.05, 0.2, 1, 12, 50000, 'call');
    rng(1, 'twister');
    put = mc_euro_price(100, 102, 0.05, 0.2, 1, 12, 50000, 'put');
    discountedTerminal = exp(-0.05) * paths(end, :);
    sampleParity = mean(discountedTerminal) - 102 * exp(-0.05);
    testCase.verifyEqual(call - put, sampleParity, 'AbsTol', 1e-10);
    analyticalParity = 100 - 102 * exp(-0.05);
    tolerance = 5 * std(discountedTerminal) / sqrt(50000) + 1e-12;
    testCase.verifyLessThanOrEqual(abs(call - put - analyticalParity), tolerance);
end
