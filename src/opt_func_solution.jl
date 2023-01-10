function show_opt_solution(x::Any, n::Integer, num_vehicle::Integer)
    tex = ""

    route = Dict()
    for k in 1:num_vehicle
        route[k] = [0]

        job = 0
        for j in 1:n
            if abs(value.(x[0, j, k]) - 1.0) <= 1e-4
                job = deepcopy(j)
                push!(route[k], job)
                break
            end
        end
        
        iter = 1
        while job != 0 && iter <= n+1
            iter += 1
            for j in setdiff(0:n, job)
                if abs(value.(x[job, j, k]) - 1.0) <= 1e-4
                    job = deepcopy(j)
                    push!(route[k], job)
                    break
                end
            end
        end
    end


    for k in 1:num_vehicle
        tex *= "vehicle $k: $(route[k])\n"
    end

    return tex, route
end

function print_solution()
    for k in K
        println("$k")
    end
end


function write_solution(route::Dict, ins_name::String, tex::String, m, t, CMAX; obj_function="balancing_completion_time"::String)
    # check location
    location = dir("data", "opt_solomon", "balancing_completion_time")
    # location = joinpath(@__DIR__, "..", "" "opt_solomon", "$name") 
    if isfile(location) == false
        mkpath(location)
    end

    # calculate max completion time
    max_com = Dict(i => value.(CMAX[k]) for k in 1:(length(route)))

    # total completion time
    total_com = sum([value.(t[i]) for i in 1:(length(t)-1)])

    d = Dict("name" => ins_name, "num_vehicle" => length(route), "route" => route, "tex" => tex, "max_completion_time" => max_com, "obj_function" => JuMP.objective_value(m), "solve_time" => solve_time(m), "relative_gap" => relative_gap(m), "solver_name" => solver_name(m), "total_com" => total_com)

    open(joinpath(location, "$ins_name.json"), "w") do io
        JSON3.pretty(io, d, JSON3.AlignmentContext(alignment=:Colon, indent=2))
    end
end