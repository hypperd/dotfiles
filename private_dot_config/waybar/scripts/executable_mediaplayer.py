#!/usr/bin/env python3

import sys
import json
import os
import time
from media_monitor import MediaMonitor


def write_output(player, text: str) -> None:
    if not text:
        return

    output = {
        'text': text,
        'tooltip': text.replace('&', '&amp;'),
        'class': f'custom-{player.props.player_name}',
        'alt': player.props.player_name
    }

    sys.stdout.write(f'{json.dumps(output)}\n')
    sys.stdout.flush()


def on_metadata(player) -> None:
    metadata = player.props.metadata
    player_name = player.props.player_name

    if (player_name == 'spotify') and ('mpris:trackid' in metadata.keys()) \
            and (':ad:' in metadata['mpris:trackid']):
        track_info = 'AD PLAYING'
    elif player.get_artist() and player.get_title():
        track_info = f'{player.get_artist()} - {player.get_title()}'
    else:
        track_info = player.get_title()

    if player.props.status != 'Playing' and track_info:
        track_info = f' {track_info}'

    # This avoid waybar not show text in module. Spotify bug?
    if track_info == '' and player_name == 'spotify':
        time.sleep(2)
        os.execv(sys.argv[0], sys.argv)

    write_output(player, track_info)


def on_writer_empty():
    sys.stdout.write('\n')
    sys.stdout.flush()


def main() -> None:
    status = MediaMonitor(on_metadata, on_writer_empty)
    status.run()


if __name__ == '__main__':
    main()
