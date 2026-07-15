import sys
import json
from ytmusicapi import YTMusic

def get_artist_infos(artist_id: str):
    try:
        ytmusic = YTMusic()
        # Récupérer les résultats de recherche
        artist_infos_raw = ytmusic.get_artist(artist_id)
        
        
        artist_infos: dict = {}
        
        to_get = [
            "description",
            "name",
            "shuffleId",
            "radioId",
            "singles",
            "subscribers",
            "monthlyListeners",
            "thumbnails",
            "songs",
            "albums",
        ]
        for info_name in to_get:
            if info_name in artist_infos_raw:
                artist_infos[info_name] = artist_infos_raw[info_name]
        
        
        # Imprimer le JSON pour Godot
        print(json.dumps({
            'success': True,
            'infos': artist_infos
        }))
        
    except Exception as e:
        print(json.dumps({
            'success': False,
            'error': str(e)
        }))

if __name__ == "__main__":
    if len(sys.argv) > 1:
        artist_id = sys.argv[1]
        get_artist_infos(artist_id)
    else:
        print(json.dumps({
            'success': False, 
            'error': 'No channel ID provided'
        }))