using tnep
using GLPK
using Test
using PowerModels

const PM = PowerModels
solver = GLPK.Optimizer

function check_tnep_status(sol)
    for (idx,val) in sol["ne_branch"]
        @test isapprox(val["built"], 0.0, atol=1e-6, rtol=1e-6) || isapprox(val["built"], 1.0, atol=1e-6, rtol=1e-6)
    end
end

@testset "test dc tnep" begin
    @testset "3-bus case" begin
        data = PM.parse_file("../test/case3_tnep.m")
        PM.calc_thermal_limits!(data)
        result = tnep.run_custom_tnep(data, PM.DCPPowerModel, solver)
        
        check_tnep_status(result["solution"])
        
        @test isapprox(result["objective"], 2; atol = 1e-2)
    end
    
    @testset "3-bus case overload" begin
        data = PM.parse_file("../test/case3_tnep.m")
        PM.calc_thermal_limits!(data)
        data["branch"]["1"]["rate_a"] = 0.00
        result = tnep.run_custom_tnep(data, PM.DCPPowerModel, solver)
        
        check_tnep_status(result["solution"])

        #= El costo de las lineas es de 1.0, si hay sobrecargas en la unica linea original
        se veria reflejado en que el resultado sea mayor por una o dos unidades respecto a 
        la penalidad por la sobrecarga en cada extremo de la linea
        =#
        @test result["objective"] > abs(result["solution"]["branch"]["1"]["pf"])*2*tnep.M
    end
end
