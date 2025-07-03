import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'welcome_page_model.dart';

class FlutterFlowTheme {
  static FlutterFlowTheme of(BuildContext context) => FlutterFlowTheme._();
  FlutterFlowTheme._();
  Color get secondaryBackground => Colors.grey[50]!;
  Color get accent4 => Colors.grey[100]!;
  Color get primaryBackground => Colors.white;
  Color get primaryText => Colors.black;
  Color get alternate => Colors.grey[300]!;
  TextStyle get displayLarge => const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black);
  TextStyle get displaySmall => const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black);
  TextStyle get labelMedium => TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[600]);
  TextStyle get titleSmall => const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black);
}

class AnimationInfo {
  final AnimationTrigger trigger;
  final List<Effect> Function() effectsBuilder;
  AnimationInfo({required this.trigger, required this.effectsBuilder});
}
enum AnimationTrigger { onPageLoad }

extension AnimateOnPageLoadExtension on Widget {
  Widget animateOnPageLoad(AnimationInfo? animationInfo) {
    if (animationInfo == null) return this;
    final effects = animationInfo.effectsBuilder();
    return animate().addEffects(effects);
  }
}

class FFButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final FFButtonOptions options;
  const FFButtonWidget({super.key, this.onPressed, required this.text, required this.options});
  
  @override
  Widget build(BuildContext context) {
    final hasElevation = options.elevation > 0;
    return Container(
      width: options.width,
      height: options.height,
      decoration: BoxDecoration(
        color: options.color,
        borderRadius: options.borderRadius,
        border: Border.all(color: options.borderSide.color, width: options.borderSide.width),
        boxShadow: hasElevation ? [BoxShadow(color: Colors.black.withAlpha(51), blurRadius: options.elevation, offset: Offset(0, options.elevation / 2))] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onPressed, borderRadius: options.borderRadius, child: Container(padding: options.padding, alignment: Alignment.center, child: Text(text, style: options.textStyle))),
      ),
    );
  }
}

class FFButtonOptions {
  final double? width, height;
  final double elevation;
  final EdgeInsetsGeometry padding, iconPadding;
  final Color color;
  final TextStyle textStyle;
  final BorderSide borderSide;
  final BorderRadius borderRadius;
  FFButtonOptions({this.width, this.height, this.padding = EdgeInsets.zero, this.iconPadding = EdgeInsets.zero, required this.color, required this.textStyle, this.elevation = 0, this.borderSide = BorderSide.none, this.borderRadius = BorderRadius.zero});
}

extension TextStyleExtension on TextStyle { TextStyle override({String? fontFamily, Color? color, double? letterSpacing}) => copyWith(fontFamily: fontFamily, color: color, letterSpacing: letterSpacing); }

class WelcomePageWidget extends StatefulWidget {
  const WelcomePageWidget({super.key});
  @override
  State<WelcomePageWidget> createState() => _WelcomePageWidgetState();
}

class _WelcomePageWidgetState extends State<WelcomePageWidget> with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    animationsMap.addAll({
      'containerOnPageLoadAnimation1': AnimationInfo(trigger: AnimationTrigger.onPageLoad, effectsBuilder: () => [VisibilityEffect(duration: 1.ms), FadeEffect(curve: Curves.easeInOut, delay: 0.0.ms, duration: 400.0.ms, begin: 0.0, end: 1.0), ScaleEffect(curve: Curves.easeInOut, delay: 0.0.ms, duration: 400.0.ms, begin: const Offset(3.0, 3.0), end: const Offset(1.0, 1.0))]),
      'containerOnPageLoadAnimation2': AnimationInfo(trigger: AnimationTrigger.onPageLoad, effectsBuilder: () => [VisibilityEffect(duration: 300.ms), FadeEffect(curve: Curves.easeInOut, delay: 300.0.ms, duration: 300.0.ms, begin: 0.0, end: 1.0), ScaleEffect(curve: Curves.bounceOut, delay: 300.0.ms, duration: 300.0.ms, begin: const Offset(0.6, 0.6), end: const Offset(1.0, 1.0))]),
      'textOnPageLoadAnimation1': AnimationInfo(trigger: AnimationTrigger.onPageLoad, effectsBuilder: () => [VisibilityEffect(duration: 350.ms), FadeEffect(curve: Curves.easeInOut, delay: 350.0.ms, duration: 400.0.ms, begin: 0.0, end: 1.0), MoveEffect(curve: Curves.easeInOut, delay: 350.0.ms, duration: 400.0.ms, begin: const Offset(0.0, 30.0), end: const Offset(0.0, 0.0))]),
      'textOnPageLoadAnimation2': AnimationInfo(trigger: AnimationTrigger.onPageLoad, effectsBuilder: () => [VisibilityEffect(duration: 400.ms), FadeEffect(curve: Curves.easeInOut, delay: 400.0.ms, duration: 400.0.ms, begin: 0.0, end: 1.0), MoveEffect(curve: Curves.easeInOut, delay: 400.0.ms, duration: 400.0.ms, begin: const Offset(0.0, 30.0), end: const Offset(0.0, 0.0))]),
      'rowOnPageLoadAnimation': AnimationInfo(trigger: AnimationTrigger.onPageLoad, effectsBuilder: () => [VisibilityEffect(duration: 300.ms), FadeEffect(curve: Curves.easeInOut, delay: 300.0.ms, duration: 600.0.ms, begin: 0.0, end: 1.0), ScaleEffect(curve: Curves.bounceOut, delay: 300.0.ms, duration: 600.0.ms, begin: const Offset(0.6, 0.6), end: const Offset(1.0, 1.0))]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WelcomePageModel(),
      child: Consumer<WelcomePageModel>(
        builder: (context, model, child) {
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
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
                        decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0x00FFFFFF), FlutterFlowTheme.of(context).secondaryBackground], stops: const [0, 1], begin: const AlignmentDirectional(0, -1), end: const AlignmentDirectional(0, 1))),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 120, height: 120, decoration: BoxDecoration(color: FlutterFlowTheme.of(context).accent4, shape: BoxShape.circle), child: Align(alignment: const AlignmentDirectional(0, 0), child: Text('L', style: FlutterFlowTheme.of(context).displayLarge.override(fontFamily: GoogleFonts.notoSans().fontFamily, color: const Color(0xFF63DA5C), letterSpacing: 0.0)))).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation2']),
                            Padding(padding: const EdgeInsetsDirectional.fromSTEB(0, 44, 0, 0), child: Text('Bienvenido', style: FlutterFlowTheme.of(context).displaySmall.override(fontFamily: GoogleFonts.interTight().fontFamily, letterSpacing: 0.0))).animateOnPageLoad(animationsMap['textOnPageLoadAnimation1']),
                            Padding(padding: const EdgeInsetsDirectional.fromSTEB(44, 8, 44, 0), child: Text('Gracias por unirte a Lumimood \nAccede o crea tu cuenta, y empieza con este viaje', textAlign: TextAlign.center, style: FlutterFlowTheme.of(context).labelMedium.override(fontFamily: GoogleFonts.inter().fontFamily, letterSpacing: 0.0))).animateOnPageLoad(animationsMap['textOnPageLoadAnimation2']),
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
                          child: Align(
                            alignment: const AlignmentDirectional(0, 0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 16),
                              child: FFButtonWidget(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Botón de Registro presionado'),
                                    ),
                                  );
                                },
                                text: 'Regístrate',
                                options: FFButtonOptions(width: 230, height: 52, color: FlutterFlowTheme.of(context).primaryBackground, textStyle: FlutterFlowTheme.of(context).titleSmall.override(fontFamily: GoogleFonts.interTight().fontFamily, color: FlutterFlowTheme.of(context).primaryText, letterSpacing: 0.0), elevation: 3, borderSide: BorderSide(color: FlutterFlowTheme.of(context).alternate, width: 1), borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: const AlignmentDirectional(0, 0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 16),
                              child: FFButtonWidget(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Botón de Iniciar Sesión presionado'),
                                    ),
                                  );
                                },
                                text: 'Iniciar sesión',
                                options: FFButtonOptions(width: 230, height: 52, color: const Color(0xFF63DA5C), textStyle: FlutterFlowTheme.of(context).titleSmall.override(fontFamily: GoogleFonts.interTight().fontFamily, color: Colors.white, letterSpacing: 0.0), elevation: 3, borderSide: const BorderSide(color: Colors.transparent, width: 1), borderRadius: BorderRadius.circular(12)),
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