
void save_poly_vector(ofstream &output_file, vector<Polygon> &vPoly, char *hole) {
  for (unsigned int k = 0; k < vPoly.size(); k++) {
    cerr << k << "/" << vPoly.size() << "/" << hole << " (" << vPoly[k].size() << ")" << endl;
    output_file << hole << endl;
    output_file << vPoly[k].size() << endl;
    for(Polygon::Vertex_const_iterator i=vPoly[k].vertices_begin(); i!=vPoly[k].vertices_end(); ++i ) {
      output_file << *i << endl;
    }
  }
}

bool save(const char* filename, vector<Polygon> &outer, vector<Polygon> &inner) {
  ofstream output_file (filename);
  if (! output_file.is_open()) {
    return false;
  }

  output_file.setf(ios::fixed,ios::floatfield);

  // Write polygons to a file.
  unsigned int total_poly = outer.size() + inner.size();
  output_file << total_poly << endl;

  save_poly_vector (output_file, outer, "0");
  save_poly_vector (output_file, inner, "1");

  return true;
}
