#!/usr/bin/env bash

./server &
sleep 2
./client
#delay for server to send spans
sleep 10
kill %1
