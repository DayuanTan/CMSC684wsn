#include <Timer.h>
#include "BlinkToRadio.h"

configuration BlinkToRadioAppC{

}

implementation {
  components MainC;
  components LedsC;
  components BlinkToRadioC as App;
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components new AMSenderC(AM_BLINKTORADIO);
  components new AMReceiverC(AM_BLINKTORADIO);

  App.Boot -> MainC.Boot;
  App.Leds -> LedsC.Leds;
  App.Timer0 -> Timer0;
  App.RadioPacket -> AMSenderC.Packet;
  App.RadioAMPacket -> AMSenderC.AMPacket;
  App.RadioSend -> AMSenderC.AMSend;
  App.RadioControl -> ActiveMessageC;
  App.RadioReceive -> AMReceiverC;
}
