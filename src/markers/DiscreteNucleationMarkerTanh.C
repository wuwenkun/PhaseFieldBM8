// This file is almost the same with DiscreteNucleationMarker 
// The main difference is that this includes DiscreteNucleationMapTanh 

#include "DiscreteNucleationMarkerTanh.h"
#include "DiscreteNucleationMapTanh.h"

//registerMooseObject("PhaseFieldApp", DiscreteNucleationMarker);

template <>
InputParameters
validParams<DiscreteNucleationMarkerTanh>()
{
  InputParameters params = validParams<Marker>();
  params.addClassDescription("Mark new nucleation sites for refinement");
  params.addRequiredParam<UserObjectName>("map", "DiscreteNucleationMapTanh user object");
  return params;
}

DiscreteNucleationMarkerTanh::DiscreteNucleationMarkerTanh(const InputParameters & parameters)
  : Marker(parameters),
    _map(getUserObject<DiscreteNucleationMapTanh>("map")),
    _periodic(_map.getPeriodic()),
    _inserter(_map.getInserter()),
    _radius(_map.getRadiusAndWidth().first),
    _int_width(_map.getRadiusAndWidth().second),
    _nucleus_list(_inserter.getNucleusList())
{
}

Marker::MarkerValue
DiscreteNucleationMarkerTanh::computeElementMarker()
{
  const RealVectorValue centroid = _current_elem->centroid();
  const Real size = 0.5 * _current_elem->hmax();

  // check if the surface of a nucleus might touch the element
  for (unsigned i = 0; i < _nucleus_list.size(); ++i)
  {
    // use a non-periodic or periodic distance
    const Real r = _periodic < 0
                       ? (centroid - _nucleus_list[i].center).norm()
                       : _mesh.minPeriodicDistance(_periodic, centroid, _nucleus_list[i].center);
    if (r < _radius + size && r > _radius - size && size > _int_width)
      return REFINE;
  }

  // We return don't mark to allow coarsening when used in a ComboMarker
  return DONT_MARK;
}
