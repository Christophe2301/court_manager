import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';

class CourtManagerExportService {
  final FirebaseFirestore _firestore;

  CourtManagerExportService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> exportSeason(String seasonId) async {
    final results = await Future.wait([
      _firestore
          .collection('members')
          .where('seasonIds', arrayContains: seasonId)
          .get(const GetOptions(source: Source.server)),
      _firestore
          .collection('groups')
          .where('seasonId', isEqualTo: seasonId)
          .get(const GetOptions(source: Source.server)),
      _firestore
          .collection('enrollments')
          .where('seasonId', isEqualTo: seasonId)
          .get(const GetOptions(source: Source.server)),
    ]);

    final memberDocs = results[0].docs
        .where((doc) => doc.data()['isActive'] != false)
        .toList();
    final groupDocs = results[1].docs
        .where((doc) => doc.data()['isActive'] != false)
        .toList();
    final enrollmentDocs = results[2].docs
        .where((doc) => doc.data()['isActive'] != false)
        .toList();

    memberDocs.sort((a, b) {
      final aData = a.data();
      final bData = b.data();
      final lastNameComparison = _text(
        aData['lastName'],
      ).compareTo(_text(bData['lastName']));
      if (lastNameComparison != 0) {
        return lastNameComparison;
      }
      return _text(aData['firstName']).compareTo(_text(bData['firstName']));
    });

    groupDocs.sort((a, b) {
      final aData = a.data();
      final bData = b.data();
      final dayComparison = _integer(
        aData['dayOfWeek'],
      ).compareTo(_integer(bData['dayOfWeek']));
      if (dayComparison != 0) {
        return dayComparison;
      }
      final timeComparison = _text(
        aData['startTime'],
      ).compareTo(_text(bData['startTime']));
      if (timeComparison != 0) {
        return timeComparison;
      }
      return _text(aData['name']).compareTo(_text(bData['name']));
    });

    final membersById = {for (final doc in memberDocs) doc.id: doc.data()};
    final groupsById = {for (final doc in groupDocs) doc.id: doc.data()};

    enrollmentDocs.sort((a, b) {
      final aData = a.data();
      final bData = b.data();
      final aMember = membersById[_text(aData['memberId'])];
      final bMember = membersById[_text(bData['memberId'])];
      final aGroup = groupsById[_text(aData['groupId'])];
      final bGroup = groupsById[_text(bData['groupId'])];

      final groupComparison = _text(
        aGroup?['name'],
      ).compareTo(_text(bGroup?['name']));
      if (groupComparison != 0) {
        return groupComparison;
      }
      final lastNameComparison = _text(
        aMember?['lastName'],
      ).compareTo(_text(bMember?['lastName']));
      if (lastNameComparison != 0) {
        return lastNameComparison;
      }
      return _text(
        aMember?['firstName'],
      ).compareTo(_text(bMember?['firstName']));
    });

    final workbook = Excel.createExcel();
    workbook.rename('Sheet1', 'Adhérents');

    _buildMembersSheet(workbook['Adhérents'], memberDocs, seasonId);
    _buildGroupsSheet(workbook['Groupes'], groupDocs);
    _buildEnrollmentsSheet(
      workbook['Inscriptions'],
      enrollmentDocs,
      membersById,
      groupsById,
    );

    workbook.setDefaultSheet('Adhérents');

    final encoded = workbook.encode();
    if (encoded == null) {
      throw StateError('La création du fichier Excel a échoué.');
    }

    final today = DateTime.now();
    final date =
        '${today.year.toString().padLeft(4, '0')}'
        '${today.month.toString().padLeft(2, '0')}'
        '${today.day.toString().padLeft(2, '0')}';
    final safeSeason = seasonId.replaceAll(RegExp(r'[^0-9A-Za-z_-]'), '_');
    final fileName = 'CourtManager_${safeSeason}_$date';

    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: Uint8List.fromList(encoded),
      fileExtension: 'xlsx',
      includeExtension: true,
      mimeType: MimeType.microsoftExcel,
    );

    return '$fileName.xlsx';
  }

  void _buildMembersSheet(
    Sheet sheet,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
    String seasonId,
  ) {
    _appendHeader(sheet, const [
      'ID CourtManager',
      'Licence',
      'Nom',
      'Prénom',
      'Date de naissance',
      'E-mail',
      'Téléphone',
      'Actif',
      'Saison',
    ]);

    for (final doc in documents) {
      final data = doc.data();
      sheet.appendRow([
        TextCellValue(doc.id),
        TextCellValue(_text(data['licenseNumber'])),
        TextCellValue(_text(data['lastName'])),
        TextCellValue(_text(data['firstName'])),
        TextCellValue(_date(data['birthDate'])),
        TextCellValue(_text(data['email'])),
        TextCellValue(_text(data['phone'])),
        TextCellValue(_yesNo(data['isActive'])),
        TextCellValue(seasonId),
      ]);
    }

    _setColumnWidths(sheet, const [22, 14, 20, 18, 18, 30, 18, 10, 14]);
  }

  void _buildGroupsSheet(
    Sheet sheet,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    _appendHeader(sheet, const [
      'ID CourtManager',
      'Nom du groupe',
      'Type',
      'Saison',
      'Jour',
      'Numéro du jour',
      'Heure de début',
      'Durée (min)',
      'IDs professeurs',
      'Actif',
    ]);

    for (final doc in documents) {
      final data = doc.data();
      final dayOfWeek = _integer(data['dayOfWeek']);
      final teacherIds = data['teacherIds'] is Iterable
          ? (data['teacherIds'] as Iterable).join(', ')
          : '';
      sheet.appendRow([
        TextCellValue(doc.id),
        TextCellValue(_text(data['name'])),
        TextCellValue(_text(data['type'])),
        TextCellValue(_text(data['seasonId'])),
        TextCellValue(_dayName(dayOfWeek)),
        IntCellValue(dayOfWeek),
        TextCellValue(_text(data['startTime'])),
        IntCellValue(_integer(data['durationMinutes'])),
        TextCellValue(teacherIds),
        TextCellValue(_yesNo(data['isActive'])),
      ]);
    }

    _setColumnWidths(sheet, const [22, 32, 18, 14, 14, 15, 16, 14, 35, 10]);
  }

  void _buildEnrollmentsSheet(
    Sheet sheet,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
    Map<String, Map<String, dynamic>> membersById,
    Map<String, Map<String, dynamic>> groupsById,
  ) {
    _appendHeader(sheet, const [
      'ID inscription',
      'Licence',
      'Nom',
      'Prénom',
      'ID adhérent',
      'Groupe',
      'ID groupe',
      'Saison',
      'Date de début',
      'Date de fin',
      'Actif',
      'Anomalie de référence',
    ]);

    for (final doc in documents) {
      final data = doc.data();
      final memberId = _text(data['memberId']);
      final groupId = _text(data['groupId']);
      final member = membersById[memberId];
      final group = groupsById[groupId];
      final anomalies = <String>[
        if (member == null) 'Adhérent absent de la saison',
        if (group == null) 'Groupe absent ou inactif',
      ];

      sheet.appendRow([
        TextCellValue(doc.id),
        TextCellValue(_text(member?['licenseNumber'])),
        TextCellValue(_text(member?['lastName'])),
        TextCellValue(_text(member?['firstName'])),
        TextCellValue(memberId),
        TextCellValue(_text(group?['name'])),
        TextCellValue(groupId),
        TextCellValue(_text(data['seasonId'])),
        TextCellValue(_date(data['startDate'])),
        TextCellValue(_date(data['endDate'])),
        TextCellValue(_yesNo(data['isActive'])),
        TextCellValue(anomalies.join(' ; ')),
      ]);
    }

    _setColumnWidths(sheet, const [
      22,
      14,
      20,
      18,
      22,
      32,
      22,
      14,
      16,
      16,
      10,
      28,
    ]);
  }

  void _appendHeader(Sheet sheet, List<String> labels) {
    sheet.appendRow(labels.map(TextCellValue.new).toList());

    final style = CellStyle(bold: true, textWrapping: TextWrapping.WrapText);
    for (var column = 0; column < labels.length; column++) {
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: column, rowIndex: 0),
              )
              .cellStyle =
          style;
    }
  }

  void _setColumnWidths(Sheet sheet, List<double> widths) {
    for (var column = 0; column < widths.length; column++) {
      sheet.setColumnWidth(column, widths[column]);
    }
  }

  String _text(Object? value) => value?.toString().trim() ?? '';

  int _integer(Object? value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(_text(value)) ?? 0;
  }

  String _yesNo(Object? value) => value == false ? 'Non' : 'Oui';

  String _date(Object? value) {
    final DateTime? date = switch (value) {
      Timestamp timestamp => timestamp.toDate(),
      DateTime dateTime => dateTime,
      _ => null,
    };
    if (date == null) {
      return '';
    }
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year.toString().padLeft(4, '0')}';
  }

  String _dayName(int dayOfWeek) {
    const names = {
      1: 'Lundi',
      2: 'Mardi',
      3: 'Mercredi',
      4: 'Jeudi',
      5: 'Vendredi',
      6: 'Samedi',
      7: 'Dimanche',
    };
    return names[dayOfWeek] ?? '';
  }
}
