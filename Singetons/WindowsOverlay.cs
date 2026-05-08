using Godot;
using System;
using Windows.Media;
using Windows.Media.Playback;

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

	// 👉 API appelée depuis GDScript

	public void SetMetadata(string title, string artist)
	{
		var updater = smtc.DisplayUpdater;

		updater.Type = MediaPlaybackType.Music;
		updater.MusicProperties.Title = title;
		updater.MusicProperties.Artist = artist;
		//updater.TrackNumber = 2;
		GD.Print("aaa");

		updater.Update();
	}

	public void SetPlaybackStatus(bool isPlaying)
	{
		smtc.PlaybackStatus = isPlaying
			? MediaPlaybackStatus.Playing
			: MediaPlaybackStatus.Paused;
	}

	// Appelle ça quand aucune musique n'est lancée
	public void HideOverlay()
	{
		smtc.PlaybackStatus = MediaPlaybackStatus.Closed;
		smtc.IsEnabled = false;
	}

	// Appelle ça quand tu commences à jouer
	public void ShowOverlay()
	{
		smtc.IsEnabled = true;
		smtc.PlaybackStatus = MediaPlaybackStatus.Playing;
	}

	// (thumbnail plus bas 👇)
}
