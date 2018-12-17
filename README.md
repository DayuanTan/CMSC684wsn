# CMSC684wsn

*The environment I used is a **`Fedora Virtual Machine`** which has a TinyOS in it. (BTW, I changed to an **`Ubuntu VM`** which has a TinyOS on it since this Fedora has some JAVA env problems. )*

*If you want to get a copy of that VMs form me, plz leave a message by creating an issue.*

## HW3 


HW3 is an example. There are 27 nodes in the WSN, transmitting and receiving messages. A topology is implemented. It uses TOSSIM to do the simulations.

Use this commond to compile:
```
make micaz sim
```

Make sure you change *simulate.py* to be executable.

Then this commond to run the simulation:
```
./simulate.py > HW3Output.txt
```

## BlinkToRadio

It implements the function to transmit and receive simple-structure messages between motes. 

There are only two elements in the message, node_id and the number value of that node's counter.

The structure of the message is:
```
typedef nx_struct BlinkToRadioMsg{
  nx_uint16_t nodeid;
  nx_uint16_t counter;
}BlinkToRadioMsg;
```

***If you want to run it:***

Put this file under the directory `/tinyos-main/apps/`.

Use this commond to compile:
```
make iris
```
Connect your programming board to computer. To check whether it is connected correctly, use this commond 
```
ls -l /dev/ttyUSB*
```
The result should be 
```
/dev/ttyUSB0
/dev/ttyUSB1
```


Use this commond to burn the code into mote:
```
make iris install,1 mib520,/dev/ttyUSB0
```

> "1" is the id I assigned to the mote. "mib520" is the programming board (MIB250CB) I used to house iris mote XM2110 CB.


*Reference: I did this part following this guide: http://tinyos.stanford.edu/tinyos-wiki/index.php/Mote-mote_radio_communication.*


## Transceive_RSSI

This is a upgrade based on ***BlinkToRadio***, which implements transmitting and receiving messages between motes. The added function in ***Transceive_RSSI*** is: 
  1. After recerving a message packet, get the RSSI value of it; 
  2. And then set Led's second light bright. (There are three lights on iris mote XM2110 CB).
  
> FYI, "`call Leds.set(1);`" brights the lowest digit light, "`call Leds.set(2);`" brights the lowest but one digit light.

*Reference:*

*1. Interface of Led: https://github.com/tinyos/tinyos-main/blob/master/tos/interfaces/Leds.nc  http://www.btnode.ethz.ch/static_docs/tinyos-2.x/nesdoc/mica2/ihtml/tos.interfaces.Leds.html*

*2. Tell us what interface and component should be used for iris mote: http://mail.millennium.berkeley.edu/pipermail/tinyos-help/2011-April/050552.html.* 

  *Most important sentence is this one: "Look at the RF230ActiveMessageC component, and there you will see the PacketRSSI interface."*
  
*3. Interfacehttps: https://github.com/tinyos/tinyos-main/blob/master/tos/lib/rfxlink/util/PacketField.nc*

*4. Even I don't think it's useful, but maybe useful for you. An example for get RSSI in CC1000. http://tinyos.stanford.edu/tinyos-wiki/index.php/Rssi_Demo*

## RSSI_dist database v0.1

***RSSI_dbv0.1***, based on the code of <a href="README.md#Transceive_RSSI">Transceive_RSSI</a>, change `Leds.set()` to `Leds.led0Toggle()` to test and collect the relationship between RSSI value (range form uint 0 to 255) and distance, we got following value pairs:

|Distance|RSSI value|
|:-:|:-:|
|5cm|20|
|15cm|16|
|10m|8|


## TestSerial: Communication between mote and PC through serial port

*From now on, I moved to a **`Ubuntu virtual machine`** which has TinyOS 2.1.2, since the Fedora VM I used has some JAVA env problems and I think it may take me long time to fix it.*  

This part is trying to communicate between motes and PC through USB wires. 

Go to *`~/tinyos-2_1_2/apps/tests/TestSerial`* and install the sample application *`TestSerial`* (in *ref* directory) on mote, which is used to communication through serial port. Then use the *corresponding JAVA application* that communication with it over the serial port, which is also located in the same directory and has already been compiled. 

Use these commands:

```
ls -l /dev/ttyUSB*
```
The result should be 
```
/dev/ttyUSB0    //MIB520 has two ports, this one is used to burn code to iris mote.
/dev/ttyUSB1    //This one is used for serial communication wiht the program running on the iris mote.
```
```
make iris
```
```
make iris install,1 mib520,/dev/ttyUSB0  //Used to burn the code into mote
```
```
java TestSerial -comm serial@/dev/ttyUSB1:iris //Used to run the JAVA app 
                                                 and commu with mote through serial port.
```

Note: Different mote and board may have different serial port and speed. For iris mote and mib520 board they should be *`/dev/ttyUSB1`* and *`iris (or 57600)`*. 

*Reference:*

*http://tinyos.stanford.edu/tinyos-wiki/index.php/Mote-PC_serial_communication_and_SerialForwarder_(TOS_2.1.1_and_later)*

## BaseStation

Mote 1 with program **Transceive_RSSI**, mote 2 with program **BaseStation** (in *ref* directory) and also connected to PC through USB. Mote 2 receives the packet form mote 1 and send it to serial port/PC. 

Use this command to print the received packet on PC:
```
java net.tinyos.tools.Listen -comm serial@/dev/ttyUSB1:iris
```
The result is printed using hex. The meaning of it refers to reference link, which is as the same as **TestSerial**'s.

## RSSI_Loc

Try to implement RSSI localizatin algorithm.

Define the message struct in `RSSILoc.h`:
```
typedef nx_struct RSSIMsg{
  nx_uint16_t nodeid;
  nx_uint16_t rssi_from_nodeid;
  nx_uint16_t rssi_to_nodeid;
  nx_uint16_t rssi;
}RSSIMsg;
```

Assume Beacon node (or sending node) id is 2, 3, 4 or 5, Unknown node (or forwarding node) id is 1, sink node id is 0.

***sendingNodes***: Work as **Beacon Nodes**. Send packets to Unknown Node, or forwarding node. 

Set nodeid=2, 3, 4 or 5 (itself), rssi_from_nodeid=2, 3, 4 or 5, rssi_to_nodeid=1, rssi=-1.

```
make iris intall,2 mib520,/dev/ttyUSB0  // for node 2
make iris intall,3 mib520,/dev/ttyUSB0  // for node 3
make iris intall,4 mib520,/dev/ttyUSB0  // for node 4
```

***forwardingNodes***: Work as **Unknown Node**, forwaridng pakcets received form Beacon nodes to sink node.

Check rssi_to_nodeid==1, rssi>0. Set nodeid=1 (itself).
```
make iris intall,1 mib520,/dev/ttyUSB0  // for node 1, as unknown node.
```

***sinkNode***:Work as **sink node**. Receive packets forwarded by Unknown Node, originally form Beacon Nodes. Send it to PC.

Check nodeid==1(forwarding node), rssi_from_nodeid==2, 3, 4 or 5, rssi_to_nodeid==1, rssi>0.
```
make iris intall,0 mib520,/dev/ttyUSB0  // for node 0, as sink node.
```

*Reference:*

*http://tinyos.stanford.edu/tinyos-wiki/index.php/Mote-PC_serial_communication_and_SerialForwarder_(TOS_2.1.1_and_later)*

*RssiDemo files, which is a sample for RSSI collection. Maybe from the offical.*
