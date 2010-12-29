#include <stdio.h>
#include "gpc.h"

// (union|diff) p1 p2 out
int main(int argn, char **argv) {
  gpc_polygon p1, pouter, pinner;

  FILE *f_p1 = fopen(argv[1], "r");
  gpc_read_polygon(f_p1, 1, &p1);
  fclose(f_p1);

  int c;
  for (c = 0; c < p1.num_contours; c++) {
    gpc_polygon p;
    gpc_init_empty_polygon(&p);
    gpc_add_contour(&p, &p1.contour[c], 0);

    if(p1.hole[c] == 0 ) {
      gpc_polygon u;
      gpc_polygon_clip(GPC_UNION, &pouter, &p, &u);
      pouter = u;
    } else {
      gpc_polygon u;
      gpc_polygon_clip(GPC_UNION, &pinner, &p, &u);
      pinner = u;
    }
  }


  for (c = 0; c < pinner.num_contours; c++) {
    gpc_add_contour(&pouter, &pinner.contour[c], 1);
  }

//  gpc_free_polygon(&p1);

  FILE *f_out = fopen(argv[2], "w");
  gpc_write_polygon(f_out, 1, &pouter);
  fclose(f_out);

//  gpc_free_polygon(&pouter);

  return 0;
}
