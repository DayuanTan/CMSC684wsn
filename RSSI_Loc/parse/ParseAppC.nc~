#include <Timer.h>
#include "RSSILoc.h"
#include <RadioConfig.h>

configuration ParseAppC{
  provides interface Intercept as RadioParse[am_id_t amid];
}

implementation {
  components MainC;
  components ActiveMessageC;
  components ParseC;

  RadioParse = ParseC.RadioParse;
  
  ParseC -> MainC.Boot;
  ParseC.RadioControl -> ActiveMessageC;
}
