import 'dart:io';

import 'console_color.dart';

class ColoredOutput {
  static void printColor(ConsoleColor color, String text,
      {bool reset = false}) {
    print('${color.ansi}$text${ConsoleColor.reset.ansi}');
  }

  static void write(ConsoleColor color, String text, {bool reset = false}) {
    stdout.write('${color.ansi}$text${ConsoleColor.reset.ansi}');
  }

  static void writeln(ConsoleColor color, String text, {bool reset = false}) {
    stdout.writeln('${color.ansi}$text${ConsoleColor.reset.ansi}');
  }
}
