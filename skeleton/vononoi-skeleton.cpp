#include <iostream>

using namespace std;

#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>
#include <CGAL/Polygon_2.h>
#include <CGAL/create_straight_skeleton_from_polygon_with_holes_2.h>

typedef CGAL::Exact_predicates_inexact_constructions_kernel K ;

typedef K::Point_2                    Point ;
typedef CGAL::Polygon_2<K>            Polygon ;


typedef Polygon::Edge_const_iterator Edge_const_iterator;


// typedefs for the traits and the algorithm
#include <CGAL/Segment_Delaunay_graph_filtered_traits_2.h>
#include <CGAL/Segment_Delaunay_graph_2.h>
typedef CGAL::Segment_Delaunay_graph_filtered_traits_2<K,
/* The construction kernel allows for / and sqrt */    CGAL::Field_with_sqrt_tag,
       K,
/* The exact kernel supports field ops exactly */      CGAL::Field_tag>  Gt;

typedef CGAL::Segment_Delaunay_graph_2<Gt>             SDG2;

//#include <CGAL/Segment_Delaunay_graph_site_2.h>
//typedef CGAL::Segment_Delaunay_graph_site_2<CK> Segment_Delaunay_graph_site_2;


typedef CGAL::Line_2<K> Line;
typedef CGAL::Segment_2<K> Segment;
typedef CGAL::Ray_2<K> Ray;
#include <CGAL/Conic_2.h>
typedef CGAL::Conic_2<K> Conic;
#include <CGAL/Parabola_2.h>
#include <CGAL/Parabola_segment_2.h>
typedef CGAL::Parabola_segment_2<Gt> Parabola;

#include <CGAL/Polygon_2_algorithms.h>

#include "load.h"

void insert_polygon(SDG2 &sdg, Polygon &p) {
//  cerr << "insert inner..." << p << endl << flush;
  for(Edge_const_iterator i=p.edges_begin(); i!=p.edges_end(); ++i ) {
//    cerr << "insert edge..." << *i << endl << flush;
    SDG2::Site_2 site;
    site = SDG2::Site_2::construct_site_2(i->source(),i->target());
    sdg.insert( site );
  }
}

bool is_in(vector<Polygon> &outer, vector<Polygon> &inner, Segment &s) {
  // Le segement en entier est d'un seul cote.
  bool in_outer = false;
  for(vector<Polygon>::iterator h=outer.begin(); h!=outer.end(); ++h) {
    if( h->bounded_side(s.source()) == CGAL::ON_BOUNDED_SIDE && h->bounded_side(s.target()) == CGAL::ON_BOUNDED_SIDE ) {
      in_outer = true;
      break;
    }
  }
  if( in_outer ) {
    for(vector<Polygon>::iterator h=inner.begin(); h!=inner.end(); ++h) {
      if( h->bounded_side(s.source()) != CGAL::ON_UNBOUNDED_SIDE || h->bounded_side(s.target()) != CGAL::ON_UNBOUNDED_SIDE ) {
        return false;
      }
    }
    return true;
  } else {
    return false;
  }
}

bool is_in(vector<Polygon> &outer, vector<Polygon> &inner, Parabola &p, vector<Point> &vp) {
  p.generate_points(vp);
  bool in_outer = false;
  for(vector<Polygon>::iterator h=outer.begin(); h!=outer.end(); ++h) {
    if( CGAL::bounded_side_2(h->vertices_begin(), h->vertices_end(), vp[0], K()) == CGAL::ON_BOUNDED_SIDE ) {
      in_outer = true;
      break;
    }
  }
  if( in_outer ) {
    for(vector<Polygon>::iterator h=inner.begin(); h!=inner.end(); ++h) {
      if( CGAL::bounded_side_2(h->vertices_begin(), h->vertices_end(), vp[0], K()) != CGAL::ON_UNBOUNDED_SIDE ) {
        return false;
      }
    }
    return true;
  } else {
    return false;
  }
}

int main(int argn, char **argv) {
  const char* filename = argv[1];
  vector<Polygon> outer;
  vector<Polygon> inner;

  if(! load(filename, outer, inner) ) {
    cerr << "Failed to open the " << filename << endl;
    return -1;
  } else {
    cerr << "loaded" << endl;
  }


  SDG2 sdg;

  int n = 0;
  for(vector<Polygon>::iterator h=outer.begin(); h!=outer.end(); ++h) {
    cerr << (++n) << endl;
    insert_polygon(sdg, *h);
  }

  for(vector<Polygon>::iterator h=inner.begin(); h!=inner.end(); ++h) {
    cerr << (++n) << endl;
    insert_polygon(sdg, *h);
  }

  cout.setf(ios::fixed,ios::floatfield);
  cout << "<gpx><trk>" << endl;
  for(SDG2::Finite_edges_iterator i=sdg.finite_edges_begin(); i!=sdg.finite_edges_end() ; ++i ) {
    SDG2::Edge e = *i;
    CGAL::Object o = sdg.primal(e);

    Line l;
    Segment s;
    Ray r;
    Parabola p;
    if (CGAL::assign(l, o)) {
      cerr << "line: " << l << endl;
    } else if (CGAL::assign(s, o)) {
      //cerr << "segment: " << s << endl;
      if( is_in(outer, inner, s) ) {
        //cout << "<path d='M" << s << "'/>" << endl;
        cout << "<trkseg><trkpt lat='" << s.source().x() << "' lon='" << s.source().y() << "'/><trkpt lat='" << s.target().x() << "' lon='" << s.target().y() << "'/></trkseg>" << endl;
      }
    } else if (CGAL::assign(r, o)) {
      cerr << "ray: " << r << endl;
    } else if (CGAL::assign(p, o)) {
      //cerr << p << endl;
      vector<Point> vp;
      if( is_in(outer, inner, p, vp ) ) {
        cout << "<trkseg>";
        for(unsigned int i = 0; i < vp.size(); i++) {
          cout << "<trkpt lat='" << vp[i].x() << "' lon='" << vp[i].y() << "'/>";
        }
        cout << "</trkseg>" << endl;
      }
    } else {
      cerr  << "?" << endl;
   }
  }
  cout << "</trk></gpx>" << endl;

  return 0;
}
