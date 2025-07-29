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
      
      // Extraer fecha de nacimiento
      DateTime birthDate;
      try {
        if (json.containsKey('birthDate')) {
          birthDate = DateTime.parse(json['birthDate'].toString());
        } else {
          birthDate = DateTime.now().subtract(const Duration(days: 365 * 25)); // Default 25 años
        }
      } catch (e) {
        log('⚠️ PATIENT MODEL: Error parsing birthDate: $e');
        birthDate = DateTime.now().subtract(const Duration(days: 365 * 25));
      }

      // Extraer género
      String gender = json['gender']?.toString() ?? 'No especificado';
      
      // Extraer teléfono
      String phone = json['phone']?.toString() ?? '';
      
      // Extraer email
      String email = json['email']?.toString() ?? '';
      
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

      log('✅ PATIENT MODEL: Successfully parsed patient - ID: $id, Name: "$name"');
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
    return 'PatientModel(id: $id, name: "$fullName", email: "$email", professionalId: $professionalId)';
  }
}