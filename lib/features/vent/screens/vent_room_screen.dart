// lib/features/vent/screens/vent_room_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/routes.dart';
import '../../../core/utils/localization.dart';
import '../../dashboard/widgets/mood_selector_sheet.dart';
import '../../settings/bloc/theme_bloc.dart';
import '../bloc/vent_bloc.dart';
import '../bloc/vent_event.dart';
import '../bloc/vent_state.dart';

class VentRoomScreen extends StatefulWidget {
  const VentRoomScreen({super.key});

  @override
  State<VentRoomScreen> createState() => _VentRoomScreenState();
}

class _VentRoomScreenState extends State<VentRoomScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _pillowController;
  late Animation<double> _pillowFlyAnimation;
  late Animation<double> _pillowRotationAnimation;
  late Animation<double> _pillowScaleAnimation;

  late AnimationController _avatarShakeController;
  late Animation<double> _avatarShakeAnimation;

  late AnimationController _featherController;
  late Animation<double> _featherSweepAnimation;
  late Animation<double> _featherFlyInAnimation;

  // Local state variables for triggering animations
  bool _isPillowFlying = false;
  bool _isTickling = false;
  String _activeSender = 'me'; // 'me' or 'partner'

  // Cotton feathers burst list
  final List<Map<String, dynamic>> _feathersBurst = [];

  // Balloons floating list
  final List<Map<String, dynamic>> _balloons = [];
  Timer? _balloonTimer;

  @override
  void initState() {
    super.initState();
    context.read<VentBloc>().add(const LoadVentRoom());

    // 1. Pillow Flight Animation
    _pillowController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _pillowFlyAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _pillowController, curve: Curves.easeInBack),
    );
    _pillowRotationAnimation = Tween<double>(begin: 0.0, end: 4 * pi).animate(
      CurvedAnimation(parent: _pillowController, curve: Curves.easeOut),
    );
    _pillowScaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pillowController, curve: Curves.easeOutQuad),
    );

    _pillowController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pillowController.reset();
        setState(() {
          _isPillowFlying = false;
        });
        // Hit the avatar: shake avatar and trigger cotton burst
        _triggerAvatarShake();
        _triggerCottonBurst();
      }
    });

    // 2. Avatar Shake Animation
    _avatarShakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _avatarShakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _avatarShakeController, curve: Curves.elasticIn),
    );
    _avatarShakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _avatarShakeController.reset();
      }
    });

    // 3. Feather Tickle Animation
    _featherController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _featherFlyInAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _featherController, curve: Curves.easeInOut));

    _featherSweepAnimation = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(
        parent: _featherController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticIn),
      ),
    );

    _featherController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _featherController.reset();
        setState(() {
          _isTickling = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pillowController.dispose();
    _avatarShakeController.dispose();
    _featherController.dispose();
    _balloonTimer?.cancel();
    super.dispose();
  }

  // Trigger avatar shake on pillow impact
  void _triggerAvatarShake() {
    HapticFeedback.mediumImpact();
    _avatarShakeController.forward(from: 0.0);
  }

  // Spawn cotton particles bursting outward from center
  void _triggerCottonBurst() {
    final random = Random();
    setState(() {
      _feathersBurst.clear();
      for (int i = 0; i < 12; i++) {
        final angle = random.nextDouble() * 2 * pi;
        final speed = 2.0 + random.nextDouble() * 4.0;
        _feathersBurst.add({
          'x': 0.0,
          'y': 0.0,
          'dx': cos(angle) * speed,
          'dy': sin(angle) * speed,
          'opacity': 1.0,
          'scale': 0.5 + random.nextDouble() * 0.8,
        });
      }
    });

    // Animate burst particles
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_feathersBurst.isEmpty) {
        timer.cancel();
        return;
      }
      setState(() {
        for (var f in _feathersBurst) {
          f['x'] = (f['x'] as double) + (f['dx'] as double);
          f['y'] = (f['y'] as double) + (f['dy'] as double);
          f['dy'] = (f['dy'] as double) + 0.1; // Add gravity
          f['opacity'] = max(0.0, (f['opacity'] as double) - 0.03);
        }
        _feathersBurst.removeWhere((f) => f['opacity'] <= 0.0);
      });
    });
  }

  // Trigger ném gối animation
  void _throwPillow({required bool isMe}) {
    if (_isPillowFlying) return;
    setState(() {
      _isPillowFlying = true;
      _activeSender = isMe ? 'me' : 'partner';
    });
    _pillowController.forward(from: 0.0);
  }

  // Trigger cù lét animation
  void _ticklePartner({required bool isMe}) {
    if (_isTickling) return;
    setState(() {
      _isTickling = true;
      _activeSender = isMe ? 'me' : 'partner';
    });
    HapticFeedback.lightImpact();
    _featherController.forward(from: 0.0);

    // Wiggle avatar continuously while tickling
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isTickling) {
        timer.cancel();
        return;
      }
      _avatarShakeController.forward(from: 0.0);
    });
  }

  // Spawn floating balloons
  void _releaseBalloons() {
    final random = Random();
    final width = MediaQuery.of(context).size.width;
    setState(() {
      for (int i = 0; i < 6; i++) {
        _balloons.add({
          'id': 'balloon-${DateTime.now().millisecondsSinceEpoch}-$i',
          'x': 40.0 + random.nextDouble() * (width - 120.0),
          'y': MediaQuery.of(context).size.height + 40.0,
          'color': [
            EmoraColors.primary,
            EmoraColors.tertiary,
            const Color(0xFFFFB7B2),
            const Color(0xFFB8E0D2),
            const Color(0xFFFFD2C4),
          ][random.nextInt(5)],
          'emoji': ['🎈', '❤️', '✨', '🧁', '🌸'][random.nextInt(5)],
          'speed': 1.8 + random.nextDouble() * 2.2,
          'swingSpeed': 0.02 + random.nextDouble() * 0.03,
          'swingOffset': random.nextDouble() * 2 * pi,
        });
      }
    });
    _startBalloonTicker();
  }

  void _startBalloonTicker() {
    if (_balloonTimer != null) return;
    _balloonTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_balloons.isEmpty) {
        timer.cancel();
        _balloonTimer = null;
        return;
      }
      setState(() {
        for (var b in _balloons) {
          b['y'] = (b['y'] as double) - (b['speed'] as double);
          // Apply horizontal swing (wave effect)
          b['swingOffset'] = (b['swingOffset'] as double) + (b['swingSpeed'] as double);
          b['x'] = (b['x'] as double) + sin(b['swingOffset'] as double) * 1.2;
        }
        // Remove out-of-screen balloons
        _balloons.removeWhere((b) => b['y'] < -100);
      });
    });
  }

  Future<bool> _checkAndIncrementLimit() async {
    final themeState = context.read<ThemeBloc>().state;
    if (themeState.isPremium) return true;

    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    const keyDate = 'vent_limit_date';
    const keyCount = 'vent_limit_count';

    final savedDate = prefs.getString(keyDate);
    int count = 0;

    if (savedDate == todayStr) {
      count = prefs.getInt(keyCount) ?? 0;
    } else {
      await prefs.setString(keyDate, todayStr);
      await prefs.setInt(keyCount, 0);
    }

    if (count >= 5) {
      _showLimitReachedDialog();
      return false;
    }

    await prefs.setInt(keyCount, count + 1);
    return true;
  }

  void _showLimitReachedDialog() {
    final themeState = context.read<ThemeBloc>().state;
    final colors = themeState.themeColors;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              const Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.translate('premium.limit_reached_title'),
                  style: TextStyle(
                    color: colors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            context.translate('premium.limit_reached_desc'),
            style: TextStyle(
              color: colors.textMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                context.translate('common.cancel'),
                style: TextStyle(
                  color: colors.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushNamed(EmoraRoutes.premiumPaywall);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                context.translate('premium.upgrade_now'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final colors = themeState.themeColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.translate('vent_room.title'),
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
            color: colors.primary,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<VentBloc, VentState>(
        listener: (context, state) {
          if (state is VentLoaded && state.lastReceivedAction != null) {
            // Received an action from the partner, trigger the corresponding animation!
            if (state.lastReceivedAction == 'pillow_throw') {
              _throwPillow(isMe: false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Đối phương đã ném gối vào bạn! 🛏️"),
                  backgroundColor: colors.primary,
                  duration: const Duration(seconds: 1),
                ),
              );
            } else if (state.lastReceivedAction == 'tickle') {
              _ticklePartner(isMe: false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Đối phương đang cù lét bạn! 🛶"),
                  backgroundColor: colors.primary,
                  duration: const Duration(seconds: 1),
                ),
              );
            } else if (state.lastReceivedAction == 'balloon_pop') {
              _releaseBalloons();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Đối phương đã thả bóng bay tặng bạn! 🎈"),
                  backgroundColor: colors.primary,
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is VentLoading || state is VentInitial) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }

          if (state is VentFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: colors.primary),
                  const SizedBox(height: 16),
                  Text(state.errorMessage, style: TextStyle(color: colors.textDark)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<VentBloc>().add(const LoadVentRoom());
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is VentLoaded) {
            final partnerMoodColor = EmoraColors.moodColors[state.partnerMood] ?? colors.secondary;
            final partnerMoodEmoji = MoodSelectorSheet.moodEmojis[state.partnerMood] ?? '😊';

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Interactive Balloons (Layered behind main contents but clickable)
                ..._balloons.map((b) {
                  return Positioned(
                    left: b['x'],
                    top: b['y'],
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _balloons.removeWhere((x) => x['id'] == b['id']);
                        });
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.translate('vent_room.pop_balloon')),
                            backgroundColor: colors.primary,
                            duration: const Duration(milliseconds: 800),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: b['color'],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: b['color'].withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Text(
                          b['emoji'],
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  );
                }),

                // 2. Playful Canvas (Pillows, feathers, explosions)
                Positioned.fill(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      // Partner Info Header
                      Text(
                        state.partnerName,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Đang ${context.translate('mood.${state.partnerMood}').toLowerCase()}",
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textMuted,
                        ),
                      ),

                      const Spacer(),

                      // Center Avatar Stage
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Avatar container with shake and wiggles
                            AnimatedBuilder(
                              animation: _avatarShakeController,
                              builder: (context, child) {
                                // Calculate wiggle/shake offsets
                                double dx = 0.0;
                                if (_avatarShakeController.isAnimating) {
                                  dx = sin(_avatarShakeAnimation.value * 8 * pi) * 12.0;
                                }
                                return Transform.translate(
                                  offset: Offset(dx, 0.0),
                                  child: child,
                                );
                              },
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: partnerMoodColor, width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: partnerMoodColor.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    )
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  partnerMoodEmoji,
                                  style: const TextStyle(fontSize: 70),
                                ),
                              ),
                            ),

                            // Feathers cotton burst overlay particles
                            ..._feathersBurst.map((f) {
                              return Positioned(
                                left: 60.0 + f['x'],
                                top: 60.0 + f['y'],
                                child: Opacity(
                                  opacity: f['opacity'],
                                  child: Transform.scale(
                                    scale: f['scale'],
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: colors.surface,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),

                            // Flying Feather (Tickle animation overlay)
                            if (_isTickling)
                              AnimatedBuilder(
                                animation: _featherController,
                                builder: (context, child) {
                                  // Compute fly-in and sweep rotation angles
                                  final opacity = _featherFlyInAnimation.value;
                                  final angle = _featherSweepAnimation.value;
                                  return Positioned(
                                    right: -30.0 + (1 - opacity) * 100,
                                    top: 10,
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Transform.rotate(
                                        angle: angle,
                                        child: const Text(
                                          '🪶',
                                          style: TextStyle(fontSize: 50),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Tool Control Panel
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                          boxShadow: [
                            BoxShadow(
                              color: colors.textDark.withOpacity(0.04),
                              blurRadius: 16,
                              offset: const Offset(0, -6),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Ném gối va chạm hoặc Cù lét chọc ghẹo đối phương",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: colors.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Action 1: Pillow Throw Button
                                _buildActionBtn(
                                  emoji: '🛏️',
                                  label: "Ném gối",
                                  color: colors.primary,
                                  colors: colors,
                                  onPressed: () async {
                                    if (await _checkAndIncrementLimit()) {
                                      _throwPillow(isMe: true);
                                      context.read<VentBloc>().add(const SendVentAction('pillow_throw'));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(context.translate('vent_room.pillow_sent')),
                                          backgroundColor: colors.primary,
                                          duration: const Duration(milliseconds: 1000),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                // Action 2: Tickle Button
                                _buildActionBtn(
                                  emoji: '🪶',
                                  label: "Cù lét",
                                  color: colors.primary,
                                  colors: colors,
                                  onPressed: () async {
                                    if (await _checkAndIncrementLimit()) {
                                      _ticklePartner(isMe: true);
                                      context.read<VentBloc>().add(const SendVentAction('tickle'));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(context.translate('vent_room.tickle_sent')),
                                          backgroundColor: colors.primary,
                                          duration: const Duration(milliseconds: 1000),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                // Action 3: Balloon release Button
                                _buildActionBtn(
                                  emoji: '🎈',
                                  label: "Thả bóng",
                                  color: const Color(0xFFFFB7B2),
                                  colors: colors,
                                  onPressed: () async {
                                    if (await _checkAndIncrementLimit()) {
                                      _releaseBalloons();
                                      context.read<VentBloc>().add(const SendVentAction('balloon_pop'));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(context.translate('vent_room.balloon_sent')),
                                          backgroundColor: colors.primary,
                                          duration: const Duration(milliseconds: 1000),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Flying Pillow (Pillow Throw animation overlay)
                if (_isPillowFlying && _activeSender == 'me')
                  AnimatedBuilder(
                    animation: _pillowController,
                    builder: (context, child) {
                      final size = MediaQuery.of(context).size;
                      final startY = size.height - 150.0;
                      final targetY = size.height / 2 - 30.0;

                      final progress = _pillowFlyAnimation.value;
                      final currentY = targetY + (startY - targetY) * progress;
                      final rotation = _pillowRotationAnimation.value;
                      final scale = _pillowScaleAnimation.value;

                      return Positioned(
                        left: size.width / 2 - 25.0,
                        top: currentY,
                        child: Transform.scale(
                          scale: scale,
                          child: Transform.rotate(
                            angle: rotation,
                            child: const Text(
                              '🛏️',
                              style: TextStyle(fontSize: 46),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // Pillow flying from top (received pillow throw)
                if (_isPillowFlying && _activeSender == 'partner')
                  AnimatedBuilder(
                    animation: _pillowController,
                    builder: (context, child) {
                      final size = MediaQuery.of(context).size;
                      const startY = -50.0;
                      final targetY = size.height / 2 - 30.0;

                      final progress = _pillowFlyAnimation.value;
                      final currentY = targetY + (startY - targetY) * progress;
                      final rotation = _pillowRotationAnimation.value;
                      final scale = _pillowScaleAnimation.value;

                      return Positioned(
                        left: size.width / 2 - 25.0,
                        top: currentY,
                        child: Transform.scale(
                          scale: scale,
                          child: Transform.rotate(
                            angle: rotation,
                            child: const Text(
                              '🛏️',
                              style: TextStyle(fontSize: 46),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildActionBtn({
    required String emoji,
    required String label,
    required Color color,
    required ThemeColors colors,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.4), width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colors.textDark,
          ),
        ),
      ],
    );
  }
}
