import 'package:flutter/material.dart';
import 'welcome_page_widget.dart' show WelcomePageWidget;

abstract class FlutterFlowModel<T extends StatefulWidget> extends ChangeNotifier {
  void initState(BuildContext context);
  
  @override
  void dispose();
}

class WelcomePageModel extends FlutterFlowModel<WelcomePageWidget> {
  @override
  void initState(BuildContext context) {
  }

}