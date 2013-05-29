ALL: callistevents

callistevents: main.m
	gcc -o callistevents -Wall -std=c99 main.m -framework EventKit -framework Foundation -lobjc 
