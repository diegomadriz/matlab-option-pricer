function check_matlab
    % Edited for publication (Oct 2026): publication verification or packaging utility.
    % CHECK_MATLAB Require MATLAB Code Analyzer to report no issues in text code.
    root = fileparts(fileparts(mfilename('fullpath')));
    files = [dir(fullfile(root, 'pricing', '*.m')); ...
             dir(fullfile(root, 'demo', '*.m')); ...
             dir(fullfile(root, 'tests', '*.m')); ...
             dir(fullfile(root, 'tools', '*.m')); ...
             dir(fullfile(root, '*.m'))];
    for k = 1:numel(files)
        filename = fullfile(files(k).folder, files(k).name);
        messages = checkcode(filename, '-id');
        assert(isempty(messages), 'CodeAnalyzer:Issues', 'Code Analyzer found issues in %s.', filename);
    end
end
