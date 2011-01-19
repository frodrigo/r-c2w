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
  const char* outfilename;

  polygon_set ps1;
  if(! load(p1filename, ps1) ) {
    cerr << "Failed to open the " << p1filename << endl;
    return -1;
  } else {
    cerr << "loaded" << endl;
  }

  polygon_set out;

  if( op[0] == 'd' ) {
    //  diff3
    const char* p2filename = argv[3];
    const char* p3filename = argv[4];
    outfilename = argv[5];

    polygon_set ps2;
    if(! load(p2filename, ps2) ) {
      cerr << "Failed to open the " << p2filename << endl;
      return -1;
    } else {
      cerr << "loaded" << endl;
    }

    polygon_set ps3;
    if(! load(p3filename, ps3) ) {
      cerr << "Failed to open the " << p3filename << endl;
      return -1;
    } else {
      cerr << "loaded" << endl;
    }

    out = ps1 - (ps2 + ps3);
  } else {
    // union1
    outfilename = argv[3];
    out = ps1;
  }

  if(! save(outfilename, out) ) {
    cerr << "Failed to save the " << outfilename << endl;
    return -1;
  } else {
    return 0;
  }
}
