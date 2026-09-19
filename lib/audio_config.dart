/// Where story audio is served from.
///
/// The audio is not bundled with the app (it was ~120 MB of the build); it
/// lives in the Cloudflare R2 bucket `qissora-audio`, served through this
/// custom domain. Object keys mirror the local `assets/audio/` folder, so
/// `assets/audio/en/fairness/01_x.ogg` is `<base>/en/fairness/01_x.ogg`.
/// `tools/upload_audio.ps1` uploads that folder with exactly those keys.
///
/// Keep this on a domain we own: installed apps hard-code it, so moving the
/// files to another host must not require changing this URL.
const String audioBaseUrl = 'https://audio.qissora.app';

/// Prefix of the local copies that [Story.audioAsset] paths start with.
const String localAudioPrefix = 'assets/audio/';
