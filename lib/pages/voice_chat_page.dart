import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class VoiceChatPage extends StatefulWidget {
  const VoiceChatPage({super.key});

  @override
  State<VoiceChatPage> createState() => _VoiceChatPageState();
}

class _VoiceChatPageState extends State<VoiceChatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isListening = true;

  static const Color primaryColor = Color(0xFFFF85A1);
  static const Color accentColor = Color(0xFFFFAACC);
  static const Color backgroundColor = Color(0xFFFDFCFB);
  static const Color textDarkColor = Color(0xFF2D3142);
  static const Color textLightColor = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: textDarkColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Assistant Vocal',
          style: TextStyle(
            color: textDarkColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Ondes de fond animées
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                double progress = (_pulseController.value + (index / 3)) % 1.0;
                return Container(
                  width: size.width * 0.4 + (progress * size.width * 0.8),
                  height: size.width * 0.4 + (progress * size.width * 0.8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withOpacity((1 - progress) * 0.25),
                      width: 2,
                    ),
                  ),
                );
              },
            );
          }),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Le Micro Central
              GestureDetector(
                onTap: () => setState(() => _isListening = !_isListening),
                child:
                    Container(
                          width: size.width * 0.32,
                          height: size.width * 0.32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [primaryColor, accentColor],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.4),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_off,
                            color: Colors.white,
                            size: size.width * 0.14,
                          ),
                        )
                        .animate(target: _isListening ? 1 : 0)
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.08, 1.08),
                          duration: 1.2.seconds,
                          curve: Curves.easeInOut,
                        ),
              ),

              SizedBox(height: size.height * 0.08),

              Text(
                    _isListening ? 'Je t\'écoute...' : 'Appuie pour parler',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textDarkColor,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 1.seconds),

              const SizedBox(height: 16),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                child: const Text(
                  'Pose ta question sur ton cycle, tes symptômes ou demande un conseil bien-être.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: textLightColor,
                    height: 1.5,
                  ),
                ),
              ),

              const Spacer(),

              // Visualiseur d'ondes (simulé avec moins d'animations si possible, ici on garde l'effet mais optimisé)
              SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(12, (index) {
                    return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          width: 4,
                          height: 12 + (math.Random().nextDouble() * 35),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [primaryColor, accentColor],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleY(
                          begin: 0.4,
                          end: 1.4,
                          duration: (400 + (index * 50))
                              .ms, // Décalage basé sur l'index pour éviter Random constant
                        );
                  }),
                ).animate(target: _isListening ? 1 : 0).fadeIn(),
              ),

              SizedBox(height: size.height * 0.08),
            ],
          ),
        ],
      ),
    );
  }
}
