import 'package:flutter/material.dart';

class VoiceInputWidget extends StatefulWidget {
  final Function(String) onVoiceResult;
  final bool isEnabled;

  const VoiceInputWidget({
    super.key,
    required this.onVoiceResult,
    this.isEnabled = true,
  });

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    if (!widget.isEnabled) return;

    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      _pulseController.repeat(reverse: true);

      // Simulate voice recognition (In real implementation, use speech_to_text package)
      await Future.delayed(const Duration(seconds: 2));

      // Simulate recognized text
      if (mounted && _isListening) {
        widget.onVoiceResult("मुझे पंचकर्म थेरेपी के बारे में जानकारी चाहिए");
        setState(() {
          _isListening = false;
        });
        _pulseController.stop();
      }
    } else {
      _pulseController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isListening ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: _toggleListening,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isListening
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isListening
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening
                    ? Colors.white
                    : Theme.of(context).colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }
}
