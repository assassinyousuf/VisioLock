import 'dart:typed_data';

import '../utils/binary_converter.dart';

class EncryptionService {
  List<int> encryptBits({required List<int> dataBits, required Uint8List key}) {
    return _xorBits(dataBits: dataBits, key: key);
  }

  List<int> decryptBits({required List<int> encryptedBits, required Uint8List key}) {
    return _xorBits(dataBits: encryptedBits, key: key);
  }

  List<int> _xorBits({required List<int> dataBits, required Uint8List key}) {
    if (dataBits.isEmpty) {
      return <int>[];
    }
    if (key.isEmpty) {
      throw ArgumentError('Key must not be empty.');
    }

    final keyBits = BinaryConverter.bytesToBits(key);
    if (keyBits.isEmpty) {
      throw ArgumentError('Key must produce at least one bit.');
    }

    final out = List<int>.filled(dataBits.length, 0, growable: false);
    for (var i = 0; i < dataBits.length; i++) {
      final bit = dataBits[i];
      if (bit != 0 && bit != 1) {
        throw ArgumentError('Bits must be 0 or 1.');
      }
      out[i] = bit ^ keyBits[i % keyBits.length];
    }

    return out;
  }
}
