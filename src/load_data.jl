struct Solomon
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


function load_data(class_ins::String; num_node = 100)
    @info "loading Solomon $(uppercase(class_ins)) => with number of nodes = $num_node"
    data = load("./data/solomon_jld2/$(uppercase(class_ins))-$num_node.jld2")
    return Solomon(
        uppercase(class_ins),
        num_node,
        data["distance_matrix"],
        data["demand"],
        data["lower"],
        data["upper"],
        data["last_time_window"],
        data["service"],
        data["capacity"]
    );
end
