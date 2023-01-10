struct Problem
    name::String
    num_node::Integer
    distance::Matrix
    demand::Vector
    lower_time_window::Vector
    upper_time_window::Vector
    depot_time_window::Integer
    service_time::Vector
    vehicle_capacity::Integer
end


"""dir()

### Returns:

    the directory of package VRPTW

"""
function dir()
    splitdir(splitdir(Base.find_package("VRPTW"))[1])[1]
end


"""
    dir(d...); 
    
### input
- `d...` -- directory seperated by commas (,) e.g. dir("src", "data")

### Returns:
    dir string: the directory of package VRPTW

### Example:
    ```julia-repl
    dir("src", "data") 
    return: ".../VRPTW/src/data"
    ```
"""
function dir(d...)
    d = string.(d)
    joinpath(dir(), d...)
end


function dir_data(class_ins::String, num_node::Integer)
    dir("data", "solomon_jld2", "$(lowercase(class_ins))-$num_node.jld2")
end


"""load solomon instance into a struct of Problem

Returns:
    struct: Problem(...)
"""
function load_solomon_data(class_ins::String; num_node=100)
    @info "loading Solomon $(uppercase(class_ins)) => with number of nodes = $num_node"
    data = load(dir_data(class_ins, num_node))


    # set the service time of node 1 (depot node) to zero
    service_time = data["service"]
    service_time[1] = 0.0

    return Problem(
        uppercase(class_ins),
        num_node,
        data["distance_matrix"],
        data["demand"],
        data["lower"],
        data["upper"],
        data["last_time_window"],
        data["service"],
        data["capacity"]
    )
end
