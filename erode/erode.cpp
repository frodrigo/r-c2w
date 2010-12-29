#include <stdlib.h>
#include <iostream>

using namespace std;

#include <CGAL/Cartesian.h>
#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>
#include <CGAL/Polygon_2.h>
typedef CGAL::Exact_predicates_inexact_constructions_kernel K;

typedef K::Point_2                    Point;
typedef CGAL::Polygon_2<K>            Polygon;

#include <CGAL/Polygon_with_holes_2.h>
typedef CGAL::Polygon_with_holes_2<K> Polygon_with_holes;

typedef Polygon::Edge_const_iterator Edge_const_iterator;

#include <CGAL/minkowski_sum_2.h>

#include "../skeleton/load.h"
#include "save.h"

#include <vector>


int main(int argn, char **argv) {
  const char*  infilename = argv[1];
  const char* outfilename = argv[2];
  const float r = atof(argv[3]);

  vector<Polygon> outer;
  vector<Polygon> inner;

  load ( infilename, outer, inner);

// FIXME orientation

  Polygon Q;
  Q.push_back (Point(0, r));
  Q.push_back (Point(r, 0));
  Q.push_back (Point(0, -r));
  Q.push_back (Point(-r, 0));

  vector<Polygon> outer_new;
  vector<Polygon> inner_new;

  for (unsigned int k = 0; k < outer.size(); k++) {
    if(outer[k].is_clockwise_oriented()) {
      outer[k].reverse_orientation();
    }
    Polygon_with_holes sum = minkowski_sum_2 (outer[k], Q);
    outer_new.push_back(sum.outer_boundary());
    for (Polygon_with_holes::Hole_const_iterator h=sum.holes_begin() ; h!=sum.holes_end() ; ++h ) {
      inner_new.push_back(*h);
    }
  }

  for (unsigned int k = 0; k < inner.size(); k++) {
    if(!outer[k].is_clockwise_oriented()) {
      outer[k].reverse_orientation();
    }
    Polygon_with_holes sum = minkowski_sum_2 (inner[k], Q);
    inner_new.push_back(sum.outer_boundary());
    for (Polygon_with_holes::Hole_const_iterator h=sum.holes_begin() ; h!=sum.holes_end() ; ++h ) {
      outer_new.push_back(*h);
    }
  }

  save (outfilename, outer_new, inner_new);

  return 0;
}
