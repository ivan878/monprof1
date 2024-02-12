import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/theme.dart';

class SimpleText extends StatelessWidget {
  final String text;
  final double? size;
  final TextAlign? align;
  final TextOverflow? overflow;
  final Color? color;
  final FontWeight? weight;
  final double? letterspacing;
  final int? maxlines;
  const SimpleText(
      {super.key,
      this.weight,
      required this.text,
      this.align,
      this.maxlines,
      this.letterspacing,
      this.size,
      this.overflow,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      maxLines: maxlines,
      style: textStyle.copyWith(
        letterSpacing: letterspacing,
        color: color,
        fontSize: size,
        fontWeight: weight,
        overflow: overflow,
      ),
    );
  }
}
