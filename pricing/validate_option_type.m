function validate_option_type(optionType)
    % Edited for publication (Oct 2026): new call/put input validation.
    % VALIDATE_OPTION_TYPE Accept call or put, ignoring case.
    if ~((ischar(optionType) && isrow(optionType)) || ...
         (isstring(optionType) && isscalar(optionType)))
        error('OptionPricer:InvalidInput', 'Option type must be call or put.');
    end
    if ~any(strcmpi(optionType, {'call', 'put'}))
        error('OptionPricer:InvalidInput', 'Option type must be call or put.');
    end
end
