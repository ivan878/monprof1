import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

/// Lecteur du conteneur vidéo chiffré « MXV1 » produit par le backend.
///
/// Format — en-tête de 41 octets, gros-boutiste, puis les blocs :
///
/// ```
///  offset  taille  champ
///  0       4       magic          "MXV1"
///  4       1       version        0x01
///  5       4       chunkSize      taille d'un bloc en clair
///  9       8       plaintextSize  taille totale en clair
///  17      16      keyId          UUID de la clé de contenu
///  33      8       baseNonce      aléatoire, propre au fichier
///  ---
///  puis, par bloc : [int longueurChiffrée][données || tag 16 o]
/// ```
///
/// Le nonce d'un bloc vaut `baseNonce (8) || index (4)`. Il est donc unique
/// par bloc et par fichier : déplacer, rejouer ou insérer un bloc change le
/// nonce attendu et fait échouer la vérification du tag GCM. Aucune donnée
/// additionnelle authentifiée n'est nécessaire.
class MxvHeader {
  static const List<int> magic = [0x4D, 0x58, 0x56, 0x31]; // "MXV1"
  static const int version = 1;
  static const int headerSize = 41;
  static const int tagSize = 16;
  static const int baseNonceSize = 8;

  final int chunkSize;
  final int plaintextSize;
  final String keyId;
  final Uint8List baseNonce;

  const MxvHeader({
    required this.chunkSize,
    required this.plaintextSize,
    required this.keyId,
    required this.baseNonce,
  });

  /// Taille d'un bloc chiffré, préfixe de longueur compris.
  int get framedChunkSize => 4 + chunkSize + tagSize;

  int get chunkCount =>
      plaintextSize == 0 ? 0 : ((plaintextSize + chunkSize - 1) ~/ chunkSize);

  /// Décale de l'en-tête vers le début du bloc [index] dans le fichier chiffré.
  ///
  /// Tous les blocs font exactement `chunkSize` octets en clair sauf le dernier,
  /// ce qui rend la position calculable sans parcourir le fichier — condition
  /// nécessaire au déplacement dans la vidéo.
  int offsetOfChunk(int index) => headerSize + index * framedChunkSize;

  /// Taille en clair du bloc [index].
  int plaintextSizeOfChunk(int index) {
    final remaining = plaintextSize - index * chunkSize;
    return remaining >= chunkSize ? chunkSize : remaining;
  }

  static MxvHeader parse(Uint8List bytes) {
    if (bytes.length < headerSize) {
      throw const FormatException('Conteneur trop court');
    }
    for (var i = 0; i < magic.length; i++) {
      if (bytes[i] != magic[i]) {
        throw const FormatException('Signature de conteneur invalide');
      }
    }
    final data = ByteData.sublistView(bytes);
    final fileVersion = bytes[4];
    if (fileVersion != version) {
      throw FormatException('Version de conteneur non gérée : $fileVersion');
    }

    return MxvHeader(
      chunkSize: data.getInt32(5),
      plaintextSize: data.getInt64(9),
      keyId: _uuidFrom(data.getInt64(17), data.getInt64(25)),
      baseNonce: Uint8List.sublistView(bytes, 33, 41),
    );
  }

  /// Lit l'en-tête sans charger le fichier entier.
  static Future<MxvHeader> readFrom(RandomAccessFile file) async {
    await file.setPosition(0);
    final bytes = await file.read(headerSize);
    return parse(bytes);
  }

  /// Reconstruit la forme canonique d'un UUID depuis ses deux moitiés.
  static String _uuidFrom(int msb, int lsb) {
    String hex(int value, int bytes) {
      final buffer = StringBuffer();
      for (var i = bytes - 1; i >= 0; i--) {
        buffer.write(((value >> (i * 8)) & 0xFF).toRadixString(16).padLeft(2, '0'));
      }
      return buffer.toString();
    }

    final high = hex(msb, 8);
    final low = hex(lsb, 8);
    return '${high.substring(0, 8)}-${high.substring(8, 12)}-${high.substring(12, 16)}'
        '-${low.substring(0, 4)}-${low.substring(4)}';
  }
}

/// Déchiffre les blocs d'un conteneur MXV1.
///
/// Sans état : l'appelant fournit la clé et l'index du bloc. Cela permet
/// l'accès aléatoire — on ne déchiffre que les blocs couvrant la plage
/// demandée, jamais le fichier entier.
class MxvDecryptor {
  final Uint8List key;
  final MxvHeader header;

  late final Encrypter _encrypter =
      Encrypter(AES(Key(key), mode: AESMode.gcm));

  MxvDecryptor({required this.key, required this.header}) {
    if (key.length != 32) {
      throw ArgumentError('La clé de contenu doit faire 256 bits');
    }
  }

  /// Nonce du bloc : `baseNonce (8) || index (4)` en gros-boutiste.
  Uint8List nonceFor(int index) {
    final nonce = Uint8List(12);
    nonce.setRange(0, MxvHeader.baseNonceSize, header.baseNonce);
    ByteData.sublistView(nonce).setInt32(MxvHeader.baseNonceSize, index);
    return nonce;
  }

  /// Déchiffre un bloc déjà lu depuis le fichier (données || tag).
  Uint8List decryptChunk(Uint8List cipherWithTag, int index) {
    final clear = _encrypter.decryptBytes(
      Encrypted(cipherWithTag),
      iv: IV(nonceFor(index)),
    );
    return Uint8List.fromList(clear);
  }

  /// Lit puis déchiffre le bloc [index] depuis le fichier ouvert.
  Future<Uint8List> readChunk(RandomAccessFile file, int index) async {
    await file.setPosition(header.offsetOfChunk(index));
    final lengthBytes = await file.read(4);
    if (lengthBytes.length < 4) {
      throw const FormatException('Bloc tronqué : longueur illisible');
    }
    final cipherLength = ByteData.sublistView(lengthBytes).getInt32(0);
    final cipherBytes = await file.read(cipherLength);
    if (cipherBytes.length < cipherLength) {
      throw const FormatException('Bloc tronqué : données incomplètes');
    }
    return decryptChunk(cipherBytes, index);
  }

  /// Décode une clé transmise en base64 par le backend.
  static Uint8List keyFromBase64(String encoded) =>
      Uint8List.fromList(base64Decode(encoded));
}
