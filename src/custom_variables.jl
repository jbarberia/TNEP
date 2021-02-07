
function variable_branch_power_soft(pm::PM.AbstractPowerModel; nw::Int=pm.cnw, bounded::Bool=true, report::Bool=true)
    p_soft = PM.var(pm, nw)[:p_soft] = JuMP.@variable(pm.model,
        [(l,i,j) in PM.ref(pm, nw, :arcs)], base_name="$(nw)_p_soft",
        start = 0.0,
        lower_bound = 0.0,
    )
end

