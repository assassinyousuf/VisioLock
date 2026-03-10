import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../utils/binary_converter.dart';
import 'image_processor.dart';

class ImageReconstructor {
  Uint8List reconstructPngFromBinaryBits(List<int> binaryBits) {
    final payloadBytes = BinaryConverter.bitsToBytes(binaryBits);
    return reconstructPngFromPayloadBytes(payloadBytes);
  }

  Uint8List reconstructPngFromPayloadBytes(Uint8List payloadBytes) {
    if (payloadBytes.length < ImagePayload.headerSizeBytes) {
      throw const FormatException('Payload too short to contain header.');
    }

    final magic = String.fromCharCodes(payloadBytes.sublist(0, 4));
    if (magic != ImagePayload.magic) {
      throw const FormatException('Invalid payload magic/header.');
    }

    final width = BinaryConverter.readUint32le(payloadBytes, 4);
    final height = BinaryConverter.readUint32le(payloadBytes, 8);
    final channels = BinaryConverter.readUint32le(payloadBytes, 12);
    final dataLen = BinaryConverter.readUint32le(payloadBytes, 16);

    if (width <= 0 || height <= 0) {
      throw FormatException('Invalid image dimensions: ${width}x$height');
    }
    if (channels != 3) {
      throw FormatException('Unsupported channel count: $channels (expected 3)');
    }

    final expectedLen = width * height * channels;
    if (dataLen != expectedLen) {
      throw FormatException('Invalid payload length: expected $expectedLen bytes, got $dataLen');
    }

    final pixelOffset = ImagePayload.headerSizeBytes;
    final end = pixelOffset + dataLen;
    if (end > payloadBytes.length) {
      throw const FormatException('Payload is truncated (not enough pixel bytes).');
    }

    final image = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: payloadBytes.buffer,
      bytesOffset: pixelOffset,
      numChannels: channels,
      order: img.ChannelOrder.rgb,
    );

    final pngBytes = img.encodePng(image);
    return Uint8List.fromList(pngBytes);
  }
}
