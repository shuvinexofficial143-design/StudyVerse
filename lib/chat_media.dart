import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Images and voice notes are access-controlled in a PRIVATE Storage bucket.
/// Object paths (not public URLs) are saved with the message.
/// RLS is required on both the messages table and storage.objects.
/// This is NOT end-to-end encryption.
class ChatMediaService {
  ChatMediaService(this.client);

  static const bucket = 'studyverse-private-media';
  static const maxBytes = 10 * 1024 * 1024;
  static const maxVoiceSeconds = 120;

  final SupabaseClient client;
  final ImagePicker picker = ImagePicker();
  final AudioRecorder recorder = AudioRecorder();
  DateTime? recordingStartedAt;
  String? localRecordingPath;
  bool _closed = false;

  Future<void> startVoiceRecording() async {
    if (!await recorder.hasPermission()) {
      throw const FormatException('Microphone permission is required.');
    }
    if (_closed) return;
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/sv-${DateTime.now().microsecondsSinceEpoch}.m4a';
    await recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 96000,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: path,
    );
    localRecordingPath = path;
    recordingStartedAt = DateTime.now();
  }

  Future<void> cancelVoiceRecording() async {
    try {
      await recorder.cancel();
    } finally {
      final path = localRecordingPath;
      localRecordingPath = null;
      recordingStartedAt = null;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    }
  }

  Future<bool> stopVoiceAndSend(String pairId) async {
    final startedAt = recordingStartedAt;
    if (startedAt == null || _closed) return false;
    String? path;
    try {
      path = await recorder.stop();
      final elapsed = DateTime.now().difference(startedAt).inSeconds;
      if (elapsed < 1) {
        throw const FormatException('Please record at least one second.');
      }
      if (elapsed > maxVoiceSeconds) {
        throw const FormatException('Voice notes must be 2 minutes or shorter.');
      }
      if (path == null) {
        throw const FormatException('No recording was captured.');
      }
      await _uploadAndSend(
        pairId: pairId,
        file: File(path),
        extension: 'm4a',
        mimeType: 'audio/mp4',
        kind: 'voice',
        durationSeconds: elapsed,
      );
      return true;
    } finally {
      recordingStartedAt = null;
      final oldPath = path ?? localRecordingPath;
      localRecordingPath = null;
      if (oldPath != null) {
        final file = File(oldPath);
        if (await file.exists()) await file.delete();
      }
    }
  }

  Future<bool> pickAndSendImage(String pairId) async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 82,
      requestFullMetadata: false,
    );
    if (picked == null || _closed) return false;
    final lower = picked.name.toLowerCase();
    final extension = lower.endsWith('.png')
        ? 'png'
        : lower.endsWith('.webp')
            ? 'webp'
            : (lower.endsWith('.jpg') || lower.endsWith('.jpeg'))
                ? 'jpg'
                : null;
    if (extension == null) {
      throw const FormatException('Choose a JPEG, PNG or WebP image.');
    }
    final data = await picked.readAsBytes();
    if (data.isEmpty || data.length > maxBytes) {
      throw const FormatException('Image must be under 10 MB.');
    }
    final mime = extension == 'png'
        ? 'image/png'
        : extension == 'webp'
            ? 'image/webp'
            : 'image/jpeg';
    await _uploadAndSend(
      pairId: pairId,
      file: File(picked.path),
      data: data,
      extension: extension,
      mimeType: mime,
      kind: 'image',
    );
    return true;
  }

  Future<void> _uploadAndSend({
    required String pairId,
    required File file,
    required String extension,
    required String mimeType,
    required String kind,
    Uint8List? data,
    int? durationSeconds,
  }) async {
    if (_closed) {
      throw const FormatException('Chat locked. Media was not sent.');
    }
    final senderId = client.auth.currentUser?.id;
    if (senderId == null) {
      throw const FormatException('Please sign in to send media.');
    }
    if (kind != 'image' && kind != 'voice') {
      throw const FormatException('Unsupported media type.');
    }
    final bytes = data ?? await file.readAsBytes();
    if (bytes.isEmpty || bytes.length > maxBytes) {
      throw const FormatException('Media must be under 10 MB.');
    }
    final objectPath = '$pairId/$senderId/${DateTime.now().microsecondsSinceEpoch}.$extension';
    await client.storage.from(bucket).uploadBinary(
      objectPath,
      bytes,
      fileOptions: FileOptions(contentType: mimeType, upsert: false),
    );
    try {
      if (_closed) {
        throw const FormatException('Chat locked. Media was not sent.');
      }
      await client.from('messages').insert({
        'pair_id': pairId,
        'sender_id': senderId,
        'message_type': kind,
        'storage_path': objectPath,
        'mime_type': mimeType,
        'duration_seconds': durationSeconds,
        'body': null,
      });
    } catch (_) {
      try {
        await client.storage.from(bucket).remove([objectPath]);
      } catch (_) {
        // Best-effort cleanup only.
      }
      rethrow;
    }
  }

  Future<String> signedMediaUrl(String path) =>
      client.storage.from(bucket).createSignedUrl(path, 120);

  Future<void> dispose() async {
    _closed = true;
    await recorder.dispose();
  }
}
