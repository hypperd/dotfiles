#!/usr/bin/env python3

import sys
import json
import os
import urllib.request

from media_monitor import MediaMonitor

def time_convert(microseconds: int) -> str:
    seconds = round(microseconds / 1000000)
    return '{:02}:{:02}'.format(seconds // 60, seconds % 60)

def write_output(output=None):
    if output is None:
        output = {
            'title': '',
            'artist': '',
            'duration': '',
            'art': '',
            'status': ''
        }

    sys.stdout.write(f"{json.dumps(output)}\n")
    sys.stdout.flush()


def on_metadata(player):
    metadata = player.props.metadata
    
    if (player.props.player_name == 'spotify') and ('mpris:trackid' in metadata.keys()) and \
            (':ad:' in metadata['mpris:trackid']):
        write_output()
        return

    output = None
    duration = None
    status = player.props.status.lower()

    if 'mpris:length' in metadata.keys():
        duration = time_convert(metadata['mpris:length'])

        if status == 'playing':
            update_eww('true') 
        else: 
            update_eww('false')
    else:
        duration=''
        update_eww('false')

    image = 'assets/music_fallback.png'

    if 'mpris:artUrl' in metadata.keys():
        art_url = player.props.metadata['mpris:artUrl']
    
        if not art_url.startswith('file://'):
            if not art_url == '':
                id = player.props.metadata['mpris:trackid'].split('/')[-1]
                image = f"{os.getenv('HOME')}/.cache/eww/{id}.jpg"

                if not os.path.exists(image):
                    try: 
                        urllib.request.urlretrieve(art_url, image) 
                    except:
                        image='assets/music_fallback.png'
        else:
            image = art_url.replace('file://','')
    
    output = {
        'title': player.get_title(),
        'artist': player.get_artist(),
        'duration': str(duration),
        'art': image,
        'status': status
    }

    write_output(output)

def update_eww(value):
    os.system(f'eww update poll_position={value}')

def main():
    status = MediaMonitor(on_metadata)

    if len(status.manager.props.player_names) == 0:
        update_eww('false')
        write_output()

    status.run()

if __name__ == '__main__':
    main()
