#include "MultiNucleiIC.h"

// MOOSE includes
#include "MooseMesh.h"
#include "MooseVariable.h"
#include "libmesh/utility.h"

//registerMooseObject("PhaseFieldApp", MultiSmoothCircleIC);

template <>
InputParameters
validParams<MultiNucleiIC>()
{
  InputParameters params = validParams<InitialCondition>();
  params.addClassDescription("Random distribution of smooth nuclei with given minimum spacing");
  params.addRequiredParam<unsigned int>("numbub", "The number of bubbles to place");
  params.addRequiredParam<Real>("bubspac",
                                "minimum spacing of bubbles, measured from center to center");
  params.addParam<unsigned int>("numtries", 1000, "The number of tries");
  params.addRequiredParam<Real>("radius", "Radius value for the nuclei");
  params.addParam<Real>(
        "int_width", 0.0, "The interfacial width of the void surface.  Defaults to sharp interface");
  params.addParam<bool>("3D_spheres", true, "in 3D, whether the objects are spheres or columns");
  params.addParam<unsigned int>("rand_seed", 12345, "Seed value for the random number generator");
  return params;
}

MultiNucleiIC::MultiNucleiIC(const InputParameters & parameters)
  : InitialCondition(parameters),
    _mesh(_fe_problem.mesh()),
    _radius(getParam<Real>("radius")),
    _numbub(getParam<unsigned int>("numbub")),
    _bubspac(getParam<Real>("bubspac")),
    _max_num_tries(getParam<unsigned int>("numtries")),
    _int_width(parameters.get<Real>("int_width")),
    _3D_spheres(parameters.get<bool>("3D_spheres")),
    _num_dim(_3D_spheres ? 3 : 2)
{
    _random.seed(_tid, getParam<unsigned int>("rand_seed"));
}

void
MultiNucleiIC::initialSetup()
{
  // Set up domain bounds with mesh tools
  for (unsigned int i = 0; i < LIBMESH_DIM; ++i)
  {
    _bottom_left(i) = _mesh.getMinInDimension(i);
    _top_right(i) = _mesh.getMaxInDimension(i);
  }
  _range = _top_right - _bottom_left;
    
  computeNucleiCenters();
}

void
MultiNucleiIC::computeNucleiCenters()
{
  _centers.resize(_numbub);
  for (unsigned int i = 0; i < _numbub; ++i)
  {
    // Vary circle center positions
    unsigned int num_tries = 0;
    while (num_tries < _max_num_tries)
    {
      num_tries++;

      RealTensorValue ran;
      ran(0, 0) = _random.rand(_tid);
      ran(1, 1) = _random.rand(_tid);
      ran(2, 2) = _random.rand(_tid);

      _centers[i] = _bottom_left + ran * _range;

      for (unsigned int j = 0; j < i; ++j)
        if (_mesh.minPeriodicDistance(_var.number(), _centers[j], _centers[i]) < _bubspac)
          goto fail;

      // accept the position of the new center
      goto accept;

    // retry a new position until tries are exhausted
    fail:
      continue;
    }

    if (num_tries == _max_num_tries)
      mooseError("Too many tries in MultiNucleiIC");

  accept:
    continue;
  }
}

Real
MultiNucleiIC::value(const Point & p)
{
  Real value = 0.0;
  Real val2 = 0.0;
  for (unsigned int circ = 0; circ < _centers.size(); ++circ)
  {
    val2 = computeNucleiValue(p, _centers[circ], _radius);
    value += val2;
    if (value > 1)
      value = 1;
  }
  return value;
}

Real
MultiNucleiIC::computeNucleiValue(const Point & p, const Point & center, const Real & radius)
{
  Point l_center = center;
  Point l_p = p;
  if (!_3D_spheres) // Create 3D cylinders instead of spheres
  {
    l_p(2) = 0.0;
    l_center(2) = 0.0;
  }
  // Compute the distance between the current point and the center
  Real dist = _mesh.minPeriodicDistance(_var.number(), l_p, l_center);
  return 0.5*(1.0-std::tanh((dist - radius)/std::sqrt(2)/_int_width));
}
