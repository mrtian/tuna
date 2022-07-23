import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
 
enum PageAnimateType{
  fade,
  zoom,
  rotateZoom,
  slide,
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  slideFromTop,
  modal,
  modalSlide,
  modalSheet,
  df
}

//渐变效果
class CustomRouteJianBian extends PageRouteBuilder{
  final Widget widget;
  final RouteSettings settings;
  CustomRouteJianBian(this.widget,{required this.settings})
    :super(
      transitionDuration:const Duration(microseconds:450),
      pageBuilder:(
        BuildContext context,
        Animation<double> animation1,
        Animation<double> animation2){
          return widget;
        },
     transitionsBuilder:(
          BuildContext context,
          Animation<double> animation1,
          Animation<double> animation2,
          Widget child){
            return FadeTransition(
              opacity: Tween(begin:0.0,end :2.0).animate(CurvedAnimation(
                  parent:animation1,
                  curve:Curves.fastOutSlowIn
              )),
              child: child,
            );
        },
    settings:settings  
  ); 
}

//缩放效果
class CustomRouteZoom extends PageRouteBuilder{
  final Widget widget;
  final RouteSettings settings;
  CustomRouteZoom(this.widget,{required this.settings})
    :super(
      transitionDuration:const Duration(seconds:1),
      pageBuilder:(
        BuildContext context,
        Animation<double> animation1,
        Animation<double> animation2){
          return widget;
        },
     transitionsBuilder:(
          BuildContext context,
          Animation<double> animation1,
          Animation<double> animation2,
          Widget child){
 
            return ScaleTransition(
              scale:Tween(begin:0.0,end:1.0).animate(CurvedAnimation(
                  parent:animation1,
                  curve: Curves.fastOutSlowIn
                  )),
              child:child
            );
            
        },
    settings:settings
    ); 
}
 
//旋转+缩放效果
class CustomRouteRotateZoom extends PageRouteBuilder{
  final Widget widget;
  final RouteSettings settings;
  CustomRouteRotateZoom(this.widget,{required this.settings})
    :super(
      transitionDuration:const Duration(seconds:1),
      pageBuilder:(
        BuildContext context,
        Animation<double> animation1,
        Animation<double> animation2){
          return widget;
        },
     transitionsBuilder:(
          BuildContext context,
          Animation<double> animation1,
          Animation<double> animation2,
          Widget child){
 
            return RotationTransition(
              turns:Tween(begin:0.0,end:1.0)
              .animate(CurvedAnimation(
                parent: animation1,
                curve: Curves.fastOutSlowIn
              )),
 
            child:ScaleTransition(
              scale:Tween(begin: 0.0,end:1.0)
              .animate(CurvedAnimation(
                parent: animation1,
                curve:Curves.fastOutSlowIn
              )),
              child: child,
            )
        );
           
      } ,
    settings:settings
    ); 
}
 
 
 
 
//滑动效果
class CustomRouteSlide extends PageRouteBuilder{
  final Widget widget;
  final RouteSettings settings;
  CustomRouteSlide(this.widget,{required this.settings})
    :super(
      // transitionDuration:const Duration(seconds:1),
      pageBuilder:(
        BuildContext context,
        Animation<double> animation1,
        Animation<double> animation2){
          return widget;
        },
     transitionsBuilder:(
          BuildContext context,
          Animation<double> animation1,
          Animation<double> animation2,
          Widget child){
 
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(1.0, 0.0),
                end:Offset(0.0, 0.0)
              )
            .animate(CurvedAnimation(
              parent: animation1,
              curve: Curves.fastOutSlowIn
            )),
            child: child,
            
      );
            
    },
    settings:settings 
  ); 
}


// 右滑过渡
class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  final RouteSettings settings;
  SlideRightRoute(this.page,{required this.settings})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
    settings:settings      
  );
}

// 由下向上过渡
class SlideFromBottomRoute extends PageRouteBuilder {
  final Widget page;
  final RouteSettings settings;
  SlideFromBottomRoute(this.page,{required this.settings})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
        settings :settings
      );
}
// 由上向下过渡
class SlideFromTopRoute extends PageRouteBuilder {
  final Widget page;
  final RouteSettings settings;
  SlideFromTopRoute(this.page,{required this.settings})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
        settings :settings
      );
}

// modal
class CustomModalRoute extends PageRouteBuilder {
  final Widget page;
  final RouteSettings settings;
  CustomModalRoute(this.page,{required this.settings})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(animation),
          child: page,
        ),
    settings:settings  
    );
}


class ModalSlideRoute extends PageRoute<void> {
  final Widget page;
  final RouteSettings settings;
  ModalSlideRoute(this.page,{required this.settings})  : super(settings: settings, fullscreenDialog: true);

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 350);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(animation),
          child: page,
        ),
    );
  }
}
