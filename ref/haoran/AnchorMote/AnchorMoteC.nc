/*
 * AnchorMoteC.nc
 * Dayuan Tan & Haoran Ren
 * CMSC 684 Project - RSSI Localization
 *
 * This file contains the interfaces and events of the App on the anchor motes.
 * An anchor mote keeps broadcasting arbitrary messages.
 *
 */

#include "Project.h"

module AnchorMoteC {
  uses interface Boot;
  uses interface SplitControl as RadioControl;
  uses interface AMSend as MsgSend;
  uses interface Timer<TMilli> as AnchorTimer;
  
}

implementation {
  message_t msg;
  
  event void Boot.booted() {
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t result) {
    call AnchorTimer.startPeriodic(ANCHOR_MSG_INTERVAL_MS);
  }

  event void RadioControl.stopDone(error_t result) {}


  event void AnchorTimer.fired() {
    call MsgSend.send(AM_BROADCAST_ADDR, &msg, sizeof(RssiMsg));    
  }

  event void MsgSend.sendDone(message_t* m, error_t error) {}
}
