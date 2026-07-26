import sys
import json
from ytmusicapi import YTMusic

def get_playlist_infos(playlist_id: str):
    try:
        ytmusic = YTMusic()
        
        playlist_infos_raw = ytmusic.get_playlist(playlist_id)
        
        
        playlist_infos: dict = {}
        
        to_get = [
            "description",
            "title",
            "author",
            "tracks",
            "thumbnails",
            "years",
        ]
        for info_name in to_get:
            if info_name in playlist_infos_raw:
                playlist_infos[info_name] = playlist_infos_raw[info_name]
        
        
        print(json.dumps({
            'success': True,
            'result': playlist_infos
        }))
        
    except Exception as e:
        print(json.dumps({
            'success': False,
            'error': str(e)
        }))

if __name__ == "__main__":
    if len(sys.argv) > 1:
        playlist_id = sys.argv[1]
        get_playlist_infos(playlist_id)
    else:
        print(json.dumps({
            'success': False, 
            'error': 'No playlist ID provided'
        }))