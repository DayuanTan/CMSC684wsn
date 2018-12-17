/*
 * AnchorMoteAppC.nc
 * Dayuan Tan & Haoran Ren
 * CMSC 684 Project - RSSI Localization
 *
 * This file contains the components of the App on the anchor motes.
 * An anchor mote keeps broadcasting arbitrary messages
 *
 */

#include "Project.h"

configuration AnchorMoteAppC {}

implementation {
  components MainC;
  components ActiveMessageC;
  components new AMSenderC(AM_RSSIMSG) as MsgSender;
  components new TimerMilliC() as AnchorTimer;

  components AnchorMoteC as App;

  App.Boot -> MainC;
  App.RadioControl -> ActiveMessageC;
  App.MsgSend -> MsgSender;
  App.AnchorTimer -> AnchorTimer;
}