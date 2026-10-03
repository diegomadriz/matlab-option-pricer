function configuration = restore_archive(outputDir)
    % Edited for publication (Oct 2026): publication verification or packaging utility.
    % RESTORE_ARCHIVE Reproduce retained figures and configuration without simulation.
    %   restore_archive writes archival outputs to artifacts, or the supplied directory.
    root = fileparts(mfilename('fullpath'));
    addpath(fullfile(root, 'pricing'));
    if nargin == 0
        outputDir = fullfile(root, 'artifacts');
    end
    if ~isfolder(outputDir)
        mkdir(outputDir);
    end
    evidence = jsondecode(fileread(fullfile(root, 'evidence', 'results.json')));
    defaults = evidence.app_defaults;
    names = fieldnames(defaults);
    values = cellfun(@(name) defaults.(name), names);
    configuration = table(names, values, 'VariableNames', {'Parameter', 'Value'});
    writetable(configuration, fullfile(outputDir, 'app-defaults.csv'));
    copyfile(fullfile(root, 'evidence', 'RESULTS.md'), fullfile(outputDir, 'RESULTS.md'));
    for k = 1:numel(evidence.report_figures)
        source = fullfile(root, 'evidence', evidence.report_figures(k).file);
        [~, name, extension] = fileparts(source);
        copyfile(source, fullfile(outputDir, [name extension]));
    end
    fprintf('Retained report figures and app configuration written to %s\n', outputDir);
    fprintf('December pricing values, raw samples and figure seed were not recorded.\n');
end
