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
  static const _stampImageAspectRatio = 0.72;
  static const _imageUrls = [
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=720&h=1000&q=85',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=720&h=1000&q=85',
    'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=720&h=1000&q=85',
  ];
  static const _folderTitle = 'Summer Escape';

  int _selectedPalette = 0;
  int _selectedStampCount = 3;

  List<StampFolderStampData> _buildCards() {
    final defaults = StampFolderWidget.buildDefaultStamps(
      imageProvider: NetworkImage(_imageUrls[0]),
      imageAspectRatio: _stampImageAspectRatio,
    );
    return List.generate(
      _selectedStampCount,
      (index) => defaults[index].copyWith(
        imageProvider: NetworkImage(_imageUrls[index]),
        displayMode: StampImageDisplayMode.cover,
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
                        title: _folderTitle,
                        subtitle: '$_selectedStampCount stamps',
                        titleOffset: const Offset(2, -3),
                        subtitleOffset: const Offset(0, 2),
                        titleTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          height: 1,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                        subtitleTextStyle: const TextStyle(
                          color: Color(0xCFFFFFFF),
                          fontSize: 13,
                          height: 1,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.35,
                        ),
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
                        frontBorderColor: Colors.white.withValues(alpha: 0.86),
                        frontBorderWidth: 2,
                        backBorderColor: Colors.white.withValues(alpha: 0.68),
                        backBorderWidth: 1.5,
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
                    Positioned(
                      top: 530,
                      left: 105,
                      right: 105,
                      height: 40,
                      child: _StampCountSelector(
                        selectedCount: _selectedStampCount,
                        onChanged: (count) {
                          setState(() => _selectedStampCount = count);
                        },
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

class _StampCountSelector extends StatelessWidget {
  const _StampCountSelector({
    required this.selectedCount,
    required this.onChanged,
  });

  final int selectedCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF1B4052).withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Text(
            'Images',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.84),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          for (final count in const [0, 1, 2, 3]) ...[
            _StampCountButton(
              key: ValueKey('stamp-count-$count'),
              count: count,
              selected: selectedCount == count,
              onPressed: () => onChanged(count),
            ),
            if (count != 3) const SizedBox(width: 3),
          ],
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _StampCountButton extends StatelessWidget {
  const _StampCountButton({
    super.key,
    required this.count,
    required this.selected,
    required this.onPressed,
  });

  final int count;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Show $count images',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 167),
          curve: Curves.easeOutCubic,
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: selected
                  ? const Color(0xFF1B4052)
                  : Colors.white.withValues(alpha: 0.82),
              fontSize: 13,
              fontWeight: FontWeight.w700,
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
