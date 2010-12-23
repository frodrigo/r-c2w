#include <iostream>

using namespace std;

#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>
#include <CGAL/Polygon_with_holes_2.h>
#include <CGAL/create_straight_skeleton_from_polygon_with_holes_2.h>

typedef CGAL::Exact_predicates_inexact_constructions_kernel K ;

typedef K::Point_2                    Point ;
typedef CGAL::Polygon_2<K>            Polygon ;
typedef CGAL::Polygon_with_holes_2<K> Polygon_with_holes ;


typedef Polygon_with_holes::Hole_const_iterator Hole_const_iterator;
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

int main(int argn, char **argv)
{
  const char* filename = argv[1];
  ifstream input_file (filename);
  if (! input_file.is_open()) {
    cerr << "Failed to open the " << filename << endl;
    return -1;
  }

  // Read a polygon with holes from a file.
  Polygon outerP;
  unsigned int num_holes;

  input_file >> outerP;
  input_file >> num_holes;

  std::vector<Polygon>  holes (num_holes);
  unsigned int k;

  for (k = 0; k < num_holes; k++) {
    cerr << k << "/" << num_holes << endl;
    input_file >> holes[k];
  }

  Polygon_with_holes poly (outerP, holes.begin(), holes.end());

  cerr << "loaded" << endl;


  SDG2          sdg;
  SDG2::Site_2  site;

//  cerr << "insert outer..." << endl << flush;
  for(Edge_const_iterator i=poly.outer_boundary().edges_begin(); i!=poly.outer_boundary().edges_end(); ++i ) {
    site = SDG2::Site_2::construct_site_2(i->source(),i->target());
    sdg.insert( site );
  }

  for(Hole_const_iterator h=poly.holes_begin(); h!=poly.holes_end(); ++h) {
//    cerr << "insert inner..." << *h << endl << flush;
    for(Edge_const_iterator i=h->edges_begin(); i!=h->edges_end(); ++i ) {
//      cerr << "insert edge..." << *i << endl << flush;
      site = SDG2::Site_2::construct_site_2(i->source(),i->target());
      sdg.insert( site );
    }
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
      // Le segement en entier est d'un seul cote.
      if( poly.outer_boundary().bounded_side(s.source()) == CGAL::ON_BOUNDED_SIDE && poly.outer_boundary().bounded_side(s.target()) == CGAL::ON_BOUNDED_SIDE) {
        bool out = true;
        for(Hole_const_iterator h=poly.holes_begin(); h!=poly.holes_end(); ++h) {
          if(h->bounded_side(s.source()) != CGAL::ON_UNBOUNDED_SIDE || h->bounded_side(s.target()) != CGAL::ON_UNBOUNDED_SIDE) {
            out = false;
            break;
          }
        }
        if( out ) {
          //cout << "<path d='M" << s << "'/>" << endl;
          cout << "<trkseg><trkpt lat='" << s.source().x() << "' lon='" << s.source().y() << "'/><trkpt lat='" << s.target().x() << "' lon='" << s.target().y() << "'/></trkseg>" << endl;
        }
      }
    } else if (CGAL::assign(r, o)) {
      cerr << "ray: " << r << endl;
    } else if (CGAL::assign(p, o)) {
      //cerr << p << endl;
      std::vector<Point> vp;
      p.generate_points(vp);
      if( CGAL::bounded_side_2(poly.outer_boundary().vertices_begin(), poly.outer_boundary().vertices_end(), vp[0], K()) == CGAL::ON_BOUNDED_SIDE ) {
        bool out = true;
        for(Hole_const_iterator h=poly.holes_begin(); h!=poly.holes_end(); ++h) {
          if( CGAL::bounded_side_2(h->vertices_begin(), h->vertices_end(), vp[0], K()) == CGAL::ON_BOUNDED_SIDE ) {
            out = false;
            break;
          }
        }
        if( out ) {
          cout << "<trkseg>";
          for(unsigned int i = 0; i < vp.size(); i++) {
             cout << "<trkpt lat='" << vp[i].x() << "' lon='" << vp[i].y() << "'/>";
          }
          cout << "</trkseg>" << endl;
        }
      }
    } else {
      cerr  << "?" << endl;
   }
  }
  cout << "</trk></gpx>" << endl;

  return 0;
}
