import 'dart:async';
import 'dart:math';

import 'package:falling_sand/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

class FallingSandSketch extends Sketch {
  late Grid<int> _grid;
  final cellWidth = 10.0;
  late int columns, rows;
  static const sandPopMatrixSize = 3;
  int hueValue = 200;

  FallingSandSketch(this.canvasSize);

  final Size canvasSize;

  @override
  void mouseDragged() {
    _onGestureUpdate();
  }

  @override
  FutureOr<void> setup() async {
    size(width: canvasSize.width.toInt(), height: canvasSize.height.toInt());

    columns = width ~/ cellWidth;
    rows = height ~/ cellWidth;
    _grid = Grid.make(rows, columns, 0);
  }

  @override
  FutureOr<void> draw() {
    background(color: Colors.black);

    for (int i = 0; i <= _grid.rows - 1; i++) {
      for (int j = 0; j <= _grid.columns - 1; j++) {
        final state = _grid.value[i][j];

        noStroke();
        fill(
          color: HSLColor.fromAHSL(1, state.toDouble(), 1, 0.5).toColor(),
        );

        if (state > 0) {
          final yOrigin = i * cellWidth;
          final xOrigin = j * cellWidth;
          final center = cellWidth / 2;
          square(
            Square.fromCenter(
                Offset(xOrigin + center, yOrigin + center), cellWidth),
          );
        }
      }
    }

    _computeGridUpdate(_grid);
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

    _grid = nextGrid;
  }

  void _onGestureUpdate() {
    final isWithinXBounds = mouseX >= 0 && mouseX < width;

    final isWithinYBounds = mouseY >= 0 && mouseY < height;

    if (isWithinXBounds && isWithinYBounds) {
      final touchInputColumn = mouseX ~/ cellWidth;
      final touchInputRow = mouseY ~/ cellWidth;

      final updateArea = _updateArea(touchInputColumn, touchInputRow);
      _grid = updateArea;

      // update hueValue to give a range of colors
      hueValue += 1;
      if (hueValue > 360) {
        hueValue = 1;
      }
    }
  }

  Grid<int> _updateArea(int touchInputColumn, int touchInputRow) {
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
    Grid<int> newGrid = Grid.make(rows, columns, 0);

    newGrid = newGrid.copyWith(grid: _grid.value);

    return newGrid;
  }
}
