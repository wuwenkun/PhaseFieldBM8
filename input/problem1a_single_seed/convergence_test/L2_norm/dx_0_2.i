# Phase Field Benchmark 8
# Nucleation Benchmark Problem I.1 
# Homogeneous Nucleation, Single Seed
# r_0 = 1.01r_c 
# Convergence Test dx=0.2 for L2 Norm Calculation (Compared to dx=0.1)
# Run this file after running dx_0_1_ref.i

[Mesh]
  type = GeneratedMesh
  dim = 2
  elem_type = QUAD4
  nx = 500
  ny = 500
  nz = 0
  xmin = -50
  xmax = 50
  ymin = -50
  ymax = 50
  zmin = 0
  zmax = 0
[]


[Variables]
  [./eta]   # phase-field variable
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Functions]
  [./ic_func_eta]
    type = ParsedFunction
    value = '0.5*(1.0-tanh((sqrt(x*x + y*y)-5.05)/sqrt(2)))' # r0 = 5.05
  [../]
[]

[ICs]
  [./eta]
    type = FunctionIC
    variable = eta
    function = ic_func_eta
  [../]
[]

[AuxVariables]
  [./Bulk_energy]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./Grad_energy]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./Total_energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  
  [./L2_eta_50]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./L2_eta_100]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./L2_eta_150]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./L2_eta_200]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[BCs]
[]

[Kernels]
  [./detadt]
    variable = eta
    type = TimeDerivative
  [../]
  [./ACInterface]
    type = ACInterface
    variable = eta
    mob_name = L
    kappa_name = eps_sq
  [../]

  [./ACBulk]
    variable = eta
    type = AllenCahn
    f_name = f_nucl
  [../]
[]

[AuxKernels]
  [./aux_Bulk_energy]
    variable = Bulk_energy
    type = BulkFreeEnergy
    f_name = f_nucl
  [../]

  [./aux_Grad_energy]
    variable = Grad_energy
    type = GradFreeEnergy
    order_parameter = eta
    kappa_name = eps_sq
  [../]

  [./aux_Total_energy]
    variable = Total_energy
    type = TotalFreeEnergyBM
    bulk_energy = Bulk_energy
    grad_energy = Grad_energy
  [../]
  
  [./local_L2_eta_50]
    type = ElementL2ErrorFunctionAux
    variable = L2_eta_50
    function = function_eta_50
    coupled_variable = eta
  [../]
    
  [./local_L2_eta_100]
    type = ElementL2ErrorFunctionAux
    variable = L2_eta_100
    function = function_eta_100
    coupled_variable = eta
  [../]
    
  [./local_L2_eta_200]
    type = ElementL2ErrorFunctionAux
    variable = L2_eta_200
    function = function_eta_200
    coupled_variable = eta
  [../]
[]

[Materials]
  [./f_eta]
    type = NucleationBMMaterial
    order_parameter = eta
    function_name = f_nucl
    w = 1.0
    deltafT = 0.04714045208 # 1/(15*sqrt(2))
  [../]
  [./constants]
    type = GenericConstantMaterial
    prop_names = 'L  eps_sq'
    prop_values = '1.0  1.0'
  [../]
[]

[Preconditioning]
  # Preconditioning is required for Newton's method. See wiki page "Solving
  # Phase Field Models" for more information.
  # http://mooseframework.org/wiki/PhysicsModules/PhaseField/SolvingModels/
  [./coupled]
    type = SMP
    full = true
  [../]
[]


[Postprocessors]
  [./BulkFreeEnergy]
    type = ElementIntegralVariablePostprocessor
    variable = Bulk_energy
  [../]
  [./GradFreeEnergy]
    type = ElementIntegralVariablePostprocessor
    variable = Grad_energy
  [../]
  [./TotalFreeEnergy]
    type = ElementIntegralVariablePostprocessor
    variable = Total_energy
  [../]
  [./Change_totE_over_time]
    type = ChangeOverTimePostprocessor
    postprocessor = TotalFreeEnergy
    change_with_respect_to_initial = false
    take_absolute_value = true
  [../]
  [./Volume]
    type = VolumePostprocessor
    execute_on = initial
  [../]
  [./Volume_Fraction]
    type = FeatureVolumeFraction
    mesh_volume = Volume
    feature_volumes = feature_volumes
    execute_on = 'initial timestep_end'
  [../]
  [./feature_counter]
    type = FeatureFloodCount
    variable = eta
    compute_var_to_feature_map = true
    execute_on = 'initial timestep_end'
  [../]
  [./eta_50_error]
    type = ElementL2Error
    variable = eta
    function = function_eta_50
  [../]  
  [./eta_100_error]
    type = ElementL2Error
    variable = eta
    function = function_eta_100
  [../]
  [./eta_150_error]
    type = ElementL2Error
    variable = eta
    function = function_eta_150
  [../]  
  [./eta_200_error]
    type = ElementL2Error
    variable = eta
    function = function_eta_200
  [../] 
[]

[VectorPostprocessors]
  [./feature_volumes]
    type = FeatureVolumeVectorPostprocessor
    flood_counter = feature_counter
    execute_on = 'initial timestep_end'
    outputs = none
  [../]
[]

[Executioner]
  type = Transient
  scheme = 'BDF2'
  solve_type = NEWTON
  
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-2
    cutback_factor = 0.75
    growth_factor = 1.05
    optimal_iterations = 6
    iteration_window = 1
    linear_iteration_ratio = 100
  [../]

  end_time = 200
  dtmin = 1e-2
  dtmax = 1e2

  petsc_options_iname = '-pc_type  -sub_pc_type'
  petsc_options_value = 'asm ilu'

  l_tol = 1e-4
  l_max_its = 50
  nl_max_its = 10

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-9
[]

[UserObjects]
  [./eta_50]
    type = SolutionUserObject
    system_variables = eta
    mesh = single_seed_ref_dx_0_1_0002_mesh.xda
    es = single_seed_ref_dx_0_1_0002.xda
  [../]
  [./eta_100]
    type = SolutionUserObject
    system_variables = eta
    mesh = single_seed_ref_dx_0_1_0003_mesh.xda
    es = single_seed_ref_dx_0_1_0003.xda
  [../]
  [./eta_150]
    type = SolutionUserObject
    system_variables = eta
    mesh = single_seed_ref_dx_0_1_0004_mesh.xda
    es = single_seed_ref_dx_0_1_0004.xda
  [../]
  [./eta_200]
    type = SolutionUserObject
    system_variables = eta
    mesh = single_seed_ref_dx_0_1_0005_mesh.xda
    es = single_seed_ref_dx_0_1_0005.xda
  [../]
[]

[Functions]
  [./function_eta_50]
    type = SolutionFunction
    solution = eta_50
  [../]
  [./function_eta_100]
    type = SolutionFunction
    solution = eta_100
  [../]
  [./function_eta_150]
    type = SolutionFunction
    solution = eta_150
  [../]
  [./function_eta_200]
    type = SolutionFunction
    solution = eta_200
  [../]
[]

[Outputs]
  console = true
  csv = true
  file_base = single_seed_dx_0_2
  checkpoint = true
  sync_times = '50 100 150 200'
[]
