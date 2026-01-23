# PP Player Reloaded
A local music player with online integration (YouTube downloads and informations)


## Addons:
### Addons used:
- yt-dlp (https://github.com/yt-dlp/yt-dlp) (not directly used as it is not a godot addon)
- godot-yt-dlp (https://github.com/Nolkaloid/godot-yt-dlp)
- GDContextMenu (https://github.com/Schimiongames/GDContextMenu)
- Godot-GlobalInput-Addon (https://github.com/Darnoman/Godot-GlobalInput-Addon)

### Changes to yt-dlp (https://github.com/Nolkaloid/godot-yt-dlp):
- Added a pull from the GitHub (https://github.com/Nolkaloid/godot-yt-dlp/pull/13) that handles abandoning DL/search requests.
- Added possibility of not downloading or only get infos (not parsed)
- Added a stop if there is an error (error != 0) when executing the command

WIP:
- Progress Hook
- Custom logger handler (half done)

The changed addon by itself does not work because I made it dependent of my project. I advise using the original addon: https://github.com/Nolkaloid/godot-yt-dlp

### Changed to globalinput:
- Set the pressed property of the returning object of GetInputEventMouseButton to false (had an issue with mouse inputs)


