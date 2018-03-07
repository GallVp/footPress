function [ assignedOptions ] = assignOptions( inputOptions, defaultOptions )
%ASSIGNOPTIONS Takes input options and assigns any missing options from
%   default options.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%
%   This program is free software; you  can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation; either version 3 of
%   the License, or ( at your option ) any later version.  See the
%   LICENSE included with this distribution for more information.

assignedOptions = inputOptions;
mustHaveFields = fieldnames(defaultOptions);
for i = 1:length(mustHaveFields)
    if(~isfield(inputOptions, mustHaveFields{i}))
        assignedOptions.(mustHaveFields{i}) = defaultOptions.(mustHaveFields{i});
    end
end
end