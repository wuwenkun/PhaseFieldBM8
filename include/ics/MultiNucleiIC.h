#ifndef MULTINUCLEIIC_H
#define MULTINUCLEIIC_H

#include "InitialCondition.h"
#include "MooseRandom.h"

// System includes
#include <string>

// Forward Declarations
class MultiNucleiIC;
//class InputParameters;

namespace libMesh
{
class Point;
}

//template <typename T>
//InputParameters validParams();

template <>
InputParameters validParams<MultiNucleiIC>();

/**
 * MultiNucleiIC initializes multiple nuclei at random positions.
 */
class MultiNucleiIC : public InitialCondition
{
public:
  MultiNucleiIC(const InputParameters & parameters);

  virtual Real value(const Point & p) override;
  virtual void initialSetup() override;

protected:
  virtual Real computeNucleiValue(const Point & p, const Point & center, const Real & radius);
  virtual void computeNucleiCenters();
    
  MooseMesh & _mesh;
    
  const Real _radius;
  const unsigned int _numbub;
  const Real _bubspac;
  const unsigned int _max_num_tries;

  Point _bottom_left;
  Point _top_right;
  Point _range;
  
  Real _int_width;
  bool _3D_spheres;
  unsigned int _num_dim;
  std::vector<Point> _centers;
  MooseRandom _random;
    
};

#endif // MULTINUCLEIIC_H
