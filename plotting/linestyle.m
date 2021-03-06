function s = linestyle(linestyle_index, allstyles)
    if nargin < 2
        allstyles = {'-', ':', '--', '-.'};
    end
    linestyle_index = mod(linestyle_index - 1, length(allstyles)) + 1;
    if length(linestyle_index) == 1
        s = allstyles{linestyle_index};
    else
        s = allstyles(linestyle_index);
    end
end
