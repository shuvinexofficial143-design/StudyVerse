import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'chat_media.dart';
import 'chat_media_bubble.dart';
import 'appwrite_private_chat.dart';

const _secureStore = FlutterSecureStorage();
const _pinKey = 'studyverse_private_vault_pin_v1';

class VaultScreen extends StatefulWidget {
  final bool onlineConfigured;
  final VoidCallback onQuickExit;
  const VaultScreen({super.key, required this.onlineConfigured,
    required this.onQuickExit});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final _controller = TextEditingController();
  bool loading = true;
  bool newPin = false;
  String? firstPin;
  String message = 'Enter your private access code';
  int failedAttempts = 0;
  DateTime? blockedUntil;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final current = await _secureStore.read(key: _pinKey);
    if (mounted) {
      setState(() {
        newPin = current == null;
        loading = false;
        message = newPin ? 'Create a private access code' : 'Enter your access code';
      });
    }
  }

  Future<void> _submit() async {
    final pin = _controller.text.trim();
    _controller.clear();
    if (!RegExp(r'^[a-zA-Z0-9]{6,32}$').hasMatch(pin)) {
      setState(() => message = 'Use 6–32 letters and numbers');
      return;
    }
    if (blockedUntil != null && DateTime.now().isBefore(blockedUntil!)) {
      setState(() => message = 'Too many attempts. Try again later.');
      return;
    }
    if (newPin) {
      if (firstPin == null) {
        setState(() {
          firstPin = pin;
          message = 'Confirm your new PIN';
        });
        return;
      }
      if (firstPin != pin) {
        setState(() {
          firstPin = null;
          message = 'PINs did not match. Create it again.';
        });
        return;
      }
      await _secureStore.write(key: _pinKey, value: pin);
    } else {
      final saved = await _secureStore.read(key: _pinKey);
      if (pin != saved) {
        failedAttempts++;
        if (failedAttempts >= 5) {
          blockedUntil = DateTime.now().add(const Duration(minutes: 1));
          failedAttempts = 0;
        }
        if (mounted) {
          setState(() {
            message = blockedUntil == null
                ? 'Incorrect PIN' : 'Too many attempts. Wait one minute.';
          });
        }
        return;
      }
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => StudyVerseAppwrite.configured
          ? AppwritePrivateChatScreen(onQuickExit: widget.onQuickExit)
          : PrivateChatScreen(
              onlineConfigured: widget.onlineConfigured,
              onQuickExit: widget.onQuickExit,
            ),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Resource Vault')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Center(child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Icon(Icons.lock_rounded, color: studyBlue, size: 80),
                    const SizedBox(height: 22),
                    const Center(child: Text('Your private space',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900))),
                    const SizedBox(height: 8),
                    Center(child: Text(message, textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF71809A)))),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      textAlign: TextAlign.center,
                      maxLength: 32,
                      autocorrect: false,
                      enableSuggestions: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Private access code', counterText: ''),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _submit,
                      child: Text(newPin ? 'Continue' : 'Unlock')),
                    const SizedBox(height: 9),
                    TextButton(onPressed: () => Navigator.pop(context),
                      child: const Text('Return to StudyVerse')),
                    if (newPin)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          'Choose your own private code on each device. '
                          'The code is stored securely on the device, not in GitHub.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Color(0xFF74829A)),
                        )),
                  ],
                ),
              )),
      );
}

class PrivateChatScreen extends StatefulWidget {
  final bool onlineConfigured;
  final VoidCallback onQuickExit;
  const PrivateChatScreen({super.key, required this.onlineConfigured,
    required this.onQuickExit});

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final input = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  String? pairId;
  String? failure;
  bool waiting = false;
  bool sending = false;
  bool signingIn = false;
  bool exited = false;
  bool recording = false;
  bool uploadingMedia = false;
  bool mediaCleaned = false;
  bool externalPickerOpen = false;
  ChatMediaService? media;

  SupabaseClient get client => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.onlineConfigured) {
      media = ChatMediaService(client);
      _loadPair();
    }
  }

  void _quickExit() {
    if (exited || !mounted) return;
    exited = true;
    input.clear();
    unawaited(_disposeMedia());
    widget.onQuickExit();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _disposeMedia() async {
    if (mediaCleaned) return;
    mediaCleaned = true;
    final service = media;
    if (service == null) return;
    try {
      if (recording) {
        await service.cancelVoiceRecording();
      }
      await service.dispose();
    } catch (_) {
      // Best effort cleanup on leaving the private route.
    }
  }

  void _showMediaError(Object error) {
    if (!mounted || exited) return;
    final text = error is FormatException
        ? error.message
        : 'Could not send media. Check private storage and your connection.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)));
  }

  Future<void> _sendImage() async {
    final service = media;
    final pair = pairId;
    if (service == null || pair == null || uploadingMedia || exited) return;
    setState(() { uploadingMedia = true; externalPickerOpen = true; });
    try {
      await service.pickAndSendImage(pair);
    } catch (error) {
      _showMediaError(error);
    } finally {
      if (mounted && !exited) {
        setState(() { uploadingMedia = false; externalPickerOpen = false; });
      }
    }
  }

  Future<void> _toggleVoice() async {
    final service = media;
    final pair = pairId;
    if (service == null || pair == null || uploadingMedia || exited) return;
    if (!recording) {
      setState(() { externalPickerOpen = true; });
      try {
        await service.startVoiceRecording();
        if (mounted && !exited) setState(() => recording = true);
      } catch (error) {
        _showMediaError(error);
      } finally {
        if (mounted && !exited) setState(() => externalPickerOpen = false);
      }
    } else {
      setState(() { uploadingMedia = true; recording = false; });
      try {
        await service.stopVoiceAndSend(pair);
      } catch (error) {
        _showMediaError(error);
      } finally {
        if (mounted && !exited) setState(() => uploadingMedia = false);
      }
    }
  }

  Future<void> _cancelVoice() async {
    if (!recording || media == null) return;
    setState(() { recording = false; });
    try {
      await media!.cancelVoiceRecording();
    } catch (error) {
      _showMediaError(error);
    }
  }

  Future<void> _loadPair() async {
    if (!widget.onlineConfigured) return;
    if (client.auth.currentUser == null) {
      if (mounted) {
        setState(() {
          pairId = null;
          waiting = false;
        });
      }
      return;
    }
    setState(() {waiting = true; failure = null;});
    try {
      final result = await client
          .from('study_pairs')
          .select('id')
          .limit(1)
          .maybeSingle();
      if (!mounted || exited) return;
      setState(() {
        pairId = result?['id'] as String?;
        if (pairId == null) {
          failure = 'No private pair configured for this account. '
              'Ask the owner to set up the two approved accounts.';
        }
      });
    } catch (error) {
      if (mounted && !exited) setState(() => failure = 'Cannot load chat: $error');
    } finally {
      if (mounted && !exited) setState(() => waiting = false);
    }
  }

  Future<void> _signIn() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) return;
    setState(() {signingIn = true; failure = null;});
    try {
      await client.auth.signInWithPassword(
        email: email.text.trim(), password: password.text);
      password.clear();
      await _loadPair();
    } on AuthException catch (error) {
      if (mounted) setState(() => failure = error.message);
    } catch (_) {
      if (mounted) setState(() => failure = 'Sign-in failed. Please retry.');
    } finally {
      if (mounted) setState(() => signingIn = false);
    }
  }

  Future<void> _sendMessage() async {
    final body = input.text.trim();
    if (body.isEmpty || pairId == null || sending || exited) return;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;
    setState(() => sending = true);
    try {
      await client.from('messages').insert({
        'pair_id': pairId, 'sender_id': userId, 'body': body,
      });
      if (mounted && !exited) input.clear();
    } catch (_) {
      if (mounted && !exited) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Message not sent. Check your connection.')));
      }
    } finally {
      if (mounted && !exited) setState(() => sending = false);
    }
  }

  @override
  void dispose() {
    unawaited(_disposeMedia());
    input.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (!widget.onlineConfigured) {
      content = const _ChatNotice(
        icon: Icons.cloud_off_outlined,
        title: 'Private chat setup pending',
        description:
          'The study features are ready. To chat between two distant phones, '
          'connect a dedicated Supabase project at build time and create the '
          'two authorised accounts.',
      );
    } else if (client.auth.currentUser == null) {
      content = ListView(padding: const EdgeInsets.all(20), children: [
        const SizedBox(height: 28),
        const Icon(Icons.lock_person_outlined, color: studyBlue, size: 68),
        const SizedBox(height: 16),
        const Center(child: Text('Sign in to your private space',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19))),
        const SizedBox(height: 16),
        TextField(controller: email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email address')),
        const SizedBox(height: 12),
        TextField(controller: password, obscureText: true,
          decoration: const InputDecoration(labelText: 'Password')),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: signingIn ? null : _signIn,
          child: Text(signingIn ? 'Signing in...' : 'Sign in'),
        ),
        const SizedBox(height: 12),
        const Text('Accounts are invite-only. Public sign-up is disabled in the app.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Color(0xFF76849B))),
        if (failure != null) Padding(
          padding: const EdgeInsets.all(12),
          child: Text(failure!, style: const TextStyle(color: Colors.red)),
        ),
      ]);
    } else if (waiting) {
      content = const Center(child: CircularProgressIndicator());
    } else if (pairId == null) {
      content = _ChatNotice(icon: Icons.people_outline,
        title: 'Pair not connected',
        description: failure ?? 'The pair must be configured in your database.');
    } else {
      content = _buildMessages();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _quickExit();
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFFFF5F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE6EE),
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Private Space ♥',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19)),
            Text('Private • Lock on exit',
              style: TextStyle(fontSize: 11, color: Color(0xFF76849B))),
          ]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _quickExit,
        ),
        actions: [
          IconButton(
            tooltip: 'Switch to study',
            onPressed: _quickExit,
            icon: const Icon(Icons.menu_book_outlined, color: studyBlue),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF4F8), Color(0xFFFFEDF3),
                    Color(0xFFFFF9F9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _LoveHeartsPainter()),
            ),
          ),
          Column(children: [
        Expanded(child: content),
        if (pairId != null && widget.onlineConfigured)
          Container(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 12),
            color: const Color(0xFFFFEAF0),
            child: Row(children: [
              if (!recording)
                IconButton(
                  tooltip: 'Send photo from gallery',
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  onPressed: uploadingMedia ? null : _sendImage,
                ),
              if (recording)
                IconButton(
                  tooltip: 'Discard voice note',
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  onPressed: _cancelVoice,
                ),
              Expanded(child: recording
                ? const Text('Recording… tap microphone to send',
                    style: TextStyle(color: Color(0xFFAC325A)))
                : TextField(
                controller: input,
                maxLines: 4, minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                ),
              )),
              const SizedBox(width: 8),
              if (!recording)
                IconButton(
                  tooltip: 'Record voice note',
                  icon: const Icon(Icons.mic_outlined),
                  onPressed: uploadingMedia ? null : _toggleVoice,
                ),
              if (recording)
                IconButton.filled(
                  tooltip: 'Stop and send voice note',
                  onPressed: uploadingMedia ? null : _toggleVoice,
                  icon: const Icon(Icons.stop_circle_outlined),
                ),
              if (!recording)
                IconButton.filled(
                  tooltip: 'Send text message',
                  onPressed: sending || uploadingMedia ? null : _sendMessage,
                  icon: Icon(sending || uploadingMedia
                      ? Icons.hourglass_empty : Icons.send),
                ),
            ]),
          ),
          ]),
        ],
      ),
    ),
    );
  }

  Widget _buildMessages() {
    final stream = client.from('messages')
        .stream(primaryKey: ['id'])
        .eq('pair_id', pairId!)
        .order('created_at');
    final self = client.auth.currentUser?.id;
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text(
            'Could not load messages. Check permissions and internet.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final messages = snapshot.data!;
        if (messages.isEmpty) {
          return const Center(
            child: Text('Your chat is ready. Say hello 👋'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final item = messages[index];
            final mine = item['sender_id'] == self;
            return Align(
              alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * .78),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: mine ? const Color(0xFFE85283) : Colors.white,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: (item['message_type'] == 'image' ||
                        item['message_type'] == 'voice')
                    ? ChatMediaBubble(
                        key: ValueKey(item['id']),
                        message: item,
                        client: client,
                        mine: mine,
                      )
                    : Text(item['body'] as String? ?? '',
                        style: TextStyle(
                          color: mine ? Colors.white : studyInk,
                          fontSize: 15,
                        )),
              ),
            );
          },
        );
      },
    );
  }
}

class _ChatNotice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _ChatNotice({
    required this.icon, required this.title, required this.description,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: StudyPanel(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: studyBlue),
              const SizedBox(height: 15),
              Text(title, textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 19)),
              const SizedBox(height: 8),
              Text(description, textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7D97))),
            ],
          )),
        ),
      );
}

/// Lightweight illustrated hearts: decorative only, no external assets.
class _LoveHeartsPainter extends CustomPainter {
  const _LoveHeartsPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x33EB799F)
      ..style = PaintingStyle.fill;
    const spots = <Offset>[
      Offset(.12, .10), Offset(.80, .18), Offset(.46, .34),
      Offset(.90, .57), Offset(.16, .72), Offset(.61, .90),
    ];
    for (var index = 0; index < spots.length; index++) {
      final point = spots[index];
      final x = point.dx * size.width;
      final y = point.dy * size.height;
      final radius = (index % 3 + 1) * 6.0;
      final path = Path()
        ..moveTo(x, y + radius)
        ..cubicTo(x - radius * 2.1, y, x - radius,
            y - radius * 1.7, x, y - radius * .45)
        ..cubicTo(x + radius, y - radius * 1.7,
            x + radius * 2.1, y, x, y + radius)
        ..close();
      canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
