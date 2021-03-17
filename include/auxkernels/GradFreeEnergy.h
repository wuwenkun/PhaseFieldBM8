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

#ifndef GRADFREEENERGY_H
#define GRADFREEENERGY_H

#include "AuxKernel.h"

//forward declarations
class GradFreeEnergy;

template<>
InputParameters validParams<GradFreeEnergy>();

class GradFreeEnergy : public AuxKernel
{
public:
  GradFreeEnergy(const InputParameters & parameters);

protected:
  virtual Real computeValue();

private:

  const VariableGradient & _grad_OP;
  const MaterialProperty<Real> & _kappa;
};

#endif //GRADFREEENERGY_H
