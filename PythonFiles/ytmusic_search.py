import sys
import json
from ytmusicapi import YTMusic

def yt_music_search(query):
    try:
        ytmusic = YTMusic()
        # Récupérer les résultats de recherche
        search_results_raw = ytmusic.search(query, filter="songs", limit=20)
        
        search_results = []
        for item in search_results_raw:
            # Extraire les informations pertinentes
            track_info = {
                'videoId': item.get('videoId', ''),
                'title': item.get('title', ''),
                'artists': [artist.get('name', '') for artist in item.get('artists', [])],
                'album': item.get('album', {}).get('name', '') if item.get('album') else '',
                'duration': item.get('duration', ''),
                'thumbnails': item.get('thumbnails', [])
            }
            search_results.append(track_info)
        
        # Imprimer le JSON pour Godot
        print(json.dumps({
            'success': True,
            'query': query,
            'count': len(search_results),
            'recommendations': search_results
        }))
        
    except Exception as e:
        print(json.dumps({
            'success': False,
            'error': str(e)
        }))

if __name__ == "__main__":
    if len(sys.argv) > 1:
        query = sys.argv[1]
        yt_music_search(query)
    else:
        print(json.dumps({
            'success': False, 
            'error': 'No search query provided'
        }))