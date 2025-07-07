import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/animation_extensions.dart';
import '../../../core/extensions/text_style_extensions.dart';
import '../../../ui/shared_widgets/custom_button.dart';
import '../viewmodel/welcome_viewmodel.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    animationsMap.addAll({
      'containerOnPageLoadAnimation1': AnimationInfo(trigger: AnimationTrigger.onPageLoad, effectsBuilder: () => [VisibilityEffect(duration: 1.ms), FadeEffect(curve: Curves.easeInOut, duration: 400.0.ms, begin: 0.0, end: 1.0), ScaleEffect(curve: Curves.easeInOut, duration: 400.0.ms, begin: const Offset(3.0, 3.0), end: const Offset(1.0, 1.0))]),
      'containerOnPageLoadAnimation2': AnimationInfo(trigger: AnimationTrigger.onPageLoad, effectsBuilder: () => [VisibilityEffect(duration: 300.ms), FadeEffect(curve: Curves.easeInOut, delay: 300.0.ms, duration: 300.0.ms, begin: 0.0, end: 1.0), ScaleEffect(curve: Curves.bounceOut, delay: 300.0.ms, duration: 300.0.ms, begin: const Offset(0.6, 0.6), end: const Offset(1.0, 1.0))]),
      'textOnPageLoadAnimation1': AnimationInfo(trigger: AnimationTrigger.onPageLoad, effectsBuilder: () => [VisibilityEffect(duration: 350.ms), FadeEffect(curve: Curves.easeInOut, delay: 350.0.ms, duration: 400.0.ms, begin: 0.0, end: 1.0), MoveEffect(curve: Curves.easeInOut, delay: 350.0.ms, duration: 400.0.ms, begin: const Offset(0.0, 30.0), end: const Offset(0.0, 0.0))]),
      'textOnPageLoadAnimation2': AnimationInfo(trigger: AnimationTrigger.onPageLoad, effectsBuilder: () => [VisibilityEffect(duration: 400.ms), FadeEffect(curve: Curves.easeInOut, delay: 400.0.ms, duration: 400.0.ms, begin: 0.0, end: 1.0), MoveEffect(curve: Curves.easeInOut, delay: 400.0.ms, duration: 400.0.ms, begin: const Offset(0.0, 30.0), end: const Offset(0.0, 0.0))]),
      'rowOnPageLoadAnimation': AnimationInfo(trigger: AnimationTrigger.onPageLoad, effectsBuilder: () => [VisibilityEffect(duration: 300.ms), FadeEffect(curve: Curves.easeInOut, delay: 300.0.ms, duration: 600.0.ms, begin: 0.0, end: 1.0), ScaleEffect(curve: Curves.bounceOut, delay: 300.0.ms, duration: 600.0.ms, begin: const Offset(0.6, 0.6), end: const Offset(1.0, 1.0))]),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return ChangeNotifierProvider(
      create: (context) => WelcomeViewModel(),
      child: Consumer<WelcomeViewModel>(
        builder: (context, viewModel, child) {
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: theme.secondaryBackground,
              body: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 500,
                      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF39E2EF), Color(0xFF63FF59), Color(0xFF60EE9E)], stops: [0, 0.5, 1], begin: AlignmentDirectional(-1, -1), end: AlignmentDirectional(1, 1))),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0x00FFFFFF), theme.secondaryBackground], stops: const [0, 1], begin: const AlignmentDirectional(0, -1), end: const AlignmentDirectional(0, 1))),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(color: theme.accent4, shape: BoxShape.circle),
                              child: Align(
                                alignment: const AlignmentDirectional(0, 0),
                                child: Text('L', style: theme.displayLarge.override(fontFamily: GoogleFonts.notoSans().fontFamily, color: theme.primaryColor, letterSpacing: 0.0)),
                              ),
                            ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation2']),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 44, 0, 0),
                              child: Text('Bienvenido', style: theme.displaySmall.override(fontFamily: GoogleFonts.interTight().fontFamily, letterSpacing: 0.0)),
                            ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation1']),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(44, 8, 44, 0),
                              child: Text('Gracias por unirte a Lumimood \nAccede o crea tu cuenta, y empieza con este viaje', textAlign: TextAlign.center, style: theme.labelMedium.override(fontFamily: GoogleFonts.inter().fontFamily, letterSpacing: 0.0)),
                            ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation2']),
                          ],
                        ),
                      ),
                    ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation1']),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 44),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 16),
                            child: CustomButton(
                              onPressed: () => viewModel.onRegisterTapped(context),
                              text: 'Regístrate',
                              options: ButtonOptions(
                                width: 230,
                                height: 52,
                                color: theme.primaryBackground,
                                textStyle: theme.titleSmall.override(fontFamily: GoogleFonts.interTight().fontFamily, color: theme.primaryText, letterSpacing: 0.0),
                                elevation: 3,
                                borderSide: BorderSide(color: theme.alternate, width: 1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 16),
                            child: CustomButton(
                              onPressed: () => viewModel.onLoginTapped(context),
                              text: 'Iniciar sesión',
                              options: ButtonOptions(
                                width: 230,
                                height: 52,
                                color: theme.primaryColor,
                                textStyle: theme.titleSmall.override(fontFamily: GoogleFonts.interTight().fontFamily, color: Colors.white, letterSpacing: 0.0),
                                elevation: 3,
                                borderSide: const BorderSide(color: Colors.transparent, width: 1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animateOnPageLoad(animationsMap['rowOnPageLoadAnimation']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}