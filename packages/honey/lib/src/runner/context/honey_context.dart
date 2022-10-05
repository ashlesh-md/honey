import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:honey/src/models/widget_expression.dart';
import 'package:honey/src/utils/fake_text_input.dart';
import 'package:honey_core/honey_core.dart';

import 'runtime_honey_context.dart';

abstract class HoneyContext {
  static Rect get screenRect => RuntimeHoneyContext.screenRect;

  var _canceled = false;
  bool get canceled => _canceled;

  var message = '';

  void cancel() {
    _canceled = true;
  }

  SemanticsNode get semanticsTree;

  FakeTextInput get fakeTextInput;

  Future<Expression> getVariable(String name);

  Future<void> setVariable(String name, Expression expression);

  void deleteVariable(String name);

  bool hasVariable(String name);

  void dispatchPointerEvent(PointerEvent e);

  Future delay(Duration duration);

  Future click({
    WidgetExp? widget,
    Offset? offset,
    ClickType type = ClickType.Single,
  }) async {
    final rect = widget?.rect ?? screenRect;
    if (offset != null) {
      if (offset.dx <= 1 && offset.dy <= 1) {
        offset = Offset(offset.dx * rect.width, offset.dy * rect.height);
      }
      offset = rect.shift(offset).center;
    }

    final downEvent = PointerDownEvent(position: offset ?? rect.center);
    dispatchPointerEvent(downEvent);
    final upEvent = PointerUpEvent();
    dispatchPointerEvent(upEvent);
  }

  //TODO: move it to separate class / mixin / extension.
  Future swipe({
    WidgetExp? widget,
    Offset? offset,
    SwipeType type = SwipeType.Left,
  }) async {
    //TODO move it to SwipeType
    int dx() {
      switch (type) {
        case SwipeType.Left:
          return -1;
        case SwipeType.Right:
          return 1;
        default:
          return 0;
      }
    }

//TODO move it to SwipeType
    int dy() {
      switch (type) {
        case SwipeType.Up:
          return -1;
        case SwipeType.Down:
          return 1;
        default:
          return 0;
      }
    }

    final rect = widget?.rect ?? screenRect;
    if (offset != null) {
      if (offset.dx <= 1 && offset.dy <= 1) {
        offset = Offset(offset.dx * rect.width, offset.dy * rect.height);
      }
      offset = rect.shift(offset).center;
    }
    final downEvent = PointerDownEvent(position: offset ?? rect.center);
    dispatchPointerEvent(downEvent);
    final move1Event = PointerMoveEvent(
      position: offset ?? rect.center,
      delta: Offset(0, 0),
    );
    dispatchPointerEvent(move1Event);
    final moveEvent = PointerMoveEvent(
      position: offset ?? rect.center,
      delta: Offset(200.0 * dx(), 200.0 * dy()),
    );
    dispatchPointerEvent(moveEvent);
    final upEvent = PointerUpEvent();
    dispatchPointerEvent(upEvent);
  }

  Future<Expression> eval(Expression expression);
}

enum ClickType { Single, Double, Long, Right }

enum SwipeType {
  Left('left'),
  Up('up'),
  Down('down'),
  Right('right');

  final String label;
  const SwipeType(this.label);
  factory SwipeType.from(String label) {
    return SwipeType.values.firstWhere((e) => e.label == label);
  }
}
