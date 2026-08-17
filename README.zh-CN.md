# stamp_folder_widget_v2

[English](./README.md) | 简体中文

一个可复用的 Flutter 文件夹组件包，包含圆角后层底板、可折叠磨砂前层封套和三张可配置图片卡片。组件以固定的 `520 x 582` 母版坐标绘制，确保不同尺寸下保持相同的形状和动效比例。

## 功能特性

- 可复用的 Flutter 包 API
- 整体尺寸可调
- 前层封套颜色可调
- 后层底板颜色可调
- 外部邮票图片源、位置、尺寸、旋转和叠色可调
- 按参考动效实现 idle、engaged、expanded 三个状态
- 仅支持点击开合，包含整体上浮、前层向用户翻开和三张图片依次展开
- 支持配色平滑过渡
- 支持 `AssetImage`、`NetworkImage` 等 `ImageProvider`
- 自带 `example` 示例工程

## 安装

```yaml
dependencies:
  stamp_folder_widget_v2: ^1.0.0
```

本地联调时可这样引用：

```yaml
dependencies:
  stamp_folder_widget_v2:
    path: ../stamp_widget_v2
```

## 使用示例

```dart
import 'package:flutter/material.dart';
import 'package:stamp_folder_widget_v2/stamp_folder_widget_v2.dart';

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stamps = StampFolderWidget.buildDefaultStamps(
      imageProvider: const AssetImage('assets/example.webp'),
    );

    return Center(
      child: StampFolderWidget(width: 760, stamps: stamps),
    );
  }
}
```

你也可以通过尺寸、前后层颜色、文案和邮票布局进行自定义：

```dart
import 'package:flutter/material.dart';
import 'package:stamp_folder_widget_v2/stamp_folder_widget_v2.dart';

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final baseImage = const AssetImage('assets/example.webp');
    final stamps = StampFolderWidget.buildDefaultStamps(
      imageProvider: baseImage,
    );
    final customizedStamps = [
      stamps[0],
      stamps[1].copyWith(
        leftFactor: 0.41,
        tint: const Color(0x3378A66A),
      ),
      stamps[2].copyWith(
        rightFactor: 0.16,
        topFactor: 0.245,
      ),
    ];

    return Center(
      child: StampFolderWidget(
        width: 820,
        title: 'STAMP',
        subtitle: 'Collection',
        frontPanelColors: const [
          Color(0xFFF7F0E3),
          Color(0xFFE8DFC7),
          Color(0xFFF7F2EA),
        ],
        backPanelColors: const [
          Color(0xFFF8F2E6),
          Color(0xFFF1E7D6),
          Color(0xFFFBF7F0),
        ],
        stamps: customizedStamps,
      ),
    );
  }
}
```

## 主要 API

- `StampFolderWidget`
- `StampFolderStampData`

## 可调参数

### 组件尺寸

- `width`：组件外部宽度
- `height`：组件外部高度
- `aspectRatio`：未固定高度时的整体比例
- `padding`：组件内部留白

### 文件夹外观

- `frontPanelColors`：前层磨砂封套渐变色
- `backPanelColors`：后层底板渐变色
- `frontEdgeGlowColor`：前层封套边缘发光颜色
- `backEdgeGlowColor`：后层底板边缘发光颜色
- `frontBorderColor`：前层封套边框颜色，颜色的透明度可控制边框透明度
- `frontBorderWidth`：前层封套边框粗细，设置为 `0` 可隐藏边框
- `backBorderColor`：后层底板边框颜色，颜色的透明度可控制边框透明度
- `backBorderWidth`：后层底板边框粗细，设置为 `0` 可隐藏边框
- `title`：前层封套主标题
- `subtitle`：前层封套副标题
- `labelColor`：文字与叶子装饰颜色
- `showLeafDecoration`：是否展示叶子装饰
- `showStampBorders`：是否全局显示图片白色边框

### 打开动画

- `enableTapAnimation`：是否启用点击打开/关闭
- `initiallyOpen`：是否以打开状态开始
- `animationDuration`：打开动画时长
- `liftAnimationDuration`：静默状态到上浮状态的动画时长
- `frontOpenAnimationDuration`：前层翻开和图片展开阶段的动画时长
- `reverseAnimationDuration`：关闭动画时长
- `colorTransitionDuration`：配色切换动画时长
- `openLiftFactor`：打开时文件夹整体上移距离比例
- `openFrontScale`：前层向用户翻开后的纵向透视比例
- `semanticsLabel`：交互文件夹的无障碍标签
- `onOpenChanged`：点击切换后返回新的打开状态

### 邮票配置

向 `stamps` 传入 0～3 个 `StampFolderStampData`。替换列表并重建组件，
即可动态添加或减少展示的图片。

每个 `StampFolderStampData` 支持：

- `imageProvider`
- `imageAspectRatio`
- `leftFactor`
- `rightFactor`
- `topFactor`
- `widthFactor`
- `heightFactor`
- `rotation`
- `tint`
- `showBorder`
- `fit`
- `displayMode`
- `borderRadius`
- `borderWidth`
- `borderColor`
- `shadowColor`
- `shadowBlurRadius`
- `shadowOffset`

`displayMode` 支持三种图片填充方式：

- `StampImageDisplayMode.cover`：保持原有行为，按 `fit` 填满卡片，默认会裁剪图片。
- `StampImageDisplayMode.contain`：完整显示图片，空余区域保持透明。
- `StampImageDisplayMode.containWithBlur`：完整显示图片，并使用同图裁剪模糊背景填满空余区域，适合竖版图片。

`buildDefaultStamps` 已使用统一约 `3:4` 的竖版卡片和
`containWithBlur`，适合直接展示竖向矩形图片。

如果图片比例固定，可以传入 `imageAspectRatio`（宽 / 高），例如：

```dart
final stamps = StampFolderWidget.buildDefaultStamps(
  imageProvider: imageProvider,
  imageAspectRatio: 0.72,
);
```

传入后组件会根据卡片宽度动态计算高度，并使用 `BoxFit.cover` 填充，
避免图片边缘出现额外的纯色或模糊填充。静默态的竖版卡片也会限制在后层文件夹范围内。

## 使用说明

- 组件支持 0～3 张图片，超过 3 张会抛出错误。
- 如果前后层颜色少于 3 个，组件会自动补齐可用的渐变颜色组。
- 组件包内部不再内置邮票图片，需要由接入方提供图片源。
- 完整包使用方式可参考 [`example/lib/main.dart`](./example/lib/main.dart)。
- 实测形状、坐标和动效约束见 [`FOLDER_SHAPE_ANIMATION_SPEC.md`](docs/FOLDER_SHAPE_ANIMATION_SPEC.md)。

## 开发

```bash
flutter analyze
flutter test
```
