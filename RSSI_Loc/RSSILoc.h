#ifndef RSSILOC_H
#define RSSILOC_H

enum {
  AM_RSSILOC = 6, //AM_RSSILOC parameter indicates the AM type of the AMSenderC.
  TIMER_PERIOD_MILLI = 250,
  
  AM_RSSIMSG = 10
};

typedef nx_struct RSSIMsg{
  nx_uint16_t nodeid;
  nx_uint16_t rssi_from_nodeid;
  nx_uint16_t rssi_to_nodeid;
  nx_uint16_t rssi;
}RSSIMsg;

#endif
