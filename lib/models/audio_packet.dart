import 'dart:typed_data';

class AudioPacket {
  final int sampleRate;
  final int bitDurationMs;
  final double frequency0Hz;
  final double frequency1Hz;
  final Uint8List wavBytes;

  const AudioPacket({
    required this.sampleRate,
    required this.bitDurationMs,
    required this.frequency0Hz,
    required this.frequency1Hz,
    required this.wavBytes,
  });
}
