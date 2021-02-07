function custom_objective_tnep_cost(pm::PM.AbstractPowerModel, M=1e6)
    return JuMP.@objective(pm.model, Min,
        sum(
            sum(branch["construction_cost"]*PM.var(pm,n,:branch_ne,i) for (i,branch) in nw_ref[:ne_branch])+
			sum(M*PM.var(pm,n,:p_soft,i) for (i) in nw_ref[:arcs])
		for (n, nw_ref) in PM.nws(pm))
    )
end

