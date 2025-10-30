import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Common
      'home': 'Home',
      'history': 'History',
      'profile': 'Profile',
      'language': 'Language',
      'sign_in': 'Sign in',
      'sign_out': 'Sign out',

      // History page
      'noTranscriptionsYet': 'No transcriptions yet',
      'dropLinkToStart': 'Drop a link to start',
      'signInToBackup': 'Sign in to back up your data',
      'goToHome': 'Go to Home',
      'transcriptLibrary': 'Transcript Library',
      'clip': 'clip',
      'clips': 'clips',
      'swipeToDelete': 'Swipe to delete',
      'keepYourTranscripts': 'Keep your transcripts safe',
      'keepYourTranscriptsDesc': 'Sign in to sync and back up your transcription history.',

      // Profile Page
      'youtext_user': 'YouText user',
      'guest_profile': 'Guest profile',
      'edit_profile': 'Edit Profile',
      'connecting': 'Connecting...',
      'continue_google': 'Continue with Google',
      'sign_in_email': 'Sign in with email',
      'create_account': 'Create a new account',
      'saved_transcripts': 'Saved transcripts',
      'history_info': 'History is stored locally until you sign in.',
      'clear_history': 'Clear history',

      // Edit Profile Page
      'display_name': 'Display Name',
      'enter_display_name': 'Please enter a display name',
      'email': 'Email',
      'enter_email': 'Please enter an email',
      'invalid_email': 'Enter a valid email',
      'save_changes': 'Save Changes',
      'email_managed_social': 'Email is managed by your social login provider',
      'profile_updated': 'Profile updated successfully',
      'profile_update_error': 'Error updating profile',

      // Home Page
      'home_title': 'YouText AI',
      'enter_url': 'Enter YouTube video URL...',
      'include_in_result': 'Include in result:',
      'text': 'Text',
      'summary': 'Summary',
      'title': 'Title',
      'start': 'Start',
      'error_invalid_url': 'Please enter a valid YouTube URL.',
      'processing': 'Processing...',
      'result': 'Result',
      'copy': 'Copy',
      'copied': 'Copied!',
      'nothing_here': 'Nothing here yet. Paste a YouTube link to begin!',
      'guest_mode': 'Guest mode',
      'guest_mode_description': 'Transcribe without signing in. Create an account later to back up projects and sync them.',

      // ResultScreen
      'no_transcript_available': 'Transcript is not available for this run.',
      'transcript_copied': 'Transcript copied to clipboard.',
      'no_highlights_available': 'Highlights are not available for this run.',
      'highlights_copied': 'Highlights copied to clipboard.',
      'no_summary_available': 'Summary is not available for this run.',
      'summary_copied': 'Summary copied to clipboard.',
      'line_copied': 'Line copied to clipboard.',
      'quick_edit_transcript': 'Quick edit transcript',
      'edit_here': 'Edit here...',
      'done': 'Done',
      'source_video': 'Source video',
      'no_transcript': 'Transcript not generated',
      'no_outline': 'Highlights not generated',
      'no_summary': 'Summary not generated',
      'enable_transcript_message': 'Enable transcript generation and run again.',
      'enable_summary_message': 'Turn on summary generation to get a short recap.',
      'copy_transcript': 'Copy transcript',
      'copy_highlights': 'Copy highlights',
      'copy_summary': 'Copy summary',
      'transcript': 'Transcript',
      'highlights': 'Highlights',
      // 'summary': 'Summary',
    },

    'ru': {
      // Общие
      'home': 'Главная',
      'history': 'История',
      'profile': 'Профиль',
      'language': 'Язык',
      'sign_in': 'Войти',
      'sign_out': 'Выйти',

      // История
      'noTranscriptionsYet': 'Пока нет транскрипций',
      'dropLinkToStart': 'Вставьте ссылку на YouTube с вкладки "Главная", чтобы начать создавать библиотеку.',
      'signInToBackup': 'Войдите в систему, чтобы сохранять транскрипции между сессиями.',
      'goToHome': 'Перейти на главную',
      'transcriptLibrary': 'Ваша библиотека транскрипций',
      'clip': 'фрагмент',
      'clips': 'фрагменты',
      'swipeToDelete': 'Смахните влево, чтобы удалить',
      'keepYourTranscripts': 'Сохраняйте свои транскрипции',
      'keepYourTranscriptsDesc': 'Сейчас всё хранится только на этом устройстве. Войдите, чтобы синхронизировать проекты с аккаунтом.',

      // Профиль
      'youtext_user': 'Пользователь YouText',
      'guest_profile': 'Гостевой профиль',
      'edit_profile': 'Редактировать профиль',
      'connecting': 'Подключение...',
      'continue_google': 'Продолжить с Google',
      'sign_in_email': 'Войти по email',
      'create_account': 'Создать новый аккаунт',
      'saved_transcripts': 'Сохранённые записи',
      'history_info': 'История хранится локально, пока вы не войдёте в систему.',
      'clear_history': 'Очистить историю',

      // Страница редактирования профиля
      'display_name': 'Имя пользователя',
      'enter_display_name': 'Введите имя пользователя',
      'email': 'Электронная почта',
      'enter_email': 'Введите адрес электронной почты',
      'invalid_email': 'Введите корректный адрес',
      'save_changes': 'Сохранить изменения',
      'email_managed_social': 'Email управляется вашим социальным аккаунтом',
      'profile_updated': 'Профиль успешно обновлён',
      'profile_update_error': 'Ошибка при обновлении профиля',

      // Главная
      'home_title': 'YouText AI',
      'enter_url': 'Введите ссылку на видео YouTube...',
      'include_in_result': 'Включить в результат:',
      'text': 'Текст',
      'summary': 'Краткое содержание',
      'title': 'Заголовок',
      'start': 'Начать',
      'error_invalid_url': 'Введите корректную ссылку на YouTube.',
      'processing': 'Обработка...',
      'result': 'Результат',
      'copy': 'Копировать',
      'copied': 'Скопировано!',
      'nothing_here': 'Здесь пока пусто. Вставьте ссылку на YouTube, чтобы начать!',
      'guest_mode': 'Гостевой режим',
      'guest_mode_description': 'Транскрибируйте без входа в аккаунт. Создайте его позже, чтобы сохранять и синхронизировать проекты.',

      // ResultScreen
      'no_transcript_available': 'Транскрипт недоступен для этого видео.',
      'transcript_copied': 'Транскрипт скопирован в буфер.',
      'no_highlights_available': 'Основные моменты недоступны.',
      'highlights_copied': 'Основные моменты скопированы.',
      'no_summary_available': 'Краткое содержание недоступно.',
      'summary_copied': 'Краткое содержание скопировано.',
      'line_copied': 'Строка скопирована.',
      'quick_edit_transcript': 'Быстрое редактирование транскрипта',
      'edit_here': 'Редактируйте здесь...',
      'done': 'Готово',
      'source_video': 'Исходное видео',
      'no_transcript': 'Транскрипт не создан',
      'no_outline': 'Основные моменты не созданы',
      'no_summary': 'Краткое содержание не создано',
      'enable_transcript_message': 'Включите генерацию транскрипта и повторите попытку.',
      'enable_summary_message': 'Включите генерацию краткого содержания, чтобы получить сводку.',
      'copy_transcript': 'Копировать транскрипт',
      'copy_highlights': 'Копировать основные моменты',
      'copy_summary': 'Копировать краткое содержание',
      'transcript': 'Транскрипт',
      'highlights': 'Основные моменты',
      // 'summary': 'Краткое содержание',
    },
  };

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  // === Геттеры для удобного доступа ===
  String get noTranscriptionsYet => t('noTranscriptionsYet');
  String get dropLinkToStart => t('dropLinkToStart');
  String get signInToBackup => t('signInToBackup');
  String get goToHome => t('goToHome');
  String get transcriptLibrary => t('transcriptLibrary');
  String get clip => t('clip');
  String get clips => t('clips');
  String get swipeToDelete => t('swipeToDelete');
  String get keepYourTranscripts => t('keepYourTranscripts');
  String get keepYourTranscriptsDesc => t('keepYourTranscriptsDesc');

  static AppLocalizations of(BuildContext context) {
    final loc = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return loc ?? AppLocalizations(const Locale('en'));
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ru'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}