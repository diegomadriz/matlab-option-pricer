function check_matlab
    % Edited for publication (Oct 2026): publication verification or packaging utility.
    % CHECK_MATLAB Require MATLAB Code Analyzer to report no issues in text code.
    root = fileparts(fileparts(mfilename('fullpath')));
    files = [dir(fullfile(root, 'pricing', '*.m')); ...
             dir(fullfile(root, 'demo', '*.m')); ...
             dir(fullfile(root, 'tests', '*.m')); ...
             dir(fullfile(root, 'tools', '*.m')); ...
             dir(fullfile(root, '*.m'))];
    total = 0;
    for k = 1:numel(files)
        filename = fullfile(files(k).folder, files(k).name);
        messages = checkcode(filename, '-id');
        relative = erase(filename, [root filesep]);
        for m = 1:numel(messages)
            % Emit a GitHub Actions annotation so findings are visible without the raw log.
            fprintf('::error file=%s,line=%d::%s %s\n', relative, messages(m).line, ...
                    messages(m).id, messages(m).message);
        end
        total = total + numel(messages);
    end
    assert(total == 0, 'CodeAnalyzer:Issues', 'Code Analyzer found %d issue(s).', total);
end
