#!/bin/sh

{
  IP_ADDRESS=$(curl ipinfo.io/ip)
} &> /dev/null

echo {\"ip\":\""$IP_ADDRESS"\"}