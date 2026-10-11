import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'chat_media.dart';

/// Renders a media item only after signed access has been authorised by
/// private Supabase Storage policy. There are no publicly accessible URLs.
class ChatMediaBubble extends StatefulWidget {
  const ChatMediaBubble({
    super.key,
    required this.message,
    required this.client,
    required this.mine,
  });

  final Map<String, dynamic> message;
  final SupabaseClient client;
  final bool mine;

  @override
  State<ChatMediaBubble> createState() => _ChatMediaBubbleState();
}

class _ChatMediaBubbleState extends State<ChatMediaBubble> {
  late Future<String> _url;
  AudioPlayer? _player;
  bool _playing = false;
  bool _loading = false;
  bool _audioLoaded = false;
  String? _error;

  bool get _voice => widget.message['message_type'] == 'voice';

  @override
  void initState() {
    super.initState();
    _refreshUrl();
    if (_voice) _player = AudioPlayer();
  }

  void _refreshUrl() {
    final path = widget.message['storage_path'] as String? ?? '';
    _url = widget.client.storage
        .from(ChatMediaService.bucket)
        .createSignedUrl(path, 120);
  }

  Future<void> _playOrPause() async {
    final player = _player;
    if (player == null || _loading) return;
    if (_playing) {
      await player.pause();
      if (mounted) setState(() => _playing = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (!_audioLoaded) {
        await player.setUrl(await _url);
        _audioLoaded = true;
      }
      if (player.processingState == ProcessingState.completed) {
        await player.seek(Duration.zero);
      }
      if (!mounted) return;
      setState(() { _playing = true; _loading = false; });
      await player.play();
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Could not play recording';
          _audioLoaded = false;
          _refreshUrl();
        });
      }
    } finally {
      if (mounted) {
        setState(() { _playing = false; _loading = false; });
      }
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_voice) {
      final length = widget.message['duration_seconds'] as int? ?? 0;
      return SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              IconButton(
                icon: Icon(_playing ? Icons.pause_circle_filled
                    : Icons.play_circle_fill, size: 31),
                onPressed: _playOrPause,
                tooltip: _playing ? 'Pause voice note' : 'Play voice note',
                color: widget.mine ? Colors.white : const Color(0xFFE85283),
              ),
              const SizedBox(width: 4),
              Expanded(child: Text(_loading ? 'Loading audio…'
                  : 'Voice note • ${length}s',
                style: TextStyle(color: widget.mine
                  ? Colors.white : const Color(0xFF40394A)))),
            ]),
            if (_error != null) Text(_error!,
              style: const TextStyle(fontSize: 11, color: Colors.red)),
          ],
        ),
      );
    }
    return FutureBuilder<String>(
      future: _url,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return TextButton.icon(
            onPressed: () => setState(_refreshUrl),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry photo'),
          );
        }
        if (!snapshot.hasData) {
          return const SizedBox(height: 130, width: 190,
            child: Center(child: CircularProgressIndicator()));
        }
        final url = snapshot.data!;
        return InkWell(
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (dialogContext) => Dialog(
                insetPadding: const EdgeInsets.all(12),
                child: InteractiveViewer(
                  child: Image.network(url, fit: BoxFit.contain),
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              width: 215,
              height: 230,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(
                    height: 95, width: 180,
                    child: Center(child: Text('Image unavailable')),
                  ),
            ),
          ),
        );
      },
    );
  }
}
