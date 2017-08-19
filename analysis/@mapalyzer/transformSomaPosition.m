function [somaXnew, somaYnew] = transformSomaPosition(~, somaX, somaY, spatialRotation, xPatternOffset, yPatternOffset)
% TRANSFORMSOMAPOSITION   Transform soma position
%
%   [SOMAXNEW,SOMAYNEW] = TRANSFORMSOMAPOSITION(SOMAX,SOMAY,...
%   SPATIALROTATION,XPATTERNOFFSET,YPATTERNOFFSET) offsets the soma
%   position (SOMAX,SOMAY) by (XPATTERNOFFSET,YPATTERNOFFSET) and rotates
%   through SPATIALROTATION degrees, returning the result as
%   (SOMAXNEW,SOMAYNEW)

% Created by John Barrett 2017-08-18 16:52 CDT
% Last modified by John Barrett 2017-08-18 16:52 CDT
% Based on code written by Gorden Shepherd May 2006

    somaXoffset = somaX - xPatternOffset;
    somaYoffset = somaY - yPatternOffset;
    rotationAngleRadians = (-1) * spatialRotation * (pi/180);
    [theta, rho] = cart2pol(somaXoffset, somaYoffset);
    [somaXnew, somaYnew] = pol2cart(theta + rotationAngleRadians, rho);
end