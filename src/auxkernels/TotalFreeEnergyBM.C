/******************************************************
 *
 *   Welcome to Hedgehog!
 *
 *   CHiMaD (ANL/Northwestern University)
 *
 *   Developer: Wenkun Wu
 *
 *   19 June 2019
 *
 *****************************************************/

#include "TotalFreeEnergyBM.h"

template<>
InputParameters validParams<TotalFreeEnergyBM>()
{
  InputParameters params = validParams<AuxKernel>();

  params.addRequiredCoupledVar("bulk_energy", "name of auxvar holding bulk energy");
  params.addRequiredCoupledVar("grad_energy", "name of auxvar holding gradient energy");
  //params.addCoupledVar("elastic_energy", 0, "name of auxvar holding elastic energy");

  return params;
}

TotalFreeEnergyBM::TotalFreeEnergyBM(const InputParameters & parameters) :
    AuxKernel(parameters),
    _f_bulk(coupledValue("bulk_energy")),
    _grad_energy(coupledValue("grad_energy"))
   // _elastic_energy(coupledValue("elastic_energy"))
{
}

Real
TotalFreeEnergyBM::computeValue()
{
  return _f_bulk[_qp] + _grad_energy[_qp];  //+ _elastic_energy[_qp]
}
