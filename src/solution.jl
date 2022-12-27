mutable struct Solution
    route::Array{Integer}
    problem::Problem
    distance::Float64
    Solution(route, problem, distance) = route[1] != 0 || route[end] != 0 ? error("This is not a route representation\nmust start with 0 and end with 0\n i.e. [0, 1, 2, 3, 0, 4, 5, 6, 0, 7, 8, 0]") : new(route, problem, distance)
    function Solution(route, problem)
        new(route, problem, length(route))
    end
end


function swap!(solution::Solution, pos1::Integer, pos2::Integer)
    solution.route[pos1], solution.route[pos2] = solution.route[pos2], solution.route[pos1]
    return Solution(solution.route, solution.problem)
end


function add!(solution::Solution, pos::Integer, cus::Integer)
    route = solution.route
    splice!(route, pos, cus)
    return Solution(route, solution.problem)
end
