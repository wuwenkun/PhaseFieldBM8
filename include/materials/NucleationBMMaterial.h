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

#ifndef NUCLEATIONBMMATERIAL_H
#define NUCLEATIONBMMATERIAL_H

#include "Material.h"
#include "DerivativeMaterialInterface.h"  //modified by Wenkun


//forward declarations
class NucleationBMMaterial;

template<>
InputParameters validParams<NucleationBMMaterial>();

class NucleationBMMaterial : public DerivativeMaterialInterface<Material> //modified by Wenkun
{
public:
  NucleationBMMaterial(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

  const VariableValue & _OP;
  unsigned int _OP_var;
  VariableName _OP_name;
  std::string _function_name;
  MaterialProperty<Real> & _prop_f;
  MaterialProperty<Real> & _prop_df;
  MaterialProperty<Real> & _prop_d2f;
    
  Real _w;
  Real _deltafT;
private:
};

#endif // NUCLEATIONBMMATERIAL
