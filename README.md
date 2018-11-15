# CMSC684wsn

## HW3 

HW3 is an example. There are 27 nodes in the WSN, transmitting and receiving messages. It uses TOSSIM to do the simulations.

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

It implements the function to transmit and receive a simple message between motes. 

Put this file under the directory `/tinyos-main/apps/`.

Use this commond to compile:
```
make iris
```
Connect your iris mote broad to computer, check whether it is connected correctly, using this commond 
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

Reference: I did this part following this guide: http://tinyos.stanford.edu/tinyos-wiki/index.php/Mote-mote_radio_communication.

