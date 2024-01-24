import 'dart:math';

import 'package:equatable/equatable.dart';

final class Grid<T> extends Equatable {
  final List<List<T>> value;

  final T initialValue;

  const Grid._(this.value, this.initialValue);

  factory Grid.make(int rows, int columns, T initialValue) {
    return Grid._(
      List.generate(
        rows,
        (index) => List.generate(columns, (index) => initialValue),
      ),
      initialValue,
    );
  }

  int get rows {
    return value.length;
  }

  int get columns {
    return value.first.length;
  }

  int filledCellsCount(bool Function(T state) filter) {
    return filledCells(filter).length;
  }

  List<({int row, int column})> filledCells(bool Function(T state) filter) {
    List<({int row, int column})> cells = [];
    for (int i = 0; i <= rows - 1; i++) {
      for (int j = 0; j <= columns - 1; j++) {
        final state = value[i][j];

        if (filter(state)) cells.add((row: i, column: j));
      }
    }
    return cells;
  }

  /// Due to the vector nature of the grid(2x2 matrix), to ensure the equality
  /// works properly and to help dart infer that a new grid object is created
  /// we use the grid factory to create a new instance and copy the grid values
  /// to this new grid before returning the instance
  Grid<T> copyWith({List<List<T>>? grid}) {
    if (grid != null) {
      Grid<T> nextGrid = Grid.make(rows, columns, initialValue);

      // scaling on the vertical side
      if (grid.gridSize.rows > nextGrid.rows ||
          grid.gridSize.rows < nextGrid.rows) {
        int shiftFactor = 1;

        if (grid.gridSize.rows < nextGrid.rows) {
          shiftFactor *= -1;
        }

        // by how many rows is the new grid smaller
        final distance =
            (grid.gridSize.rows - nextGrid.value.gridSize.rows) * shiftFactor;

        for (int i = 0; i <= rows - 1; i++) {
          for (int j = 0; j <= columns - 1; j++) {
            final gridState =
                grid.elementAtOrNull(i + distance)?.elementAtOrNull(j);
            nextGrid.value[i][j] = gridState ?? initialValue;
          }
        }

        return nextGrid;
      }

      for (int i = 0; i <= rows - 1; i++) {
        for (int j = 0; j <= columns - 1; j++) {
          final gridState = grid.elementAtOrNull(i)?.elementAtOrNull(j);
          // fill with the default/initial value if we can't find the cell to
          // update
          nextGrid.value[i][j] = gridState ?? initialValue;
        }
      }

      return nextGrid;
    }

    return Grid._(grid ?? this.value, initialValue);
  }

  @override
  List<Object?> get props => [value];
}

extension GridX<T> on List<List<T>> {
  ({int rows, int columns}) get gridSize {
    int maxColumns = 0;

    for (int i = 0; i < length - 1; i++) {
      maxColumns = max(maxColumns, this[i].length);
    }

    return (rows: length, columns: maxColumns);
  }
}
