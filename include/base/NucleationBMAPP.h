#ifndef NUCLEATIONBMAPP_H
#define NUCLEATIONBMAPP_H

#include "MooseApp.h"

class NucleationBMAPP;

template<>
InputParameters validParams<NucleationBMAPP>();

class NucleationBMAPP : public MooseApp
{
public:
  NucleationBMAPP(InputParameters parameters);
  virtual ~NucleationBMAPP();

  static void registerApps();
  static void registerObjects(Factory & factory);
  static void associateSyntax(Syntax & syntax, ActionFactory & action_factory);
};

#endif /* NUCLEATIONBMAPP_H */
