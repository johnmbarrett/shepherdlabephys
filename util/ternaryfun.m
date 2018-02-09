function result = ternaryfun(c,a,b)
%TERNARYFUN Ternary operator with lazy evaluation
%
% RESULT = TERNARYFUN(C,A,B) results the RESULT of the nullary function A
% if C is true, otherwise it returns the RESULT of the nullary function B.
% This is roughly equivalent to the ternary operator (?:) in C.

    if c
        result = a();
    else
        result = b();
    end
end