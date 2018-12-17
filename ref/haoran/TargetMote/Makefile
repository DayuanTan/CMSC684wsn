COMPONENT=TargetMoteAppC

INCLUDES= -I..

CFLAGS += $(INCLUDES)

ifneq ($(filter iris,$(MAKECMDGOALS)),) 
	CFLAGS += -DRF230_RSSI_ENERGY
endif

include $(MAKERULES)
