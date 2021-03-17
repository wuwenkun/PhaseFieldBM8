# Phase Field Benchmark 8
# Nucleation Benchmark Problem I.2 
# Homogeneous Nucleation, Multiple Seeds at t=0
# Random Seed #4

[Mesh]
  type = GeneratedMesh
  dim = 2
  elem_type = QUAD4
  nx = 320
  ny = 320
  nz = 0
  xmin = -250
  xmax = 250
  ymin = -250
  ymax = 250
  zmin = 0
  zmax = 0
[]


[Variables]
  [./eta]   # phase-field variable
    order = FIRST
    family = LAGRANGE
  [../]
[]
  
[ICs]
  [./testIC]
    type = MultiNucleiIC
    variable = eta
    rand_seed = 280
    radius = 2.2 
    int_width = 1.0
    numbub = 25
    bubspac = 0.1    
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
[]

[BCs]
  # Zero-normal derivative Neumann boundary conditions by default
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
[]

[Materials]
  [./f_eta]
    type = NucleationBMMaterial
    order_parameter = eta
    function_name = f_nucl
    w = 1.0
    deltafT = 0.23570 # 1/(3*sqrt(2))
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


[Adaptivity]
  marker = combo
  initial_steps = 4
  max_h_level = 4  
  [./Markers]
    [./EFM_1]
      type = ErrorFractionMarker
      coarsen = 0.05
      refine = 0.75
      indicator = GJI_1
    [../]

    [./combo]
      type = ComboMarker
      markers = 'EFM_1'
    [../]
  [../]

  [./Indicators]
    [./GJI_1]
     type = GradientJumpIndicator
     variable = eta
    [../]
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
  [./Check_dtotE]
    type = Terminator
    expression = 'Change_totE_over_time < 1e-2'
  [../]
[]

[Outputs]
  [./exodus]
    type = Exodus
	sync_times = '20 40 60 80 100'
    interval = 100
  [../]
  console = true
  csv = true
  checkpoint = true
[]
