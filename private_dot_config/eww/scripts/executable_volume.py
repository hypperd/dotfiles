#!/usr/bin/env python3

import asyncio
import signal
import sys
from contextlib import suppress
import pulsectl_asyncio
import fcntl
import os

import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning) 
volume_old=-1



#fileno = sys.stdout.fileno()
#fcntl.fcntl(fileno, fcntl.F_GETFL, os.O_NONBLOCK)

async def listen():

    async with pulsectl_asyncio.PulseAsync('event-printer') as pulse:
        default_sink = await get_default_sink(pulse)
        default_source = await get_default_source(pulse)

        await write_volume_source(pulse, default_source.name)
        await write_volume(pulse, default_sink.name)
        async for event in pulse.subscribe_events('all'):

            if event.t != 'change':
                continue

            match event.facility:
                case 'sink_input':
                    default_sink = await get_default_sink(pulse)
                    await write_volume(pulse, default_sink.name)
                case 'sink':
                    if event.index == default_sink.index:
                        await write_volume(pulse, default_sink.name)
                case 'source_output':
                    #default_sink = await get_default_sink(pulse)
                    default_source = await get_default_source(pulse)
                    #await write_volume(pulse, default_sink.name)
                    await write_volume_source(pulse, default_source.name)
                case 'source':
                    if event.index == default_source.index:
                        await write_volume_source(pulse, default_source.name)
                case default:
                    continue

async def get_default_sink(pulse: pulsectl_asyncio.PulseAsync):
    server_info = await pulse.server_info();
    sink = await pulse.get_sink_by_name(server_info.default_sink_name)
    return sink

async def get_default_source(pulse: pulsectl_asyncio.PulseAsync):
    server_info = await pulse.server_info();
    source = await pulse.get_source_by_name(server_info.default_source_name)
    return source

async def write_volume(pulse, name):
    sink = await pulse.get_sink_by_name(name)
    volume = await pulse.volume_get_all_chans(sink)
    
    global volume_old
    if volume_old != volume:
        volume_old = volume
        sys.stdout.write(str(round(volume * 100)) + '\n')
        sys.stdout.flush()

async def write_volume_source(pulse, name):
    sink = await pulse.get_source_by_name(name)
    volume = await pulse.volume_get_all_chans(sink)
    file = os.open('/home/hypper/.config/eww/test',os.O_WRONLY | os.O_NONBLOCK)
    os.write(file, str(round(volume * 100)).encode() + '\n'.encode())
    #os.flush(file)
    os.close(file)
    #sys.stderr.write(str(round(volume * 100)) + '\n')
    #sys.stderr.flush()


async def main():
    # Run listen() coroutine in task to allow cancelling it
    listen_task = asyncio.create_task(listen())

    # register signal handlers to cancel listener when program is asked to terminate
    for sig in (signal.SIGTERM, signal.SIGHUP, signal.SIGINT):
        loop.add_signal_handler(sig, listen_task.cancel)
    # Alternatively, the PulseAudio event subscription can be ended by breaking/returning from the `async for` loop

    with suppress(asyncio.CancelledError):
        await listen_task

# Run event loop until main_task finishes
loop = asyncio.get_event_loop()
loop.run_until_complete(main())