/******************************************************
 *
 *   Welcome to NucleationBM!
 *
 *   CHiMaD (ANL/Northwestern University)
 *
 *   Developer: Wenkun Wu
 *
 *   18 June 2019
 *
 *****************************************************/

#include "NucleationBMMaterial.h"

template<>
InputParameters validParams<NucleationBMMaterial>()
{
  InputParameters params = validParams<Material>();
  params.addRequiredCoupledVar("order_parameter", "order parameter variable");
  params.addRequiredParam<std::string>("function_name", "actual name for the elastic free energy density function");
  params.addRequiredParam<Real>("w", "barrier height of the double-well bulk free energy");
  params.addParam<Real>("deltafT", 0.0, "difference in free energy per unit volume between the phase nucleation is occuring in and te phase that is nucleating, usually temperature dependent");
  return params;
}

NucleationBMMaterial::NucleationBMMaterial(const InputParameters & parameters) :
    DerivativeMaterialInterface(parameters),
    _OP(coupledValue("order_parameter")),
    _OP_var(coupled("order_parameter")),
    _OP_name(getVar("order_parameter", 0)->name()),
    _function_name(getParam<std::string>("function_name")),
    _prop_f(declareProperty<Real>(_function_name)),
    _prop_df(declarePropertyDerivative<Real>(_function_name, _OP_name)),
    _prop_d2f(declarePropertyDerivative<Real>(_function_name, _OP_name, _OP_name)),
    _w(getParam<Real>("w")),
    _deltafT(getParam<Real>("deltafT"))
{
}

void
NucleationBMMaterial::computeQpProperties()
{
  const Real n = _OP[_qp];
  Real g = n * n * (1.0 - n) * (1.0 - n);
  Real dg = 2.0 * n * (n - 1.0) * (2.0 * n - 1.0);
  Real d2g = 12.0 * (n * n - n) + 2.0;
 
  Real h = n * n * n * (6.0 * n * n - 15.0 * n + 10.0);
  Real dh = 30.0 * n * n * (n * n - 2.0 * n + 1.0);
  Real d2h = n * (120.0 * n * n - 180.0 * n + 60.0);
    
  _prop_f[_qp] = _w*g - _deltafT*h;
  _prop_df[_qp] = _w*dg - _deltafT*dh;
  _prop_d2f[_qp] = _w*d2g - _deltafT*d2h;
}

