#!/usr/bin/env python

import sys
import json
import signal
from media_monitor import PlayerManager
from gi.repository.Playerctl import PlaybackStatus


def signal_handler(sig, frame):
    on_empty()
    sys.exit(0)


def write_output(player, text: str) -> None:
    player_name = player.props.player_name

    output = {
        'text': text,
        'tooltip': text.replace('&', '&amp;'),
        'class': f'custom-{player_name}',
        'alt': player_name
    }

    sys.stdout.write(f'{json.dumps(output)}\n')
    sys.stdout.flush()


def on_metadata(player, metadata) -> None:
    artist = player.get_artist()
    title = player.get_title()

    if artist and title:
        track_info = f'{artist} - {title}'
    else:
        track_info = title

    if not track_info:
        return

    if player.props.playback_status != PlaybackStatus.PAUSED:
        track_info = f' {track_info}'
    else:
        track_info = f" {track_info}"

    write_output(player, track_info)


def on_empty():
    sys.stdout.write('\n')
    sys.stdout.flush()


def main() -> None:
    manager = PlayerManager(selected_player="spotify")

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)

    manager.run(on_empty, on_metadata)


if __name__ == '__main__':
    main()
