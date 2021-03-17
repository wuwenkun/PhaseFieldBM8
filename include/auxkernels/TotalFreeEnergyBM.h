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

#ifndef TOTALFREEENERGYBM_H
#define TOTALFREEENERGYBM_H

#include "AuxKernel.h"

//forward declarations
class TotalFreeEnergyBM;

template<>
InputParameters validParams<TotalFreeEnergyBM>();

class TotalFreeEnergyBM : public AuxKernel
{
public:
  TotalFreeEnergyBM(const InputParameters & parameters);

protected:
  virtual Real computeValue();

private:
  const VariableValue & _f_bulk;
  const VariableValue & _grad_energy;
//  const VariableValue & _elastic_energy;

};

#endif //TOTALFREEENERGYBM_H
