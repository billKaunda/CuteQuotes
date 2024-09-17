import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class _SvgAsset extends StatelessWidget {
  const _SvgAsset(
    this.assetPath, {
    // ignore: unused_element
    super.key,
    this.height,
    this.width,
  });

  final String? assetPath;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/$assetPath',
      height: height,
      width: width,
      package: 'component_library',
    );
  }
}

class OpeningQuoteSvgAsset extends StatelessWidget {
  const OpeningQuoteSvgAsset({
    super.key,
    this.height,
    this.width,
  });

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return _SvgAsset(
      'opening-quote.svg',
      height: height,
      width: width,
    );
  }
}

class ClosingQuoteSvgAsset extends StatelessWidget {
  const ClosingQuoteSvgAsset({
    super.key,
    this.height,
    this.width,
  });

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return _SvgAsset(
      'closing-quote.svg',
      height: height,
      width: width,
    );
  }
}
