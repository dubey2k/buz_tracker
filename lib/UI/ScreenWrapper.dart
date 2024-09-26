import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:flutter/material.dart';

class ScreenStatus {}

class OkStatus extends ScreenStatus {}

class EmptyStatus extends ScreenStatus {
  final String message;
  EmptyStatus(this.message);
}

class ErrorStatus extends ScreenStatus {
  final String message;
  ErrorStatus(this.message);
}

class LoadingStatus extends ScreenStatus {
  final bool toBlur;
  final double opacity;
  final Color blurColor;

  LoadingStatus({
    this.toBlur = false,
    this.opacity = 0.7,
    this.blurColor = Colors.grey,
  });
}

class ScreenWrapper extends StatefulWidget {
  final Widget child;
  final ScreenStatus status;
  const ScreenWrapper({super.key, required this.child, required this.status});

  @override
  State<ScreenWrapper> createState() => _ScreenWrapperState();
}

class _ScreenWrapperState extends State<ScreenWrapper> {
  @override
  Widget build(BuildContext context) {
    if (widget.status is LoadingStatus) {
      return addLoadingScreen(widget.status as LoadingStatus);
    } else if (widget.status is ErrorStatus) {
      return addErrorScreen(widget.status as ErrorStatus);
    } else if (widget.status is EmptyStatus) {
      return addEmptyScreen();
    } else if (widget.status is OkStatus) {
      return widget.child;
    } else {
      return widget.child;
    }
  }

  Widget addLoadingScreen(LoadingStatus status) {
    if (status.toBlur) {
      return Stack(
        children: [
          widget.child,
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: status.opacity,
              child: Container(
                color: status.blurColor,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget addErrorScreen(ErrorStatus status) {
    return Center(
      child: TextWidget(size: 18, text: status.message),
    );
  }

  Widget addEmptyScreen() {
    return const Center(
      child: TextWidget(size: 18, text: "Data isn't available"),
    );
  }
}
