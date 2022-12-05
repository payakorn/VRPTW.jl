function my_func(x, y)
    return x + 2y
end

struct VR
    a
    b
    function VR(a, b)
        new(a+1, b+1)
    end
end
