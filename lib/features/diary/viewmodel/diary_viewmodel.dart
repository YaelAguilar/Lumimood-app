import 'package:flutter/material.dart';
import '../model/emotion_model.dart';

class DiaryViewModel extends ChangeNotifier {
  late final TextEditingController titleController;
  late final TextEditingController contentController;
  late final FocusNode titleFocusNode;
  late final FocusNode contentFocusNode;

  DiaryViewModel() {
    titleController = TextEditingController();
    contentController = TextEditingController();
    titleFocusNode = FocusNode();
    contentFocusNode = FocusNode();
  }

  List<Emotion> get emotions => AppEmotions.emotions;

  void onEmotionTapped(BuildContext context, Emotion emotion) {
    print('Emoción seleccionada: ${emotion.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Seleccionaste: ${emotion.name}'),
        backgroundColor: emotion.color,
      ),
    );
  }

  void saveNote() {
    final title = titleController.text;
    final content = contentController.text;

    if (title.isEmpty || content.isEmpty) {
      print('El título o el contenido están vacíos.');
      return;
    }
    
    print('Guardando nota...');
    print('Título: $title');
    print('Contenido: $content');

    titleController.clear();
    contentController.clear();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    super.dispose();
  }
}