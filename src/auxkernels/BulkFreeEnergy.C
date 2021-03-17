/******************************************************
 *
 *   Welcome to NucleationBM!
 *
 *   CHiMaD (ANL/Northwestern University)
 *
 *   Developer: Wenkun Wu	
 *
 *   19 June 2019
 *
 *****************************************************/

#include "BulkFreeEnergy.h"


// This contains f_bulk - deltafT*h(eta)
template<>
InputParameters validParams<BulkFreeEnergy>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addRequiredParam<MaterialPropertyName>("f_name",
                                                "Base name of the free energy function "
                                                "F (f_name in the corresponding "
                                                "derivative function material)");
  return params;
}

BulkFreeEnergy::BulkFreeEnergy(const InputParameters & parameters) :
    AuxKernel(parameters),
    _f_bulk(getMaterialProperty<Real>("f_name"))
{
}

Real
BulkFreeEnergy::computeValue()
{
  return _f_bulk[_qp];
}
