function tests = test_evidence
    % Edited for publication (Oct 2026): publication verification or packaging utility.
    % TEST_EVIDENCE Retained outputs, recorded defaults and archival entry point.
    tests = functiontests(localfunctions);
end

function setupOnce(testCase)
    testCase.TestData.root = fileparts(fileparts(mfilename('fullpath')));
    testCase.TestData.oldPath = path;
    addpath(testCase.TestData.root);
end

function teardownOnce(testCase)
    path(testCase.TestData.oldPath);
end

function testRecordedDefaultsMatchApp(testCase)
    root = testCase.TestData.root;
    evidence = jsondecode(fileread(fullfile(root, 'evidence', 'results.json')));
    directory = tempname;
    mkdir(directory);
    cleanup = onCleanup(@() rmdir(directory, 's'));
    unzip(fullfile(root, 'app', 'Final_work.mlapp'), directory);
    document = fileread(fullfile(directory, 'matlab', 'document.xml'));
    fields = {'S0EditField', 'KEditField', 'rEditField', 'SigmaEditField', ...
              'TEditField', 'NstepsEditField', 'NpathsEditField'};
    names = {'S0', 'K', 'r', 'sigma', 'T', 'nSteps', 'nPaths'};
    for k = 1:numel(fields)
        pattern = ['app\.' fields{k} '\.Value\s*=\s*([0-9.]+)'];
        tokens = regexp(document, pattern, 'tokens');
        testCase.assertNotEmpty(tokens);
        for j = 1:numel(tokens)
            testCase.verifyEqual(str2double(tokens{j}{1}), evidence.app_defaults.(names{k}));
        end
    end
    testCase.verifyNotEmpty(regexp(document, 'nShow\s*=\s*min\(30,', 'once'));
    testCase.verifyEqual(evidence.app_defaults.display_cap, 30);
end

function testDemoParametersMatchRecordedEvidence(testCase)
    root = testCase.TestData.root;
    evidence = jsondecode(fileread(fullfile(root, 'evidence', 'results.json')));
    script = fileread(fullfile(root, 'demo', 'demo_option_pricing.m'));
    names = {'S0', 'K', 'r', 'sigma', 'T', 'nSteps', 'nPaths'};
    for k = 1:numel(names)
        tokens = regexp(script, [names{k} '\s*=\s*([0-9.]+);'], 'tokens', 'once');
        testCase.assertNotEmpty(tokens);
        testCase.verifyEqual(str2double(tokens{1}), evidence.demo_parameters.(names{k}));
    end
end

function testArchivalEntryPoint(testCase)
    % No model or licensed toolbox is needed for this end-to-end command.
    root = testCase.TestData.root;
    directory = tempname;
    mkdir(directory);
    cleanup = onCleanup(@() rmdir(directory, 's'));
    configuration = restore_archive(directory);
    saved = readtable(fullfile(directory, 'app-defaults.csv'));
    testCase.verifyEqual(saved, configuration);
    evidence = jsondecode(fileread(fullfile(root, 'evidence', 'results.json')));
    testCase.verifyEqual(configuration.Value(strcmp(configuration.Parameter, 'nPaths')), ...
                         evidence.app_defaults.nPaths);
    files = {'gbm-paths.png', 'terminal-prices.png'};
    for k = 1:numel(files)
        testCase.verifyEqual(readBytes(fullfile(directory, files{k})), ...
                             readBytes(fullfile(root, 'evidence', 'figures', files{k})));
    end
    testCase.verifyEqual(fileread(fullfile(directory, 'RESULTS.md')), ...
                         fileread(fullfile(root, 'evidence', 'RESULTS.md')));
end

function testResultsConfigurationTable(testCase)
    root = testCase.TestData.root;
    evidence = jsondecode(fileread(fullfile(root, 'evidence', 'results.json')));
    readme = fileread(fullfile(root, 'evidence', 'RESULTS.md'));
    labels = {'Spot', 'Strike', 'Annual risk-free rate', 'Annual volatility', ...
              'Maturity in years', 'Time steps', 'Pricing paths'};
    names = {'S0', 'K', 'r', 'sigma', 'T', 'nSteps', 'nPaths'};
    for k = 1:numel(labels)
        pattern = ['\| ' labels{k} ' \| ([0-9.,]+) \| ([0-9.,]+) \|'];
        tokens = regexp(readme, pattern, 'tokens', 'once');
        testCase.assertNotEmpty(tokens);
        actual = cellfun(@(value) str2double(strrep(value, ',', '')), tokens);
        testCase.verifyEqual(actual, [evidence.app_defaults.(names{k}), evidence.demo_parameters.(names{k})]);
    end
    testCase.verifySubstring(readme, '| Paths displayed | At most 30 | 20 |');
    testCase.verifySubstring(readme, evidence.period);
end

function testPreservedFileHashes(testCase)
    root = testCase.TestData.root;
    manifest = jsondecode(fileread(fullfile(root, 'evidence', 'source-sha256.json')));
    for k = 1:numel(manifest)
        testCase.verifyEqual(sha256(fullfile(root, manifest(k).file)), manifest(k).sha256);
    end
end

function hash = sha256(filename)
    digest = java.security.MessageDigest.getInstance('SHA-256');
    digest.update(typecast(readBytes(filename), 'int8'));
    bytes = typecast(digest.digest(), 'uint8');
    hash = lower(reshape(dec2hex(bytes, 2)', 1, []));
end

function bytes = readBytes(filename)
    file = fopen(filename, 'rb');
    assert(file >= 0, 'Could not read evidence.');
    cleanup = onCleanup(@() fclose(file));
    bytes = fread(file, Inf, '*uint8');
end
