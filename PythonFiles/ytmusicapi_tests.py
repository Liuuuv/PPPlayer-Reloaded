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
        # result = ytmusic.get_artist("UCOeG6YTLjO7JApWPl_q0D-A") ## à exploiter
        # result = ytmusic.get_artist_albums("VLOLAK5uy_lDyN1VI3OoUae9vaMJQOO8ATQ2Z0xsV0Q", ytmusic.get_artist("UC51Ub6b_RjxnC7ePn9z0FTQ").get("result")) ## does not work
        
        # useless
        # result = ytmusic.get_mood_categories()
        # result = ytmusic.get_mood_playlists("ggMPOg1uX1MxaFQ3Z0JMZkN4")
        
        # result = ytmusic.search("kawakiwoameku", filter="songs", limit=20)
        
        
        ## issue: only displays the first song :(
        # result = ytmusic.get_artist("UCOeG6YTLjO7JApWPl_q0D-A")
        # audioPlaylistId = result.get("songs").get("browseId")
        # audioPlaylistId = audioPlaylistId[2:]
        # print(audioPlaylistId)
        # browseId = ytmusic.get_album_browse_id(audioPlaylistId)
        # print(browseId)
        # result = ytmusic.get_album(browseId)
        
        ## solution: treat it like a playlist :)
        # result = ytmusic.get_artist("UCOeG6YTLjO7JApWPl_q0D-A")
        # audioPlaylistId = result.get("songs").get("browseId")
        # result = ytmusic.get_playlist(audioPlaylistId)
        
        result = ytmusic.get_playlist("PLd-zJRILbNSAsC-wiJFfLD384gxxOBg1i")
        
        # result = ytmusic.get_user("UCQ1U65-CQdIoZ2_NA4Z4F7A") ## does not work bc the path wasnt found
        
        
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