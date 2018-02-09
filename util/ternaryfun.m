function result = ternaryfun(c,a,b)
    if c
        result = a();
    else
        result = b();
    end
end