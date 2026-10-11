import 'dart:async';
import 'dart:io';

import 'package:appwrite/appwrite.dart' as aw;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Separate backend from every Supabase project. Config must be supplied at
/// build time; no admin key, password or private media URL belongs in source.
/// Appwrite per-row read permissions restrict messages to two user IDs.
/// Private by permissions, but NOT end-to-end encrypted.
class StudyVerseAppwrite {
  // Public project identifiers, not private API keys.
  // Build-time definitions can override the defaults.
  static const endpoint = String.fromEnvironment('APPWRITE_ENDPOINT',
      defaultValue: 'https://sgp.cloud.appwrite.io/v1');
  static const projectId = String.fromEnvironment('APPWRITE_PROJECT_ID',
      defaultValue: '6acb25f9002eed3e32d5');
  static const databaseId = String.fromEnvironment('APPWRITE_DATABASE_ID',
      defaultValue: '6acb26b800128ccfb9b7');
  static const tableId = String.fromEnvironment('APPWRITE_CHAT_TABLE_ID',
      defaultValue: '6acb27370006d588e3f4');
  static const bucketId = String.fromEnvironment('APPWRITE_MEDIA_BUCKET_ID',
      defaultValue: 'studyverse-private-media');

  static bool get configured =>
      endpoint.startsWith('https://') &&
      projectId.isNotEmpty &&
      databaseId.isNotEmpty &&
      tableId.isNotEmpty &&
      bucketId.isNotEmpty;

  static aw.Client createClient() =>
      aw.Client().setEndpoint(endpoint).setProject(projectId);
}

class AppwritePrivateChatScreen extends StatefulWidget {
  final VoidCallback onQuickExit;
  const AppwritePrivateChatScreen({super.key, required this.onQuickExit});

  @override
  State<AppwritePrivateChatScreen> createState() =>
      _AppwritePrivateChatScreenState();
}

class _AppwritePrivateChatScreenState extends State<AppwritePrivateChatScreen> {
  final _myIdController = TextEditingController();
  final _peerController = TextEditingController();
  final _text = TextEditingController();
  final _recorder = AudioRecorder();
  final _picker = ImagePicker();
  static const _androidPackage = 'com.studyverse.app.studyverse';

  late final aw.Client _client = StudyVerseAppwrite.createClient();
  late final aw.Account _account = aw.Account(_client);
  late final aw.TablesDB _database = aw.TablesDB(_client);
  late final aw.Storage _storage = aw.Storage(_client);
  late final aw.Realtime _realtime = aw.Realtime(_client);

  aw.RealtimeSubscription? _subscription;
  StreamSubscription? _events;
  final List<Map<String, dynamic>> _messages = [];
  String? _senderId;
  String? _myChatId;
  String? _peerId;
  String? _peerChatId;
  String? _error;
  static const _savedPeerKey = 'studyverse_appwrite_peer_v1';
  static const _savedPeerAliasKey = 'studyverse_appwrite_peer_alias_v2';
  static const _savedMyAliasKey = 'studyverse_appwrite_my_alias_v2';
  static const _aliasPattern = r'^[a-z][a-z0-9_-]{2,29}
  bool _loading = true;
  bool _sending = false;
  bool _recording = false;
  bool _exited = false;
  String? _recordingPath;
  DateTime? _recordingStarted;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    if (!StudyVerseAppwrite.configured) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final current = await _account.get();
      await _restoreIdentity(current.$id);
    } on aw.AppwriteException catch (e) {
      if (mounted && !_exited) {
        setState(() {
          _loading = false;
          // A 401 indicates first install: show a Create Chat ID button.
          _error = e.code == 401 ? null : _explainAppwriteError(e);
        });
      }
    } catch (_) {
      if (mounted && !_exited) {
        setState(() { _loading = false; _error = 'Internet unavailable.'; });
      }
    }
  }

  // A short, user-selected Chat ID is reserved as a profile row ID.
  // This keeps the database to the one table already created in Appwrite.
  static String _aliasRowId(String alias) => 'user_$alias';

  Future<void> _createMyChatId() async {
    if (_sending || _exited) return;
    final alias = _myIdController.text.trim().toLowerCase();
    if (!RegExp(_aliasPattern).hasMatch(alias)) {
      setState(() => _error =
        'Use 3–30 characters: start with a letter, then letters, numbers, _ or -.');
      return;
    }
    setState(() { _sending = true; _error = null; });
    try {
      String userId;
      try {
        userId = (await _account.get()).$id;
      } on aw.AppwriteException catch (e) {
        if (e.code != 401) rethrow;
        await _account.createAnonymousSession();
        userId = (await _account.get()).$id;
      }
      // No table-level READ is required: only the alias row itself grants READ
      // to other Appwrite sessions, whereas message rows grant READ to two IDs.
      try {
        await _database.createRow(
          databaseId: StudyVerseAppwrite.databaseId,
          tableId: StudyVerseAppwrite.tableId,
          rowId: _aliasRowId(alias),
          data: {
            'sender_id': userId,
            'kind': 'profile',
            'body': alias,
            'file_id': null,
            'duration_seconds': null,
          },
          permissions: [
            aw.Permission.read(aw.Role.users()),
          ],
        );
      } on aw.AppwriteException catch (e) {
        if (e.code != 409) rethrow;
        final existing = await _database.getRow(
          databaseId: StudyVerseAppwrite.databaseId,
          tableId: StudyVerseAppwrite.tableId,
          rowId: _aliasRowId(alias),
        );
        if (existing.data['sender_id'] != userId ||
            existing.data['kind'] != 'profile') {
          throw const FormatException('This Chat ID is already taken. Choose another.');
        }
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedMyAliasKey, alias);
      await _restoreIdentity(userId);
    } on aw.AppwriteException catch (e) {
      if (mounted && !_exited) {
        setState(() => _error = _explainAppwriteError(e));
      }
    } on FormatException catch (e) {
      if (mounted && !_exited) setState(() => _error = e.message);
    } catch (_) {
      if (mounted && !_exited) {
        setState(() => _error = 'Could not create ID. Check your internet connection.');
      }
    } finally {
      if (mounted && !_exited) setState(() => _sending = false);
    }
  }

  String _explainAppwriteError(aw.AppwriteException e) {
    final message = (e.message ?? '').toLowerCase();
    if (message.contains('origin') || message.contains('platform')) {
      return 'One-time Appwrite setup needed: add an Android platform '
          'using package $_androidPackage in Appwrite Project > Apps.';
    }
    if (message.contains('permission') || e.code == 401) {
      return 'Chat database access is not ready. Grant Users CREATE only '
          'to Private Messages and enable Row Security in Appwrite.';
    }
    if (e.code == 429) return 'Please wait a moment and try again.';
    return 'Could not connect (HTTP ${e.code ?? 'unknown'}). '
        '${e.message ?? 'Please check Appwrite settings.'}';
  }

  Future<void> _restoreIdentity(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final myAlias = prefs.getString(_savedMyAliasKey);
    final peer = prefs.getString(_savedPeerKey);
    final peerAlias = prefs.getString(_savedPeerAliasKey);
    if (_exited || !mounted) return;
    setState(() {
      _senderId = userId;
      _myChatId = myAlias;
      _myIdController.text = myAlias ?? '';
      _peerId = peer;
      _peerChatId = peerAlias ?? peer;
      _peerController.text = peerAlias ?? '';
      _error = null;
      _loading = false;
    });
    if (myAlias != null) await _startRealtime();
  }

  Future<void> _savePeer() async {
    final alias = _peerController.text.trim().toLowerCase();
    if (!RegExp(_aliasPattern).hasMatch(alias) || alias == _myChatId) {
      setState(() => _error = 'Enter the other person\'s Chat ID.');
      return;
    }
    setState(() { _sending = true; _error = null; });
    try {
      final profile = await _database.getRow(
        databaseId: StudyVerseAppwrite.databaseId,
        tableId: StudyVerseAppwrite.tableId,
        rowId: _aliasRowId(alias),
      );
      if (profile.data['kind'] != 'profile') {
        throw const FormatException('That Chat ID does not exist.');
      }
      final userId = profile.data['sender_id'] as String?;
      if (userId == null || userId == _senderId) {
        throw const FormatException('Enter another person\'s ID.');
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedPeerKey, userId);
      await prefs.setString(_savedPeerAliasKey, alias);
      if (_exited || !mounted) return;
      setState(() { _peerId = userId; _peerChatId = alias; _error = null; });
      await _startRealtime();
    } on aw.AppwriteException catch (e) {
      if (mounted && !_exited) {
        setState(() => _error = e.code == 404
          ? 'Chat ID not found. Ask the other person to create it first.'
          : _explainAppwriteError(e));
      }
    } on FormatException catch (e) {
      if (mounted && !_exited) setState(() => _error = e.message);
    } finally {
      if (mounted && !_exited) setState(() => _sending = false);
    }
  }

  Future<void> _startRealtime() async {
    _events?.cancel();
    _subscription?.unsubscribe();
    _subscription = null;
    await _loadMessages();
    if (_exited) return;
    _subscription = _realtime.subscribe([
      'tablesdb.${StudyVerseAppwrite.databaseId}.tables.${StudyVerseAppwrite.tableId}.rows',
    ]);
    _events = _subscription!.stream.listen((_) {
      if (!_exited) unawaited(_loadMessages());
    });
  }

  Future<void> _changeContact() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedPeerKey);
    await prefs.remove(_savedPeerAliasKey);
    await _events?.cancel();
    _subscription?.unsubscribe();
    _subscription = null;
    if (mounted && !_exited) {
      setState(() {
        _peerId = null;
        _peerChatId = null;
        _peerController.clear();
        _messages.clear();
      });
    }
  }

  Future<void> _loadMessages() async {
    if (_senderId == null || _exited) return;
    try {
      final result = await _database.listRows(
        databaseId: StudyVerseAppwrite.databaseId,
        tableId: StudyVerseAppwrite.tableId,
        queries: [aw.Query.orderDesc('\$createdAt'), aw.Query.limit(100)],
      );
      if (!mounted || _exited) return;
      final all = result.rows.reversed
          .map((row) => Map<String, dynamic>.from(row.data)).toList();
      // When the first inbound message arrives, the receiver needs no ID
      // search, QR scan or invitation. The sender becomes their one contact.
      final incoming = all.where((row) =>
          row['kind'] != 'profile' &&
          row['sender_id'] != _senderId &&
          (row['sender_id'] as String? ?? '').isNotEmpty);
      String? discoveredPeer;
      if (_peerId == null && incoming.isNotEmpty) {
        discoveredPeer = incoming.last['sender_id'] as String?;
      }
      if (discoveredPeer != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_savedPeerKey, discoveredPeer);
      }
      if (!mounted || _exited) return;
      setState(() {
        _peerId ??= discoveredPeer;
        _messages
          ..clear()
          ..addAll(all.where((row) =>
            row['kind'] != 'profile' &&
            (row['sender_id'] == _senderId ||
             row['sender_id'] == _peerId)));
        _error = null;
      });
    } catch (_) {
      if (mounted && !_exited) {
        setState(() => _error = 'Unable to load messages. Check permissions.');
      }
    }
  }

  Future<void> _sendRow({
    required String kind,
    String? body,
    String? fileId,
    int? durationSeconds,
  }) async {
    if (_exited || _senderId == null || _peerId == null) return;
    await _database.createRow(
      databaseId: StudyVerseAppwrite.databaseId,
      tableId: StudyVerseAppwrite.tableId,
      rowId: aw.ID.unique(),
      data: {
        'sender_id': _senderId!,
        'kind': kind,
        'body': body,
        'file_id': fileId,
        'duration_seconds': durationSeconds,
      },
      permissions: [
        aw.Permission.read(aw.Role.user(_senderId!)),
        aw.Permission.read(aw.Role.user(_peerId!)),
      ],
    );
    if (!_exited) await _loadMessages();
  }

  Future<void> _sendText() async {
    final text = _text.text.trim();
    if (_sending || text.isEmpty || text.length > 4000) return;
    setState(() => _sending = true);
    try {
      await _sendRow(kind: 'text', body: text);
      if (!_exited) _text.clear();
    } catch (_) {
      _notice('Message not sent. Check internet and table permissions.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _uploadMedia({
    required Uint8List bytes,
    required String name,
    required String contentType,
    required String kind,
    int? durationSeconds,
  }) async {
    if (bytes.isEmpty || bytes.length > 10 * 1024 * 1024) {
      throw const FormatException('Files must be less than 10 MB.');
    }
    if (_exited || _senderId == null || _peerId == null) return;
    final file = await _storage.createFile(
      bucketId: StudyVerseAppwrite.bucketId,
      fileId: aw.ID.unique(),
      file: aw.InputFile.fromBytes(
        bytes: bytes, filename: name, contentType: contentType),
      permissions: [
        aw.Permission.read(aw.Role.user(_senderId!)),
        aw.Permission.read(aw.Role.user(_peerId!)),
        aw.Permission.delete(aw.Role.user(_senderId!)),
      ],
    );
    try {
      if (_exited) throw const FormatException('Chat closed before sending.');
      await _sendRow(
        kind: kind, fileId: file.$id, durationSeconds: durationSeconds);
    } catch (_) {
      try {
        await _storage.deleteFile(
          bucketId: StudyVerseAppwrite.bucketId, fileId: file.$id);
      } catch (_) { /* Orphan cleanup is best effort. */ }
      rethrow;
    }
  }

  Future<void> _sendImage() async {
    if (_sending || _exited || _senderId == null) return;
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600, imageQuality: 82,
        requestFullMetadata: false,
      );
      if (picked == null || _exited) return;
      setState(() => _sending = true);
      final lower = picked.name.toLowerCase();
      final mime = lower.endsWith('.png')
          ? 'image/png'
          : lower.endsWith('.webp') ? 'image/webp' : 'image/jpeg';
      final name = mime == 'image/png'
          ? 'photo.png' : mime == 'image/webp' ? 'photo.webp' : 'photo.jpg';
      await _uploadMedia(
        bytes: await picked.readAsBytes(),
        name: name,
        contentType: mime,
        kind: 'image',
      );
    } catch (e) {
      _notice(e is FormatException ? e.message : 'Photo was not sent.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _toggleVoice() async {
    if (_sending || _exited) return;
    if (!_recording) {
      try {
        if (!await _recorder.hasPermission()) {
          throw const FormatException('Allow microphone to record a voice note.');
        }
        final folder = await getTemporaryDirectory();
        final path = '${folder.path}/studyverse-${DateTime.now().microsecondsSinceEpoch}.m4a';
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            numChannels: 1,
            bitRate: 96000,
          ),
          path: path,
        );
        _recordingPath = path;
        _recordingStarted = DateTime.now();
        if (mounted && !_exited) setState(() => _recording = true);
      } catch (e) {
        _notice(e is FormatException ? e.message : 'Recording failed.');
      } finally {
      }
      return;
    }
    if (mounted) setState(() { _recording = false; _sending = true; });
    String? path;
    try {
      path = await _recorder.stop();
      final elapsed = DateTime.now()
          .difference(_recordingStarted ?? DateTime.now()).inSeconds;
      if (elapsed < 1 || elapsed > 120) {
        throw const FormatException('Record 1–120 seconds only.');
      }
      if (path == null || _exited) return;
      await _uploadMedia(
        bytes: await File(path).readAsBytes(),
        name: 'voice.m4a',
        contentType: 'audio/mp4',
        kind: 'voice',
        durationSeconds: elapsed,
      );
    } catch (e) {
      _notice(e is FormatException ? e.message : 'Voice note not sent.');
    } finally {
      _recordingPath = null;
      _recordingStarted = null;
      final filePath = path;
      if (filePath != null) {
        try { await File(filePath).delete(); } catch (_) {}
      }
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _discardVoice() async {
    if (!_recording) return;
    setState(() => _recording = false);
    try { await _recorder.cancel(); } catch (_) {}
    final path = _recordingPath;
    _recordingPath = null;
    _recordingStarted = null;
    if (path != null) {
      try { await File(path).delete(); } catch (_) {}
    }
  }

  void _notice(String message) {
    if (mounted && !_exited) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _quickExit() {
    if (_exited || !mounted) return;
    _exited = true;
    _text.clear();
    unawaited(_closeMedia());
    widget.onQuickExit();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _closeMedia() async {
    try {
      if (_recording) await _recorder.cancel();
      await _recorder.dispose();
    } catch (_) {}
    final path = _recordingPath;
    if (path != null) {
      try { await File(path).delete(); } catch (_) {}
    }
  }

  @override
  void dispose() {
    _exited = true;
    _events?.cancel();
    _subscription?.unsubscribe();
    unawaited(_realtime.disconnect());
    unawaited(_closeMedia());
    _myIdController.dispose();
    _peerController.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget main;
    if (!StudyVerseAppwrite.configured) {
      main = const Center(child: Text('Private chat backend not configured.'));
    } else if (_loading) {
      main = const Center(child: CircularProgressIndicator());
    } else if (_senderId == null) {
      main = ListView(padding: const EdgeInsets.all(24), children: [
        const SizedBox(height: 50),
        const Icon(Icons.favorite, size: 55, color: Color(0xFFE85283)),
        const SizedBox(height: 18),
        const Center(child: Text('अपनी चैट ID बनाएँ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
        const SizedBox(height: 8),
        const Text('एक बार ID बनेगी। ईमेल, पासवर्ड या QR की जरूरत नहीं।',
          textAlign: TextAlign.center),
        const SizedBox(height: 22),
        FilledButton(
          onPressed: _sending ? null : _createMyChatId,
          child: Text(_sending ? 'ID बन रही है…' : 'Create My Chat ID'),
        ),
        if (_error != null) Padding(
          padding: const EdgeInsets.all(12),
          child: SelectableText(_error!, style: const TextStyle(color: Colors.red))),
        const SizedBox(height: 12),
        const Text('Android Package Name (Appwrite Apps में register करें):',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12)),
        Center(child: TextButton.icon(
          onPressed: () {
            Clipboard.setData(const ClipboardData(text: _androidPackage));
            _notice('Android package copied');
          },
          icon: const Icon(Icons.copy),
          label: const Text(_androidPackage),
        )),
      ]);
    } else if (_peerId == null) {
      main = ListView(padding: const EdgeInsets.all(24), children: [
        const SizedBox(height: 20),
        const Text('मेरी चैट ID',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 8),
        SelectableText(_senderId!,
            style: const TextStyle(fontWeight: FontWeight.w700,
                color: Color(0xFF9C375F), fontSize: 16)),
        TextButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _senderId!));
            _notice('तुम्हारी ID कॉपी हो गई');
          },
          icon: const Icon(Icons.copy),
          label: const Text('Copy My ID'),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _peerController,
          autocorrect: false,
          enableSuggestions: false,
          decoration: const InputDecoration(
            labelText: 'सामने वाले की Chat ID',
            hintText: 'Paste Chat ID'),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _savePeer,
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('Start Chat'),
        ),
        const SizedBox(height: 14),
        const Text(
          'दूसरा व्यक्ति अपने फोन पर ऐप खोलकर अपनी ID बनाए और तुम्हें '
          'वह ID बताए। फिर एक-दूसरे को सीधे मैसेज भेज सकते हो। '
          'ID इस फोन के अनाम अकाउंट से जुड़ी है; ऐप हटाने या डेटा साफ़ '
          'करने पर ID वापस नहीं मिल भी सकती है।',
          style: TextStyle(fontSize: 12, color: Color(0xFF737087))),
        if (_error != null) Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(_error!, style: const TextStyle(color: Colors.red))),
      ]);
    } else {
      main = Column(children: [
        if (_error != null) Padding(
          padding: const EdgeInsets.all(8),
          child: Text(_error!, style: const TextStyle(color: Colors.red))),
        Expanded(child: _messages.isEmpty
          ? const Center(child: Text('Private chat ready ♥'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final item = _messages[index];
                final mine = item['sender_id'] == _senderId;
                return Align(
                  alignment: mine ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth:
                      MediaQuery.sizeOf(context).width * .8),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: mine ? const Color(0xFFE85283)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: item['kind'] == 'text'
                        ? Text(item['body'] as String? ?? '',
                            style: TextStyle(color: mine
                                ? Colors.white : const Color(0xFF273044)))
                        : AppwriteMediaBubble(
                            key: ValueKey(item['file_id']),
                            fileId: item['file_id'] as String? ?? '',
                            voice: item['kind'] == 'voice',
                            durationSeconds: item['duration_seconds'] as int?,
                            storage: _storage, mine: mine,
                          ),
                  ),
                );
              },
            )),
        Container(
          color: const Color(0xFFFFE1EB),
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            if (!_recording) IconButton(
              tooltip: 'Send photo',
              onPressed: _sending ? null : _sendImage,
              icon: const Icon(Icons.add_photo_alternate_outlined)),
            if (_recording) IconButton(
              tooltip: 'Discard recording', onPressed: _discardVoice,
              icon: const Icon(Icons.close, color: Colors.red)),
            Expanded(child: _recording
                ? const Text('Recording voice…',
                    style: TextStyle(color: Color(0xFFB43A67)))
                : TextField(controller: _text, minLines: 1, maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Message…'))),
            IconButton(
              tooltip: _recording ? 'Stop and send voice'
                  : 'Start voice note',
              onPressed: _sending ? null : _toggleVoice,
              icon: Icon(_recording ? Icons.stop_circle : Icons.mic)),
            if (!_recording) IconButton.filled(
              tooltip: 'Send message',
              onPressed: _sending ? null : _sendText,
              icon: const Icon(Icons.send)),
          ]),
        ),
      ]);
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _quickExit();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF3F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFE1EB),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _quickExit,
          ),
          title: const Text('Private Space ♥'),
          actions: [
            if (_senderId != null && _peerId != null)
              IconButton(
                tooltip: 'Change Chat ID',
                icon: const Icon(Icons.person_search_outlined),
                onPressed: _changeContact,
              ),
            IconButton(
              tooltip: 'Return to studying',
              icon: const Icon(Icons.menu_book_outlined),
              onPressed: _quickExit,
            ),
          ],
        ),
        body: SafeArea(child: main),
      ),
    );
  }
}

/// Private file bytes are fetched only after Appwrite verifies the session
/// and file-level read permission. No public URL is generated.
class AppwriteMediaBubble extends StatefulWidget {
  final String fileId;
  final bool voice;
  final int? durationSeconds;
  final aw.Storage storage;
  final bool mine;
  const AppwriteMediaBubble({
    super.key, required this.fileId, required this.voice,
    required this.durationSeconds, required this.storage,
    required this.mine,
  });
  @override
  State<AppwriteMediaBubble> createState() => _AppwriteMediaBubbleState();
}

class _AppwriteMediaBubbleState extends State<AppwriteMediaBubble> {
  late Future<Uint8List> _download;
  final _player = AudioPlayer();
  File? _audioFile;
  bool _playing = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    _download = widget.storage.getFileDownload(
      bucketId: StudyVerseAppwrite.bucketId,
      fileId: widget.fileId,
    );
  }

  Future<void> _togglePlay() async {
    if (_busy) return;
    if (_playing) {
      await _player.pause();
      if (mounted) setState(() => _playing = false);
      return;
    }
    setState(() => _busy = true);
    try {
      if (_audioFile == null) {
        final bytes = await _download;
        final folder = await getTemporaryDirectory();
        final file = File('${folder.path}/audio-${widget.fileId}.m4a');
        await file.writeAsBytes(bytes, flush: true);
        _audioFile = file;
        await _player.setFilePath(file.path);
      }
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }
      if (mounted) setState(() => _playing = true);
      await _player.play();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to play private voice note.')));
      }
    } finally {
      if (mounted) setState(() { _playing = false; _busy = false; });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    final temp = _audioFile;
    if (temp != null) unawaited(temp.delete().catchError((_) => temp));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.voice
      ? Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            onPressed: _togglePlay,
            icon: Icon(_playing ? Icons.pause_circle
                : Icons.play_circle_filled,
              color: widget.mine ? Colors.white
                : const Color(0xFFE85283))),
          Text(_busy ? 'Loading…'
            : 'Voice note ${widget.durationSeconds ?? 0}s',
            style: TextStyle(color: widget.mine ? Colors.white
                : const Color(0xFF273044))),
        ])
      : FutureBuilder<Uint8List>(
          future: _download,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return TextButton(
                onPressed: () => setState(_fetch),
                child: const Text('Retry private photo'));
            }
            if (!snapshot.hasData) {
              return const SizedBox(width: 150, height: 150,
                child: Center(child: CircularProgressIndicator()));
            }
            return GestureDetector(
              onTap: () => showDialog<void>(
                context: context,
                builder: (context) => Dialog(
                  child: InteractiveViewer(
                    child: Image.memory(snapshot.data!,
                      fit: BoxFit.contain)))),
              child: Image.memory(
                snapshot.data!, width: 200, height: 210,
                fit: BoxFit.cover),
            );
          },
        );
}
