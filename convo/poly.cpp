#include <iostream>
#include <fstream>
using namespace std;

#include <boost/polygon/polygon.hpp>

typedef boost::polygon::point_data<int> point;
typedef boost::polygon::polygon_data<int> polygon_data;
typedef boost::polygon::polygon_set_data<int> polygon_set;
typedef boost::polygon::polygon_with_holes_data<int> polygon;
typedef std::pair<point, point> edge;
using namespace boost::polygon::operators;


#include "load.h"

int main(int argn, char **argv) {
  const char* op = argv[1];
  const char* p1filename = argv[2];
  const char* p2filename = argv[3];
  const char* outfilename = argv[4];

  polygon_set ps1;
  if(! load(p1filename, ps1) ) {
    cerr << "Failed to open the " << p1filename << endl;
    return -1;
  } else {
    cerr << "loaded" << endl;
  }

  polygon_set ps2;
  if(! load(p2filename, ps2) ) {
    cerr << "Failed to open the " << p2filename << endl;
    return -1;
  } else {
    cerr << "loaded" << endl;
  }

  polygon_set out;
  if( op[0] == 'u' ) {
    out = ps1 + ps2;
  } else {
    out = ps1 - ps2;
  }

  if(! save(outfilename, out) ) {
    cerr << "Failed to save the " << outfilename << endl;
    return -1;
  } else {
    return 0;
  }
}
