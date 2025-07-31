import 'dart:developer';
import '../models/summary_model.dart';

abstract class SummaryLocalDataSource {
  Future<SummaryModel> getSummaryByPatient(String patientId);
}

class SummaryLocalDataSourceImpl implements SummaryLocalDataSource {
  // Datos estáticos simulando resúmenes generados por IA
  final Map<String, SummaryModel> _summaries = {};

  SummaryLocalDataSourceImpl() {
    _initializeSummaries();
  }

  void _initializeSummaries() {
    // Resúmenes para diferentes pacientes
    _summaries['patient_001'] = SummaryModel(
      id: 'summary_001',
      patientId: 'patient_001',
      title: 'Resumen de Progreso Emocional',
      content: '''Análisis basado en 24 notas registradas durante las últimas 4 semanas:

**Patrones Emocionales Identificados:**
• Predominancia de estados de calma y reflexión en las tardes
• Picos de ansiedad principalmente los lunes y miércoles
• Mejora gradual en la gestión del estrés laboral

**Temas Recurrentes:**
• Búsqueda de equilibrio entre vida personal y profesional
• Desarrollo de técnicas de mindfulness y respiración
• Fortalecimiento de relaciones interpersonales

**Indicadores de Progreso:**
• Incremento del 40% en emociones positivas comparado con el mes anterior
• Mayor conciencia emocional y capacidad de auto-reflexión
• Implementación exitosa de rutinas de autocuidado

**Recomendaciones:**
• Continuar con las prácticas de meditación matutina
• Explorar técnicas de gestión del tiempo para reducir ansiedad
• Mantener la consistencia en el registro emocional''',
      generatedAt: DateTime.now().subtract(const Duration(days: 1)),
      aiModel: 'GPT-4 Therapeutic Analysis',
      analysedNotesCount: 24,
    );

    _summaries['patient_002'] = SummaryModel(
      id: 'summary_002',
      patientId: 'patient_002',
      title: 'Análisis de Bienestar Emocional',
      content: '''Resumen basado en 18 entradas del diario emocional:

**Tendencias Emocionales:**
• Estados de gratitud y alegría más frecuentes los fines de semana
• Episodios de tristeza leve correlacionados con cambios climáticos
• Notable estabilidad emocional general con pequeñas fluctuaciones

**Insights Principales:**
• Las actividades creativas generan mayor sensación de logro
• El ejercicio físico muestra impacto positivo inmediato en el estado de ánimo
• Las interacciones sociales actúan como reguladores emocionales naturales

**Fortalezas Identificadas:**
• Excelente capacidad de introspección y autoconocimiento
• Habilidad para identificar triggers emocionales tempranamente
• Uso efectivo de estrategias de afrontamiento positivas

**Áreas de Oportunidad:**
• Desarrollar mayor tolerancia a la incertidumbre
• Fortalecer la resiliencia ante situaciones imprevistas
• Explorar nuevas formas de expresión emocional''',
      generatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      aiModel: 'Claude-3 Emotional Intelligence',
      analysedNotesCount: 18,
    );

    _summaries['patient_003'] = SummaryModel(
      id: 'summary_003',
      patientId: 'patient_003',
      title: 'Evaluación de Crecimiento Personal',
      content: '''Análisis comprehensivo de 31 registros emocionales:

**Evolución Emocional:**
• Transición exitosa de estados predominantemente reactivos a proactivos
• Desarrollo significativo en la regulación emocional
• Mayor frecuencia de emociones asociadas con propósito y significado

**Patrones de Comportamiento:**
• Las mañanas muestran mayor claridad mental y decisiones más asertivas
• Los momentos de soledad se han convertido en oportunidades de crecimiento
• Mejora notable en la comunicación de necesidades emocionales

**Logros Destacados:**
• Reducción del 60% en episodios de ansiedad severa
• Incremento en actividades de autocuidado y bienestar
• Establecimiento de límites saludables en relaciones personales

**Plan de Continuidad:**
• Mantener la práctica diaria de registro emocional
• Explorar técnicas avanzadas de autorregulación
• Considerar la incorporación de actividades de servicio comunitario''',
      generatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      aiModel: 'Gemini Pro Wellness Analysis',
      analysedNotesCount: 31,
    );

    // Resumen por defecto para cualquier paciente sin resumen específico
    _summaries['default'] = SummaryModel(
      id: 'summary_default',
      patientId: 'default',
      title: 'Resumen Inicial de Seguimiento',
      content: '''Análisis preliminar basado en los primeros registros emocionales:

**Observaciones Iniciales:**
• El paciente muestra compromiso con el proceso de autorregistro emocional
• Diversidad emocional saludable con predominancia de estados neutros y positivos
• Capacidad de introspección y reflexión en desarrollo

**Patrones Tempranos:**
• Mayor actividad emocional durante las transiciones del día
• Respuesta positiva a las actividades de relajación y mindfulness
• Interés genuino en el autoconocimiento y crecimiento personal

**Recomendaciones Iniciales:**
• Continuar con la consistencia en el registro diario
• Explorar la conexión entre actividades específicas y estados emocionales
• Desarrollar un vocabulario emocional más amplio y específico

**Próximos Pasos:**
• Mantener la observación de patrones durante 2-3 semanas más
• Identificar triggers y estrategias de afrontamiento personalizadas
• Establecer objetivos específicos de bienestar emocional''',
      generatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      aiModel: 'AI Therapeutic Assistant',
      analysedNotesCount: 5,
    );
  }

  @override
  Future<SummaryModel> getSummaryByPatient(String patientId) async {
    log('📋 SUMMARY DATA SOURCE: Fetching summary for patient: $patientId');
    await Future.delayed(const Duration(milliseconds: 800)); // Simular latencia de red
    
    final summary = _summaries[patientId] ?? _summaries['default']!;
    
    // Crear una copia con el patientId correcto
    final adjustedSummary = SummaryModel(
      id: summary.id,
      patientId: patientId,
      title: summary.title,
      content: summary.content,
      generatedAt: summary.generatedAt,
      aiModel: summary.aiModel,
      analysedNotesCount: summary.analysedNotesCount,
    );
    
    log('✅ SUMMARY DATA SOURCE: Found summary "${adjustedSummary.title}" for patient $patientId');
    return adjustedSummary;
  }
}
