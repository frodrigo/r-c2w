bool load(const char* filename, vector<Polygon> &outer, vector<Polygon> &inner) {
  std::ifstream input_file (filename);
  if (! input_file.is_open()) {
    return false;
  }

  // Read polygons from a file.
  unsigned int total_poly;
  input_file >> total_poly;

  for (unsigned int k = 0; k < total_poly; k++) {
    unsigned int hole;
    input_file >> hole;
    Polygon poly;
    input_file >> poly;
    if( ! poly.is_simple() ) {
      std::cerr << "Poly " << k << " is not simple" << std::endl;
    }
    std::cerr << k << "/" << total_poly << "(" << poly.size() << "," << hole << ")" << std::endl;
    if( hole == 0 ) {
      outer.push_back(poly);
    } else {
      inner.push_back(poly);
    }
  }

  return true;
}
