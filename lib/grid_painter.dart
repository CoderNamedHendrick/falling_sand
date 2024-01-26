import 'dart:math';

import 'package:flutter/material.dart';

import 'grid.dart';

class GridPainter extends CustomPainter {
  GridPainter({
    required this.gridNotifier,
    required this.grid,
    required this.cellSize,
  });

  final ValueNotifier<Grid<int>> gridNotifier;
  final Grid<int> grid;
  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas, size, grid);
    _computeGridUpdate(grid);
  }

  void _computeGridUpdate(Grid<int> grid) {
    Grid<int> nextGrid = Grid.make(grid.rows, grid.columns, 0);

    for (int i = 0; i <= grid.rows - 1; i++) {
      for (int j = 0; j <= grid.columns - 1; j++) {
        final state = grid.value[i][j];
        if (state > 0) {
          final below = grid.value.elementAtOrNull(i + 1)?[j];

          final dir = Random().nextDouble() < 0.5 ? -1 : 1;
          int? belowA, belowB;

          // checks that the right cell beside the cell below is in bounds
          if (j + dir >= 0 && j + dir <= grid.columns - 1) {
            belowA =
                grid.value.elementAtOrNull(i + 1)?.elementAtOrNull(j + dir);
          }

          // checks that the left cell beside the cell below is in bounds
          if (j - dir >= 0 && j - dir <= grid.columns - 1) {
            belowB =
                grid.value.elementAtOrNull(i + 1)?.elementAtOrNull(j - dir);
          }

          if (below == 0) {
            nextGrid.value[i + 1][j] = grid.value[i][j];
          } else if (belowA == 0) {
            nextGrid.value[i + 1][j + dir] = grid.value[i][j];
          } else if (belowB == 0) {
            nextGrid.value[i + 1][j - dir] = grid.value[i][j];
          } else {
            nextGrid.value[i][j] = grid.value[i][j];
          }
        }
      }
    }

    // safely tells the notifier to update its value to trigger a rebuild
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      gridNotifier.value = nextGrid;
    });
  }

  void _paintGrid(Canvas canvas, Size size, Grid<int> grid) {
    for (int i = 0; i <= grid.rows - 1; i++) {
      for (int j = 0; j <= grid.columns - 1; j++) {
        final state = grid.value[i][j];

        // a cell is filled when it's greater than zero
        if (state > 0) {
          final yOrigin = 0 + (size.height ~/ grid.rows * i).toDouble();
          final xOrigin = 0 + (size.width ~/ grid.columns * j).toDouble();
          final center = cellSize / 2;

          final hue = HSLColor.fromAHSL(1, state.toDouble(), 1, 0.5);
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(xOrigin + center, yOrigin + center),
              width: cellSize,
              height: cellSize,
            ),
            Paint()
              ..color = hue.toColor()
              ..style = PaintingStyle.fill,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! GridPainter) return false;

    // ensure unnecessary paint calls doesn't trigger repaints
    if (oldDelegate.grid != grid) return true;

    return false;
  }
}
