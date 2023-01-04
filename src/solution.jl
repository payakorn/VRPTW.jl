mutable struct Solution
    route::Array{Integer}
    problem::Problem
    distance::Float64
    # check
    Solution(route, problem, distance) = route[1] != 0 || route[end] != 0 ? error("This is not a route representation\nmust start with 0 and end with 0\n i.e. [0, 1, 2, 3, 0, 4, 5, 6, 0, 7, 8, 0]") : new(route, problem, distance)
    function Solution(route, problem)
        new(route, problem, length(route))
    end
end


struct Point
    x::Float64
    y::Float64
end


function fix_route_zero(route::Array)
    delete_position = Integer[]
    if route[1] != 0 || route[end] != 0
        return false
    elseif length(route) > 2
        zero_position = findall(x -> x == 0, route)
        for i in (length(zero_position) - 1):-1:1
            if zero_position[i+1] - zero_position[i] == 1
                push!(delete_position, zero_position[i])
            end
        end
    end
    for i in delete_position
        route = deleteat!(route, i)
    end
    return route
end


function route_length(route::Array)
    fix_route_zero(route)
    return length(findall(x -> x == 0, route)) - 1
end


function route_length(solution::Solution)
    route_length(solution.route)
end


function distance(point1::Point, point2::Point)
    sqrt((point1.x^2-point1.x)^2 + (point2.x^2-point2.x)^2)
end


function distance(route::Array, distance_matrix::Matrix)
    route = fix_route_zero(route)
    dis = 0.0
    for i in 1:length(route)-1
        dis += distance_matrix[route[i], route[i+1]]
    end
end


function distance(route::Array, distance_matrix::Matrix)
    nothing
end


function empty_solution(problem::Problem)
    route = [0, 0]
    return Solution(route, problem, zero(1))
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


function splice!(solution::Solution, pos::Integer, cus::Integer)
    route = solution.route
    splice!(route, pos, cus)
    return Solution(route, solution.problem)
end