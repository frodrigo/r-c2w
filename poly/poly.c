#include <stdio.h>
#include "gpc.h"

// (union|diff) p1 p2 out
int main(int argn, char **argv) {
  gpc_polygon p1, p2, out;

  FILE *f_p1 = fopen(argv[2], "r");
  FILE *f_p2 = fopen(argv[3], "r");
  gpc_read_polygon(f_p1, 0, &p1);
  gpc_read_polygon(f_p2, 0, &p2);
  fclose(f_p1);
  fclose(f_p2);

  gpc_op op = (argv[1][0] == 'u')? GPC_UNION : GPC_DIFF;
  gpc_polygon_clip(op, &p1, &p2, &out);

  gpc_free_polygon(&p1);
  gpc_free_polygon(&p2);

  FILE *f_out = fopen(argv[4], "w");
  gpc_write_polygon(f_out, 0, &out);
  fclose(f_out);

  gpc_free_polygon(&out);

  return 0;
}
