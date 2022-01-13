import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ff_navigation_bar_theme.dart';
import 'dart:ui' as ui;

// This class has mutable instance properties as they are used to store
// calculated values required by multiple build functions but not known
// (or required to be specified) at creation of instance parameters.
// For example, a color attribute will be modified depending on whether
// the item is selected or not.
// They are also used to store values retrieved from a Provider allowing
// properties to be communicated from the navigation bar to the individual
// items of the bar.

// ignore: must_be_immutable
class FFNavigationBarItem extends StatelessWidget {
  final String label;
  final IconData? iconData;
  final Duration animationDuration;
  Color? selectedBackgroundColor;
  Color? selectedForegroundColor;
  Color? selectedLabelColor;

  int? index;
  int? selectedIndex;
  late FFNavigationBarTheme theme;
  late bool showSelectedItemShadow;
  double itemWidth;
  VoidCallback? onClick;

  void setIndex(int index) {
    this.index = index;
  }

  Color _getDerivedBorderColor() {
    return theme.selectedItemBorderColor;
  }

  Color _getBorderColor(bool isOn) {
    return isOn ? _getDerivedBorderColor() : _getDerivedBorderColor().withOpacity(0.0);
  }

  bool _isItemSelected() {
    return index == selectedIndex;
  }

  static const kDefaultAnimationDuration = Duration(milliseconds: 1500);

  FFNavigationBarItem({
    Key? key,
    required this.label,
    this.itemWidth = 60,
    this.selectedBackgroundColor,
    this.selectedForegroundColor,
    this.selectedLabelColor,
    this.iconData,
    this.animationDuration = kDefaultAnimationDuration,
    this.onClick,
  }) : super(key: key);

  Center _makeLabel(String label) {
    bool isSelected = _isItemSelected();
    return Center(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isSelected ? theme.selectedItemTextStyle.fontSize : theme.unselectedItemTextStyle.fontSize,
          fontWeight: isSelected ? theme.selectedItemTextStyle.fontWeight : theme.unselectedItemTextStyle.fontWeight,
          color: isSelected ? selectedLabelColor ?? theme.selectedItemLabelColor : theme.unselectedItemLabelColor,
          letterSpacing: isSelected ? 1.1 : 1.0,
        ),
      ),
    );
  }

  Widget _makeIconArea(double itemWidth, IconData? iconData) {
    bool isSelected = _isItemSelected();
    double radius = itemWidth / 2;
    double innerBoxSize = itemWidth - 8;
    double innerRadius = (itemWidth - 8) / 2 - 4;

    return AnimatedContainer(
      duration: animationDuration,
      width: itemWidth,
      height: isSelected ? itemWidth : itemWidth / 1.4,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isSelected ? theme.selectedItemBackgroundGradient : null,
        color: isSelected ? selectedBackgroundColor ?? theme.selectedItemBackgroundColor : theme.unselectedItemBackgroundColor,
        border: Border.all(width: theme.selectedItemBorderWidth, color: _getBorderColor(isSelected)),
      ),
      child: (isSelected && onClick != null) ? GestureDetector(onTap: onClick, child: _makeIcon(iconData)) : _makeIcon(iconData),
    );
    /*return CircleAvatar(
      radius: isSelected ? radius : radius * 0.7,
      backgroundColor: _getBorderColor(isSelected),
      child: SizedBox(
        width: innerBoxSize,
        height: isSelected ? innerBoxSize : innerBoxSize / 2,
        child: CircleAvatar(
          radius: innerRadius,
          backgroundColor: isSelected
              ? selectedBackgroundColor ?? theme.selectedItemBackgroundColor
              : theme.unselectedItemBackgroundColor,
          child: _makeIcon(iconData),
        ),
      ),
    );*/
  }

  Widget _makeIcon(IconData? iconData) {
    bool isSelected = _isItemSelected();
    if (theme.unselectedItemIconGradient != null && !isSelected)
      return ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (Rect bounds) {
          return ui.Gradient.linear((theme.unselectedItemIconGradient!.begin as Alignment).alongSize(bounds.size), (theme.unselectedItemIconGradient!.end as Alignment).alongSize(bounds.size), theme.unselectedItemIconGradient!.colors);
        },
        child: Icon(
          iconData,
          size: theme.unselectedItemIconSize,
        ),
      );
    else
      return Icon(
        iconData,
        color: isSelected ? selectedForegroundColor ?? theme.selectedItemIconColor : theme.unselectedItemIconColor,
        size: isSelected ? theme.selectedItemIconSize : theme.unselectedItemIconSize,
      );
  }

  Widget _makeShadow() {
    bool isSelected = _isItemSelected();
    double height = isSelected ? 4 : 0;
    double width = isSelected ? itemWidth + 6 : 0;

    return AnimatedContainer(
      duration: Duration(milliseconds: 100),
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.elliptical(itemWidth / 2, 2)),
        boxShadow: [
          theme.barShadow ??
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
              ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    theme = Provider.of<FFNavigationBarTheme>(context);
    showSelectedItemShadow = theme.showSelectedItemShadow;
    itemWidth = theme.itemWidth;
    selectedIndex = Provider.of<int>(context);

    selectedBackgroundColor = selectedBackgroundColor ?? theme.selectedItemBackgroundColor;
    selectedForegroundColor = selectedForegroundColor ?? theme.selectedItemIconColor;
    selectedLabelColor = selectedLabelColor ?? theme.selectedItemLabelColor;

    bool isSelected = _isItemSelected();
    double itemHeight = itemWidth - 20;
    double topOffset = isSelected ? (-10 - theme.selectedItemTopOffset) : -10;
    double iconTopSpacer = isSelected ? 0 : 2;
    double shadowTopSpacer = 4;

    Widget labelWidget = _makeLabel(label);
    Widget iconAreaWidget = _makeIconArea(itemWidth, iconData);
    Widget shadowWidget = showSelectedItemShadow ? _makeShadow() : Container();

    return AnimatedContainer(
      width: itemWidth,
      height: double.maxFinite,
      duration: animationDuration,
      child: SizedBox(
        width: itemWidth,
        height: itemHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              top: topOffset,
              left: -itemWidth / 2,
              right: -itemWidth / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: iconTopSpacer),
                  iconAreaWidget,
                  labelWidget,
                  SizedBox(height: shadowTopSpacer),
                  shadowWidget,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
