#!/bin/bash

# Start dbus-monitor to listen for screen saver signals
dbus-monitor --session "type='signal',interface='org.gnome.ScreenSaver'" | \
awk '
    # When "boolean true" is encountered and the screen is not locked yet
    /boolean true/ && !locked {
        # Get the current date in YYYY-MM-DD format
        date = strftime("%Y-%m-%d", systime())
        # Store the lock event along with the current date in locked_events array
        locked_events[date] = locked_events[date] "Screen locked on " strftime("%Y-%m-%d %H:%M:%S", systime()) "\n"
        # Set locked flag to true
        locked = 1
    }

    # When "boolean false" is encountered and the screen is locked
    /boolean false/ && locked {
        # Get the current date in YYYY-MM-DD format
        date = strftime("%Y-%m-%d", systime())
        # Store the unlock event along with the current date in unlocked_events array
        unlocked_events[date] = unlocked_events[date] "Screen unlocked on " strftime("%Y-%m-%d %H:%M:%S", systime()) "\n"
        # Set locked flag to false
        locked = 0
    }

    # At the end of processing
    END {
        # Loop through each date in locked_events array
        for (date in locked_events) {
            # Print header for lock events for the current date to the log file
            print "Lock events for " date >> "'$HOME'/lock_screen.log"
            # Print all lock events for the current date to the log file
            print locked_events[date] >> "'$HOME'/lock_screen.log"
        }

        # Loop through each date in unlocked_events array
        for (date in unlocked_events) {
            # Print header for unlock events for the current date to the log file
            print "Unlock events for " date >> "'$HOME'/lock_screen.log"
            # Print all unlock events for the current date to the log file
            print unlocked_events[date] >> "'$HOME'/lock_screen.log"
        }
    }
'
