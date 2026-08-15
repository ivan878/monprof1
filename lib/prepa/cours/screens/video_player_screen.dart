// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/corps/utils/local_storage/hive_service.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String filePath;
  final String? title;
  final String coursId;
  final String? matiereId;
  final String? videoUrl;

  const VideoPlayerScreen({
    super.key,
    required this.filePath,
    required this.coursId,
    this.matiereId,
    this.title,
    this.videoUrl,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  // ── Player ──────────────────────────────────────────────────────────────────
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  // ── Controls visibility ─────────────────────────────────────────────────────
  bool _showControls = true;
  Timer? _controlsTimer;

  // ── Seek bar ────────────────────────────────────────────────────────────────
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _seekValue = 0.0;
  bool _isDraggingSeek = false;

  // ── Volume (video-level, 0.0–1.0) ───────────────────────────────────────────
  double _videoVolume = 1.0;

  // ── Brightness (system, 0.0–1.0) ────────────────────────────────────────────
  double _brightness = 0.5;
  double _initialBrightness = 0.5;

  // ── Drag gesture state ───────────────────────────────────────────────────────
  bool _isDragging = false;
  bool _dragOnLeft = true; // left = brightness, right = volume
  _OverlayKind? _overlayKind;
  double _overlayValue = 0.0;
  Timer? _overlayHideTimer;

  // ── Seek-flash state ─────────────────────────────────────────────────────────
  bool _flashRewind = false;
  bool _flashForward = false;
  Timer? _flashTimer;

  // ── Hive ────────────────────────────────────────────────────────────────────
  late final HiveService _hive;
  Timer? _positionSaveTimer;

  // ── Buffering ────────────────────────────────────────────────────────────────
  bool _isBuffering = false;

  // ── Plein écran : true = l'image remplit l'écran (rognée), false = adaptée ──
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _hive = GetIt.instance<HiveService>();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _loadBrightness();
    _initPlayer();
  }

  Future<void> _loadBrightness() async {
    try {
      _initialBrightness = await ScreenBrightness().current;
      _brightness = _initialBrightness;
    } catch (_) {}
  }

  Future<void> _initPlayer() async {
    try {
      final file = File(widget.filePath);
      if (!await file.exists()) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage =
                'Le fichier vidéo est introuvable.\nVeuillez le télécharger à nouveau.';
          });
        }
        return;
      }

      final ctrl = VideoPlayerController.file(file);
      await ctrl.initialize();

      // Seek to saved position
      final saved = _hive.getPlaybackPosition(widget.coursId, widget.matiereId);
      Duration startPos = Duration.zero;
      if (saved != null && saved.positionMs > 0) {
        final candidate = Duration(milliseconds: saved.positionMs);
        // Don't resume if within last 3s (considered finished)
        if (ctrl.value.duration.inMilliseconds - saved.positionMs > 3000) {
          startPos = candidate;
        }
      }
      if (startPos > Duration.zero) await ctrl.seekTo(startPos);

      ctrl.addListener(_onValueChanged);
      await ctrl.play();

      if (mounted) {
        setState(() {
          _controller = ctrl;
          _isInitialized = true;
          _duration = ctrl.value.duration;
          _position = startPos;
          _videoVolume = 1.0;
        });
      }

      // Auto-save position every 5 s
      _positionSaveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (_controller?.value.isPlaying == true) _persistPosition();
      });

      _scheduleControlsHide();
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage =
              'Impossible de lire la vidéo.\nFormat non supporté ou fichier corrompu.';
        });
      }
    }
  }

  void _onValueChanged() {
    if (!mounted) return;
    final v = _controller!.value;
    if (!_isDraggingSeek) {
      setState(() {
        _position = v.position;
        _seekValue = _duration.inMilliseconds > 0
            ? v.position.inMilliseconds / _duration.inMilliseconds
            : 0;
        _isBuffering = v.isBuffering;
      });
    }
    // When playback ends → save as fully watched
    if (!v.isPlaying && v.position >= v.duration && v.duration > Duration.zero) {
      _persistPosition(force: true);
    }
  }

  void _persistPosition({bool force = false}) {
    final ctrl = _controller;
    if (ctrl == null || !_isInitialized) return;
    final posMs = ctrl.value.position.inMilliseconds;
    final totMs = ctrl.value.duration.inMilliseconds;
    if (posMs <= 0 && !force) return;
    _hive.savePlaybackPosition(
      coursId: widget.coursId,
      matiereId: widget.matiereId,
      positionMs: posMs,
      totalMs: totMs,
      title: widget.title,
      filePath: widget.filePath,
      videoUrl: widget.videoUrl,
    );
  }

  // ── Controls timer ───────────────────────────────────────────────────────────

  void _scheduleControlsHide() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller?.value.isPlaying == true) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleControlsHide();
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    _scheduleControlsHide();
  }

  /// Sortie explicite : la position est écrite AVANT le pop pour que l'écran
  /// appelant lise une valeur à jour dès que son `await` se termine.
  void _exit() {
    _persistPosition();
    Navigator.pop(context);
  }

  // ── Double-tap seek ──────────────────────────────────────────────────────────

  TapDownDetails? _lastDoubleTapDetails;

  void _onDoubleTapDown(TapDownDetails d) => _lastDoubleTapDetails = d;

  void _onDoubleTap() {
    final d = _lastDoubleTapDetails;
    if (d == null || _controller == null) return;
    final w = MediaQuery.of(context).size.width;
    final isLeft = d.localPosition.dx < w / 2;
    final delta = Duration(seconds: isLeft ? -5 : 5);
    var newPos = _controller!.value.position + delta;
    if (newPos < Duration.zero) newPos = Duration.zero;
    if (newPos > _duration) newPos = _duration;
    _controller!.seekTo(newPos);
    _scheduleControlsHide();

    _flashTimer?.cancel();
    setState(() {
      _flashRewind = isLeft;
      _flashForward = !isLeft;
    });
    _flashTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() { _flashRewind = false; _flashForward = false; });
    });
  }

  // ── Vertical drag (brightness / volume) ─────────────────────────────────────

  void _onVerticalDragStart(DragStartDetails d) {
    _isDragging = true;
    _dragOnLeft = d.localPosition.dx < MediaQuery.of(context).size.width / 2;
    _overlayKind = _dragOnLeft ? _OverlayKind.brightness : _OverlayKind.volume;
    _overlayValue = _dragOnLeft ? _brightness : _videoVolume;
    _controlsTimer?.cancel();
    setState(() {});
  }

  void _onVerticalDragUpdate(DragUpdateDetails d) {
    if (!_isDragging) return;
    final screenH = MediaQuery.of(context).size.height;
    // Drag up → increase (delta.dy is negative when moving up)
    final delta = -d.delta.dy / screenH;

    if (_dragOnLeft) {
      _brightness = (_brightness + delta).clamp(0.0, 1.0);
      ScreenBrightness().setScreenBrightness(_brightness).catchError((_) {});
      setState(() => _overlayValue = _brightness);
    } else {
      _videoVolume = (_videoVolume + delta).clamp(0.0, 1.0);
      _controller?.setVolume(_videoVolume);
      setState(() => _overlayValue = _videoVolume);
    }
  }

  void _onVerticalDragEnd(DragEndDetails _) {
    _isDragging = false;
    _overlayHideTimer?.cancel();
    _overlayHideTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _overlayKind = null);
    });
    _scheduleControlsHide();
  }

  // ── Dispose ──────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _persistPosition();
    _positionSaveTimer?.cancel();
    _controlsTimer?.cancel();
    _overlayHideTimer?.cancel();
    _flashTimer?.cancel();
    _controller?.removeListener(_onValueChanged);
    _controller?.dispose();
    ScreenBrightness().setScreenBrightness(_initialBrightness).catchError((_) {});
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_hasError) return Scaffold(backgroundColor: Colors.black, body: _buildError());
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    return PopScope(
      // Retour système (geste ou bouton) : même garantie que la flèche de retour.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _persistPosition();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _buildPlayer(),
      ),
    );
  }

  Widget _buildPlayer() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ─ Video ──────────────────────────────────────────────────────────────
        _buildVideoSurface(),

        // ─ Buffering spinner ──────────────────────────────────────────────────
        if (_isBuffering)
          const Center(child: CircularProgressIndicator(color: Colors.white70)),

        // ─ Gesture layer (transparent) ────────────────────────────────────────
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControls,
          onDoubleTapDown: _onDoubleTapDown,
          onDoubleTap: _onDoubleTap,
          onVerticalDragStart: _onVerticalDragStart,
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
        ),

        // ─ Controls overlay ───────────────────────────────────────────────────
        IgnorePointer(
          ignoring: !_showControls,
          child: AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: _buildControls(),
          ),
        ),

        // ─ Seek flash ────────────────────────────────────────────────────────
        if (_flashRewind || _flashForward) _buildSeekFlash(),

        // ─ Brightness / Volume overlay ────────────────────────────────────────
        if (_overlayKind != null) _buildDragOverlay(),
      ],
    );
  }

  /// Deux rendus : « adapté » (letterbox, ratio respecté) et « plein écran »
  /// (l'image couvre tout l'écran, les bords débordants sont rognés).
  Widget _buildVideoSurface() {
    final ctrl = _controller!;
    if (!_isFullscreen) {
      return Center(
        child: AspectRatio(
          aspectRatio: ctrl.value.aspectRatio,
          child: VideoPlayer(ctrl),
        ),
      );
    }
    return SizedBox.expand(
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: ctrl.value.size.width,
            height: ctrl.value.size.height,
            child: VideoPlayer(ctrl),
          ),
        ),
      ),
    );
  }

  // ── Controls overlay ─────────────────────────────────────────────────────────

  Widget _buildControls() {
    final isPlaying = _controller!.value.isPlaying;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Top gradient bar
        Positioned(
          top: 0, left: 0, right: 0,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xBB000000), Colors.transparent],
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 4,
              left: 4,
              right: 16,
              bottom: 12,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _exit,
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white, size: 22),
                ),
                Expanded(
                  child: Text(
                    widget.title ?? 'Cours vidéo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Center play/pause
        Center(
          child: GestureDetector(
            onTap: () {
              isPlaying ? _controller!.pause() : _controller!.play();
              _scheduleControlsHide();
              setState(() {});
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
        ),

        // Bottom gradient bar + seek + time
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xBB000000), Colors.transparent],
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 8,
              left: 8,
              right: 8,
              top: 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Seek bar
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: Colors.red,
                    inactiveTrackColor: Colors.white38,
                    thumbColor: Colors.red,
                    overlayColor: Colors.red.withValues(alpha: 0.25),
                  ),
                  child: Slider(
                    value: _seekValue.clamp(0.0, 1.0),
                    onChangeStart: (_) {
                      _isDraggingSeek = true;
                      _controlsTimer?.cancel();
                    },
                    onChanged: (v) => setState(() {
                      _seekValue = v;
                      _position = Duration(
                          milliseconds: (_duration.inMilliseconds * v).round());
                    }),
                    onChangeEnd: (v) {
                      _controller!.seekTo(_position);
                      _isDraggingSeek = false;
                      _scheduleControlsHide();
                    },
                  ),
                ),

                // Time row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Text(_fmt(_position),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                      const Spacer(),
                      // Mute toggle
                      GestureDetector(
                        onTap: () {
                          final v = _videoVolume > 0 ? 0.0 : 1.0;
                          _videoVolume = v;
                          _controller!.setVolume(v);
                          setState(() {});
                          _scheduleControlsHide();
                        },
                        child: Icon(
                          _videoVolume > 0
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(_fmt(_duration),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                      const SizedBox(width: 12),
                      // Zoom / dézoom — plein écran (image rognée) ou adapté
                      GestureDetector(
                        onTap: _toggleFullscreen,
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          _isFullscreen
                              ? Icons.fullscreen_exit_rounded
                              : Icons.fullscreen_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Seek flash ────────────────────────────────────────────────────────────────

  Widget _buildSeekFlash() {
    return Row(
      children: [
        Expanded(
          child: _flashRewind
              ? Center(child: _SeekFlashBubble(label: '−5s', forward: false))
              : const SizedBox.shrink(),
        ),
        Expanded(
          child: _flashForward
              ? Center(child: _SeekFlashBubble(label: '+5s', forward: true))
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ── Brightness / Volume overlay ───────────────────────────────────────────────

  Widget _buildDragOverlay() {
    final isBrightness = _overlayKind == _OverlayKind.brightness;
    final icon = isBrightness
        ? (_overlayValue < 0.3
            ? Icons.brightness_2_rounded
            : Icons.brightness_7_rounded)
        : (_overlayValue == 0
            ? Icons.volume_off_rounded
            : Icons.volume_up_rounded);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 10),
            SizedBox(
              width: 130,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _overlayValue.clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: Colors.white30,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(_overlayValue * 100).round()}%',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.video_file_outlined, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Impossible de lire la vidéo.',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white70),
              // pas de position à persister : la vidéo n'a jamais démarré
              label: const Text('Retour',
                  style: TextStyle(color: Colors.white70)),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white30)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

// ── Seek flash bubble ─────────────────────────────────────────────────────────

class _SeekFlashBubble extends StatefulWidget {
  final String label;
  final bool forward;
  const _SeekFlashBubble({required this.label, required this.forward});

  @override
  State<_SeekFlashBubble> createState() => _SeekFlashBubbleState();
}

class _SeekFlashBubbleState extends State<_SeekFlashBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _anim, curve: const Interval(0.4, 1.0)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.forward
                  ? Icons.forward_5_rounded
                  : Icons.replay_5_rounded,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(widget.label,
                style:
                    const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

enum _OverlayKind { brightness, volume }
