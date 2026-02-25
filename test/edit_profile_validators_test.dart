import 'package:flutter_test/flutter_test.dart';

import '../lib/pages/edit_profile_page.dart'; 

void main() {
  group('Тесты валидаторов профиля (ProfileValidators)', () {
    
    test('Имя не должно быть пустым', () {
      final result1 = ProfileValidators.validateName('');
      final result2 = ProfileValidators.validateName('   ');
      final result3 = ProfileValidators.validateName(null);

      expect(result1, 'empty_name');
      expect(result2, 'empty_name');
      expect(result3, 'empty_name');
    });

    test('Правильное имя проходит проверку', () {
      final result = ProfileValidators.validateName('Alikhan');
      
      expect(result, isNull);
    });

    test('Почта не должна быть пустой', () {
      final result = ProfileValidators.validateEmail('');
      expect(result, 'empty_email');
    });

    test('Неправильный формат почты выдает ошибку', () {
      final missingAt = ProfileValidators.validateEmail('alikhan.gmail.com');
      final missingDomain = ProfileValidators.validateEmail('alikhan@gmail');
      final justWords = ProfileValidators.validateEmail('hello world');

      expect(missingAt, 'invalid_email');
      expect(missingDomain, 'invalid_email');
      expect(justWords, 'invalid_email');
    });

    test('Правильная почта проходит проверку', () {
      final validEmail = ProfileValidators.validateEmail('test.user@example.com');
      
      expect(validEmail, isNull);
    });

  });
}