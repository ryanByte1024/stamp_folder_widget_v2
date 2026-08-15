import 'package:flutter/material.dart';
import 'package:stamp_folder_widget_v2/stamp_folder_widget_v2.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16BDF2)),
        scaffoldBackgroundColor: const Color(0xFFE4EDF5),
        useMaterial3: true,
      ),
      home: const FolderDemoPage(),
    );
  }
}

class FolderDemoPage extends StatefulWidget {
  const FolderDemoPage({super.key});

  @override
  State<FolderDemoPage> createState() => _FolderDemoPageState();
}

class _FolderDemoPageState extends State<FolderDemoPage> {
  static const _imageUrls = [
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=800&q=85',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=85',
    'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=800&q=85',
  ];

  int _selectedPalette = 0;

  List<StampFolderStampData> _buildCards() {
    final defaults = StampFolderWidget.buildDefaultStamps(
      imageProvider: NetworkImage(_imageUrls[0]),
    );
    return List.generate(
      defaults.length,
      (index) => defaults[index].copyWith(
        imageProvider: NetworkImage(_imageUrls[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[_selectedPalette];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 520,
                height: 582,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: StampFolderWidget(
                        stamps: _buildCards(),
                        showStampBorders: false,
                        animationDuration: const Duration(milliseconds: 900),
                        liftAnimationDuration: const Duration(
                          milliseconds: 160,
                        ),
                        frontOpenAnimationDuration: const Duration(
                          milliseconds: 160,
                        ),
                        frontPanelColors: palette.frontColors,
                        backPanelColors: palette.backColors,
                        semanticsLabel: 'Animated designs folder',
                      ),
                    ),
                    Positioned(
                      top: 475,
                      left: 162,
                      right: 162,
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (var index = 0; index < _palettes.length; index++)
                            _PaletteButton(
                              key: ValueKey('palette-$index'),
                              color: _palettes[index].selectorColor,
                              selected: index == _selectedPalette,
                              onPressed: () {
                                setState(() => _selectedPalette = index);
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaletteButton extends StatelessWidget {
  const _PaletteButton({
    super.key,
    required this.color,
    required this.selected,
    required this.onPressed,
  });

  final Color color;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Select folder color',
      child: InkResponse(
        onTap: onPressed,
        radius: 25,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 167),
          curve: Curves.easeOutCubic,
          width: selected ? 44 : 28,
          height: selected ? 44 : 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: selected ? 0.82 : 0.35),
              width: selected ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.28),
                blurRadius: selected ? 14 : 7,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderPalette {
  const _FolderPalette({
    required this.selectorColor,
    required this.frontColors,
    required this.backColors,
  });

  final Color selectorColor;
  final List<Color> frontColors;
  final List<Color> backColors;
}

const _palettes = [
  _FolderPalette(
    selectorColor: Color(0xFF16BDF2),
    frontColors: [Color(0xFF7CDBF6), Color(0xFF6BB8C6), Color(0xFF62C5C7)],
    backColors: [Color(0xFF13C4FA), Color(0xFF14BCFA), Color(0xFF12B8F3)],
  ),
  _FolderPalette(
    selectorColor: Color(0xFFFFB332),
    frontColors: [Color(0xFFF1D069), Color(0xFFDFC543), Color(0xFFE0C73F)],
    backColors: [Color(0xFFFDB032), Color(0xFFFAAA26), Color(0xFFF5A51F)],
  ),
  _FolderPalette(
    selectorColor: Color(0xFF08C593),
    frontColors: [Color(0xFF31AF86), Color(0xFF2EB88B), Color(0xFF53CC71)],
    backColors: [Color(0xFF02C698), Color(0xFF05BD8F), Color(0xFF00B98A)],
  ),
];
