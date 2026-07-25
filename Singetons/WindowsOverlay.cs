using Godot;
using System;
using Windows.Media;
using Windows.Media.Playback;
using Windows.Storage;

// https://learn.microsoft.com/en-us/uwp/api/windows.media.systemmediatransportcontrolsdisplayupdater?view=winrt-28000

public partial class WindowsOverlay : Node
{
	private MediaPlayer player;
	private SystemMediaTransportControls smtc;

	// 👉 Signaux vers GDScript
	[Signal] public delegate void PlayPressedEventHandler();
	[Signal] public delegate void PausePressedEventHandler();
	[Signal] public delegate void NextPressedEventHandler();
	[Signal] public delegate void PreviousPressedEventHandler();

	public override void _Ready()
	{
		player = new MediaPlayer();
		smtc = player.SystemMediaTransportControls;

		smtc.IsEnabled = false; // ← désactivé par défaut
		smtc.IsPlayEnabled = true;
		smtc.IsPauseEnabled = true;
		smtc.IsNextEnabled = true;
		smtc.IsPreviousEnabled = true;
		smtc.PlaybackStatus = MediaPlaybackStatus.Closed; // ← état fermé

		smtc.ButtonPressed += OnButtonPressed;
	}

	// 👉 Gérer les boutons système
	private void OnButtonPressed(SystemMediaTransportControls sender, SystemMediaTransportControlsButtonPressedEventArgs args)
	{
		switch (args.Button)
		{
			case SystemMediaTransportControlsButton.Play:
				CallDeferred(GodotObject.MethodName.EmitSignal, SignalName.PlayPressed);
				break;

			case SystemMediaTransportControlsButton.Pause:
				CallDeferred(GodotObject.MethodName.EmitSignal, SignalName.PausePressed);
				break;

			case SystemMediaTransportControlsButton.Next:
				CallDeferred(GodotObject.MethodName.EmitSignal, SignalName.NextPressed);
				break;

			case SystemMediaTransportControlsButton.Previous:
				CallDeferred(GodotObject.MethodName.EmitSignal, SignalName.PreviousPressed);
				break;
		}
	}


	public void SetMetadata(string title, string artist, Image img)
	{
		var updater = smtc.DisplayUpdater;
		
		updater.Type = MediaPlaybackType.Music;
		updater.MusicProperties.Title = title;
		updater.MusicProperties.Artist = artist;
		
		// Thumbnail
		//if (!FileAccess.FileExists(webpPath))
		//{
			//GD.Print($"Miniature absente : {webpPath}");
			//updater.Update();
			//return;
		//}
		//
		//var img = new Image();
		
		//if (error != Error.Ok)
		//{
			//GD.Print($"Impossible de charger la miniature : {webpPath}");
			//updater.Update(); // update other metadatas
			//return;
		//}
		if (img != null)
		{
			string cachePath = "user://smtc_thumbnail.jpg";
			var error = img.SaveJpg(cachePath);
			if (error != Error.Ok)
			{
				GD.PrintErr($"Can't save the thumbnail: {cachePath}");
				updater.Update(); // update other metadatas
				return;
			}

			string globalPath = ProjectSettings.GlobalizePath(cachePath);
			globalPath = globalPath.Replace('/', '\\');
			StorageFile file = StorageFile.GetFileFromPathAsync(globalPath).AsTask().Result;
			var thumbnail = Windows.Storage.Streams.RandomAccessStreamReference.CreateFromFile(file);
			updater.Thumbnail = thumbnail;
		}
		
		
		updater.Update();
	}

	public void SetPlaybackStatus(bool isPlaying)
	{
		smtc.PlaybackStatus = isPlaying
			? MediaPlaybackStatus.Playing
			: MediaPlaybackStatus.Paused;
	}

	// When no song is played.
	public void HideOverlay()
	{
		smtc.PlaybackStatus = MediaPlaybackStatus.Closed;
		smtc.IsEnabled = false;
	}

	// When a song plays.
	public void ShowOverlay()
	{
		smtc.IsEnabled = true;
		smtc.PlaybackStatus = MediaPlaybackStatus.Playing;
	}

	
}
