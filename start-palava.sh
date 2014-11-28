#!/bin/sh

echo "Building Palava Portal Web Application"
cd /home/palava/portal
export PALAVA_BASE_ADDRESS="https://example.com"
export PALAVA_RTC_ADDRESS="wss://example.com/info/machine"
bundle exec middleman build

echo "Starting Supervisor"
/usr/bin/supervisord
