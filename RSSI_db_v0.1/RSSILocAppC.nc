#include <Timer.h>
#include "RSSILoc.h"
#include <RadioConfig.h>

configuration RSSILocAppC{

}

implementation {
  components MainC;
  components LedsC;
  components RSSILocC as App;
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components new AMSenderC(AM_RSSILOC);
  components new AMReceiverC(AM_RSSILOC);

  components RF230RadioC;

  App.Boot -> MainC.Boot;
  App.Leds -> LedsC.Leds;
  App.Timer0 -> Timer0;
  App.RadioPacket -> AMSenderC.Packet;
  App.RadioAMPacket -> AMSenderC.AMPacket;
  App.RadioSend -> AMSenderC.AMSend;
  App.RadioControl -> ActiveMessageC;
  App.RadioReceive -> AMReceiverC;
  App.PacketRSSI -> RF230RadioC.PacketRSSI;
}
