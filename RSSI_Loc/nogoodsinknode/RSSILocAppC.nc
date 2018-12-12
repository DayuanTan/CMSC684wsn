#include <Timer.h>
#include "RSSILoc.h"
#include <RadioConfig.h>
#include "message.h"

configuration RSSILocAppC{

}

implementation {
  components MainC;
  components LedsC;
  components RSSILocC as App;
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  //components new AMSenderC(AM_RSSILOC);
  //components new AMReceiverC(AM_RSSILOC);
  
  components ParseAppC;

  //components RF230RadioC;
  components RF230ActiveMessageC;

  App.Boot -> MainC.Boot;
  App.Leds -> LedsC.Leds;
  App.Timer0 -> Timer0;
  //App.RadioPacket -> AMSenderC.Packet;
  //App.RadioAMPacket -> AMSenderC.AMPacket;
  //App.RadioSend -> AMSenderC.AMSend;
  App.RadioControl -> ActiveMessageC;
  App -> ParseAppC.RadioParse[AM_RSSIMSG];
  App.PacketRSSI -> RF230ActiveMessageC.PacketRSSI;
}
