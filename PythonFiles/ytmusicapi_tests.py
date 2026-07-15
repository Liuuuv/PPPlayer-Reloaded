import sys
import json
from ytmusicapi import YTMusic
import pyperclip

## https://github.com/sigma67/ytmusicapi
## pip show ytmusicapi

def test():
    try:
        ytmusic = YTMusic(location="JP")
        
        # result = ytmusic.get_charts(country='JP')
        # result = ytmusic.get_artist("UCgwteC3ja-6FkDDHiK8diQw") ## à exploiter
        # result = ytmusic.get_artist_albums("VLOLAK5uy_lDyN1VI3OoUae9vaMJQOO8ATQ2Z0xsV0Q", ytmusic.get_artist("UC51Ub6b_RjxnC7ePn9z0FTQ").get("result")) ## does not work
        
        # useless
        # result = ytmusic.get_mood_categories()
        # result = ytmusic.get_mood_playlists("ggMPOg1uX1MxaFQ3Z0JMZkN4")
        
        # result = ytmusic.search("kawakiwoameku", filter="songs", limit=20)
        
        
        result = ytmusic.get_artist("UC7fW7oNXyRDSxMOHVJE1jrA")
        audioPlaylistId = result.get("songs").get("browseId")
        audioPlaylistId = audioPlaylistId[2:]
        print(audioPlaylistId)
        browseId = ytmusic.get_album_browse_id(audioPlaylistId)
        print(browseId)
        result = ytmusic.get_album(browseId)
        
        
        
        
        to_print = json.dumps({
            'success': True,
            'result': result
        })
        print(to_print)
        pyperclip.copy(to_print)
        
        
    except Exception as e:
        print(json.dumps({
            'success': False,
            'error': str(e)
        }))
        pyperclip.copy(str(e))

if __name__ == "__main__":
    test()