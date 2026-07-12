# get_recommendations.py
import sys
import json
from ytmusicapi import YTMusic

def get_recommendations(video_id):
	try:
		ytmusic = YTMusic()
		autoplay_playlist = ytmusic.get_watch_playlist(video_id)
		
		recommendations = []
		for track in autoplay_playlist['tracks']:
			if track.get('videoId') and track.get('title'):
				artists = []
				for artist in track.get('artists', []):
					artists.append(artist.get('name', ''))
				
				recommendations.append({
					'title': track['title'],
					'videoId': track['videoId'],
					'artists': artists,
					'duration': track.get('duration', ''),
					'thumbnail': track.get('thumbnail', '')
				})
		
		# Imprimer le JSON pour Godot
		print(json.dumps({
			'success': True,
			'count': len(recommendations),
			'recommendations': recommendations
		}))
		
	except Exception as e:
		print(json.dumps({
			'success': False,
			'error': str(e)
		}))

if __name__ == "__main__":
	if len(sys.argv) > 1:
		video_id = sys.argv[1]
		get_recommendations(video_id)
	else:
		print(json.dumps({'success': False, 'error': 'No video ID provided'}))
