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
  uses interface Receive as RadioReceive;

  uses interface PacketField<uint8_t> as PacketRSSI;
}

implementation {
  bool busy = FALSE;
  message_t pkt;
  RSSIMsg* btrpkt;
  uint16_t rssi_value = 0;
  
  am_addr_t dest ;
  am_addr_t source ;

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
      
      btrpkt->nodeid = (uint16_t)TOS_NODE_ID;

      if (call RadioSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(RSSIMsg)) == SUCCESS){ //forward to sink node.
	busy = TRUE;
	call Leds.led0Toggle();
      }
	

    }
  }
 


  event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len){
    btrpkt = (RSSIMsg*)payload;

    if (btrpkt->rssi_to_nodeid == (uint16_t)1 ){//As unknown node which needs to be located, TOS_NODE_ID should be 1, forwarding rssi value it received to sink node.
      call Leds.led1Toggle();
    }
    
    rssi_value = call PacketRSSI.get(msg);
    if (rssi_value > 0){
      call Leds.led2Toggle();
    }

      
    return msg;
  }

  event void RadioSend.sendDone(message_t* msg, error_t err){
    if(&pkt == msg){
      busy = FALSE;
    }
  }

}
