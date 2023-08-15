import 'package:flutter/material.dart';

class SearchViewStyle {
  static double get toolbarHeightSearch => 120.0;
  static double get toolbarHeightOfSliverAppBar => 44.0;

  static EdgeInsetsGeometry get paddingRecentChatsHeaders =>
      const EdgeInsets.symmetric(horizontal: 16);
  static EdgeInsetsGeometry get paddingLeadingAppBar =>
      const EdgeInsetsDirectional.only(end: 8, start: 8, top: 40);
  static EdgeInsets get marginIconBack =>
      const EdgeInsets.symmetric(vertical: 12.0);
  static EdgeInsetsGeometry get contentPaddingAppBar =>
      const EdgeInsets.all(12.0);
  static EdgeInsetsGeometry get paddingRecentChats =>
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
}
