import 'package:flutter/cupertino.dart';

class IconHelper {
  static IconData getStationIcon(String key) {
    switch (key) {
      case 'school': return CupertinoIcons.building_2_fill;
      case 'tent': return CupertinoIcons.map_pin_ellipse;
      case 'building': return CupertinoIcons.house_fill;
      case 'office': return CupertinoIcons.square_grid_2x2_fill;
      default: return CupertinoIcons.location_solid;
    }
  }
}
