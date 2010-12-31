
bool load(const char* filename, polygon_set &ps) {
  ifstream input_file(filename);
  if (! input_file.is_open()) {
    return false;
  }

  // Read polygons from a file.
  unsigned int total_poly;
  input_file >> total_poly;

  for (unsigned int k = 0; k < total_poly; k++) {
    unsigned int hole, nb;
    input_file >> hole;
    input_file >> nb;

    std::vector<point> pts;
    for(unsigned int j=0 ; j<nb ; j++) {
      double a, b;
      input_file >> a >> b;
      int aa, bb;
      aa = a * 10e6;
      bb = b * 10e6;
      pts.push_back(point(aa, bb));
    }

    polygon poly;
    boost::polygon::set_points(poly, pts.begin(), pts.end());

    cerr << k << "/" << total_poly << "(" << poly.size() << "," << hole << ")" << endl;
    if( hole == 0 ) {
      ps += poly;
    } else {
      ps -= poly;
    }
  }

  return true;
}

void save_poly(ofstream &output_file, const polygon_data &poly, int hole) {
  output_file << hole << endl;
  output_file << poly.size() << endl;
  for(polygon::iterator_type i=poly.begin() ; i!=poly.end() ; ++i) {
    int xx = i->x();
    int yy = i->y();
    double x = ((double)xx) / 10e6;
    double y = ((double)yy) / 10e6;
    output_file << x << " " << y << endl;
  }
}

void save_poly(ofstream &output_file, const polygon &poly, int hole) {
  output_file << hole << endl;
  output_file << poly.size() << endl;
  for(polygon::iterator_type i=poly.begin() ; i!=poly.end() ; ++i) {
    int xx = i->x();
    int yy = i->y();
    double x = ((double)xx) / 10e6;
    double y = ((double)yy) / 10e6;
    output_file << x << " " << y << endl;
  }
}

int count_poly(const polygon_set &ps) {
  std::vector<polygon> polys;
  ps.get(polys);

  int ret = polys.size();

  for(std::size_t i = 0; i < polys.size(); ++i) {
    ret += polys[i].size_holes();
  }

  return ret;
}

bool save(const char* filename, polygon_set &ps) {
  using namespace boost::polygon;

  ofstream output_file(filename);
  if (! output_file.is_open()) {
    return false;
  }

  output_file.setf(ios::fixed,ios::floatfield);

  std::vector<polygon> polys;
  ps.get(polys);

  // Write polygons to a file.
  output_file << count_poly(ps) << endl;

  for(std::size_t i = 0; i < polys.size(); ++i) {
    cerr << i << "/" << polys.size() << "/" << 0 << " (" << polys[i].size() << ")" << endl;
    save_poly(output_file, polys[i], 0);
    for(polygon_with_holes_traits<polygon>::iterator_holes_type j = begin_holes(polys[i]); j != end_holes(polys[i]); ++j) {
      cerr << i << "/" << polys.size() << "/" << 1 << " (" << j->size() << ")" << endl;
      save_poly(output_file, *j, 1);
    }
  }

  return true;
}
