using Gurobi

function opt_balancing(ins_name::String, num_vehicle::Integer)

    # data = load(joinpath(@__DIR__, "..", "data", "solomon_jld2", "c101-25.jld2"))
    data = load(dir("data", "solomon_jld2", "$(lowercase(ins_name)).jld2"))
    # data = load(joinpath(@__DIR__, "..", "data", "solomon_jld2", "$ins_name.jld2"))
    d = data["upper"]
    low_d = data["lower"]
    demand = data["demand"]
    solomon_demand = data["capacity"]
    distance_matrix = data["distance_matrix"]
    service = data["service"]

    # number of node
    n = length(d) - 1

    m = Model(Gurobi.Optimizer)
    # set_optimizer_attribute(m, "logLevel", 1)

    # num_vehicle = 3
    K = 1:num_vehicle
    M = n*1000


    # test round distance (some papers truncate digits)
    distance_matrix = floor.(distance_matrix, digits=1)

    # add variables
    @variable(m, x[i=0:n, j=0:n, k=K; i!=j], Bin)
    @variable(m, low_d[i+1] <= t[i=0:n] <= d[i+1])

    # new variables: CMAX_i = max completion time of vehicle i
    #               CM_ij = |CMAX_i - CMAX_j|
    @variable(m, 0 <= CMAX[i=K])
    @variable(m, 0 <= CM[i=K,j=K; i<j])


    # add waiting time 
    @variable(m, w[i=0:n], Bin)


    for k in K
        @constraint(m, sum(x[0, j, k] for j in 1:n) == 1)
        @constraint(m, sum(x[i, 0, k] for i in 1:n) == 1)

    end


    # # add new 
    # for j in 1:n
    #     @constraint(m, sum(x[i, j, k] for i in 1:n for k in K if i != j) == 1)
    # end


    # one vehicle in and out each node
    for i = 1:n
        @constraint(m, sum(x[j, i, k] for j in 0:n for k in K if i != j) == 1)
        @constraint(m, sum(x[i, j, k] for j in 0:n for k in K if i != j) == 1)
    end

    # continuity
    for j in 1:n
        for k in K
            @constraint(m, sum(x[i, j, k] for i in 0:n if i != j) - sum(x[j, l, k] for l in 0:n if j != l) == 0)
        end
    end

    # time windows
    for k in K
        # fix(t[0,k], 0, force=true)
        for j in 1:n
            @constraint(m, distance_matrix[1, j+1] <= t[j]+ M*(1-x[0, j, k]) + M*w[j])
            @constraint(m, distance_matrix[1, j+1] >= t[j]- M*(1-x[0, j, k]) - M*w[j])
        end
    end

    for i in 1:n
        for j in 0:n
            if i != j
                for k in K

                    @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] - M*(1-x[i, j, k]) <= t[j] )

                    # 
                    @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] - M*(1-x[i, j, k]) - M*w[j] <= t[j] )
                    @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] + M*(1-x[i, j, k]) + M*w[j] >= t[j] )
                end
            end
        end
    end

    # waiting time constraints
    for i in 1:n
        @constraint(m, t[i] - M*(1-w[i]) <= low_d[i+1])
        @constraint(m, low_d[i+1] <= t[i] + M*(1-w[i]))
    end


    # subtour elimination constraints
    @variable(m, demand[i+1] <= u[i=1:n] <= solomon_demand)
    for i in 1:n
        for j in 1:n
            for k in K
                if i!=j
                    @constraint(m, u[i] - u[j] + demand[j+1] <= solomon_demand*(1 - x[i, j, k]))
                end
            end
        end
    end
    
    # C max constraints: the max completion time is equal to the completion time of the last visit
    for i in 1:n
        for k in K
            @constraint(m, t[i] + service[i+1] + M*(1-x[i, 0, k]) >= CMAX[k])
            @constraint(m, t[i] + service[i+1] - M*(1-x[i, 0, k]) <= CMAX[k])
        end
    end

    # the different between two max completion time of two vehicles
    for i in K
        for j in K
            if i < j
                @constraint(m, CMAX[i] - CMAX[j] <= CM[i, j])
                @constraint(m, CMAX[j] - CMAX[i] <= CM[i, j])
            end
        end
    end

    # objective to minimize the total different of max completion time of all vehicles
    @objective(m, Min, sum(CM[i, j] for i in K for j in K if i < j))

    optimize!(m)
    return m, x, t, CM, CMAX, w
end


function find_opt()
    NameNumVehicle = CSV.File(dir("data", "solomon_opt_from_web", "Solomon_Name_NumCus_NumVehicle.csv"))
    Ins_name = [String("$(NameNumVehicle[i][1])-$(NameNumVehicle[i][2])") for i in 1:(length(NameNumVehicle))]
    Num_vehicle = [NameNumVehicle[i][3] for i in 1:(length(NameNumVehicle))]

    for (ins_name, num_vehicle) in zip(Ins_name, Num_vehicle)
        if !isfile(dir("data", "opt_solomon", "balancing_completion_time", "$ins_name.json"))
            println("Optimizing $(ins_name)!!!")
            m, x, t, CM, CMAX = opt_balancing(ins_name, num_vehicle)
            tex, route = show_opt_solution(x, length(t), num_vehicle)
            write_solution(route, ins_name, tex, m, t, CMAX, obj_function="balancing_completion_time")
        end
    end
end
