import 'package:flutter_test/flutter_test.dart';

import '../lib/pages/history_page.dart'; 

void main() {
  group('Тесты функции formatDate', () {
    
    test('Правильно форматирует дату текущего года (без указания года)', () {
      final currentYear = DateTime.now().year;
      final testDate = DateTime(currentYear, 5, 15); 
      
      final result = formatDate(testDate);
      
      expect(result, 'May 15');
    });

    test('Правильно форматирует дату прошлых лет (с указанием года)', () {
      final testDate = DateTime(2022, 12, 25);
      
      final result = formatDate(testDate);
      
      expect(result, 'Dec 25, 2022');
    });

    test('Правильно работает с однозначными числами дня', () {
      final currentYear = DateTime.now().year;
      final testDate = DateTime(currentYear, 1, 5);
      
      final result = formatDate(testDate);
      
      expect(result, 'Jan 5');
    });


    test('Правильно обрабатывает високосный год (29 февраля прошлого года)', () {
      final testDate = DateTime(2024, 2, 29);
      
      final result = formatDate(testDate);
      
      expect(result, 'Feb 29, 2024');
    });

    test('Правильно форматирует даты будущих лет (с указанием года)', () {
      final futureYear = DateTime.now().year + 5;
      final testDate = DateTime(futureYear, 8, 10);
      
      final result = formatDate(testDate);
      
      expect(result, 'Aug 10, $futureYear');
    });

  });
}