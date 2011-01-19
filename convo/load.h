
struct pdata {
  pdata(polygon_set poly_, int min_x_): poly(poly_), min_x(min_x_) {}
  polygon_set poly;
  int min_x;
};

bool compare_min_poly(pdata p1, pdata p2)
{
  return p1.min_x < p2.min_x;
}

polygon_set &reduce_polygon_list(std::list<pdata> &polygon_list) {
  polygon_list.sort(compare_min_poly);

  while (polygon_list.size() > 1) {
    cerr << polygon_list.size() << endl;
    polygon_set wps1 = polygon_list.front().poly;
    polygon_list.pop_front();
    polygon_set wps2 = polygon_list.front().poly;
    polygon_list.pop_front();
    polygon_list.push_back(pdata(wps1+=wps2,0));
  }

  return polygon_list.front().poly;
}

bool load(const char* filename, polygon_set &ps) {
  ifstream input_file(filename);
  if (! input_file.is_open()) {
    return false;
  }

  // Read polygons from a file.
  unsigned int total_poly;
  input_file >> total_poly;

  std::list<pdata> polygon_list;
  pdata cur_data(polygon_set(),0);
  for (unsigned int k = 0; k < total_poly; k++) {
    unsigned int hole, nb;
    input_file >> hole;
    input_file >> nb;

    int min_x = 180*10e6;
    std::vector<point> pts;
    for(unsigned int j=0 ; j<nb ; j++) {
      double a, b;
      input_file >> a >> b;
      int aa, bb;
      aa = a * 10e6;
      bb = b * 10e6;
      pts.push_back(point(aa, bb));
      min_x = aa < min_x ? aa : min_x;
    }

    polygon poly;
    boost::polygon::set_points(poly, pts.begin(), pts.end());
    if (hole == 0) {
      polygon_set wps;
      wps.insert(poly, false);
      cur_data = pdata(wps, min_x);
      polygon_list.push_back(cur_data);
    } else {
      cur_data.poly.insert(poly, true);
    }
  }

  ps = reduce_polygon_list(polygon_list);
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
