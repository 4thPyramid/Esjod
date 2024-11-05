import 'dart:convert';

import 'package:azkar/src/features/quran/data/models/surahs_model.dart';
import 'package:azkar/src/features/quran/domain/entities/surahs.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/json_reader.dart';

void main() {
  const tSurahsModel = Surahs(count: 114, references: [
    References(
        number: 1,
        name: "سُورَةُ ٱلْفَاتِحَةِ",
        englishName: "Al-Faatiha",
        englishNameTranslation: "The Opening",
        numberOfAyahs: 7,
        revelationType: "Meccan")
  ]);

  const tSurahs = SurahsEntity(count: 114, references: [
    References(
        number: 1,
        name: "سُورَةُ ٱلْفَاتِحَةِ",
        englishName: "Al-Faatiha",
        englishNameTranslation: "The Opening",
        numberOfAyahs: 7,
        revelationType: "Meccan")
  ]);
  group('to entity', () {
    test(
      'should be a subclass of weather entity',
      () async {
        // assert
        final result = tSurahsModel.toEntity();
        expect(result, equals(tSurahs));
      },
    );
  });

  group('from json', () {
    test(
      'should return a valid model from json',
      () async {
        // arrange
        final Map<String, dynamic> jsonMap = json.decode(
          readJson('helpers/dummy/surahs_response.json'),
        );

        // act
        final result = Surahs.fromMap(jsonMap);

        // assert
        expect(result, equals(tSurahsModel));
      },
    );
  });

  group('to json', () {
    test(
      'should return a json map containing proper data',
      () async {
        // act
        final result = tSurahsModel.toMap();

        // assert
        final expectedJsonMap = {
          "count": 114,
          "references": [
            {
              "number": 1,
              "name": "سُورَةُ ٱلْفَاتِحَةِ",
              "englishName": "Al-Faatiha",
              "englishNameTranslation": "The Opening",
              "numberOfAyahs": 7,
              "revelationType": "Meccan"
            },
          ]
        };
        expect(result, equals(expectedJsonMap));
      },
    );
  });
}
