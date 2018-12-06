function result = ternaryop(c,a,b)
%TERNARYFUN Ternary operator (equivalent to c ? a : b; in C)
%
% RESULT = TERNARYFUN(C,A,B) results the A if C is true, otherwise it
% returns B. This is equivalent to the ternary operator (?:) in C, but be
% warned that both A and B will be evaluated before the function is called.

    if c
        result = a;
    else
        result = b;
    end
end