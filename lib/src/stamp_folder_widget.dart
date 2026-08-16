import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

const Size _referenceSize = Size(520, 582);
const double _referenceLiftFactor = 32 / 582;

/// Controls how the image content is fitted inside its stamp card.
enum StampImageDisplayMode {
  /// Uses the configured [BoxFit], which defaults to [BoxFit.cover].
  cover,

  /// Shows the complete image and leaves the remaining space transparent.
  contain,

  /// Shows the complete image over a softly blurred, cropped version of it.
  containWithBlur,
}

class StampFolderWidget extends StatefulWidget {
  static const int maxStampCount = 3;

  const StampFolderWidget({
    super.key,
    this.width,
    this.height,
    this.aspectRatio = 520 / 582,
    this.padding = EdgeInsets.zero,
    this.title = 'Designs',
    this.subtitle = '',
    this.labelColor = const Color(0xFFF7FFFF),
    this.frontPanelColors = const [
      Color(0xFF7CDBF6),
      Color(0xFF6BB8C6),
      Color(0xFF62C5C7),
    ],
    this.backPanelColors = const [
      Color(0xFF13C4FA),
      Color(0xFF14BCFA),
      Color(0xFF12B8F3),
    ],
    this.frontEdgeGlowColor = const Color(0xFFFFFFFF),
    this.backEdgeGlowColor = const Color(0xFFFFFFFF),
    this.frontBorderColor = const Color(0xB8FFFFFF),
    this.frontBorderWidth = 1,
    this.backBorderColor = const Color(0xB3FFFFFF),
    this.backBorderWidth = 1,
    this.stamps = const [],
    this.showLeafDecoration = false,
    this.showStampBorders = true,
    this.enableTapAnimation = true,
    this.initiallyOpen = false,
    this.animationDuration = const Duration(milliseconds: 1433),
    this.liftAnimationDuration = const Duration(milliseconds: 400),
    this.frontOpenAnimationDuration = const Duration(milliseconds: 233),
    this.reverseAnimationDuration = const Duration(milliseconds: 367),
    this.colorTransitionDuration = const Duration(milliseconds: 167),
    this.openLiftFactor = _referenceLiftFactor,
    this.openFrontScale = 0.84,
    this.semanticsLabel = 'Design folder',
    this.onOpenChanged,
  });

  static List<StampFolderStampData> buildDefaultStamps({
    required ImageProvider imageProvider,
    double? imageAspectRatio,
  }) {
    if (imageAspectRatio != null && imageAspectRatio <= 0) {
      throw ArgumentError.value(
        imageAspectRatio,
        'imageAspectRatio',
        'must be greater than zero',
      );
    }
    final defaultDisplayMode = imageAspectRatio == null
        ? StampImageDisplayMode.containWithBlur
        : StampImageDisplayMode.cover;

    return [
      StampFolderStampData(
        imageProvider: imageProvider,
        leftFactor: 120 / 520,
        topFactor: 84 / 582,
        widthFactor: 108 / 520,
        heightFactor: 144 / 582,
        rotation: -8 * math.pi / 180,
        tint: Colors.transparent,
        imageAspectRatio: imageAspectRatio,
        displayMode: defaultDisplayMode,
      ),
      StampFolderStampData(
        imageProvider: imageProvider,
        leftFactor: 202 / 520,
        topFactor: 96 / 582,
        widthFactor: 117 / 520,
        heightFactor: 156 / 582,
        rotation: 0,
        tint: Colors.transparent,
        imageAspectRatio: imageAspectRatio,
        displayMode: defaultDisplayMode,
      ),
      StampFolderStampData(
        imageProvider: imageProvider,
        rightFactor: 120 / 520,
        topFactor: 84 / 582,
        widthFactor: 108 / 520,
        heightFactor: 144 / 582,
        rotation: 8 * math.pi / 180,
        tint: Colors.transparent,
        imageAspectRatio: imageAspectRatio,
        displayMode: defaultDisplayMode,
      ),
    ];
  }

  final double? width;
  final double? height;
  final double aspectRatio;
  final EdgeInsetsGeometry padding;
  final String title;
  final String subtitle;
  final Color labelColor;
  final List<Color> frontPanelColors;
  final List<Color> backPanelColors;
  final Color frontEdgeGlowColor;
  final Color backEdgeGlowColor;

  /// Color of the front pocket outline. Set its alpha to control opacity.
  final Color frontBorderColor;

  /// Stroke width of the front pocket outline. Set to 0 to hide it.
  final double frontBorderWidth;

  /// Color of the rear panel outline. Set its alpha to control opacity.
  final Color backBorderColor;

  /// Stroke width of the rear panel outline. Set to 0 to hide it.
  final double backBorderWidth;

  /// Stamp images to render. The parent can replace this list to dynamically
  /// add or remove images; at most [maxStampCount] images are supported.
  final List<StampFolderStampData> stamps;
  final bool showLeafDecoration;
  final bool showStampBorders;
  final bool enableTapAnimation;
  final bool initiallyOpen;

  /// Total time for the opening timeline, including the engaged hold.
  final Duration animationDuration;

  /// Time used by the initial idle-to-engaged lift phase.
  final Duration liftAnimationDuration;

  /// Time used by the front-pocket fold and card reveal phase.
  final Duration frontOpenAnimationDuration;
  final Duration reverseAnimationDuration;
  final Duration colorTransitionDuration;
  final double openLiftFactor;
  final double openFrontScale;
  final String semanticsLabel;
  final ValueChanged<bool>? onOpenChanged;

  @override
  State<StampFolderWidget> createState() => _StampFolderWidgetState();
}

class _StampFolderWidgetState extends State<StampFolderWidget>
    with TickerProviderStateMixin {
  late final AnimationController _motionController;
  late final AnimationController _colorController;

  late List<Color> _frontColorsFrom;
  late List<Color> _frontColorsTo;
  late List<Color> _backColorsFrom;
  late List<Color> _backColorsTo;
  late Color _frontGlowFrom;
  late Color _frontGlowTo;
  late Color _backGlowFrom;
  late Color _backGlowTo;

  late bool _targetOpen;

  @override
  void initState() {
    super.initState();
    _targetOpen = widget.initiallyOpen;
    _motionController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      reverseDuration: widget.reverseAnimationDuration,
      value: widget.initiallyOpen ? 1 : 0,
    );
    _colorController = AnimationController(
      vsync: this,
      duration: widget.colorTransitionDuration,
      value: 1,
    );

    _frontColorsFrom = _resolveColors(widget.frontPanelColors);
    _frontColorsTo = List<Color>.of(_frontColorsFrom);
    _backColorsFrom = _resolveColors(widget.backPanelColors);
    _backColorsTo = List<Color>.of(_backColorsFrom);
    _frontGlowFrom = widget.frontEdgeGlowColor;
    _frontGlowTo = widget.frontEdgeGlowColor;
    _backGlowFrom = widget.backEdgeGlowColor;
    _backGlowTo = widget.backEdgeGlowColor;
  }

  @override
  void didUpdateWidget(covariant StampFolderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _motionController
      ..duration = widget.animationDuration
      ..reverseDuration = widget.reverseAnimationDuration;
    _colorController.duration = widget.colorTransitionDuration;

    final nextFront = _resolveColors(widget.frontPanelColors);
    final nextBack = _resolveColors(widget.backPanelColors);
    final paletteChanged =
        !_sameColors(nextFront, _frontColorsTo) ||
        !_sameColors(nextBack, _backColorsTo) ||
        widget.frontEdgeGlowColor != _frontGlowTo ||
        widget.backEdgeGlowColor != _backGlowTo;

    if (paletteChanged) {
      final colorProgress = _colorController.value;
      _frontColorsFrom = _lerpColors(
        _frontColorsFrom,
        _frontColorsTo,
        colorProgress,
      );
      _backColorsFrom = _lerpColors(
        _backColorsFrom,
        _backColorsTo,
        colorProgress,
      );
      _frontGlowFrom = Color.lerp(_frontGlowFrom, _frontGlowTo, colorProgress)!;
      _backGlowFrom = Color.lerp(_backGlowFrom, _backGlowTo, colorProgress)!;
      _frontColorsTo = nextFront;
      _backColorsTo = nextBack;
      _frontGlowTo = widget.frontEdgeGlowColor;
      _backGlowTo = widget.backEdgeGlowColor;
      _colorController.forward(from: 0);
    }

    if (oldWidget.initiallyOpen != widget.initiallyOpen) {
      _setOpen(widget.initiallyOpen, notify: false);
    }
  }

  @override
  void dispose() {
    _motionController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _setOpen(bool value, {bool notify = true}) {
    if (_targetOpen == value &&
        (_motionController.isAnimating ||
            _motionController.value == (value ? 1 : 0))) {
      return;
    }

    setState(() => _targetOpen = value);
    value ? _motionController.forward() : _motionController.reverse();
    if (notify) {
      widget.onOpenChanged?.call(value);
    }
  }

  void _toggle() {
    if (widget.enableTapAnimation) {
      _setOpen(!_targetOpen);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stamps.length > StampFolderWidget.maxStampCount) {
      throw FlutterError(
        'StampFolderWidget supports at most '
        '${StampFolderWidget.maxStampCount} stamps, but received '
        '${widget.stamps.length}.',
      );
    }

    Widget artwork = AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: SizedBox(
          width: _referenceSize.width,
          height: _referenceSize.height,
          child: AnimatedBuilder(
            animation: Listenable.merge([_motionController, _colorController]),
            builder: (context, _) => _buildReferenceArtwork(),
          ),
        ),
      ),
    );

    artwork = Padding(padding: widget.padding, child: artwork);
    if (widget.width != null || widget.height != null) {
      artwork = SizedBox(
        width: widget.width,
        height: widget.height,
        child: artwork,
      );
    }

    final interactive = widget.enableTapAnimation;
    Widget result = Semantics(
      button: interactive,
      toggled: _targetOpen,
      label: widget.semanticsLabel,
      onTap: widget.enableTapAnimation ? _toggle : null,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.enableTapAnimation ? _toggle : null,
        child: artwork,
      ),
    );

    return result;
  }

  Widget _buildReferenceArtwork() {
    final motion = _motionController.value;
    final totalMilliseconds = math
        .max(1, widget.animationDuration.inMilliseconds)
        .toDouble();
    final liftEnd = _timelineFraction(
      widget.liftAnimationDuration,
      totalMilliseconds,
    );
    final frontEnd =
        (1 -
                _timelineFraction(
                  const Duration(milliseconds: 200),
                  totalMilliseconds,
                ))
            .clamp(0.001, 1.0);
    final frontStart = math
        .max(
          liftEnd,
          frontEnd -
              _timelineFraction(
                widget.frontOpenAnimationDuration,
                totalMilliseconds,
              ),
        )
        .clamp(0.0, frontEnd - 0.001);
    final cardStart = math.max(0.0, frontStart - 40 / totalMilliseconds);

    final engageProgress = Interval(
      0,
      liftEnd,
      curve: Curves.easeOutCubic,
    ).transform(motion);
    final frontProgress = Interval(
      frontStart,
      frontEnd,
      curve: Cubic(0.2, 0, 0.2, 1),
    ).transform(motion);
    final cardProgress = Interval(
      cardStart,
      (frontEnd + 20 / totalMilliseconds).clamp(cardStart + 0.001, 1.0),
      curve: Cubic(0.18, 0.89, 0.32, 1.08),
    ).transform(motion);

    final extraLift =
        _referenceSize.height * (widget.openLiftFactor - _referenceLiftFactor);
    final foldStrength = ((1 - widget.openFrontScale) / 0.16).clamp(0.0, 1.0);
    final effectiveFrontProgress = frontProgress * foldStrength;

    final engagedBack = _backEngaged.translate(0, -extraLift);
    final backGeometry = _BackGeometry.lerp(
      _backIdle,
      engagedBack,
      engageProgress,
    );

    final engagedFront = _frontEngaged.translate(0, -extraLift);
    final liftedFront = _FrontGeometry.lerp(
      _frontIdle,
      engagedFront,
      engageProgress,
    );
    final frontGeometry = liftedFront;

    final engagedLabel = _labelEngaged.translate(0, -extraLift);
    final liftedLabel = Offset.lerp(_labelIdle, engagedLabel, engageProgress)!;
    final labelOffset = Offset.lerp(
      liftedLabel,
      _labelFoldedBase.translate(0, -extraLift),
      effectiveFrontProgress,
    )!;

    final shadowGeometry = Rect.lerp(
      _shadowIdle,
      _shadowEngaged.translate(0, -extraLift * 0.35),
      engageProgress,
    )!;

    final colorProgress = _colorController.value;
    final frontColors = _lerpColors(
      _frontColorsFrom,
      _frontColorsTo,
      colorProgress,
    );
    final backColors = _lerpColors(
      _backColorsFrom,
      _backColorsTo,
      colorProgress,
    );
    final frontGlow = Color.lerp(_frontGlowFrom, _frontGlowTo, colorProgress)!;
    final backGlow = Color.lerp(_backGlowFrom, _backGlowTo, colorProgress)!;

    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fromRect(
            rect: shadowGeometry,
            child: _FolderFloatingShadow(progress: engageProgress),
          ),
          Positioned.fromRect(
            rect: backGeometry.rect,
            child: FolderBackPanel(
              colors: backColors,
              edgeGlowColor: backGlow,
              borderColor: widget.backBorderColor,
              borderWidth: widget.backBorderWidth,
            ),
          ),
          for (final index in const [2, 0, 1])
            if (index < widget.stamps.length)
              _buildAnimatedStamp(
                stamp: widget.stamps[index],
                index: index,
                engageProgress: engageProgress,
                cardProgress: cardProgress,
                extraLift: extraLift,
              ),
          Positioned.fromRect(
            rect: frontGeometry.rect,
            child: _PerspectiveFrontPocket(
              progress: effectiveFrontProgress,
              child: FrontPocket(
                colors: frontColors,
                title: widget.title,
                subtitle: widget.subtitle,
                labelColor: widget.labelColor,
                showLeafDecoration: widget.showLeafDecoration,
                edgeGlowColor: frontGlow,
                borderColor: widget.frontBorderColor,
                borderWidth: widget.frontBorderWidth,
                openProgress: effectiveFrontProgress,
                clipper: frontGeometry.toClipper(),
                titleOffset: labelOffset - frontGeometry.rect.topLeft,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStamp({
    required StampFolderStampData stamp,
    required int index,
    required double engageProgress,
    required double cardProgress,
    required double extraLift,
  }) {
    final basePose = _StampPose.fromData(stamp);
    final isPortrait = basePose.size.height > basePose.size.width;
    final expanded = basePose.translate(
      isPortrait ? _portraitCardGroupShift : 0,
      -extraLift,
    );
    final idleCardOffsets = isPortrait
        ? _portraitIdleCardOffsets
        : _horizontalIdleCardOffsets;
    final engagedCardOffsets = isPortrait
        ? _portraitEngagedCardOffsets
        : _horizontalEngagedCardOffsets;
    final engaged = expanded
        .translate(engagedCardOffsets[index].dx, engagedCardOffsets[index].dy)
        .rotate(_engagedCardRotationOffsets[index]);
    final idle = expanded
        .translate(idleCardOffsets[index].dx, idleCardOffsets[index].dy)
        .rotate(_idleCardRotationOffsets[index]);
    final boundedIdle = isPortrait
        ? _constrainPortraitIdlePose(idle, stampRotation: stamp.rotation)
        : idle;
    final lifted = _StampPose.lerp(boundedIdle, engaged, engageProgress);
    final pose = _StampPose.lerp(lifted, expanded, cardProgress);

    return Positioned(
      left: pose.center.dx - pose.size.width / 2,
      top: pose.center.dy - pose.size.height / 2,
      width: pose.size.width,
      height: pose.size.height,
      child: Transform.rotate(
        angle: pose.rotationDelta,
        alignment: Alignment.center,
        child: StampCard(
          data: stamp,
          showBorder: widget.showStampBorders,
          width: pose.size.width,
          height: pose.size.height,
        ),
      ),
    );
  }
}

class _PerspectiveFrontPocket extends StatelessWidget {
  const _PerspectiveFrontPocket({required this.progress, required this.child});

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Measured projection: the engaged top edge lands on the expanded frame
    // while the bottom-center hinge remains fixed.
    return Transform(
      alignment: Alignment.bottomCenter,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0009)
        ..rotateX(0.57 * progress),
      filterQuality: FilterQuality.high,
      child: child,
    );
  }
}

class StampFolderStampData {
  const StampFolderStampData({
    required this.imageProvider,
    this.leftFactor,
    this.rightFactor,
    required this.topFactor,
    required this.widthFactor,
    required this.heightFactor,
    required this.rotation,
    required this.tint,
    this.showBorder = true,
    this.fit = BoxFit.cover,
    this.displayMode = StampImageDisplayMode.cover,
    this.imageAspectRatio,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.borderWidth = 7,
    this.borderColor = const Color(0xFFFFFCF9),
    this.shadowColor = const Color(0x1A000000),
    this.shadowBlurRadius = 10,
    this.shadowOffset = const Offset(0, 4),
  }) : assert(
         leftFactor != null || rightFactor != null,
         'Either leftFactor or rightFactor must be provided.',
       ),
       assert(
         imageAspectRatio == null || imageAspectRatio > 0,
         'imageAspectRatio must be greater than zero.',
       );

  final ImageProvider imageProvider;
  final double? leftFactor;
  final double? rightFactor;
  final double topFactor;
  final double widthFactor;
  final double heightFactor;
  final double rotation;
  final Color tint;
  final bool showBorder;
  final BoxFit fit;
  final StampImageDisplayMode displayMode;
  /// Optional image width / height ratio used to derive the card height.
  final double? imageAspectRatio;
  final BorderRadius borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color shadowColor;
  final double shadowBlurRadius;
  final Offset shadowOffset;

  StampFolderStampData copyWith({
    ImageProvider? imageProvider,
    double? leftFactor,
    double? rightFactor,
    bool clearLeftFactor = false,
    bool clearRightFactor = false,
    double? topFactor,
    double? widthFactor,
    double? heightFactor,
    double? rotation,
    Color? tint,
    bool? showBorder,
    BoxFit? fit,
    StampImageDisplayMode? displayMode,
    double? imageAspectRatio,
    BorderRadius? borderRadius,
    double? borderWidth,
    Color? borderColor,
    Color? shadowColor,
    double? shadowBlurRadius,
    Offset? shadowOffset,
  }) {
    return StampFolderStampData(
      imageProvider: imageProvider ?? this.imageProvider,
      leftFactor: clearLeftFactor ? null : (leftFactor ?? this.leftFactor),
      rightFactor: clearRightFactor ? null : (rightFactor ?? this.rightFactor),
      topFactor: topFactor ?? this.topFactor,
      widthFactor: widthFactor ?? this.widthFactor,
      heightFactor: heightFactor ?? this.heightFactor,
      rotation: rotation ?? this.rotation,
      tint: tint ?? this.tint,
      showBorder: showBorder ?? this.showBorder,
      fit: fit ?? this.fit,
      displayMode: displayMode ?? this.displayMode,
      imageAspectRatio: imageAspectRatio ?? this.imageAspectRatio,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      shadowOffset: shadowOffset ?? this.shadowOffset,
    );
  }
}

class FolderBackPanel extends StatelessWidget {
  const FolderBackPanel({
    super.key,
    required this.colors,
    required this.edgeGlowColor,
    this.borderColor = const Color(0xB3FFFFFF),
    this.borderWidth = 1,
  });

  final List<Color> colors;
  final Color edgeGlowColor;
  final Color borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    const clipper = _BackPanelClipper();
    return CustomPaint(
      foregroundPainter: _BackPanelEdgePainter(
        glowColor: edgeGlowColor,
        borderColor: borderColor,
        borderWidth: borderWidth,
        clipper: clipper,
      ),
      child: ClipPath(
        clipper: clipper,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _resolveColors(colors),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.18),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.035),
                  ],
                  stops: const [0, 0.32, 1],
                ),
              ),
            ),
            const NoiseOverlay(opacity: 0.012),
          ],
        ),
      ),
    );
  }
}

class FrontPocket extends StatelessWidget {
  const FrontPocket({
    super.key,
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.labelColor,
    required this.showLeafDecoration,
    required this.edgeGlowColor,
    this.borderColor = const Color(0xB8FFFFFF),
    this.borderWidth = 1,
    this.openProgress = 0,
    this.clipper = const PocketClipper(),
    this.titleOffset = const Offset(25, 116),
  });

  final List<Color> colors;
  final String title;
  final String subtitle;
  final Color labelColor;
  final bool showLeafDecoration;
  final Color edgeGlowColor;
  final Color borderColor;
  final double borderWidth;
  final double openProgress;
  final PocketClipper clipper;
  final Offset titleOffset;

  @override
  Widget build(BuildContext context) {
    final resolvedColors = _resolveColors(colors);
    return CustomPaint(
      foregroundPainter: PocketEdgePainter(
        glowColor: edgeGlowColor,
        borderColor: borderColor,
        borderWidth: borderWidth,
        clipper: clipper,
      ),
      child: ClipPath(
        clipper: clipper,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      resolvedColors[0].withValues(alpha: 0.84),
                      resolvedColors[1].withValues(alpha: 0.82),
                      resolvedColors[2].withValues(alpha: 0.86),
                    ],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.24),
                      Colors.white.withValues(alpha: 0.07),
                      Colors.white.withValues(alpha: 0.14),
                    ],
                    stops: const [0, 0.44, 1],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.40, -0.08),
                    radius: 0.85,
                    colors: [
                      const Color(0xFF7EDC83).withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.transparent,
                      Colors.black.withValues(
                        alpha: 0.025 + openProgress * 0.015,
                      ),
                    ],
                  ),
                ),
              ),
              const NoiseOverlay(opacity: 0.018),
              _PocketContents(
                title: title,
                subtitle: subtitle,
                labelColor: labelColor,
                showLeafDecoration: showLeafDecoration,
                titleOffset: titleOffset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StampCard extends StatelessWidget {
  const StampCard({
    super.key,
    required this.data,
    this.showBorder = true,
    required this.width,
    required this.height,
  });

  final StampFolderStampData data;
  final bool showBorder;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final showBlurBackdrop =
        data.displayMode == StampImageDisplayMode.containWithBlur;
    final foregroundFit = data.displayMode == StampImageDisplayMode.cover
        ? data.fit
        : BoxFit.contain;

    return Transform.rotate(
      angle: data.rotation,
      alignment: Alignment.center,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: showBorder && data.showBorder
              ? data.borderColor
              : Colors.transparent,
          borderRadius: data.borderRadius,
          boxShadow: [
            BoxShadow(
              color: data.shadowColor,
              blurRadius: data.shadowBlurRadius,
              offset: data.shadowOffset,
            ),
          ],
        ),
        child: Padding(
          padding: showBorder && data.showBorder
              ? EdgeInsets.all(data.borderWidth)
              : EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: data.borderRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (showBlurBackdrop)
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Transform.scale(
                      scale: 1.12,
                      child: Image(
                        image: data.imageProvider,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ),
                if (showBlurBackdrop)
                  const ColoredBox(color: Color(0x1A000000)),
                Image(
                  image: data.imageProvider,
                  fit: foregroundFit,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) =>
                      const _CardFallback(),
                ),
                if (data.tint.a > 0)
                  ColoredBox(color: data.tint.withValues(alpha: 0.18)),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.10),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.04),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardFallback extends StatelessWidget {
  const _CardFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8BD7F0), Color(0xFF70BFA8)],
        ),
      ),
      child: Center(
        child: Icon(Icons.image_outlined, color: Colors.white70, size: 28),
      ),
    );
  }
}

class PocketClipper extends CustomClipper<Path> {
  const PocketClipper({
    this.leftShelfYFactor = 0.133,
    this.rightShelfYFactor = 0.006,
    this.leftShelfEndFactor = 0.534,
    this.rightShelfStartFactor = 0.737,
    this.cornerRadiusFactor = 0.162,
    this.bottomLeftInsetFactor = 0,
    this.bottomRightInsetFactor = 0,
  });

  final double leftShelfYFactor;
  final double rightShelfYFactor;
  final double leftShelfEndFactor;
  final double rightShelfStartFactor;
  final double cornerRadiusFactor;
  final double bottomLeftInsetFactor;
  final double bottomRightInsetFactor;

  @override
  Path getClip(Size size) {
    final leftShelfY = size.height * leftShelfYFactor;
    final rightShelfY = size.height * rightShelfYFactor;
    final leftShelfEnd = size.width * leftShelfEndFactor;
    final rightShelfStart = size.width * rightShelfStartFactor;
    final radius = size.width * cornerRadiusFactor;
    final bottomLeftInset = size.width * bottomLeftInsetFactor;
    final bottomRightInset = size.width * bottomRightInsetFactor;

    return Path()
      ..moveTo(radius, leftShelfY)
      ..lineTo(leftShelfEnd, leftShelfY)
      ..cubicTo(
        leftShelfEnd + 20,
        leftShelfY,
        rightShelfStart - 24,
        rightShelfY,
        rightShelfStart,
        rightShelfY,
      )
      ..lineTo(size.width - radius, rightShelfY)
      ..quadraticBezierTo(
        size.width,
        rightShelfY,
        size.width,
        rightShelfY + radius,
      )
      ..lineTo(size.width - bottomRightInset, size.height - radius)
      ..quadraticBezierTo(
        size.width - bottomRightInset,
        size.height,
        size.width - bottomRightInset - radius,
        size.height,
      )
      ..lineTo(bottomLeftInset + radius, size.height)
      ..quadraticBezierTo(
        bottomLeftInset,
        size.height,
        bottomLeftInset,
        size.height - radius,
      )
      ..lineTo(0, leftShelfY + radius)
      ..quadraticBezierTo(0, leftShelfY, radius, leftShelfY)
      ..close();
  }

  @override
  bool shouldReclip(covariant PocketClipper oldClipper) {
    return oldClipper.leftShelfYFactor != leftShelfYFactor ||
        oldClipper.rightShelfYFactor != rightShelfYFactor ||
        oldClipper.leftShelfEndFactor != leftShelfEndFactor ||
        oldClipper.rightShelfStartFactor != rightShelfStartFactor ||
        oldClipper.cornerRadiusFactor != cornerRadiusFactor ||
        oldClipper.bottomLeftInsetFactor != bottomLeftInsetFactor ||
        oldClipper.bottomRightInsetFactor != bottomRightInsetFactor;
  }
}

class PocketEdgePainter extends CustomPainter {
  const PocketEdgePainter({
    required this.glowColor,
    this.borderColor = const Color(0xB8FFFFFF),
    this.borderWidth = 1,
    this.clipper = const PocketClipper(),
  });

  final Color glowColor;
  final Color borderColor;
  final double borderWidth;
  final PocketClipper clipper;

  @override
  void paint(Canvas canvas, Size size) {
    final path = clipper.getClip(size);

    final outerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = glowColor.withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawPath(path, outerGlow);

    if (borderWidth > 0) {
      final border = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = borderColor;
      canvas.drawPath(path, border);
    }
  }

  @override
  bool shouldRepaint(covariant PocketEdgePainter oldDelegate) {
    return oldDelegate.glowColor != glowColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        clipper.shouldReclip(oldDelegate.clipper);
  }
}

class _PocketContents extends StatelessWidget {
  const _PocketContents({
    required this.title,
    required this.subtitle,
    required this.labelColor,
    required this.showLeafDecoration,
    required this.titleOffset,
  });

  final String title;
  final String subtitle;
  final Color labelColor;
  final bool showLeafDecoration;
  final Offset titleOffset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: titleOffset.dx,
          top: titleOffset.dy,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 25,
                  height: 1,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    color: labelColor.withValues(alpha: 0.66),
                    fontSize: 14,
                    height: 1,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showLeafDecoration)
          Positioned(
            right: 24,
            bottom: 20,
            width: 58,
            height: 58,
            child: CustomPaint(
              painter: LeafSprigPainter(
                color: labelColor.withValues(alpha: 0.72),
              ),
            ),
          ),
      ],
    );
  }
}

class _FolderFloatingShadow extends StatelessWidget {
  const _FolderFloatingShadow({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _EllipseShadowPainter(progress: progress),
      child: const SizedBox.expand(),
    );
  }
}

class _EllipseShadowPainter extends CustomPainter {
  const _EllipseShadowPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(
        0xFF466878,
      ).withValues(alpha: lerpDouble(0.12, 0.16, progress)!)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        lerpDouble(12, 16, progress)!,
      );
    canvas.drawOval(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _EllipseShadowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _BackPanelClipper extends CustomClipper<Path> {
  const _BackPanelClipper();

  @override
  Path getClip(Size size) {
    final sx = size.width / 281;
    final sy = size.height / 250;
    Offset p(double x, double y) => Offset(x * sx, y * sy);

    return Path()
      ..moveTo(p(29, 0).dx, p(29, 0).dy)
      ..lineTo(p(99, 0).dx, p(99, 0).dy)
      ..cubicTo(
        p(110, 0).dx,
        p(110, 0).dy,
        p(119, 25).dx,
        p(119, 25).dy,
        p(141, 25).dx,
        p(141, 25).dy,
      )
      ..lineTo(p(254, 25).dx, p(254, 25).dy)
      ..quadraticBezierTo(
        p(281, 25).dx,
        p(281, 25).dy,
        p(281, 51).dx,
        p(281, 51).dy,
      )
      ..lineTo(p(281, 222).dx, p(281, 222).dy)
      ..quadraticBezierTo(
        p(281, 250).dx,
        p(281, 250).dy,
        p(253, 250).dx,
        p(253, 250).dy,
      )
      ..lineTo(p(28, 250).dx, p(28, 250).dy)
      ..quadraticBezierTo(
        p(0, 250).dx,
        p(0, 250).dy,
        p(0, 222).dx,
        p(0, 222).dy,
      )
      ..lineTo(p(0, 28).dx, p(0, 28).dy)
      ..quadraticBezierTo(p(0, 0).dx, p(0, 0).dy, p(29, 0).dx, p(29, 0).dy)
      ..close();
  }

  @override
  bool shouldReclip(covariant _BackPanelClipper oldClipper) => false;
}

class _BackPanelEdgePainter extends CustomPainter {
  const _BackPanelEdgePainter({
    required this.glowColor,
    required this.borderColor,
    required this.borderWidth,
    required this.clipper,
  });

  final Color glowColor;
  final Color borderColor;
  final double borderWidth;
  final _BackPanelClipper clipper;

  @override
  void paint(Canvas canvas, Size size) {
    final path = clipper.getClip(size);
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = glowColor.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, glow);

    if (borderWidth > 0) {
      final border = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = borderColor;
      canvas.drawPath(path, border);
    }
  }

  @override
  bool shouldRepaint(covariant _BackPanelEdgePainter oldDelegate) {
    return oldDelegate.glowColor != glowColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}

class LeafSprigPainter extends CustomPainter {
  const LeafSprigPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final stem = Path()
      ..moveTo(size.width * 0.10, size.height * 0.82)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.62,
        size.width * 0.50,
        size.height * 0.40,
        size.width * 0.68,
        size.height * 0.10,
      );
    canvas.drawPath(stem, paint);
    _drawLeaf(canvas, paint, size, const Offset(0.28, 0.67), 0.18, -0.95);
    _drawLeaf(canvas, paint, size, const Offset(0.40, 0.52), 0.20, -1.95);
    _drawLeaf(canvas, paint, size, const Offset(0.53, 0.37), 0.22, -0.85);
    _drawLeaf(canvas, paint, size, const Offset(0.66, 0.18), 0.24, -1.55);
    _drawLeaf(canvas, paint, size, const Offset(0.64, 0.49), 0.20, -0.20);
  }

  void _drawLeaf(
    Canvas canvas,
    Paint paint,
    Size size,
    Offset anchor,
    double scale,
    double angle,
  ) {
    final leafLength = size.shortestSide * scale;
    final leafWidth = leafLength * 0.42;
    final center = Offset(anchor.dx * size.width, anchor.dy * size.height);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final leaf = Path()
      ..moveTo(0, 0)
      ..cubicTo(
        leafLength * 0.24,
        -leafWidth,
        leafLength * 0.78,
        -leafWidth,
        leafLength,
        0,
      )
      ..cubicTo(
        leafLength * 0.78,
        leafWidth,
        leafLength * 0.24,
        leafWidth,
        0,
        0,
      );
    canvas.drawPath(leaf, paint);
    canvas.drawLine(Offset.zero, Offset(leafLength * 0.78, 0), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LeafSprigPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class NoiseOverlay extends StatelessWidget {
  const NoiseOverlay({super.key, required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: NoisePainter(opacity: opacity),
      child: const SizedBox.expand(),
    );
  }
}

class NoisePainter extends CustomPainter {
  const NoisePainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(7);
    const step = 5.0;

    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        paint.color = Colors.white.withValues(
          alpha: random.nextDouble() * opacity,
        );
        canvas.drawRect(Rect.fromLTWH(x, y, step, step), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant NoisePainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}

class _BackGeometry {
  const _BackGeometry(this.rect);

  final Rect rect;

  _BackGeometry translate(double dx, double dy) {
    return _BackGeometry(rect.translate(dx, dy));
  }

  static _BackGeometry lerp(_BackGeometry begin, _BackGeometry end, double t) {
    return _BackGeometry(Rect.lerp(begin.rect, end.rect, t)!);
  }
}

class _FrontGeometry {
  const _FrontGeometry({
    required this.left,
    required this.right,
    required this.bottom,
    required this.leftShelfY,
    required this.leftShelfEndX,
    required this.rightShelfY,
    required this.rightShelfStartX,
    required this.outerRadius,
    required this.bottomLeft,
    required this.bottomRight,
  });

  final double left;
  final double right;
  final double bottom;
  final double leftShelfY;
  final double leftShelfEndX;
  final double rightShelfY;
  final double rightShelfStartX;
  final double outerRadius;
  final double bottomLeft;
  final double bottomRight;

  Rect get rect =>
      Rect.fromLTRB(left, math.min(leftShelfY, rightShelfY) - 1, right, bottom);

  _FrontGeometry translate(double dx, double dy) {
    return _FrontGeometry(
      left: left + dx,
      right: right + dx,
      bottom: bottom + dy,
      leftShelfY: leftShelfY + dy,
      leftShelfEndX: leftShelfEndX + dx,
      rightShelfY: rightShelfY + dy,
      rightShelfStartX: rightShelfStartX + dx,
      outerRadius: outerRadius,
      bottomLeft: bottomLeft + dx,
      bottomRight: bottomRight + dx,
    );
  }

  PocketClipper toClipper() {
    final bounds = rect;
    return PocketClipper(
      leftShelfYFactor: (leftShelfY - bounds.top) / bounds.height,
      rightShelfYFactor: (rightShelfY - bounds.top) / bounds.height,
      leftShelfEndFactor: (leftShelfEndX - bounds.left) / bounds.width,
      rightShelfStartFactor: (rightShelfStartX - bounds.left) / bounds.width,
      cornerRadiusFactor: outerRadius / bounds.width,
      bottomLeftInsetFactor: (bottomLeft - bounds.left) / bounds.width,
      bottomRightInsetFactor: (bounds.right - bottomRight) / bounds.width,
    );
  }

  static _FrontGeometry lerp(
    _FrontGeometry begin,
    _FrontGeometry end,
    double t,
  ) {
    return _FrontGeometry(
      left: lerpDouble(begin.left, end.left, t)!,
      right: lerpDouble(begin.right, end.right, t)!,
      bottom: lerpDouble(begin.bottom, end.bottom, t)!,
      leftShelfY: lerpDouble(begin.leftShelfY, end.leftShelfY, t)!,
      leftShelfEndX: lerpDouble(begin.leftShelfEndX, end.leftShelfEndX, t)!,
      rightShelfY: lerpDouble(begin.rightShelfY, end.rightShelfY, t)!,
      rightShelfStartX: lerpDouble(
        begin.rightShelfStartX,
        end.rightShelfStartX,
        t,
      )!,
      outerRadius: lerpDouble(begin.outerRadius, end.outerRadius, t)!,
      bottomLeft: lerpDouble(begin.bottomLeft, end.bottomLeft, t)!,
      bottomRight: lerpDouble(begin.bottomRight, end.bottomRight, t)!,
    );
  }
}

class _StampPose {
  const _StampPose({
    required this.center,
    required this.size,
    required this.rotationDelta,
  });

  final Offset center;
  final Size size;
  final double rotationDelta;

  factory _StampPose.fromData(StampFolderStampData data) {
    final width = data.widthFactor * _referenceSize.width;
    final height = data.imageAspectRatio == null
        ? data.heightFactor * _referenceSize.height
        : width / data.imageAspectRatio!;
    final left = data.leftFactor != null
        ? data.leftFactor! * _referenceSize.width
        : _referenceSize.width -
              data.rightFactor! * _referenceSize.width -
              width;
    final top = data.topFactor * _referenceSize.height;
    return _StampPose(
      center: Offset(left + width / 2, top + height / 2),
      size: Size(width, height),
      rotationDelta: 0,
    );
  }

  _StampPose translate(double dx, double dy) {
    return _StampPose(
      center: center.translate(dx, dy),
      size: size,
      rotationDelta: rotationDelta,
    );
  }

  _StampPose rotate(double delta) {
    return _StampPose(
      center: center,
      size: size,
      rotationDelta: rotationDelta + delta,
    );
  }

  static _StampPose lerp(_StampPose begin, _StampPose end, double t) {
    return _StampPose(
      center: Offset.lerp(begin.center, end.center, t)!,
      size: Size.lerp(begin.size, end.size, t)!,
      rotationDelta: lerpDouble(begin.rotationDelta, end.rotationDelta, t)!,
    );
  }
}

_StampPose _constrainPortraitIdlePose(
  _StampPose pose, {
  required double stampRotation,
}) {
  const inset = 2.0;
  final bounds = _backIdle.rect.deflate(inset);
  final angle = (pose.rotationDelta + stampRotation).abs();
  final sinAngle = math.sin(angle).abs();
  final cosAngle = math.cos(angle).abs();
  final halfWidth =
      (pose.size.width * cosAngle + pose.size.height * sinAngle) / 2;
  final halfHeight =
      (pose.size.width * sinAngle + pose.size.height * cosAngle) / 2;
  final minX = bounds.left + halfWidth;
  final maxX = bounds.right - halfWidth;
  final minY = bounds.top + halfHeight;
  final maxY = bounds.bottom - halfHeight;
  final center = Offset(
    minX <= maxX
        ? pose.center.dx.clamp(minX, maxX).toDouble()
        : bounds.center.dx,
    minY <= maxY
        ? pose.center.dy.clamp(minY, maxY).toDouble()
        : bounds.center.dy,
  );

  return _StampPose(
    center: center,
    size: pose.size,
    rotationDelta: pose.rotationDelta,
  );
}

List<Color> _resolveColors(List<Color> colors) {
  if (colors.isEmpty) {
    return const [Colors.transparent, Colors.transparent, Colors.transparent];
  }
  if (colors.length == 1) {
    return [colors[0], colors[0], colors[0]];
  }
  if (colors.length == 2) {
    return [colors[0], colors[1], colors[1]];
  }
  return [colors[0], colors[1], colors[2]];
}

double _timelineFraction(Duration duration, double totalMilliseconds) {
  return (duration.inMilliseconds / totalMilliseconds).clamp(0.0, 1.0);
}

List<Color> _lerpColors(List<Color> begin, List<Color> end, double t) {
  return List<Color>.generate(
    3,
    (index) => Color.lerp(begin[index], end[index], t)!,
    growable: false,
  );
}

bool _sameColors(List<Color> first, List<Color> second) {
  if (first.length != second.length) {
    return false;
  }
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) {
      return false;
    }
  }
  return true;
}

const _backIdle = _BackGeometry(Rect.fromLTRB(109, 152, 391, 402));
const _backEngaged = _BackGeometry(Rect.fromLTRB(108, 120, 389, 370));

const _frontIdle = _FrontGeometry(
  left: 109,
  right: 391,
  bottom: 402,
  leftShelfY: 245,
  leftShelfEndX: 252,
  rightShelfY: 225,
  rightShelfStartX: 310,
  outerRadius: 28,
  bottomLeft: 109,
  bottomRight: 391,
);
const _frontEngaged = _FrontGeometry(
  left: 108,
  right: 389,
  bottom: 370,
  leftShelfY: 220,
  leftShelfEndX: 258,
  rightShelfY: 198,
  rightShelfStartX: 316,
  outerRadius: 28,
  bottomLeft: 108,
  bottomRight: 389,
);
const _labelIdle = Offset(134, 343);
const _labelEngaged = Offset(133, 313);
const _labelFoldedBase = Offset(136, 308);

const _shadowIdle = Rect.fromLTRB(145, 400, 357, 434);
const _shadowEngaged = Rect.fromLTRB(139, 383, 361, 422);

const _horizontalIdleCardOffsets = [
  Offset(0, 112),
  Offset(0, 100),
  Offset(-10, 110),
];
const _horizontalEngagedCardOffsets = [
  Offset(0, 64),
  Offset(0, 70),
  Offset(0, 60),
];
const _portraitIdleCardOffsets = [
  Offset(0, 112),
  Offset(0, 124),
  Offset(-10, 110),
];
const _portraitEngagedCardOffsets = [
  Offset(0, 64),
  Offset(0, 82),
  Offset(0, 60),
];
const double _portraitCardGroupShift = -6;
const _idleCardRotationOffsets = <double>[0.02, 0, -0.03];
const _engagedCardRotationOffsets = <double>[0.01, 0, -0.01];
