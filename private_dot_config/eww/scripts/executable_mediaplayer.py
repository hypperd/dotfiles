#!/usr/bin/env python3

import sys
import json
import os
import urllib.request

from media_monitor import MediaMonitor

def time_convert(microseconds: int) -> str:
    seconds = round(microseconds / 1000000)
    return '{:02}:{:02}'.format(seconds // 60, seconds % 60)


def update_eww(value: bool) -> None:
    os.system(f'eww update poll_position={str(value).lower()}')


def write_output(output: dict = None) -> None:
    if not output:
        output = {}

    sys.stdout.write(f'{json.dumps(output)}\n')
    sys.stdout.flush()


def on_metadata(player):
    metadata = player.props.metadata

    if (player.props.player_name == 'spotify') and \
            ('mpris:trackid' in metadata.keys()):
        if ':ad:' in metadata['mpris:trackid']:
            write_output()
            return

    if ('mpris:trackid' in metadata.keys() and 'mpris:artUrl'
            in metadata.keys()):
        art_url = metadata['mpris:artUrl']
        if not art_url.startswith('file://') and art_url != '':

            id = metadata['mpris:trackid'].split('/')[-1]
            image = f"{os.getenv('HOME')}/.cache/eww/{id}.jpg"

            if not os.path.exists(image):
                try:
                    urllib.request.urlretrieve(art_url, image)
                except:
                    image = 'assets/music_fallback.png'
        else:
            image = art_url
    else:
        image = 'assets/music_fallback.png'

    duration = ''
    status = player.props.status.lower()

    if 'mpris:length' in metadata.keys():
        duration = time_convert(metadata['mpris:length'])
        update_eww(status == 'playing')
    else:
        update_eww(False)

    artist = player.get_artist()

    output = {
        'title': player.get_title(),
        'artist': artist if artist != '' else 'Unknown Artist',
        'duration': duration,
        'art': image,
        'status': status
    }

    write_output(output)


def main():
    status = MediaMonitor(on_metadata, write_output)
    player_names = [player.name for player in status.manager.props.player_names]

    if status.args.player not in player_names:
        update_eww(False)
        write_output()

    status.run()


if __name__ == '__main__':
    main()
