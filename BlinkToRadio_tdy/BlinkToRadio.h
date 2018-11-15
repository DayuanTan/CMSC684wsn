#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H

enum {
  AM_BLINKTORADIO = 6, //AM_BLINKTORADIO parameter indicates the AM type of the AMSenderC.
  TIMER_PERIOD_MILLI = 250
};

typedef nx_struct BlinkToRadioMsg{
  nx_uint16_t nodeid;
  nx_uint16_t counter;
}BlinkToRadioMsg;

#endif
