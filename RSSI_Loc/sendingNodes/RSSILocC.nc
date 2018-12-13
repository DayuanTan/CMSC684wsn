#include <Timer.h>
#include "RSSILoc.h"
#include <RadioConfig.h>

module RSSILocC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;

  uses interface Packet as RadioPacket;
  uses interface AMPacket as RadioAMPacket;
  uses interface AMSend as RadioSend;
  uses interface SplitControl as RadioControl;

}

implementation {
  bool busy = FALSE;
  message_t pkt;

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

  
  event void Timer0.fired() {
    if (!busy){
      RSSIMsg* btrpkt = (RSSIMsg*)(call RadioPacket.getPayload(&pkt, sizeof(RSSIMsg)));
      btrpkt->nodeid = (uint16_t)TOS_NODE_ID;
      btrpkt->rssi_from_nodeid = (uint16_t)TOS_NODE_ID;
      btrpkt->rssi_to_nodeid = (uint16_t)1; //1 as unknown node which needs to be located.
      btrpkt->rssi = (uint16_t)(0);
      
      if (btrpkt->rssi_to_nodeid == (uint16_t)1){
	call Leds.led1Toggle();
      }
      if (btrpkt->rssi == (uint16_t)(0) ){
	call Leds.led2Toggle();
      }

      if (call RadioSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(RSSIMsg)) == SUCCESS){
        busy = TRUE;
	call Leds.led0Toggle();
      }
    }
  }



  event void RadioSend.sendDone(message_t* msg, error_t err){
    if(&pkt == msg){
      busy = FALSE;
    }
  }

}
