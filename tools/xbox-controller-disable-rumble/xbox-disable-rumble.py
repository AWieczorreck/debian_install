#!/usr/bin/env python3
"""
Creates a virtual controller device that is identical to the real one,
but ignores all rumble and force feedback commands.
"""

import evdev
from evdev import UInput, ecodes
import asyncio
import sys

# to get VENDOR_ID and PRODUCT_ID run:
# $ lsusb | grep -i xbox
# > Bus 001 Device 004: ID 045e:02ea Microsoft Corp. Xbox One Controller
#                           ^     ^
#                           |     |
#                          VENDOR PRODUCT

VENDOR_ID  = 0x045e
PRODUCT_ID = 0x02ea

def find_controller():
    for path in evdev.list_devices():
        dev = evdev.InputDevice(path)
        if dev.info.vendor == VENDOR_ID and dev.info.product == PRODUCT_ID:
            return dev
    return None

async def run(real_dev):
    # copy capabilities, but remove EV_FF (Rumble) and EV_SYN
    caps = dict(real_dev.capabilities())
    caps.pop(ecodes.EV_FF, None)
    caps.pop(ecodes.EV_SYN, None)

    # creates virtual device
    virtual_dev = UInput(
        caps,
        name=real_dev.name + " (no rumble)",
        vendor=real_dev.info.vendor,
        product=real_dev.info.product,
        version=real_dev.info.version,
    )

    print(f"Real controller:    {real_dev.path} ({real_dev.name})")
    print(f"virtuel device:     {virtual_dev.device.path} ({virtual_dev.name})")
    print("rumble status: deactivate")
    print("Pre Ctrl+C to quit\n")

    # apply real controller (games see only the virtual device)
    real_dev.grab()

    try:
        async for event in real_dev.async_read_loop():
            # just ignore EV_FF Events (Rumble)
            if event.type == ecodes.EV_FF:
                continue
            # apply all other events (buttons, axies)
            virtual_dev.write_event(event)
            virtual_dev.syn()
    except asyncio.CancelledError:
        pass
    finally:
        real_dev.ungrab()
        virtual_dev.close()
        print("Beendet.")

def main():
    dev = find_controller()
    if not dev:
        print("Error: Xbox One Controller not found!")
        sys.exit(1)

    try:
        asyncio.run(run(dev))
    except KeyboardInterrupt:
        print("\nQuit.")

if __name__ == "__main__":
    main()
