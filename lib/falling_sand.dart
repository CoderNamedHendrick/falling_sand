import 'dart:math';

import 'package:flutter/material.dart';

import 'grid.dart';
import 'grid_painter.dart';

final _kNullValue = Grid<int>.make(0, 0, 0);

class FallingSand extends StatefulWidget {
  const FallingSand({super.key});

  @override
  State<FallingSand> createState() => _FallingSandState();
}

class _FallingSandState extends State<FallingSand> {
  late Size size = MediaQuery.sizeOf(context);

  static const sandPopMatrixSize = 3;

  int hueValue = 200;

  ValueNotifier<Grid<int>>? gridNotifier;
  double cellSize = 15;

  @override
  void didChangeDependencies() {
    gridNotifier ??= ValueNotifier(
        Grid.make(size.height ~/ cellSize, size.width ~/ cellSize, 0));

    _rebuildGrid();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    gridNotifier?.dispose();
    super.dispose();
  }

  void _rebuildGrid() {
    if (gridNotifier != null) {
      Grid<int> newGrid = _copyGrid();
      gridNotifier!.value = newGrid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            size = Size(constraints.maxWidth, constraints.maxHeight);
            return RepaintBoundary(
              child: ValueListenableBuilder(
                valueListenable: gridNotifier ?? ValueNotifier(_kNullValue),
                builder: (context, grid, child) {
                  return Listener(
                    onPointerDown: _onGestureUpdate,
                    onPointerMove: _onGestureUpdate,
                    child: CustomPaint(
                      painter: GridPainter(
                        gridNotifier:
                            gridNotifier ?? ValueNotifier(_kNullValue),
                        cellSize: cellSize,
                        grid: grid,
                      ),
                      size: Size(
                        size.width, // accounting for left and right
                        size.height, // accounting for top and bottom
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        Slider(
          value: cellSize,
          min: 8,
          max: 40,
          label: cellSize.toString(),
          divisions: 32,
          onChanged: (value) {
            setState(() {
              cellSize = value;
            });

            _rebuildGrid();
          },
        ),
      ],
    );
  }

  // generate a splurge of particles when we detect tap/drag events
  // within the bounds of the particles canvas
  void _onGestureUpdate(PointerEvent event) {
    if (gridNotifier == null) return;

    final position = event.localPosition;
    final isWithinXBounds = position.dx >= 0 && position.dx < size.width;

    final isWithinYBounds = position.dy >= 0 && position.dy < size.height;

    if (isWithinXBounds && isWithinYBounds) {
      final touchInputColumn = position.dx ~/ cellSize;
      final touchInputRow = position.dy ~/ cellSize;

      final updateArea = _updateArea(touchInputColumn, touchInputRow);
      gridNotifier!.value = updateArea;

      // update hueValue to give a range of colors
      hueValue += 1;
      if (hueValue > 360) {
        hueValue = 1;
      }
    }
  }

  Grid<int> _updateArea(int touchInputColumn, int touchInputRow) {
    if (gridNotifier == null) return _kNullValue;
    Grid<int> newGrid = _copyGrid();

    const extent = sandPopMatrixSize ~/ 2;

    for (int i = -extent; i <= extent; i++) {
      for (int j = -extent; j <= extent; j++) {
        // introduce some randomness with emitting the particles
        if (Random().nextDouble() < 0.6) {
          final col = touchInputColumn + i;
          final row = touchInputRow + j;

          if (col >= 0 &&
              col <= newGrid.columns - 1 &&
              row >= 0 &&
              row <= newGrid.rows) {
            newGrid.value[row][col] = hueValue;
          }
        }
      }
    }

    return newGrid;
  }

  Grid<int> _copyGrid() {
    Grid<int> newGrid =
        Grid.make(size.height ~/ cellSize, size.width ~/ cellSize, 0);

    newGrid = newGrid.copyWith(grid: gridNotifier!.value.value);

    return newGrid;
  }
}
