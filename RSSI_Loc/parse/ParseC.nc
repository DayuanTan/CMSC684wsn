#include <Timer.h>
#include "RSSILoc.h"
#include <RadioConfig.h>

module ParseC @safe(){
  uses interface Boot;
  uses interface SplitControl as RadioControl;
  
  provides interface Intercept as RadioParse[am_id_t amid];
}

implementation {
  
  event void Boot.booted() {
    call RadioControl.start();
  }
  
  event void RadioControl.startDone(error_t err){
  }

  event void RadioControl.stopDone(error_t err){
  }
  
  default event bool RadioParse.forward[am_id_t amid](message_t* msg, void* payload, uint8_t len){
    return TRUE;
  }
}