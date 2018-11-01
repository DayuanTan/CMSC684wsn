#include <Timer.h>
#include "HW3.h"

configuration HW3AppC {
}

implementation {
    components MainC;
    components LedsC;
    components HW3C as App;
    components new TimerMilliC() as Timer0;
    components ActiveMessageC;
    components new AMSenderC(AM_HW3);
    components new AMReceiverC(AM_HW3);
    components LocalTimeMilliC as localTimer;

    App.Boot -> MainC.Boot;
    App.Leds -> LedsC.Leds;
    App.Timer0 -> Timer0;
    App.RadioPacket -> AMSenderC.Packet;
    App.RadioAMPacket -> AMSenderC.AMPacket;
    App.RadioSend -> AMSenderC.AMSend;
    App.RadioReceive -> AMReceiverC;
    App.RadioControl -> ActiveMessageC;
    App.LocalTime -> localTimer;

}
