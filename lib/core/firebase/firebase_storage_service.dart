// lib/core/firebase/firebase_storage_service.dart
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:petverse/core/config/app_config.dart';
import 'package:petverse/core/validation/input_validator.dart';

/// Resultado de upload
class UploadResult {
  final bool success;
  final String? downloadUrl;
  final String? filePath;
  final int? fileSizeBytes;
  final String? error;
  final TaskSnapshot? snapshot;

  const UploadResult({
    required this.success,
    this.downloadUrl,
    this.filePath,
    this.fileSizeBytes,
    this.error,
    this.snapshot,
  });

  factory UploadResult.success({
    required String downloadUrl,
    required String filePath,
    int? fileSizeBytes,
    TaskSnapshot? snapshot,
  }) {
    return UploadResult(
      success: true,
      downloadUrl: downloadUrl,
      filePath: filePath,
      fileSizeBytes: fileSizeBytes,
      snapshot: snapshot,
    );
  }

  factory UploadResult.failure(String error) {
    return UploadResult(success: false, error: error);
  }
}

/// Progresso de upload
class UploadProgress {
  final int bytesTransferred;
  final int totalBytes;
  final double percentage;
  final TaskState state;

  const UploadProgress({
    required this.bytesTransferred,
    required this.totalBytes,
    required this.percentage,
    required this.state,
  });

  factory UploadProgress.fromSnapshot(TaskSnapshot snapshot) {
    final bytesTransferred = snapshot.bytesTransferred;
    final totalBytes = snapshot.totalBytes;
    final percentage =
        totalBytes > 0 ? (bytesTransferred / totalBytes) * 100 : 0.0;

    return UploadProgress(
      bytesTransferred: bytesTransferred,
      totalBytes: totalBytes,
      percentage: percentage,
      state: snapshot.state,
    );
  }
}

/// Configuração de upload
class UploadConfig {
  final String folder;
  final int maxSizeBytes;
  final List<String> allowedExtensions;
  final bool generateThumbnail;
  final Map<String, String> metadata;

  const UploadConfig({
    required this.folder,
    this.maxSizeBytes = 5 * 1024 * 1024, // 5MB
    this.allowedExtensions = const ['.jpg', '.jpeg', '.png', '.webp'],
    this.generateThumbnail = false,
    this.metadata = const {},
  });

  static const UploadConfig petImages = UploadConfig(
    folder: 'pets',
    maxSizeBytes: 3 * 1024 * 1024, // 3MB para imagens de pets
    allowedExtensions: ['.jpg', '.jpeg', '.png', '.webp'],
    generateThumbnail: true,
  );

  static const UploadConfig userAvatars = UploadConfig(
    folder: 'avatars',
    maxSizeBytes: 2 * 1024 * 1024, // 2MB para avatares
    allowedExtensions: ['.jpg', '.jpeg', '.png'],
    generateThumbnail: true,
  );
}

/// Serviço do Firebase Storage para upload de arquivos
class FirebaseStorageService {
  static final Logger _logger = Logger();
  static FirebaseStorageService? _instance;

  final FirebaseStorage _storage;

  FirebaseStorageService._() : _storage = FirebaseStorage.instance {
    _configureStorage();
  }

  /// Singleton instance
  static FirebaseStorageService get instance {
    return _instance ??= FirebaseStorageService._();
  }

  /// Configurações do Storage
  void _configureStorage() {
    // Configura timeout baseado no ambiente
    final config = AppConfig.instance;

    final maxOperationTimeout = Duration(
      seconds: config.isProduction ? 60 : 30,
    );

    _storage.setMaxOperationRetryTime(maxOperationTimeout);
    _storage.setMaxUploadRetryTime(maxOperationTimeout);
    _storage.setMaxDownloadRetryTime(maxOperationTimeout);

    _logger.d('Firebase Storage configured');
  }

  // ========================================
  // MÉTODOS DE UPLOAD
  // ========================================

  /// Upload de arquivo com validação
  Future<UploadResult> uploadFile({
    required File file,
    required String fileName,
    required UploadConfig config,
    String? userId,
    StreamController<UploadProgress>? onProgress,
  }) async {
    try {
      // 1. Validações básicas
      final validation = await _validateFile(file, fileName, config);
      if (!validation.isValid) {
        return UploadResult.failure(validation.error!);
      }

      // 2. Gera nome único do arquivo
      final sanitizedFileName = _sanitizeFileName(fileName);
      final uniqueFileName = _generateUniqueFileName(sanitizedFileName, userId);
      final filePath = '${config.folder}/$uniqueFileName';

      // 3. Cria referência do Storage
      final storageRef = _storage.ref().child(filePath);

      // 4. Prepara metadata
      final metadata = SettableMetadata(
        contentType: _getContentType(fileName),
        customMetadata: {
          'originalName': fileName,
          'uploadedBy': userId ?? 'anonymous',
          'uploadedAt': DateTime.now().toIso8601String(),
          'platform': 'mobile',
          ...config.metadata,
        },
      );

      // 5. Inicia upload
      final uploadTask = storageRef.putFile(file, metadata);

      // 6. Monitora progresso se solicitado
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen(
          (snapshot) {
            final progress = UploadProgress.fromSnapshot(snapshot);
            onProgress.add(progress);
          },
          onError: (error) {
            _logger.w('Upload progress error: $error');
          },
        );
      }

      // 7. Aguarda conclusão
      final snapshot = await uploadTask;

      // 8. Obtém URL de download
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _logger.i('File uploaded successfully: $filePath');

      return UploadResult.success(
        downloadUrl: downloadUrl,
        filePath: filePath,
        fileSizeBytes: snapshot.totalBytes,
        snapshot: snapshot,
      );
    } on FirebaseException catch (e) {
      _logger.e('Firebase Storage error: ${e.code} - ${e.message}');
      return UploadResult.failure(_getStorageErrorMessage(e.code));
    } catch (e, stackTrace) {
      _logger.e('Upload failed', error: e, stackTrace: stackTrace);
      return UploadResult.failure('Erro interno no upload: $e');
    }
  }

  /// Upload de dados em bytes
  Future<UploadResult> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    required UploadConfig config,
    String? userId,
    StreamController<UploadProgress>? onProgress,
  }) async {
    try {
      // 1. Validações
      if (bytes.isEmpty) {
        return UploadResult.failure('Dados vazios');
      }

      if (bytes.length > config.maxSizeBytes) {
        return UploadResult.failure(
          'Arquivo muito grande. Máximo: ${_formatBytes(config.maxSizeBytes)}',
        );
      }

      final fileNameValidation = InputValidator.validate(
        fileName,
        ValidationType.fileName,
      );
      if (!fileNameValidation.isValid) {
        return UploadResult.failure(
          'Nome de arquivo inválido: ${fileNameValidation.error}',
        );
      }

      // 2. Gera nome único
      final sanitizedFileName = _sanitizeFileName(fileName);
      final uniqueFileName = _generateUniqueFileName(sanitizedFileName, userId);
      final filePath = '${config.folder}/$uniqueFileName';

      // 3. Cria referência
      final storageRef = _storage.ref().child(filePath);

      // 4. Metadata
      final metadata = SettableMetadata(
        contentType: _getContentType(fileName),
        customMetadata: {
          'originalName': fileName,
          'uploadedBy': userId ?? 'anonymous',
          'uploadedAt': DateTime.now().toIso8601String(),
          'platform': 'mobile',
          'sizeBytes': bytes.length.toString(),
          ...config.metadata,
        },
      );

      // 5. Upload
      final uploadTask = storageRef.putData(bytes, metadata);

      // 6. Progresso
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen(
          (snapshot) {
            final progress = UploadProgress.fromSnapshot(snapshot);
            onProgress.add(progress);
          },
          onError: (error) {
            _logger.w('Upload progress error: $error');
          },
        );
      }

      // 7. Conclusão
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _logger.i('Bytes uploaded successfully: $filePath');

      return UploadResult.success(
        downloadUrl: downloadUrl,
        filePath: filePath,
        fileSizeBytes: snapshot.totalBytes,
        snapshot: snapshot,
      );
    } on FirebaseException catch (e) {
      _logger.e('Firebase Storage error: ${e.code} - ${e.message}');
      return UploadResult.failure(_getStorageErrorMessage(e.code));
    } catch (e, stackTrace) {
      _logger.e('Bytes upload failed', error: e, stackTrace: stackTrace);
      return UploadResult.failure('Erro interno no upload: $e');
    }
  }

  // ========================================
  // MÉTODOS DE GERENCIAMENTO
  // ========================================

  /// Deleta arquivo
  Future<bool> deleteFile(String filePath) async {
    try {
      final fileRef = _storage.ref().child(filePath);
      await fileRef.delete();

      _logger.d('File deleted: $filePath');
      return true;
    } on FirebaseException catch (e) {
      _logger.e('Failed to delete file: ${e.code} - ${e.message}');
      return false;
    } catch (e, stackTrace) {
      _logger.e('Delete failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Obtém URL de download
  Future<String?> getDownloadUrl(String filePath) async {
    try {
      final fileRef = _storage.ref().child(filePath);
      return await fileRef.getDownloadURL();
    } catch (e) {
      _logger.w('Failed to get download URL: $e');
      return null;
    }
  }

  /// Obtém metadata do arquivo
  Future<FullMetadata?> getFileMetadata(String filePath) async {
    try {
      final fileRef = _storage.ref().child(filePath);
      return await fileRef.getMetadata();
    } catch (e) {
      _logger.w('Failed to get file metadata: $e');
      return null;
    }
  }

  /// Lista arquivos de uma pasta
  Future<List<Reference>> listFiles(String folderPath,
      {int maxResults = 100}) async {
    try {
      final folderRef = _storage.ref().child(folderPath);
      final listResult =
          await folderRef.list(ListOptions(maxResults: maxResults));

      return listResult.items;
    } catch (e) {
      _logger.w('Failed to list files: $e');
      return [];
    }
  }

  // ========================================
  // MÉTODOS ESPECÍFICOS
  // ========================================

  /// Upload de imagem de pet
  Future<UploadResult> uploadPetImage({
    required File imageFile,
    required String petId,
    String? userId,
    StreamController<UploadProgress>? onProgress,
  }) async {
    final fileName =
        'pet_${petId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    return uploadFile(
      file: imageFile,
      fileName: fileName,
      config: UploadConfig.petImages.copyWith(
        metadata: {
          'petId': petId,
          'type': 'pet_image',
        },
      ),
      userId: userId,
      onProgress: onProgress,
    );
  }

  /// Upload de avatar do usuário
  Future<UploadResult> uploadUserAvatar({
    required File imageFile,
    required String userId,
    StreamController<UploadProgress>? onProgress,
  }) async {
    final fileName =
        'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    return uploadFile(
      file: imageFile,
      fileName: fileName,
      config: UploadConfig.userAvatars.copyWith(
        metadata: {
          'userId': userId,
          'type': 'user_avatar',
        },
      ),
      userId: userId,
      onProgress: onProgress,
    );
  }

  // ========================================
  // MÉTODOS AUXILIARES
  // ========================================

  /// Valida arquivo antes do upload
  Future<ValidationResult> _validateFile(
    File file,
    String fileName,
    UploadConfig config,
  ) async {
    // Verifica se arquivo existe
    if (!await file.exists()) {
      return ValidationResult.invalid('Arquivo não encontrado');
    }

    // Verifica tamanho
    final fileSize = await file.length();
    if (fileSize > config.maxSizeBytes) {
      return ValidationResult.invalid(
        'Arquivo muito grande. Máximo: ${_formatBytes(config.maxSizeBytes)}',
      );
    }

    if (fileSize == 0) {
      return ValidationResult.invalid('Arquivo vazio');
    }

    // Valida nome do arquivo
    final fileNameValidation = InputValidator.validate(
      fileName,
      ValidationType.fileName,
    );
    if (!fileNameValidation.isValid) {
      return ValidationResult.invalid(
        'Nome de arquivo inválido: ${fileNameValidation.error}',
      );
    }

    // Verifica extensão
    final extension = path.extension(fileName).toLowerCase();
    if (!config.allowedExtensions.contains(extension)) {
      return ValidationResult.invalid(
        'Tipo de arquivo não permitido. Permitidos: ${config.allowedExtensions.join(', ')}',
      );
    }

    return ValidationResult.valid(fileName);
  }

  /// Sanitiza nome do arquivo
  String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')
        .replaceAll(RegExp(r'_{2,}'), '_')
        .replaceAll(RegExp(r'^[._-]+|[._-]+$'), '');
  }

  /// Gera nome único para o arquivo
  String _generateUniqueFileName(String fileName, String? userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(fileName);
    final nameWithoutExt = path.basenameWithoutExtension(fileName);

    final userPrefix = userId != null ? '${userId}_' : '';
    return '$userPrefix${nameWithoutExt}_$timestamp$extension';
  }

  /// Determina content type baseado na extensão
  String _getContentType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();

    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }

  /// Formata bytes para exibição
  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '$bytes bytes';
    }
  }

  /// Converte códigos de erro do Storage
  String _getStorageErrorMessage(String code) {
    switch (code) {
      case 'storage/unauthorized':
        return 'Não autorizado para esta operação';
      case 'storage/canceled':
        return 'Upload cancelado';
      case 'storage/unknown':
        return 'Erro desconhecido no upload';
      case 'storage/invalid-format':
        return 'Formato de arquivo inválido';
      case 'storage/invalid-event-name':
        return 'Nome de evento inválido';
      case 'storage/invalid-url':
        return 'URL inválida';
      case 'storage/invalid-argument':
        return 'Argumento inválido';
      case 'storage/no-default-bucket':
        return 'Bucket padrão não configurado';
      case 'storage/cannot-slice-blob':
        return 'Erro no processamento do arquivo';
      case 'storage/server-file-wrong-size':
        return 'Tamanho de arquivo incorreto';
      case 'storage/quota-exceeded':
        return 'Cota de armazenamento excedida';
      default:
        return 'Erro no upload: $code';
    }
  }
}

// ========================================
// EXTENSIONS
// ========================================

extension UploadConfigExtensions on UploadConfig {
  UploadConfig copyWith({
    String? folder,
    int? maxSizeBytes,
    List<String>? allowedExtensions,
    bool? generateThumbnail,
    Map<String, String>? metadata,
  }) {
    return UploadConfig(
      folder: folder ?? this.folder,
      maxSizeBytes: maxSizeBytes ?? this.maxSizeBytes,
      allowedExtensions: allowedExtensions ?? this.allowedExtensions,
      generateThumbnail: generateThumbnail ?? this.generateThumbnail,
      metadata: metadata ?? this.metadata,
    );
  }
}
