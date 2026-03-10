import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../utils/binary_converter.dart';

class ImagePayload {
  static const String magic = 'I2A1';
  static const int headerSizeBytes = 20;

  final int width;
  final int height;
  final int channels;
  final Uint8List rgbBytes;
  final Uint8List payloadBytes;
  final List<int> payloadBits;

  const ImagePayload({
    required this.width,
    required this.height,
    required this.channels,
    required this.rgbBytes,
    required this.payloadBytes,
    required this.payloadBits,
  });
}

class ImageProcessor {
  Future<ImagePayload> convertImageToBinary(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw const FormatException('Unsupported or corrupted image file.');
    }

    const channels = 3;
    final rgbBytes = decoded.getBytes(order: img.ChannelOrder.rgb);

    final expectedLen = decoded.width * decoded.height * channels;
    if (rgbBytes.length != expectedLen) {
      throw FormatException(
        'Unexpected RGB byte length. Expected $expectedLen, got ${rgbBytes.length}.',
      );
    }

    final header = ByteData(ImagePayload.headerSizeBytes);
    _writeAscii(header, 0, ImagePayload.magic);
    header.setUint32(4, decoded.width, Endian.little);
    header.setUint32(8, decoded.height, Endian.little);
    header.setUint32(12, channels, Endian.little);
    header.setUint32(16, rgbBytes.length, Endian.little);

    final payloadBytes = Uint8List(ImagePayload.headerSizeBytes + rgbBytes.length);
    payloadBytes.setAll(0, header.buffer.asUint8List());
    payloadBytes.setAll(ImagePayload.headerSizeBytes, rgbBytes);

    final payloadBits = BinaryConverter.bytesToBits(payloadBytes);

    return ImagePayload(
      width: decoded.width,
      height: decoded.height,
      channels: channels,
      rgbBytes: rgbBytes,
      payloadBytes: payloadBytes,
      payloadBits: payloadBits,
    );
  }

  void _writeAscii(ByteData bd, int offset, String s) {
    final units = s.codeUnits;
    for (var i = 0; i < units.length; i++) {
      bd.setUint8(offset + i, units[i]);
    }
  }
}
