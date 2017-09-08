function [Xnew, Ynew] = transformPosition(X, Y, theta, xOffset, yOffset)
% TRANSFORMPOSITION Transform a pair of coordinates
%
%   [XNEW,YNEW] = TRANSFORMPOSITION(X,Y,THETA,XOFFSET,YOFFSET) offsets the 
%   co-ordinate pair (X,Y) by (XOFFSET,YOFFSET) and rotates through THETA
%   degrees, returning the result as (XNEW,YNEW)

% Created by John Barrett 2017-08-18 16:52 CDT
% Last modified by John Barrett 2017-09-08 14:59 CDT
% Based on code written by Gorden Shepherd May 2006

    somaXoffset = X - xOffset;
    somaYoffset = Y - yOffset;
    rotationAngleRadians = (-1) * theta * (pi/180);
    [theta, rho] = cart2pol(somaXoffset, somaYoffset);
    [Xnew, Ynew] = pol2cart(theta + rotationAngleRadians, rho);
end