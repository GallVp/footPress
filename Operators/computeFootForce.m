function [ force, bwpForce ] = computeFootForce( footData )
%computeFootForce Computes per frame  force on  a foot in Newtons
%   and as  percentage of body  weight. bwpForce  stands for body
%   weight percentage force. The units of pressure are assumed to
%   be KPa and the units of row and column spacing are assumed to
%   be meters.
%
%   Inputs:
%   footData is a structure with following fields:
%       a. frames is a 3D  matrix with sensel  values across rows 
%       and columns, and frames across the third dimension.
%       b. rowSpacing,  colSpacing Row and  Column spacing of 
%       each sensel (Units assumed to be meters)
%       c. bodyMass The weight of the person in Kilograms (Kg). 
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project
%   root for license information.

KPA_TO_PA_FACTOR    = 1000;
GRAVITATIONAL_ACCEL = 9.8;% m/s
PERCENTAGE_FACTOR   = 100;

pressureSumKPa = nansum(nansum(footData.frames, 1), 2);

% Multiplied by 1000 as pressure is assumed to be in KPa
force = pressureSumKPa(:) .* KPA_TO_PA_FACTOR .* footData.rowSpacing .* footData.colSpacing;
% 9.8 m/s as gravitational acceleration and 100 for percentage
bwpForce = force ./ footData.bodyMass ./ GRAVITATIONAL_ACCEL .* PERCENTAGE_FACTOR;
end