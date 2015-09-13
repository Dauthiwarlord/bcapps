// Attempts to re-create the functions I had in Mathematica, just so I
// can get a hang of the SPICE C kernel (have been trying to do too
// much w/ it?)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"

// actually declaring entire functions here, not just prototype
double et2jd(double d) {return 2451545.+d/86400.;}
double jd2et(double d) {return 86400.*(d-2451545.);}

// icky defining functions first

void posxyz(double time, int planet, SpiceDouble position[3]) {
  SpiceDouble lt;
  spkezp_c(planet, jd2et(time),"J2000","NONE",0,position,&lt);
}

int main (int argc, char **argv) {

  SpiceDouble pos[3], pos2[3];
  SpiceDouble lt;

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  if (!strcmp(argv[1],"posxyz")) {
    double time = jd2et(atof(argv[2]));
    int planet = atoi(argv[3]);
    //    spkezp_c(planet,time,"J2000","NONE",0,position,&lt);
    //    spkgps_c(planet,time,"J2000",0,position,&lt);
    posxyz(atof(argv[2]),atoi(argv[3]),pos);
    posxyz(2450000,6,pos2);
    printf("%f -> %f %f %f\n",time,pos2[0],pos2[1],pos2[2]);
    printf("%f -> %f %f %f\n",time,pos[0],pos[1],pos[2]);
  }

}
