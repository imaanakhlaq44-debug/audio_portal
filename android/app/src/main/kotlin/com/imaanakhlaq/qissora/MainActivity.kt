package com.imaanakhlaq.qissora

import com.ryanheise.audioservice.AudioServiceActivity

/// Extends AudioServiceActivity (instead of FlutterActivity) so the
/// audio_service plugin can attach its media session to this activity and
/// tapping the playback notification brings the app back to the foreground.
class MainActivity : AudioServiceActivity()
