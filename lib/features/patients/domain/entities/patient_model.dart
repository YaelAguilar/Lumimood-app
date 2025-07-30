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
      String gender = json['gender']?.toString() ?? 'No especificado';
      if (gender.startsWith('{value:') || gender.startsWith('{value :')) {
        // Extraer el valor entre {value: y }
        final match = RegExp(r'\{value\s*:\s*([^}]+)\}').firstMatch(gender);
        if (match != null) {
          gender = match.group(1)?.trim() ?? gender;
        }
      }
      log('📋 PATIENT MODEL: Cleaned gender: $gender');
      
      // Extraer teléfono
      String phone = json['phone']?.toString() ?? '';
      
      // EXTRACCIÓN MEJORADA DEL EMAIL - más exhaustiva
      String email = '';
      
      // Lista de posibles campos donde puede estar el email
      List<String> emailFields = [
        'email', 'userEmail', 'emailAddress', 'mail', 'correo',
        'Email', 'UserEmail', 'EmailAddress', 'Mail', 'Correo'
      ];
      
      for (String field in emailFields) {
        if (json.containsKey(field) && json[field] != null) {
          email = json[field].toString();
          if (email.isNotEmpty && email != 'null') {
            log('📋 PATIENT MODEL: Found email in field "$field": $email');
            break;
          }
        }
      }
      
      // Si no encontramos email en los campos obvios, buscar en objetos anidados
      if (email.isEmpty) {
        // Buscar en posibles objetos anidados como 'user', 'credentials', etc.
        if (json.containsKey('user') && json['user'] is Map<String, dynamic>) {
          final userObj = json['user'] as Map<String, dynamic>;
          for (String field in emailFields) {
            if (userObj.containsKey(field) && userObj[field] != null) {
              email = userObj[field].toString();
              if (email.isNotEmpty && email != 'null') {
                log('📋 PATIENT MODEL: Found email in user.$field: $email');
                break;
              }
            }
          }
        }
        
        if (email.isEmpty && json.containsKey('credentials') && json['credentials'] is Map<String, dynamic>) {
          final credentialsObj = json['credentials'] as Map<String, dynamic>;
          for (String field in emailFields) {
            if (credentialsObj.containsKey(field) && credentialsObj[field] != null) {
              email = credentialsObj[field].toString();
              if (email.isNotEmpty && email != 'null') {
                log('📋 PATIENT MODEL: Found email in credentials.$field: $email');
                break;
              }
            }
          }
        }
      }
      
      // Limpiar formato {value: email} si existe
      if (email.startsWith('{value:') || email.startsWith('{value :')) {
        final match = RegExp(r'\{value\s*:\s*([^}]+)\}').firstMatch(email);
        if (match != null) {
          email = match.group(1)?.trim() ?? email;
        }
      }
      
      // Limpiar comillas si existen
      email = email.replaceAll('"', '').replaceAll("'", '').trim();
      
      // Si aún no tenemos email, intentar construir uno basado en el nombre
      if (email.isEmpty || email == 'null') {
        log('⚠️ PATIENT MODEL: No email found, will show placeholder');
        // No construir un email falso, mejor dejarlo vacío para manejar en la UI
      }
      
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