using Random, JuMP, DelimitedFiles, Cbc, JLD2

data = load(joinpath(@__DIR__, "c101-25.jld2"))
d = data["upper"]
low_d = data["lower"]
demand = data["demand"]
solomon_demand = data["capacity"]
distance_matrix = data["distance_matrix"]
service = data["service"]

# number of node
n = length(d) - 1

m = Model(Cbc.Optimizer)
set_optimizer_attribute(m, "logLevel", 1)

num_vehicle = 3
K = 1:num_vehicle
M = n*1000


# test round distance (some papers truncate digits)
distance_matrix = floor.(distance_matrix, digits=1)

# add variables
@variable(m, x[i=0:n, j=0:n, k=K; i!=j], Bin)
@variable(m, low_d[i+1] <= t[i=0:n] <= d[i+1])


# conpatibility constraint
# for j in 1:n
#     for k in K
#         @constraint(m, sum(x[i, j, k] for i in 0:n if i!=j) <= Q[k, j])
#     end
# end


for k in K
    @constraint(m, sum(x[0, j, k] for j in 1:n) == 1)
    @constraint(m, sum(x[i, 0, k] for i in 1:n) == 1)
end

for i = 1:n
    @constraint(m, sum(x[j, i, k] for j in 0:n for k in K if i != j) == 1)
    @constraint(m, sum(x[i, j, k] for j in 0:n for k in K if i != j) == 1)
end

for j in 1:n
    for k in K
        @constraint(m, sum(x[i, j, k] for i in 0:n if i != j) - sum(x[j, l, k] for l in 0:n if j != l) == 0)
    end
end

# time windows
for k in K
    # fix(t[0,k], 0, force=true)
    for j in 1:n
        @constraint(m, distance_matrix[1, j+1] <= t[j]+ M*(1-x[0, j, k]))
    end
end

for i in 1:n
    for j in 0:n
        if i != j
            for k in K
                @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] - M*(1-x[i, j, k]) <= t[j] )
            end
        end
    end
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

@objective(m, Min, sum(distance_matrix[i+1, j+1]*x[i, j, k] for i in 0:n for j in 0:n for k in K if i != j))

optimize!(m)

