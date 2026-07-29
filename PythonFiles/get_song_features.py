import numpy as np # Numerical computing and array operations
import librosa # Audio and music processin
import sys
import json


def get_features(audio_path):
    try:
        y, sr = librosa.load(audio_path)
        
        result: dict = {}
        
        frame_length = 2048
        hop_length = 512
        
        ##############
        # Root Mean Squared
        rms = librosa.feature.rms(y=y, frame_length=frame_length, hop_length=hop_length)[0]


        result["rms_mean"] = float(np.mean(rms))
        result["rms_std"] = float(np.std(rms))
        ##############
        
        ##############
        # Zero Crossing Rate
        zcr = librosa.feature.zero_crossing_rate(y, frame_length=frame_length, hop_length=hop_length)[0]

        result["zcr_mean"] = float(np.mean(zcr))
        result["zcr_std"] = float(np.std(zcr))
        ##############
        
        ##############
        # Spectral centroid
        spectral_centroid = librosa.feature.spectral_centroid(y=y, sr=sr, n_fft=frame_length, hop_length=hop_length)[0]
        result["spectral_centroid_mean"] = float(np.mean(spectral_centroid))
        result["spectral_centroid_std"] = float(np.std(spectral_centroid))
        ##############
        
        
        ##############
        mfccs = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=7, n_fft=frame_length, hop_length=hop_length)
        for i in range(7):
            result[f"mfcc_{i+1}_mean"] = float(np.mean(mfccs[i]))
            result[f"mfcc_{i+1}_std"] = float(np.std(mfccs[i]))
        ##############
        ##############
        
        
        
        print(json.dumps({
            'success': True,
            'result': result
        }))
    except Exception as e:
        print(json.dumps({
            'success': False,
            'error': str(e)
        }))



if __name__ == "__main__":
    if len(sys.argv) > 1:
        fullpath: str = sys.argv[1]
        get_features(fullpath)
    else:
        print(json.dumps({'success': False, 'error': 'No path provided.'}))


# if __name__ == "__main__":
#     folder_path = r"O:\PPPLAYER-DOWNLOADS\downloads"

#     result = get_bpm(
#         f"{folder_path}\\2ma.mp3"
#     )