/*
 * Project.h
 * Dayuan Tan & Haoran Ren
 * CMSC 684 Project - RSSI Localization
 *
 * This file is the header of the project.
 * It contains the constants and message data format of the project.
 *
 */

#ifndef PROJECT_H_
#define PROJECT_H_

enum{
  AM_RSSIMSG = 10,	/*active message ID*/
  ANCHOR_MSG_INTERVAL_MS = 250,	/*interval between messages that anchors send out*/
  SERAIL_QUEUE_LEN = 16,	/*the length of serial message queue*/
};

typedef nx_struct RssiMsg{
  nx_int16_t rssi;
} RssiMsg;

#endif
