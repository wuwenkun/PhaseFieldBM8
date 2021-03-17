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

#ifndef BULKFREEENERGY_H
#define BULKFREEENERGY_H

#include "AuxKernel.h"
// This contains f_bulk - deltafT*h(eta)
//forward declarations
class BulkFreeEnergy;

template<>
InputParameters validParams<BulkFreeEnergy>();

// Compute the chemical free energy
// h*fa+(1-h)*fb+wg

class BulkFreeEnergy : public AuxKernel
{
public:
  BulkFreeEnergy(const InputParameters & parameters);

protected:
  virtual Real computeValue();

private:
    const MaterialProperty<Real> & _f_bulk;
};

#endif //BULKFREEENERGY_H
