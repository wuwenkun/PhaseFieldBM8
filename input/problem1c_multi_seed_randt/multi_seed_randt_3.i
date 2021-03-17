# Phase Field Benchmark 8
# Nucleation Benchmark Problem I.3 
# Homogeneous Nucleation, Multiple Seeds at Random Times
# Random Seed #3

[Mesh]
  type = GeneratedMesh
  dim = 2
  elem_type = QUAD4
  nx = 320 
  ny = 320 
  nz = 0
  xmin = -500
  xmax = 500
  ymin = -500
  ymax = 500
  zmin = 0
  zmax = 0
[]


[Variables]
  [./eta]   # phase-field variable
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
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
    f_name = f_tot
  [../]
[]

[AuxKernels]
  [./aux_Bulk_energy]
    variable = Bulk_energy
    type = BulkFreeEnergy
    f_name = f_tot 
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
    function_name = f_eta 
    w = 1.0
    deltafT = 0.11785 # 1/(6*sqrt(2))
  [../]

  [./nucleation]
    type = DiscreteNucleationTanh
    f_name = f_nucl
    op_names = eta
    op_values = 1
    penalty = 10
    map = map
  [../]

  [./free_energy]
    type = DerivativeSumMaterial
    f_name = f_tot
    derivative_order = 2
    args = eta
    sum_materials = 'f_eta f_nucl'
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
  cycles_per_step = 3
  recompute_markers_during_cycles = true
  initial_steps = 4 
  max_h_level = 4  
  [./Indicators]
    [./jump]
      type = GradientJumpIndicator
      variable = eta
    [../]
  [../]
  [./Markers]
    [./nuc]
      type = DiscreteNucleationMarkerTanh
      map = map
    [../]
    [./grad]
      type = ValueThresholdMarker
      variable = jump
      coarsen = 0.1
      refine = 0.2
    [../]
    [./combo]
      type = ComboMarker
      markers = 'nuc grad'
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
  [./dt]
    type = TimestepSize
  [../]
  [./dtnuc]
    type = DiscreteNucleationTimeStep
    inserter = inserter
    p2nucleus = 0.005
    dt_max = 0.1
  [../]
  [./rate]
    type = DiscreteNucleationData
    value = RATE
    inserter = inserter
  [../]
  [./update]
    type = DiscreteNucleationData
    value = UPDATE
    inserter = inserter
  [../]
  [./count]
    type = DiscreteNucleationData
    value = COUNT
    inserter = inserter
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
    cutback_factor = 0.50 
    growth_factor = 1.50 
    optimal_iterations = 6
    iteration_window = 1
    linear_iteration_ratio = 100
    timestep_limiting_postprocessor = dtnuc
  [../]

  end_time = 600 
  dtmin = 1e-2
  dtmax = 1.0

  petsc_options_iname = '-pc_type  -sub_pc_type'
  petsc_options_value = 'asm ilu'

  l_tol = 1e-4
  l_max_its = 50
  nl_max_its = 10

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-9
[]

[UserObjects]
  [./inserter]
    type = DiscreteNucleationFromFile
    hold_time = 1
    execute_on = TIMESTEP_BEGIN
    file = nuclei_info_3.csv
  [../]

  [./map]
    type = DiscreteNucleationMapTanh
    inserter = inserter
    radius = 2.2
    int_width = 1.0
  [../]
[]

[Outputs]
  console = true
  csv = true
  [exodus_snap]
    type = Exodus
    start_time = 80
    end_time = 100
  []
[]
