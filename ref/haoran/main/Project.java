/*
 * Project.java
 * Dayuan Tan & Haoran Ren
 * CMSC 684 Project - RSSI Localization
 *
 * This is the JAVA code to be executed on laptop to read RSSI value from the serial port
 * and calculate the location of the target mote.
 *
 * Some methods are modified from TestSerial.java, at tinyOS/apps/tests/TestSerial
 * from TinyOS 2.x (www.tinyos.net)
 * Copyright (c) 2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 */


import java.io.IOException;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;


public class Project implements MessageListener {
  
  /** Constants*/
  
  // maximun distance with valid RSSI reading in cm
  private static final double RSSI_RANGE = 500;
  
  // pre-defined coordinates of the four anchor motes
  private static final double X_2 = 200;
  private static final double Y_2 = 200;
  
  private static final double X_3 = 200;
  private static final double Y_3 = 400;
  
  private static final double X_4 = 400;
  private static final double Y_4 = 200;
  
  private static final double X_5 = 400;
  private static final double Y_5 = 400;
  
  /* RSSI readings by distance between each anchor mote and the target mote are fitted into
   * cubic polynomial expressions with four coefficients A, B, C, and D. Let x = RSSI reading,
   * distance = A * x^3 + B * x^2 + C * x + D
   *
   */
  private static final double A_2 = -0.0036761747;
  private static final double B_2 = 0.63570119;
  private static final double C_2 = -38.805710;
  private static final double D_2 = 858.24974;
  
  private static final double A_3 = -0.0028704042;
  private static final double B_3 = 0.55857542;
  private static final double C_3 = -37.740422;
  private static final double D_3 = 897.44456;
  
  private static final double A_4 = -0.0034937663;
  private static final double B_4 = 0.65141816;
  private static final double C_4 = -41.658381;
  private static final double D_4 = 923.15524;
  
  private static final double A_5 = -0.0043624193;
  private static final double B_5 = 0.73461881;
  private static final double C_5 = -43.198265;
  private static final double D_5 = 910.64925;
  
  // number of distance read from RSSI per localization cycle
  private static final int DISTANCE_NUM = 5;
  
  // offset to avoid divide by 0
  private static final double DIVISION_OFFSET = 0.0000000001;
  
  /** Constants End*/
  
  private MoteIF moteIF;
  
  // buffer with counter & flag to store distance read from RSSI per localization cycle from each anchor mote
  private double[] disBuf2;
  private int counter2;
  private boolean bufferFull2;
  
  private double[] disBuf3;
  private int counter3;
  private boolean bufferFull3;
  
  private double[] disBuf4;
  private int counter4;
  private boolean bufferFull4;
  
  private double[] disBuf5;
  private int counter5;
  private boolean bufferFull5;
  

  
  public Project(MoteIF moteIF) {
    this.moteIF = moteIF;
    this.moteIF.registerListener(new RssiMsg(), this);
    
    disBuf2 = new double[DISTANCE_NUM];
    counter2 = 0;
    bufferFull2 = true;
    
    disBuf3 = new double[DISTANCE_NUM];
    counter3 = 0;
    bufferFull3 = true;
    
    disBuf4 = new double[DISTANCE_NUM];
    counter4 = 0;
    bufferFull4 = true;
    
    disBuf5 = new double[DISTANCE_NUM];
    counter5 = 0;
    bufferFull5 = true;    
  }
  
  public double rssiExpression(int rssi, double a, double b, double c, double d) {
    return (a * (rssi * rssi * rssi) + b * (rssi * rssi) + c * rssi + d);
  }

    
  public void messageReceived(int to, Message message) {
    RssiMsg msg = (RssiMsg) message;
    int source = message.getSerialPacket().get_header_src();
    int rssi = msg.get_rssi();
    
    System.out.println("RSSI:\t" + source + "\t" + rssi);
    
    // read DISTANCE_NUM distances and average them, store at disBuf?[0]
    switch (source) {
      case 2:
	if (!bufferFull2) {
	  // stop reading immediately when seeing the DISTANCE_NUMth reading
	  if (counter2 == DISTANCE_NUM - 1) {
	    bufferFull2 = true;
	  }
	  disBuf2[counter2] = rssiExpression(rssi, A_2, B_2, C_2, D_2);
	  counter2 += 1;
	  if (counter2 == DISTANCE_NUM) {
	    double sum = 0;
	    for (int i = 0; i < DISTANCE_NUM; i++) {
	      sum += disBuf2[i];
	    }
	    counter2 = 0;
	    disBuf2[0] = sum / DISTANCE_NUM;
	  }
	}
	break;
	
      case 3:
	if (!bufferFull3) {
	  // stop reading immediately when seeing the DISTANCE_NUMth reading
	  if (counter3 == DISTANCE_NUM - 1) {
	    bufferFull3 = true;
	  }
	  disBuf3[counter3] = rssiExpression(rssi, A_3, B_3, C_3, D_3);
	  counter3 += 1;
	  if (counter3 == DISTANCE_NUM) {
	    double sum = 0;
	    for (int i = 0; i < DISTANCE_NUM; i++) {
	      sum += disBuf3[i];
	    }
	    counter3 = 0;
	    disBuf3[0] = sum / DISTANCE_NUM;
	  }
	}
	break;
	
      case 4:
	if (!bufferFull4) {
	  // stop reading immediately when seeing the DISTANCE_NUMth reading
	  if (counter4 == DISTANCE_NUM - 1) {
	    bufferFull4 = true;
	  }
	  disBuf4[counter4] = rssiExpression(rssi, A_4, B_4, C_4, D_4);
	  counter4 += 1;
	  if (counter4 == DISTANCE_NUM) {
	    double sum = 0;
	    for (int i = 0; i < DISTANCE_NUM; i++) {
	      sum += disBuf4[i];
	    }
	    counter4 = 0;
	    disBuf4[0] = sum / DISTANCE_NUM;
	  }
	}
	break;
	
      case 5:
	if (!bufferFull5) {
	  // stop reading immediately when seeing the DISTANCE_NUMth reading
	  if (counter5 == DISTANCE_NUM - 1) {
	    bufferFull5 = true;
	  }
	  disBuf5[counter5] = rssiExpression(rssi, A_5, B_5, C_5, D_5);
	  counter5 += 1;
	  if (counter5 == DISTANCE_NUM) {
	    double sum = 0;
	    for (int i = 0; i < DISTANCE_NUM; i++) {
	      sum += disBuf5[i];
	    }
	    counter5 = 0;
	    disBuf5[0] = sum / DISTANCE_NUM;
	  }
	}
	break;
	
      default:
	break;
    }
  }
  
  /* solve for the position of the target mote with the equations
   * a1 * x + b1 * y = c1
   * a2 * x + b2 * y = c2
   *
   */
  public Coordinate trilateration(double r1, double x1, double y1, double r2, double x2, double y2, double r3, double x3, double y3) {
    double a1 = 2 * (x3 - x1);
    double b1 = 2 * (y3 - y1);
    double c1 = (r1 * r1 - r3 * r3) - (x1 * x1 - x3 * x3) - (y1 * y1 - y3 * y3);
    
    double a2 = 2 * (x3 - x2);
    double b2 = 2 * (y3 - y2);
    double c2 = (r2 * r2 - r3 * r3) - (x2 * x2 - x3 * x3) - (y2 * y2 - y3 * y3);
    
    double x = (c1 * b2 - c2 * b1) / ((a1 * b2 - a2 * b1) + DIVISION_OFFSET);
    double y;
    if (b1 != 0) {
      y = (c1 - a1 * x) / b1;
    }
    else {
      y = (c2 - a2 * x) / b2;
    }
    
    Coordinate position = new Coordinate(x, y);
    return position;
  }
  
  public void localization() {
    bufferFull2 = false;
    bufferFull3 = false;
    bufferFull4 = false;
    bufferFull5 = false;
    
    while (!bufferFull2 || !bufferFull3 || !bufferFull4 || !bufferFull5) {/*wait for reading*/}

    double r2 = disBuf2[0];
    double r3 = disBuf3[0];
    double r4 = disBuf4[0];
    double r5 = disBuf5[0];
    
    System.out.println((int) r2 + "\t" + (int) r3 + "\t" + (int) r4 + "\t" + (int) r5);
    
    /*
    // do trilateration localization of the four triangles form by the four anchor motes, get the average
    if (r2 <= RSSI_RANGE && r3 <= RSSI_RANGE && r4 <= RSSI_RANGE && r5 <= RSSI_RANGE) {
    
      Coordinate p1 = trilateration(r2, X_2, Y_2, r3, X_3, Y_3, r4, X_4, Y_4);
      Coordinate p2 = trilateration(r2, X_2, Y_2, r3, X_3, Y_3, r5, X_5, Y_5);
      Coordinate p3 = trilateration(r2, X_2, Y_2, r4, X_4, Y_4, r5, X_5, Y_5);
      Coordinate p4 = trilateration(r3, X_3, Y_3, r4, X_4, Y_4, r5, X_5, Y_5);
    
      double x = (p1.m_x + p2.m_x + p3.m_x + p4.m_x) / 4;
      double y = (p1.m_y + p2.m_y + p3.m_y + p4.m_y) / 4;
    
      System.out.println("Position:\tx: " + (int) x + "\ty: " + (int) y);
    }
    else {
      System.out.println("Out of RSSI range!");
    }*/
    
    Coordinate p1 = trilateration(r2, X_2, Y_2, r3, X_3, Y_3, r4, X_4, Y_4);
    Coordinate p2 = trilateration(r2, X_2, Y_2, r3, X_3, Y_3, r5, X_5, Y_5);
    Coordinate p3 = trilateration(r2, X_2, Y_2, r4, X_4, Y_4, r5, X_5, Y_5);
    Coordinate p4 = trilateration(r3, X_3, Y_3, r4, X_4, Y_4, r5, X_5, Y_5);
    
    double x = (p1.m_x + p2.m_x + p3.m_x + p4.m_x) / 4;
    double y = (p1.m_y + p2.m_y + p3.m_y + p4.m_y) / 4;
    
    System.out.println("Position:\tx: " + (int) x + "\ty: " + (int) y);
    
  }
  
  private static void usage() {
    System.err.println("usage: Proejct [-comm <source>]");
  }
  
  public static void main(String[] args) throws Exception {
    String source = null;
    if (args.length == 2) {
      if (!args[0].equals("-comm")) {
	usage();
	System.exit(1);
      }
      source = args[1];
    }
    else if (args.length != 0) {
      usage();
      System.exit(1);
    }
    
    PhoenixSource phoenix;
    
    if (source == null) {
      phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
    }
    else {
      phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
    }

    MoteIF mif = new MoteIF(phoenix);
    Project serial = new Project(mif);
    
    while (true) {
      serial.localization();
    }
  }


}
