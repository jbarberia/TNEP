# TNEP

This module is an example of how to use a custom formulation with the [PowerModels](https://github.com/lanl-ansi/PowerModels.jl) Package.

In this example the only changes were apply a soft constraint for the thermal constraint in existing branches:

- Objective Function:
```math
\min{\sum{Build_{cost}X}+M\sum{\bar{p_f}+\bar{p_t}}}
```
- Soft Thermal Constraint:
```math
|p_f|\le{rate + \bar{p_f}}
```

```math
|p_t|\le{rate + \bar{p_t}}
```

This examples only works with the `DCPPowerModel` formulation. However it can be easily extended.