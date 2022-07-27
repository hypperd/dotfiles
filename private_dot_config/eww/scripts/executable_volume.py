#!/usr/bin/env python3

import asyncio
import signal
import sys
import pulsectl_asyncio
import pulsectl
import os
from contextlib import suppress

async def listen():
    async with pulsectl_asyncio.PulseAsync('eww volume monitor') as pulse:
        default_sink = await get_default_sink(pulse)
        default_source = await get_default_source(pulse)

        await write_volume_source(pulse, default_source.name)
        await write_volume_sink(pulse, default_sink.name)

        async for event in pulse.subscribe_events('all'):

            if event.t != 'change':
                continue

            match event.facility:
                case 'server':
                    default_source = await get_default_source(pulse)
                    default_sink = await get_default_sink(pulse)
                    await write_volume_sink(pulse, default_sink.name)
                    await write_volume_source(pulse, default_source.name)
                case 'sink':
                    if event.index == default_sink.index:
                        await write_volume_sink(pulse, default_sink.name)
                case 'source':
                    if event.index == default_source.index:
                        await write_volume_source(pulse, default_source.name)
                case _:
                    continue

async def get_default_sink(pulse: pulsectl_asyncio.PulseAsync):
    server_info = await pulse.server_info();
    sink = await pulse.get_sink_by_name(server_info.default_sink_name)
    return sink

async def get_default_source(pulse: pulsectl_asyncio.PulseAsync):
    server_info = await pulse.server_info();
    source = await pulse.get_source_by_name(server_info.default_source_name)
    return source

async def write_volume_sink(pulse, name):
    sink = await pulse.get_sink_by_name(name)
    volume = await pulse.volume_get_all_chans(sink)
    
    global sink_volume_old
    if sink_volume_old != volume:
        sink_volume_old = volume
        sys.stdout.write(f"{volume * 100}\n")
        sys.stdout.flush()

async def write_volume_source(pulse, name):
    sink = await pulse.get_source_by_name(name)
    volume = await pulse.volume_get_all_chans(sink)
    
    global source_volume_old
    if source_volume_old != volume:
        source_volume_old = volume
        with open(fifo, 'w') as file:
            file.write(f"{volume * 100}\n")
            file.flush()


async def main_task():
    # Run listen() coroutine in task to allow cancelling it
    listen_task = asyncio.create_task(listen())

    # register signal handlers to cancel listener when program is asked to terminate
    for sig in (signal.SIGTERM, signal.SIGHUP, signal.SIGINT):
        loop.add_signal_handler(sig, listen_task.cancel)

    with suppress(asyncio.CancelledError):
        await listen_task

fifo = f"{os.getenv('XDG_RUNTIME_DIR')}/eww.pipe"
if not os.path.exists(fifo):
    os.mkfifo(fifo)

source_volume_old = None
sink_volume_old = None
# Run event loop until main_task finishes
loop = asyncio.new_event_loop()
loop.run_until_complete(main_task())