#include <Timer.h>
#include "RSSILoc.h"
#include <RadioConfig.h>

module RSSILocC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;

  //uses interface Packet as RadioPacket;
  //uses interface AMPacket as RadioAMPacket;
  //uses interface AMSend as RadioSend;
  uses interface SplitControl as RadioControl;
  uses interface Intercept as RadioForward;

  uses interface PacketField<uint8_t> as PacketRSSI;
}

implementation {
  //bool busy = FALSE;
  //message_t pkt;
  //uint16_t counter = 0;
  uint16_t rssi_value = 0;

  
  event void Boot.booted() {
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err){
    if (err == SUCCESS){
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    }
    else {
      call RadioControl.start();
    }

  }

  event void RadioControl.stopDone(error_t err){
  }

  
  event bool RadioForward.forward(message_t *msg, void *payload, uint8_t len){
    RSSIMsg *rssiMsg = (RSSIMsg*) payload;
    rssiMsg->rssi = rssi_value;
    
    rssi_value = (uint16_t) call PacketRSSI.get(msg);
    
    call Leds.led0Toggle();
    if ( 8 <= rssi_value && rssi_value <= 255 ){
      call Leds.led2Toggle();
      if ( 16 <= rssi_value ){
        call Leds.led1Toggle();
      }
    }
    
    return TRUE;
  }


}
