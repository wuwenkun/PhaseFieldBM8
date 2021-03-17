# Phase Field Benchmark 8
# Nucleation Benchmark Problem II 
# Athermal Heterogeneous Nucleation
# \Delta f = 1.11\Delta f_0 
# Convergence Test dx=0.025
# Run this file after running dx_0_0125_ref.i

[Mesh]
  # generate a 2D, 40nm x 20nm mesh
  type = GeneratedMesh
  dim = 2
  elem_type = QUAD4
  nx = 1600
  ny = 800
  nz = 0
  xmin = -20
  xmax = 20
  ymin = -10
  ymax = 10
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
  [./bc_bottom]
    type = ParsedFunction
    value = 'if(x>0,0.45*(1.0-tanh((x-10.0)/sqrt(2.0))),0.45*(1.0+tanh((x+10.0)/sqrt(2.0))))'
  [../]
[]

[ICs]
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
  
#  [./L2_eta_500]
#    order = CONSTANT
#    family = MONOMIAL
#  [../]
#  [./L2_eta_650]
#    order = CONSTANT
#    family = MONOMIAL
#  [../]
#  [./L2_eta_800]
#    order = CONSTANT
#    family = MONOMIAL
#  [../]
#  [./L2_eta_950]
#    order = CONSTANT
#    family = MONOMIAL
#  [../]
[]

[BCs]
  [./eta_bottom]
    type = FunctionDirichletBC
    function = bc_bottom
    variable = eta
    boundary = 'bottom'
  [../]
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
  
#  [./local_L2_eta_500]
#    type = ElementL2ErrorFunctionAux
#    variable = L2_eta_500
#    function = function_eta_500
#    coupled_variable = eta
#  [../]
    
#  [./local_L2_eta_650]
#    type = ElementL2ErrorFunctionAux
#    variable = L2_eta_650
#    function = function_eta_650
#    coupled_variable = eta
#  [../]
    
#  [./local_L2_eta_800]
#    type = ElementL2ErrorFunctionAux
#    variable = L2_eta_800
#    function = function_eta_800
#    coupled_variable = eta
#  [../]
  
#  [./local_L2_eta_950]
#    type = ElementL2ErrorFunctionAux
#    variable = L2_eta_950
#    function = function_eta_950
#    coupled_variable = eta
#  [../]
[]

[Materials]
  [./f_eta]
    type = NucleationBMMaterial
    order_parameter = eta
    function_name = f_nucl
    w = 1.0
    deltafT = 0.02592724864 # 1/(30*sqrt(2)) * 1.1
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
  [./eta_500_error]
    type = ElementL2Error
    variable = eta
    function = function_eta_500
  [../]  
  [./eta_650_error]
    type = ElementL2Error
    variable = eta
    function = function_eta_650
  [../]
  [./eta_800_error]
    type = ElementL2Error
    variable = eta
    function = function_eta_800
  [../]  
  [./eta_950_error]
    type = ElementL2Error
    variable = eta
    function = function_eta_950
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

  end_time = 6500
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
  [./eta_500]
    type = SolutionUserObject
    system_variables = eta
    mesh = athermal_ref_dx_0_0125_0002_mesh.xda
    es = athermal_ref_dx_0_0125_0002.xda
  [../]
  [./eta_650]
    type = SolutionUserObject
    system_variables = eta
    mesh = athermal_ref_dx_0_0125_0003_mesh.xda
    es = athermal_ref_dx_0_0125_0003.xda
  [../]
  [./eta_800]
    type = SolutionUserObject
    system_variables = eta
    mesh = athermal_ref_dx_0_0125_0004_mesh.xda
    es = athermal_ref_dx_0_0125_0004.xda
  [../]
  [./eta_950]
    type = SolutionUserObject
    system_variables = eta
    mesh = athermal_ref_dx_0_0125_0005_mesh.xda
    es = athermal_ref_dx_0_0125_0005.xda
  [../]
[]

[Functions]
  [./function_eta_500]
    type = SolutionFunction
    solution = eta_500
  [../]
  [./function_eta_650]
    type = SolutionFunction
    solution = eta_650
  [../]
  [./function_eta_800]
    type = SolutionFunction
    solution = eta_800
  [../]
  [./function_eta_950]
    type = SolutionFunction
    solution = eta_950
  [../]
[]

[Outputs]
  console = true
  csv = true
  file_base = athermal_dx_0_025
  sync_times = '500 650 800 950'
  interval = 500
  checkpoint = true
[]
