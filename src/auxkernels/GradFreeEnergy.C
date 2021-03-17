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

#include "GradFreeEnergy.h"

template<>
InputParameters validParams<GradFreeEnergy>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addRequiredCoupledVar("order_parameter", "order parameter variable");
  params.addParam<MaterialPropertyName>("kappa_name", "eps_sq", "The kappa used with the kernel");

  return params;
}

GradFreeEnergy::GradFreeEnergy(const InputParameters & parameters) :
    AuxKernel(parameters),
    _grad_OP(coupledGradient("order_parameter")),
    _kappa(getMaterialProperty<Real>("kappa_name"))
{
}

Real
GradFreeEnergy::computeValue()
{
  return 0.5*_kappa[_qp]*_grad_OP[_qp].norm_sq();
  //return 0.5*_kappa[_qp]*_grad_OP[_qp].size_sq();
}
