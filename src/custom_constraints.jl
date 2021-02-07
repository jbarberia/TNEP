function constraint_thermal_limit_soft_from(pm::PM.AbstractDCPModel, i::Int, nw::Int=pm.cnw)
    branch = PM.ref(pm, nw, :branch, i)
    f_bus = branch["f_bus"]
    t_bus = branch["t_bus"]
    f_idx = (i, f_bus, t_bus)

    if haskey(branch, "rate_a")
        constraint_thermal_limit_soft_from(pm, nw, f_idx, branch["rate_a"])
    end
end
    

function constraint_thermal_limit_soft_to(pm::PM.AbstractDCPModel, i::Int, nw::Int=pm.cnw)
    branch = PM.ref(pm, nw, :branch, i)
    f_bus = branch["f_bus"]
    t_bus = branch["t_bus"]
    t_idx = (i, t_bus, f_bus)

    if haskey(branch, "rate_a")
        constraint_thermal_limit_soft_to(pm, nw, t_idx, branch["rate_a"])
    end
end


function constraint_thermal_limit_soft_from(pm::PM.AbstractDCPModel, n::Int, f_idx, rate_a)
    p_fr = PM.var(pm, n, :p, f_idx)
    p_fr_soft = PM.var(pm, n, :p_soft, f_idx)

    JuMP.@constraint(pm.model, p_fr <=  rate_a + p_fr_soft)
    JuMP.@constraint(pm.model, p_fr >=  -rate_a - p_fr_soft)
end


function constraint_thermal_limit_soft_to(pm::PM.AbstractDCPModel, n::Int, t_idx, rate_a)
    p_to = PM.var(pm, n, :p, t_idx)
    p_to_soft = PM.var(pm, n, :p_soft, t_idx)

    JuMP.@constraint(pm.model, p_to <=  rate_a + p_to_soft)
    JuMP.@constraint(pm.model, p_to >=  -rate_a - p_to_soft)
end
