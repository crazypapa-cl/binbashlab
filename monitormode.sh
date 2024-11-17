#!/bin/bash

# Especifica el nombre de tu interfaz de red WiFi
INTERFACE="wlxe84e0606d725"

# Poner la interfaz en modo monitor
ifconfig $INTERFACE down
iwconfig $INTERFACE mode monitor
ifconfig $INTERFACE up
