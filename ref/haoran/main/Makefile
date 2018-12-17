all: Project.class

RssiMsg.class: RssiMsg.java
	javac $<

Coordinate.class: Coordinate.java
	javac $<

Project.class: Project.java RssiMsg.java Coordinate.java
	javac $^

RssiMsg.java: ../Project.h
	mig java -target=null -java-classname=RssiMsg $< RssiMsg -o $@
