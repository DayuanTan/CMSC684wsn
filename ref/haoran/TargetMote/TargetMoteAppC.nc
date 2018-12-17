/*
 * TargetMoteAppC.nc
 * Dayuan Tan & Haoran Ren
 * CMSC 684 Project - RSSI Localization
 *
 * This file contains the components of the App on the target mote.
 * A target mote receives the messages sent by the anchors.
 * Get the RSSI value and assign to the rssi field of RssiMsg message.
 * Queue the messages before sending to the serial port to avoid conflict.
 *
 */

#include "Project.h"
#include "message.h"

configuration TargetMoteAppC {}

implementation {
  components MainC;
  components LedsC;
  components ActiveMessageC;
  components SerialActiveMessageC;
  components RF230ActiveMessageC;
  
  components TargetMoteC as App;
  
  App.Boot -> MainC;
  App.Leds -> LedsC.Leds;
  App.RadioControl -> ActiveMessageC;
  App.SerialControl -> SerialActiveMessageC;
  App.MsgReceive -> ActiveMessageC.Receive;
  App.SerialAMSend -> SerialActiveMessageC;
  App -> RF230ActiveMessageC.PacketRSSI;
  
  App.SerialAMPacket -> SerialActiveMessageC;
  App.RadioPacket -> ActiveMessageC;
  App.RadioAMPacket -> ActiveMessageC;
}