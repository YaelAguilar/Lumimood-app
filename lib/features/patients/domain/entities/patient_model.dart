import 'dart:developer';
import 'patient_entity.dart';

class PatientModel extends PatientEntity {
  const PatientModel({
    required super.id,
    required super.name,
    required super.lastNameFather,
    required super.lastNameMother,
    required super.birthDate,
    required super.gender,
    required super.phone,
    required super.email,
    required super.professionalId,
    super.createdAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    try {
      log('📋 PATIENT MODEL: Parsing JSON: $json');
      
      // Extraer el ID
      String id;
      if (json.containsKey('idPatient')) {
        id = json['idPatient'].toString();
      } else if (json.containsKey('id')) {
        id = json['id'].toString();
      } else if (json.containsKey('_id')) {
        id = json['_id'].toString();
      } else {
        throw Exception('No se encontró el ID del paciente en la respuesta');
      }

      // Extraer nombre
      String name = json['name']?.toString() ?? '';
      
      // Extraer apellidos
      String lastNameFather = json['lastNameFather']?.toString() ?? '';
      String lastNameMother = json['lastNameMother']?.toString() ?? '';
      
      // Extraer fecha de nacimiento - manejar formato DD-MM-YYYY
      DateTime birthDate;
      try {
        if (json.containsKey('birthDate')) {
          String birthDateStr = json['birthDate'].toString();
          log('📋 PATIENT MODEL: Raw birthDate: $birthDateStr');
          
          // Si viene en formato DD-MM-YYYY, convertir a YYYY-MM-DD
          if (birthDateStr.contains('-') && birthDateStr.length == 10) {
            List<String> parts = birthDateStr.split('-');
            if (parts.length == 3 && parts[0].length == 2) {
              // Es formato DD-MM-YYYY, convertir a YYYY-MM-DD
              birthDateStr = '${parts[2]}-${parts[1]}-${parts[0]}';
              log('📋 PATIENT MODEL: Converted birthDate to: $birthDateStr');
            }
          }
          
          birthDate = DateTime.parse(birthDateStr);
        } else {
          birthDate = DateTime.now().subtract(const Duration(days: 365 * 25)); // Default 25 años
        }
      } catch (e) {
        log('⚠️ PATIENT MODEL: Error parsing birthDate: $e');
        birthDate = DateTime.now().subtract(const Duration(days: 365 * 25));
      }

      // Extraer género - limpiar formato {value: Masculino}
      String gender = _cleanTextValue(json['gender']?.toString() ?? 'No especificado');
      log('📋 PATIENT MODEL: Cleaned gender: $gender');
      
      // Extraer teléfono
      String phone = json['phone']?.toString() ?? '';
      
      // EXTRACCIÓN MEJORADA DEL EMAIL - MÁS ROBUSTA
      String email = _extractEmail(json);
      log('📋 PATIENT MODEL: Final email: "$email"');
      
      // Extraer professionalId
      String professionalId = json['professionalId']?.toString() ?? '';
      
      // Extraer fecha de creación
      DateTime? createdAt;
      if (json.containsKey('createdAt')) {
        try {
          createdAt = DateTime.parse(json['createdAt'].toString());
        } catch (e) {
          log('⚠️ PATIENT MODEL: Error parsing createdAt: $e');
          createdAt = null;
        }
      }

      final patientModel = PatientModel(
        id: id,
        name: name,
        lastNameFather: lastNameFather,
        lastNameMother: lastNameMother,
        birthDate: birthDate,
        gender: gender,
        phone: phone,
        email: email,
        professionalId: professionalId,
        createdAt: createdAt,
      );

      log('✅ PATIENT MODEL: Successfully parsed patient');
      log('   - ID: $id');
      log('   - Name: "$name $lastNameFather $lastNameMother"');
      log('   - Email: "$email"');
      log('   - Gender: "$gender"');
      log('   - Phone: "$phone"');
      
      return patientModel;

    } catch (e, stackTrace) {
      log('❌ PATIENT MODEL: Error parsing JSON: $e');
      log('❌ PATIENT MODEL: Stack trace: $stackTrace');
      log('❌ PATIENT MODEL: JSON was: $json');
      rethrow;
    }
  }

  /// Función mejorada para extraer el email de diferentes estructuras JSON
  static String _extractEmail(Map<String, dynamic> json) {
    // Primera pasada: buscar en el nivel principal
    String email = _searchEmailInLevel(json);
    if (email.isNotEmpty) {
      log('📧 EMAIL: Found in main level: "$email"');
      return email;
    }

    // Segunda pasada: buscar en objetos anidados comunes
    final nestedObjects = ['user', 'credentials', 'account', 'profile', 'personal'];
    for (String objectKey in nestedObjects) {
      if (json.containsKey(objectKey) && json[objectKey] is Map<String, dynamic>) {
        final nestedEmail = _searchEmailInLevel(json[objectKey] as Map<String, dynamic>);
        if (nestedEmail.isNotEmpty) {
          log('📧 EMAIL: Found in nested object "$objectKey": "$nestedEmail"');
          return nestedEmail;
        }
      }
    }

    // Tercera pasada: búsqueda recursiva en todos los objetos anidados
    for (var entry in json.entries) {
      if (entry.value is Map<String, dynamic>) {
        final recursiveEmail = _extractEmail(entry.value as Map<String, dynamic>);
        if (recursiveEmail.isNotEmpty) {
          log('📧 EMAIL: Found recursively in "${entry.key}": "$recursiveEmail"');
          return recursiveEmail;
        }
      }
    }

    log('📧 EMAIL: No email found in any structure');
    return '';
  }

  /// Busca email en un nivel específico del JSON
  static String _searchEmailInLevel(Map<String, dynamic> data) {
    // Lista de posibles campos donde puede estar el email
    final emailFields = [
      'email', 'userEmail', 'emailAddress', 'mail', 'correo', 'e_mail',
      'Email', 'UserEmail', 'EmailAddress', 'Mail', 'Correo', 'E_mail',
      'EMAIL', 'USER_EMAIL', 'EMAIL_ADDRESS', 'MAIL', 'CORREO'
    ];

    for (String field in emailFields) {
      if (data.containsKey(field) && data[field] != null) {
        String rawEmail = data[field].toString();
        if (rawEmail.isNotEmpty && rawEmail != 'null') {
          String cleanEmail = _cleanTextValue(rawEmail);
          if (_isValidEmail(cleanEmail)) {
            return cleanEmail;
          }
        }
      }
    }

    return '';
  }

  /// Limpia valores de texto que pueden venir en formato {value: contenido}
  static String _cleanTextValue(String input) {
    if (input.isEmpty || input == 'null') return '';
    
    // Limpiar formato {value: contenido} o {value : contenido}
    if (input.startsWith('{value:') || input.startsWith('{value :')) {
      final match = RegExp(r'\{value\s*:\s*([^}]+)\}').firstMatch(input);
      if (match != null) {
        input = match.group(1)?.trim() ?? input;
      }
    }
    
    // Limpiar comillas y espacios
    return input.replaceAll('"', '').replaceAll("'", '').trim();
  }

  /// Valida si una cadena es un email válido
  static bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    // Regex básico para validar email
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  Map<String, dynamic> toJson() {
    return {
      'idPatient': id,
      'name': name,
      'lastNameFather': lastNameFather,
      'lastNameMother': lastNameMother,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'phone': phone,
      'email': email,
      'professionalId': professionalId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'PatientModel(id: $id, name: "$fullName", email: "$email", gender: "$gender", phone: "$phone", professionalId: $professionalId)';
  }
}