#include "NucleationBMAPP.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "Moose.h"

#include "PhaseFieldApp.h"
#include "TensorMechanicsApp.h"
#include "MultiNucleiIC.h"
#include "NucleationBMMaterial.h"
#include "DiscreteNucleationTanh.h"
#include "BulkFreeEnergy.h"
#include "GradFreeEnergy.h"
#include "TotalFreeEnergyBM.h"
#include "DiscreteNucleationMapTanh.h"
#include "DiscreteNucleationMarkerTanh.h"



template <>
InputParameters
validParams<NucleationBMAPP>()
{
  InputParameters params = validParams<MooseApp>();
  return params;
}

NucleationBMAPP::NucleationBMAPP(InputParameters parameters) : MooseApp(parameters)
{
  srand(processor_id());

  Moose::registerObjects(_factory);
  NucleationBMAPP::registerObjects(_factory);
  
  PhaseFieldApp::registerObjects(_factory);
  PhaseFieldApp::associateSyntax(_syntax, _action_factory);

  TensorMechanicsApp::registerObjects(_factory);
  TensorMechanicsApp::associateSyntax(_syntax, _action_factory);

  Moose::associateSyntax(_syntax, _action_factory);
  NucleationBMAPP::associateSyntax(_syntax, _action_factory);
}

NucleationBMAPP::~NucleationBMAPP()
{
}

void
NucleationBMAPP::registerObjects(Factory & factory)
{
  //Registry::registerObjectsTo(factory, {"HedgehogCApp"}); wrong
  registerInitialCondition(MultiNucleiIC);
  registerMaterial(NucleationBMMaterial);
  registerMaterial(DiscreteNucleationTanh);
  registerAuxKernel(BulkFreeEnergy);
  registerAuxKernel(GradFreeEnergy);
  registerAuxKernel(TotalFreeEnergyBM);
  registerUserObject(DiscreteNucleationMapTanh);
  registerMarker(DiscreteNucleationMarkerTanh);
}

void
NucleationBMAPP::registerApps()
{
  registerApp(NucleationBMAPP);
}

void
NucleationBMAPP::associateSyntax(Syntax & /*syntax*/, ActionFactory & action_factory)
{
  Registry::registerActionsTo(action_factory, {"NucleationBMAPP"});
}
