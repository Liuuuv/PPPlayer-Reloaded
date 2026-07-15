# PP Player Reloaded (Godot 4.6 Mono - Windows 10) (WIP)
## What's PP Player?
PP Player is and open-source local music player with online integrations (YouTube downloads and informations) made with Godot.

## Why does it exists?
- I listen to music all day, it's a way to show my love to the songs I adore.
- It turns out YouTube likes to pause my music when it feels like it and I hate this.
- I am afraid some songs I listen to get deleted someday, I'd like to 'pause time'.
- Some songs are not on YouTube Music, maybe because they are not tag as 'song'.
- Youtube Music lacks some feature like cropping songs or offsetting the volume for individual songs. I don't like raising my entire volume for one single song.

So I thought to myself 'can I really complain?', so my goal is to recreate a music player that is objectively better that YouTube Music (even if it relies on it to works).

## Shortcuts:
### Search bar:
- use 'id:' for id search only.

## Dependencies
- You need to have Python v3.10+ installed in order to execute Python scripts (they are not compiled because of transparency).
- You need to put deno.exe in the user folder (Settings > Open user folder) for yt-dlp to work properly.

## Uses/inspiration of other projects:
- Godot (excluding addons):
    - Godot Virtual Scrolling (https://github.com/Ryhon0/GodotVirtualScrolling)
    - Nollie (https://github.com/Cranzor/nollie)

## Addons:
### Addons used:
- yt-dlp (https://github.com/yt-dlp/yt-dlp) (not directly used as it is not a godot addon)
- godot-yt-dlp (https://github.com/Nolkaloid/godot-yt-dlp) (v3.0.6)
- GDContextMenu (https://github.com/Schimiongames/GDContextMenu)
- Godot-GlobalInput-Addon (https://github.com/Darnoman/Godot-GlobalInput-Addon)
- godot_tree_table (https://github.com/EinRainerZufall/godot_tree_table)

### Changes to Godot YT-DLP (https://github.com/Nolkaloid/godot-yt-dlp):
- Added a pull from the GitHub (https://github.com/Nolkaloid/godot-yt-dlp/pull/13) that handles abandoning DL/search requests.
- Added possibility of not downloading or only get infos (not parsed).
- Added a stop if there is an error (```error != 0```) when executing the command.
- Added additional arguments for preferring the best quality (```options_and_arguments.append_array(["-f bestaudio", "--audio-quality 0"])```)

You need to have deno (the .exe for Win10 users) at the same path as ffmpeg, ffmprobe, yt-flp (```user://```).

The changed addon by itself does not work because I made it dependent of my project (because of logs, if you have a solution I'm down).
I advise using the original addon for your own project: https://github.com/Nolkaloid/godot-yt-dlp

### Changes to Godot Global Input Addon:
- Set the pressed property of the returning object of GetInputEventMouseButton to false (had an issue with mouse inputs).
(```<ItemGroup>
    <PackageReference Include="SharpHook" Version="6.1.2" />
  </ItemGroup>``` in the ```.csproj``` in case you want to use it.)

### Changes to Godot Context Menu:
- Modified the ContextMenu.cs to support subwindows;
Added these lines in the function ```show_item``` before setting the position of the menu (for supporting not embedded subwindows):
```
bool embededSubwindows = ProjectSettings.GetSetting("display/window/subwindows/embed_subwindows").AsBool();
if (!embededSubwindows)
{
    int windowId = parent.GetWindow().GetWindowId();
    Vector2I windowPos = DisplayServer.WindowGetPosition(windowId);
    position += windowPos;
}
```
(This is clearly not the most optimized way to do it, but hey it works and surely won't be used that often :D)

### Changes to godot_tree_table:
- Made so that "true" and "false" (bool or string) are displayed as green and red color respectively instead of just text.
- Added (sloppy) support for bool values sorting (thanks to https://github.com/godotengine/godot/issues/49618#issuecomment-3368709438).

(
    https://github.com/godotengine/godot/issues/49618#issuecomment-3368709438 :
    fixed the error ```ERROR: unguarded_linear_insert: bad comparison function; sorting will be broken``` when using custom comparison functions:
    "
    This behavior still happens in 4.5
    To avoid this issue, ensure that the sort function returns false when the two compared elements are identical
    "
)


## Complementary informations
- This software has not been release yet and is work in progress.
- Works on Godot 4.6 Mono but apparently does not on Godot 4.7.