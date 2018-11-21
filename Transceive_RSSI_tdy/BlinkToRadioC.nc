#include <Timer.h>
#include "BlinkToRadio.h"
#include <RadioConfig.h>

module BlinkToRadioC {
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
      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)(call RadioPacket.getPayload(&pkt, sizeof(BlinkToRadioMsg)));
      btrpkt->nodeid = TOS_NODE_ID;
      btrpkt->counter = counter;
      if (call RadioSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS){
        busy = TRUE;
      }
    }
  }


  event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len){
    /*
    if (len == sizeof(BlinkToRadioMsg)){
      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
      call Leds.set(btrpkt->counter);
    }
    */
    if (call PacketRSSI.get(msg) != 100){
      call Leds.set(2);
    }
    return msg;
  }

  event void RadioSend.sendDone(message_t* msg, error_t err){
    if(&pkt == msg){
      busy = FALSE;
    }
  }

}
