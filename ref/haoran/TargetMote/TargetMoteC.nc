/*
 * TargetMoteC.nc
 * Dayuan Tan & Haoran Ren
 * CMSC 684 Project - RSSI Localization
 *
 * This file contains the interfaces and events of the App on the target mote.
 * A target mote receives the messages sent by the anchors.
 * Get the RSSI value and assign to the rssi field of RssiMsg message.
 * Queue the messages before sending to the serial port to avoid conflict.
 *
 * Functions for sending messages to serial port are modified from
 * tinyOS build-in app BaseStation at tinyOS/apps/BaseStation/
 * Copyright (c) 2000-2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 */

#include "Project.h"

module TargetMoteC {
  uses interface Boot;
  uses interface Leds;
  uses interface SplitControl as RadioControl;
  uses interface SplitControl as SerialControl;
  uses interface Receive as MsgReceive[am_id_t id];
  uses interface AMSend as SerialAMSend[am_id_t id];
  uses interface PacketField<uint8_t> as PacketRSSI;
  
  uses interface AMPacket as SerialAMPacket;
  uses interface Packet as RadioPacket;
  uses interface AMPacket as RadioAMPacket;
}

implementation {
  //queue buffer to cache serial messages
  message_t serialQueueBuf[SERAIL_QUEUE_LEN];
  message_t* serialQueue[SERAIL_QUEUE_LEN];
  uint8_t queueIn, queueOut;
  bool queueBusy, queueFull;
  
  uint16_t getRssi(message_t *msg);
  message_t* receive(message_t* msg, void* payload, uint8_t len, am_id_t id);
  task void serialSendTask();
  
  void dropBlink() {
    call Leds.led2Toggle();
  }

  void failBlink() {
    call Leds.led2Toggle();
  }
  
  event void Boot.booted() {
    //initialize the serial message queue buffer
    uint8_t i;

    for (i = 0; i < SERAIL_QUEUE_LEN; i++) {
      serialQueue[i] = &serialQueueBuf[i];
    }
    queueIn = queueOut = 0;
    queueBusy = FALSE;
    queueFull = TRUE;
    
    call RadioControl.start();
    call SerialControl.start();
  }
  
  event void RadioControl.startDone(error_t error) {}
  event void SerialControl.startDone(error_t error) {
    if (error == SUCCESS) {
      queueFull = FALSE;
    }
  }
  
  event void RadioControl.stopDone(error_t error) {}
  event void SerialControl.stopDone(error_t error) {}

  event message_t* MsgReceive.receive[am_id_t id](message_t* msg, void* payload, uint8_t len) {
    return receive(msg, payload, len, id);
  }
  
  message_t* receive(message_t* msg, void* payload, uint8_t len, am_id_t id) {
    message_t* tmp = msg;
    RssiMsg* rssiMsg = (RssiMsg*) payload;
    rssiMsg->rssi = getRssi(msg);
    
    //led1 blinks when receive a message
    call Leds.led1Toggle();
    
    atomic {
      if (!queueFull) {
	tmp = serialQueue[queueIn];
	serialQueue[queueIn] = msg;
	
	queueIn = (queueIn + 1) % SERAIL_QUEUE_LEN;
	
	if (queueIn == queueOut) {
	  queueFull = TRUE;
	}
	
	if (!queueBusy) {
	  post serialSendTask();
	  queueBusy = TRUE;
	}
      }
      else {
	dropBlink();
      }
    }
    return tmp;
  }
  
  task void serialSendTask() {
    uint8_t len;
    am_id_t id;
    am_addr_t addr, src;
    message_t* msg;
    atomic {
      if (queueIn == queueOut && !queueFull) {
	queueBusy = FALSE;
	return;	
      }
    }
    msg = serialQueue[queueOut];
    len = call RadioPacket.payloadLength(msg);
    id = call RadioAMPacket.type(msg);
    addr = call RadioAMPacket.destination(msg);
    src = call RadioAMPacket.source(msg);
    call SerialAMPacket.setSource(msg, src);

    if (call SerialAMSend.send[id](addr, serialQueue[queueOut], len) == SUCCESS) {
      //led2 blinks when send a message to serial port
      call Leds.led2Toggle();
    }
    else {
      failBlink();
      post serialSendTask();
    }
  }
  
  event void SerialAMSend.sendDone[am_id_t id](message_t* msg, error_t error) {
    if (error != SUCCESS) {
      failBlink();
    }
    else {
      atomic {
	if (msg == serialQueue[queueOut]) {
	  if (++queueOut >= SERAIL_QUEUE_LEN) {
	    queueOut = 0;
	  }
	  
	  if (queueFull) {
	    queueFull = FALSE;
	  }
	}
      }
    }
    post serialSendTask();
  }
  
  uint16_t getRssi(message_t* msg) {
    if(call PacketRSSI.isSet(msg)) {
      return (uint16_t) call PacketRSSI.get(msg);
    }
    else {
      return 0xFFFF;
    }
  }

}