import sys
import json
import librosa
import matplotlib.pyplot as plt
import numpy as np

def safe_to_float(value, default=0.0):
    try:
        if isinstance(value, np.ndarray):
            value = value.item() if value.size == 1 else value.ravel()[0]
        return float(value)
    except (ValueError, TypeError, IndexError):
        return default


def get_bpm(fullpath: str):
    try:
        y, sr = librosa.load(fullpath, sr=None, mono=True)
        duration = len(y) / sr

        bpm, _ = librosa.beat.beat_track(y=y, sr=sr)
        bpm = safe_to_float(bpm)
        
        print(json.dumps({
            'success': True,
            'result': {"bpm": round(bpm, 2)}
        }))
        
    except Exception as e:
        print(json.dumps({
            'success': False,
            'error': str(e)
        }))



if __name__ == "__main__":
    if len(sys.argv) > 1:
        fullpath: str = sys.argv[1]
        get_bpm(fullpath)
    else:
        print(json.dumps({'success': False, 'error': 'No path provided.'}))


# if __name__ == "__main__":
#     folder_path = r"O:\PPPLAYER-DOWNLOADS\downloads"

#     result = get_bpm(
#         f"{folder_path}\\2ma.mp3"
#     )