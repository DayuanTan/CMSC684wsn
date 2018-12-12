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
  uint16_t counter = 0;
  uint8_t rssi_value = 0;

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
    counter++;
    //call Leds.set(counter);

    if (!busy){
      RSSIMsg* btrpkt = (RSSIMsg*)(call RadioPacket.getPayload(&pkt, sizeof(RSSIMsg)));
      btrpkt->nodeid = TOS_NODE_ID;
      btrpkt->counter = counter;
      if (call RadioSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(RSSIMsg)) == SUCCESS){
        busy = TRUE;
      }
    }
  }


  event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len){
    /*
    if (len == sizeof(RSSIMsg)){
      RSSIMsg* btrpkt = (RSSIMsg*)payload;
      call Leds.set(btrpkt->counter);
    }
    */
    rssi_value = call PacketRSSI.get(msg);
    call Leds.led0Toggle();
    if ( 8 <= rssi_value && rssi_value <= 255 ){
      call Leds.led2Toggle();
      if ( 16 <= rssi_value ){
        call Leds.led1Toggle();
      }
    }
    return msg;
  }

  event void RadioSend.sendDone(message_t* msg, error_t err){
    if(&pkt == msg){
      busy = FALSE;
    }
  }

}
