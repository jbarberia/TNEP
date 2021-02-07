module tnep

import JuMP
import PowerModels

const PM = PowerModels
const M = 1e6

include("custom_variables.jl")
include("custom_constraints.jl")
include("custom_objectives.jl")

function run_custom_tnep(file, model_type::Type, optimizer; kwargs...)
    return PM.run_model(file, model_type, optimizer, custom_build_tnep; ref_extensions=[PM.ref_add_on_off_va_bounds!,PM.ref_add_ne_branch!], kwargs...)
end

function custom_build_tnep(pm::PM.AbstractPowerModel; kwargs...)
    PM.variable_bus_voltage(pm)
    PM.variable_gen_power(pm)
    PM.variable_branch_power(pm, bounded=false)
    tnep.variable_branch_power_soft(pm)
    PM.variable_dcline_power(pm)

    PM.variable_ne_branch_indicator(pm)
    PM.variable_ne_branch_power(pm)
    PM.variable_ne_branch_voltage(pm)

    tnep.custom_objective_tnep_cost(pm, M)

    PM.constraint_model_voltage(pm)
    PM.constraint_ne_model_voltage(pm)

    for i in PM.ids(pm, :ref_buses)
        PM.constraint_theta_ref(pm, i)
    end

    for (i, bus) in PM.ref(pm, :bus)
        PM.constraint_ne_power_balance(pm, i)

        if length(PM.ref(pm, :bus_gens, i)) > 0 && !(i in PM.ids(pm,:ref_buses))
            # this assumes inactive generators are filtered out of bus_gens
            @assert bus["bus_type"] == 2
            for j in PM.ref(pm, :bus_gens, i)
                PM.constraint_gen_setpoint_active(pm, j)
            end
        end
    end

    for i in PM.ids(pm, :branch)
        PM.constraint_ohms_yt_from(pm, i)
        PM.constraint_ohms_yt_to(pm, i)
        PM.constraint_voltage_angle_difference(pm, i)

        tnep.constraint_thermal_limit_soft_from(pm, i)
        tnep.constraint_thermal_limit_soft_to(pm, i)
    end

    for i in PM.ids(pm, :ne_branch)
        PM.constraint_ne_ohms_yt_from(pm, i)
        PM.constraint_ne_ohms_yt_to(pm, i)
        PM.constraint_ne_voltage_angle_difference(pm, i)

        PM.constraint_ne_thermal_limit_from(pm, i)
        PM.constraint_ne_thermal_limit_to(pm, i)
    end

    for i in PM.ids(pm, :dcline)
        PM.constraint_dcline_power_losses(pm, i)
    end
end
end # module
