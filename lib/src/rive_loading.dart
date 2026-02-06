library rive_loading_plus;

import 'package:flutter/material.dart' hide Animation;
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class RiveLoading extends StatefulWidget {
  final String name;
  final Function(dynamic data) onSuccess;
  final Function(dynamic error, dynamic stacktrace) onError;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;
  final Future Function()? until;
  final String? loopAnimation;
  final String? endAnimation;
  final String? startAnimation;
  final bool? isLoading;

  const RiveLoading({
    Key? key,
    required this.name,
    required this.onSuccess,
    required this.onError,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.until,
    this.loopAnimation,
    this.endAnimation,
    this.startAnimation,
    this.isLoading,
  }) : super(key: key);

  @override
  State<RiveLoading> createState() => _RiveLoadingState();
}

class _RiveLoadingState extends State<RiveLoading> {
  File? _riveFile;
  Artboard? _riveArtboard;
  _LoadingRiveController? _controller;
  bool _isInitialized = false;
  dynamic _data;
  dynamic _error;
  dynamic _stack;
  bool _isSuccessful = false;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  Future<void> _loadRiveFile() async {
    try {
      final bytes = await rootBundle.load(widget.name);
      _riveFile = await File.decode(
        bytes.buffer.asUint8List(),
        riveFactory: Factory.flutter,
      );
      _riveArtboard = _riveFile!.defaultArtboard();

      _controller = _LoadingRiveController(
        artboard: _riveArtboard!,
        startAnimation: widget.startAnimation,
        loopAnimation: widget.loopAnimation,
        endAnimation: widget.endAnimation,
        fit: _mapFit(widget.fit),
        alignment: widget.alignment,
        onFinished: _finished,
      );

      setState(() => _isInitialized = true);
      _processCallback();
    } catch (error, stackTrace) {
      widget.onError(error, stackTrace);
    }
  }

  @override
  void didUpdateWidget(covariant RiveLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != null && widget.isLoading != oldWidget.isLoading) {
      _controller?.isLoading = widget.isLoading;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _riveArtboard?.dispose();
    _riveFile?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: _isInitialized && _riveArtboard != null && _controller != null
            ? RiveArtboardWidget(
                artboard: _riveArtboard!,
                painter: _controller!,
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Future<void> _processCallback() async {
    if (widget.until == null) {
      _isSuccessful = true;
    } else {
      try {
        _data = await widget.until!();
        _isSuccessful = true;
      } catch (err, stack) {
        _error = err;
        _stack = stack;
        _isSuccessful = false;
      }
      _controller?.isLoading = false;
      if (!_controller!.hasLoopAnimation &&
          !_controller!.hasEndAnimation &&
          (_controller!.isIntroFinished || _controller!.isCompleted)) {
        _finished();
      }
    }
  }

  void _finished() {
    if (!(_controller?.isLoading ?? true)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isSuccessful) {
          widget.onSuccess(_data);
        } else {
          widget.onError(_error, _stack);
        }
      });
    }
  }
}

Fit _mapFit(BoxFit fit) {
  return switch (fit) {
    BoxFit.cover => Fit.cover,
    BoxFit.fill => Fit.fill,
    BoxFit.fitHeight => Fit.fitHeight,
    BoxFit.fitWidth => Fit.fitWidth,
    BoxFit.none => Fit.none,
    BoxFit.scaleDown => Fit.scaleDown,
    BoxFit.contain => Fit.contain,
  };
}

base class _LoadingRiveController extends BasicArtboardPainter {
  final String? _startAnimation;
  final String? _loopAnimation;
  final String? _endAnimation;
  final VoidCallback onFinished;

  bool isIntroFinished = false;
  bool _isLastLoadingFinished = false;
  bool? _isLoading = true;
  bool isCompleted = false;
  bool _isActive = true;

  Animation? _start;
  Animation? _loading;
  Animation? _complete;

  bool? get isLoading => _isLoading;

  set isLoading(bool? value) {
    _isLoading = value;
    if (_isLoading ?? false) {
      _isLastLoadingFinished = false;
      isCompleted = false;
      _isActive = true;
      if (!isIntroFinished && _start != null) {
        _start!.time = 0;
      }
    }
    notifyListeners();
  }

  bool get hasStartAnimation => _startAnimation != null;
  bool get hasLoopAnimation => _loopAnimation != null;
  bool get hasEndAnimation => _endAnimation != null;

  _LoadingRiveController({
    required Artboard artboard,
    String? startAnimation,
    String? loopAnimation,
    String? endAnimation,
    required this.onFinished,
    Fit fit = RiveDefaults.fit,
    Alignment alignment = RiveDefaults.alignment,
  })  : _startAnimation = startAnimation,
        _loopAnimation = loopAnimation,
        _endAnimation = endAnimation,
        super(fit: fit, alignment: alignment) {
    artboardChanged(artboard);
  }

  @override
  void artboardChanged(Artboard artboard) {
    super.artboardChanged(artboard);
    _initAnimations(artboard);
  }

  void _initAnimations(Artboard artboard) {
    final startAnimation = _startAnimation;
    if (startAnimation != null) {
      _start = artboard.animationNamed(startAnimation);
      assert(
        _start != null,
        'Start animation "$startAnimation" not found in Rive file',
      );
    }
    final loopAnimation = _loopAnimation;
    if (loopAnimation != null) {
      _loading = artboard.animationNamed(loopAnimation);
      assert(
        _loading != null,
        'Loop animation "$loopAnimation" not found in Rive file',
      );
    }
    final endAnimation = _endAnimation;
    if (endAnimation != null) {
      _complete = artboard.animationNamed(endAnimation);
      assert(
        _complete != null,
        'End animation "$endAnimation" not found in Rive file',
      );
    }
    _isActive = _endAnimation != null ||
        _loopAnimation != null ||
        _startAnimation != null;
  }

  @override
  bool advance(double elapsedSeconds) {
    if (!_isActive) return false;

    final artboard = this.artboard;
    if (artboard == null) return false;

    if (!isIntroFinished && _start != null) {
      final isPlaying = _start!.advanceAndApply(elapsedSeconds);

      if (!isPlaying) {
        isIntroFinished = true;
        _loading?.time = 0;

        if (_loading == null && _complete == null) {
          isLoading = false;
          onFinished();
          _isActive = false;
          return false;
        }
      }

      return _isActive;
    }

    if (isLoading! && _loading != null) {
      final isPlaying = _loading!.advanceAndApply(elapsedSeconds);
      if (!isPlaying) {
        _loading!.time = 0;
      }
      return _isActive;
    } else if (_loading != null && !_isLastLoadingFinished) {
      final isPlaying = _loading!.advanceAndApply(elapsedSeconds);

      if (!isPlaying) {
        _isLastLoadingFinished = true;
        _complete?.time = 0;
      }
      return _isActive;
    } else if (_complete == null) {
      isLoading = false;
      onFinished();
      _isActive = false;
      return false;
    } else if (!isCompleted) {
      final isPlaying = _complete!.advanceAndApply(elapsedSeconds);

      if (!isPlaying) {
        isCompleted = true;
        isLoading = false;
        onFinished();
        _isActive = false;
        return false;
      }
      return _isActive;
    }

    return _isActive;
  }

  @override
  void dispose() {
    _isActive = false;
    super.dispose();
  }
}
