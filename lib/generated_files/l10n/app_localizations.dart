import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Islamic Todo'**
  String get appName;

  /// The tagline of the application
  ///
  /// In en, this message translates to:
  /// **'Harmonize your spiritual and daily life'**
  String get appTagline;

  /// Home navigation tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Calendar navigation tab
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// Progress navigation tab
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// Challenges/Adhkar navigation tab
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get navChallenges;

  /// Settings navigation tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Fajr prayer name
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// Sunrise time name
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// Dhuhr prayer name
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// Asr prayer name
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// Maghrib prayer name
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// Isha prayer name
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// Tahajjud prayer name
  ///
  /// In en, this message translates to:
  /// **'Tahajjud'**
  String get tahajjud;

  /// Doha prayer name
  ///
  /// In en, this message translates to:
  /// **'Doha'**
  String get doha;

  /// Ishraq prayer name
  ///
  /// In en, this message translates to:
  /// **'Ishraq'**
  String get ishraq;

  /// Awwabin prayer name
  ///
  /// In en, this message translates to:
  /// **'Awwabin'**
  String get awwabin;

  /// Witr prayer name
  ///
  /// In en, this message translates to:
  /// **'Witr'**
  String get witr;

  /// Tahiyyat al-Masjid prayer name
  ///
  /// In en, this message translates to:
  /// **'Tahiyyat al-Masjid'**
  String get tahiyyatMasjid;

  /// Next prayer label on home screen
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get nextPrayer;

  /// Today's prayers section label
  ///
  /// In en, this message translates to:
  /// **'Today\'s Prayers'**
  String get todaysPrayers;

  /// Today's tasks section label
  ///
  /// In en, this message translates to:
  /// **'Today\'s Tasks'**
  String get todaysTasks;

  /// Add task button label
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// Daily quote section label
  ///
  /// In en, this message translates to:
  /// **'Daily Inspiration'**
  String get dailyQuote;

  /// Task title field label
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// Task description field label
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get taskDescription;

  /// Task deadline field label
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get taskDeadline;

  /// Task priority field label
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get taskPriority;

  /// Task category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get taskCategory;

  /// Save task button label
  ///
  /// In en, this message translates to:
  /// **'Save Task'**
  String get saveTask;

  /// Delete task dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTask;

  /// Edit task action
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// Empty tasks state message
  ///
  /// In en, this message translates to:
  /// **'No tasks for today'**
  String get noTasks;

  /// Success message when all tasks are done
  ///
  /// In en, this message translates to:
  /// **'All tasks completed! 🎉'**
  String get allTasksCompleted;

  /// High priority level
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// Medium priority level
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// Low priority level
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// Work task category
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get categoryWork;

  /// Personal task category
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get categoryPersonal;

  /// Family task category
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get categoryFamily;

  /// Health task category
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// Learning task category
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get categoryLearning;

  /// Other task category
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// Daily calendar view
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get dailyView;

  /// Weekly calendar view
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weeklyView;

  /// Monthly calendar view
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyView;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Progress screen title
  ///
  /// In en, this message translates to:
  /// **'Progress & Statistics'**
  String get progressTitle;

  /// Current streak counter
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// Prayers completed stat
  ///
  /// In en, this message translates to:
  /// **'Prayers Completed'**
  String get prayersCompleted;

  /// Tasks completed stat
  ///
  /// In en, this message translates to:
  /// **'Tasks Completed'**
  String get tasksCompleted;

  /// This week period label
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// This month period label
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// Achievements section label
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Prayer settings section
  ///
  /// In en, this message translates to:
  /// **'Prayer Settings'**
  String get prayerSettings;

  /// Notification settings section
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Location settings section
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationSettings;

  /// Prayer time calculation method setting
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get calculationMethod;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// About section header
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Enable notifications setting
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// Prayer reminder notification type
  ///
  /// In en, this message translates to:
  /// **'Prayer Reminder'**
  String get prayerReminder;

  /// Task reminder notification type
  ///
  /// In en, this message translates to:
  /// **'Task Reminder'**
  String get taskReminder;

  /// Reminder time setting label
  ///
  /// In en, this message translates to:
  /// **'Remind me before'**
  String get reminderTime;

  /// Minutes time unit label
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Done button label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Confirm button label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// OK button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Time preposition
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get inTime;

  /// Hours unit
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// Minutes short form
  ///
  /// In en, this message translates to:
  /// **'mins'**
  String get mins;

  /// Days time unit label
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No data empty state message
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Task added success message
  ///
  /// In en, this message translates to:
  /// **'Task added successfully'**
  String get taskAdded;

  /// Task updated success message
  ///
  /// In en, this message translates to:
  /// **'Task updated successfully'**
  String get taskUpdated;

  /// Task deleted success message
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get taskDeleted;

  /// Prayer completion success message
  ///
  /// In en, this message translates to:
  /// **'Prayer marked as completed'**
  String get prayerMarked;

  /// Settings save success message
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// Skip action for tasks
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Archive action for tasks
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// Delete task confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Task?'**
  String get deleteTaskConfirm;

  /// Delete task confirmation message
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTaskMessage;

  /// Validation error when task title is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a task title'**
  String get taskTitleEmpty;

  /// Hint text for task title input
  ///
  /// In en, this message translates to:
  /// **'e.g., Read Surah Al-Kahf'**
  String get taskTitleHint;

  /// Hint text for task description input
  ///
  /// In en, this message translates to:
  /// **'What do you need to do?'**
  String get taskDescriptionHint;

  /// Hint text for adding task details
  ///
  /// In en, this message translates to:
  /// **'Add details...'**
  String get addDetailsHint;

  /// Prayer timeline header
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule'**
  String get todaysSchedule;

  /// Next button label
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Now indicator in timeline
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get now;

  /// Night prayer in English
  ///
  /// In en, this message translates to:
  /// **'Qiyam al-Layl'**
  String get qiyamAlLayl;

  /// Available status
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Tasks status
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// Qiyam status
  ///
  /// In en, this message translates to:
  /// **'Qiyam'**
  String get qiyam;

  /// Sleep time indicator
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// Free time indicator
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// Prayer preparation time suffix
  ///
  /// In en, this message translates to:
  /// **'min prep'**
  String get prepTime;

  /// Free time suffix
  ///
  /// In en, this message translates to:
  /// **'min free'**
  String get freeTime;

  /// Section header for recommended actions
  ///
  /// In en, this message translates to:
  /// **'Recommended Actions'**
  String get recommendedActions;

  /// Qiyam al-Layl hadith quote
  ///
  /// In en, this message translates to:
  /// **'Our Lord descends every night to the lowest heaven when the last third remains.'**
  String get qiyamQuote;

  /// English translation of Qiyam hadith
  ///
  /// In en, this message translates to:
  /// **'Our Lord descends every night to the lowest heaven when the last third remains.'**
  String get qiyamQuoteTranslation;

  /// Source of Qiyam hadith
  ///
  /// In en, this message translates to:
  /// **'— Sahih al-Bukhari & Muslim'**
  String get qiyamQuoteSource;

  /// Recommended surahs for recitation during Qiyam
  ///
  /// In en, this message translates to:
  /// **'Recite: Al-Mulk, As-Sajdah, Al-Muzammil, or your memorized surahs'**
  String get qiyamRecitation;

  /// Edit task menu item
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get taskMenuEdit;

  /// Delete task menu item
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get taskMenuDelete;

  /// Task completed state
  ///
  /// In en, this message translates to:
  /// **'✓ Done'**
  String get taskStateDone;

  /// Task skipped state
  ///
  /// In en, this message translates to:
  /// **'⊘ Skipped'**
  String get taskStateSkipped;

  /// Task archived state
  ///
  /// In en, this message translates to:
  /// **'📦 Archived'**
  String get taskStateArchived;

  /// Task overdue state
  ///
  /// In en, this message translates to:
  /// **'⚠ Overdue'**
  String get taskStateOverdue;

  /// Prayer preparation settings section
  ///
  /// In en, this message translates to:
  /// **'Prayer Preparation'**
  String get prayerPreparation;

  /// Description for prayer preparation settings
  ///
  /// In en, this message translates to:
  /// **'Set your preparation time for each prayer (includes wudu, travel to mosque if needed, etc.)'**
  String get prayerPrepDescription;

  /// Sleep and Qiyam al-Layl settings section
  ///
  /// In en, this message translates to:
  /// **'Sleep & Qiyam al-Layl'**
  String get sleepQiyamAlLayl;

  /// Toggle to enable Qiyam al-Layl time calculation
  ///
  /// In en, this message translates to:
  /// **'Enable night prayer time calculation'**
  String get enableNightPrayerCalculation;

  /// Start time for Qiyam al-Layl
  ///
  /// In en, this message translates to:
  /// **'Qiyam Start Time'**
  String get qiyamStartTime;

  /// Target sleep time
  ///
  /// In en, this message translates to:
  /// **'Sleep Time'**
  String get sleepTime;

  /// Islamic school of thought
  ///
  /// In en, this message translates to:
  /// **'Madhab'**
  String get madhab;

  /// First madhab option
  ///
  /// In en, this message translates to:
  /// **'Shafi\'i, Maliki, Hanbali'**
  String get madhab0;

  /// Description for Madhab 0 (Standard Asr)
  ///
  /// In en, this message translates to:
  /// **'Standard Asr time (shadow equals object)'**
  String get madhab0Description;

  /// Second madhab option
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get madhab1;

  /// Description for Madhab 1 (Later Asr)
  ///
  /// In en, this message translates to:
  /// **'Later Asr time (shadow equals twice object)'**
  String get madhab1Description;

  /// Location settings title
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationTitle;

  /// Use current location button
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// Search city input hint text
  ///
  /// In en, this message translates to:
  /// **'Search city...'**
  String get searchCity;

  /// Popular cities section header
  ///
  /// In en, this message translates to:
  /// **'Popular Cities'**
  String get popularCities;

  /// Morning Adhkar time setting
  ///
  /// In en, this message translates to:
  /// **'Morning Adhkar Time'**
  String get morningAdhkarTime;

  /// Evening Adhkar time setting
  ///
  /// In en, this message translates to:
  /// **'Evening Adhkar Time'**
  String get eveningAdhkarTime;

  /// Reminder time configuration title
  ///
  /// In en, this message translates to:
  /// **'Reminder Time Before Prayer'**
  String get reminderTimeBeforePrayer;

  /// Week starting day setting
  ///
  /// In en, this message translates to:
  /// **'Week Starts On'**
  String get weekStartsOn;

  /// Monday day name
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// Sunday day name
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// Saturday day name
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// Backup data dialog title
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// Description for backup data option
  ///
  /// In en, this message translates to:
  /// **'Export your data to a file'**
  String get backupDataDescription;

  /// Backup data dialog title
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupDataTitle;

  /// Backup data dialog message
  ///
  /// In en, this message translates to:
  /// **'This will export your data to a JSON file that you can share or save.'**
  String get backupDataMessage;

  /// Data to backup label
  ///
  /// In en, this message translates to:
  /// **'Data to backup:'**
  String get dataToBackup;

  /// Export and share button label
  ///
  /// In en, this message translates to:
  /// **'Export & Share'**
  String get exportShare;

  /// Restore data dialog title
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// Description for restore data option
  ///
  /// In en, this message translates to:
  /// **'Import data from a backup file'**
  String get restoreDataDescription;

  /// Restore data dialog title
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreDataTitle;

  /// Restore data dialog message
  ///
  /// In en, this message translates to:
  /// **'Select a backup file to restore. This will add the backup data to your current data (existing data will not be deleted).'**
  String get restoreDataMessage;

  /// Select file button label
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// Clear all data dialog title
  ///
  /// In en, this message translates to:
  /// **'Clear All Data?'**
  String get clearAllData;

  /// Clear all data confirmation title
  ///
  /// In en, this message translates to:
  /// **'Clear All Data?'**
  String get clearAllDataConfirm;

  /// Clear all data warning message
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your prayers, tasks, and settings. This action cannot be undone.'**
  String get clearAllDataMessage;

  /// Success message after clearing data
  ///
  /// In en, this message translates to:
  /// **'All data cleared'**
  String get dataCleared;

  /// Application version number
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get versionNumber;

  /// Qibla direction setting
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaDirection;

  /// Prayer time calculation method title
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get calculationMethodTitle;

  /// Daily Adhkar section title
  ///
  /// In en, this message translates to:
  /// **'Daily Adhkar'**
  String get dailyAdhkar;

  /// Tasbih category
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get tasbih;

  /// Adhkar category
  ///
  /// In en, this message translates to:
  /// **'Adhkar'**
  String get adhkar;

  /// Quran category
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quran;

  /// Today's progress indicator
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress'**
  String get todaysProgress;

  /// Set target button for challenges
  ///
  /// In en, this message translates to:
  /// **'Set Target'**
  String get setTarget;

  /// Daily Tasbih section
  ///
  /// In en, this message translates to:
  /// **'Daily Tasbih'**
  String get dailyTasbih;

  /// Read Quran task example
  ///
  /// In en, this message translates to:
  /// **'Read Quran'**
  String get readQuran;

  /// Update task button label
  ///
  /// In en, this message translates to:
  /// **'Update Task'**
  String get updateTask;

  /// Empty state message for calendar day
  ///
  /// In en, this message translates to:
  /// **'No events for this day'**
  String get noEventsForThisDay;

  /// Day completion badge
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get dayDone;

  /// Eid Arabic label
  ///
  /// In en, this message translates to:
  /// **'عيد'**
  String get eid;

  /// Guidance text for event details
  ///
  /// In en, this message translates to:
  /// **'Tap for details & guidance'**
  String get tapForDetails;

  /// What to do action section
  ///
  /// In en, this message translates to:
  /// **'What to Do'**
  String get whatToDo;

  /// Guidance attribution text
  ///
  /// In en, this message translates to:
  /// **'Guidance according to'**
  String get guidanceAccording;

  /// Fasting prohibition warning
  ///
  /// In en, this message translates to:
  /// **'Fasting is prohibited on this day'**
  String get fastingProhibited;

  /// Sunnah prayer type label
  ///
  /// In en, this message translates to:
  /// **'Sunnah Prayer'**
  String get sunnahPrayer;

  /// Task type label
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task;

  /// Productivity meter label
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get productivity;

  /// Prayer streak mini card label
  ///
  /// In en, this message translates to:
  /// **'Prayer streak'**
  String get prayerStreak;

  /// Task streak mini card label
  ///
  /// In en, this message translates to:
  /// **'Task streak'**
  String get taskStreak;

  /// Weekly insights card header
  ///
  /// In en, this message translates to:
  /// **'Weekly Insights'**
  String get weeklyInsights;

  /// Task completion rate label
  ///
  /// In en, this message translates to:
  /// **'Task rate'**
  String get taskRate;

  /// Prayer completion rate label
  ///
  /// In en, this message translates to:
  /// **'Prayer rate'**
  String get prayerRate;

  /// Best prayer time slot label
  ///
  /// In en, this message translates to:
  /// **'Best slot'**
  String get bestSlot;

  /// Best day of week label
  ///
  /// In en, this message translates to:
  /// **'Best day'**
  String get bestDay;

  /// Preposition for task count display
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get tasksOf;

  /// Preposition for prayer count display
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get prayersOf;

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'First Light'**
  String get firstLight;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'Pray 5 prayers in a day'**
  String get firstLightDesc;

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'On Fire'**
  String get onFire;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'7-day prayer streak'**
  String get onFireDesc;

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get star;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'30-day prayer streak'**
  String get starDesc;

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'Taskmaster'**
  String get taskmaster;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'Complete 10 tasks'**
  String get taskmasterDesc;

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'Devoted'**
  String get devoted;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'Enable 3 nafila prayers'**
  String get devotedDesc;

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'Night Owl'**
  String get nightOwl;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'7-day task streak'**
  String get nightOwlDesc;

  /// Nafila prayers screen title
  ///
  /// In en, this message translates to:
  /// **'Nafila Prayers'**
  String get nafilaPrayers;

  /// Empty state message for daily adhkar
  ///
  /// In en, this message translates to:
  /// **'No daily Adhkar available.'**
  String get noDailyAdhkarAvailable;

  /// Daily adhkar section header in progress
  ///
  /// In en, this message translates to:
  /// **'Daily Adkar'**
  String get dailyAdhkarSection;

  /// Day timeline screen title
  ///
  /// In en, this message translates to:
  /// **'Day Timeline'**
  String get dayTimeline;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Preferences settings section
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Data settings section
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// Prayer subsection header
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get prayer;

  /// Morning adhkar toggle label
  ///
  /// In en, this message translates to:
  /// **'Morning Adhkar'**
  String get morningAdhkar;

  /// Evening adhkar toggle label
  ///
  /// In en, this message translates to:
  /// **'Evening Adhkar'**
  String get eveningAdhkar;

  /// After prayer adhkar toggle label
  ///
  /// In en, this message translates to:
  /// **'After Prayer Adhkar'**
  String get afterPrayerAdhkar;

  /// Sleep adhkar toggle label
  ///
  /// In en, this message translates to:
  /// **'Sleep Adhkar'**
  String get sleepAdhkar;

  /// Nafila prayer reminders toggle
  ///
  /// In en, this message translates to:
  /// **'Nafila Reminders'**
  String get nafilaReminders;

  /// Task reminders toggle label
  ///
  /// In en, this message translates to:
  /// **'Task Reminders'**
  String get taskReminders;

  /// 24-hour time format toggle
  ///
  /// In en, this message translates to:
  /// **'24-Hour Format'**
  String get twentyFourHourFormat;

  /// Show completed tasks toggle
  ///
  /// In en, this message translates to:
  /// **'Show Completed Tasks'**
  String get showCompletedTasks;

  /// Minutes label for reminder time display
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get reminded;

  /// Reminder time before prayer label
  ///
  /// In en, this message translates to:
  /// **'min before prayer'**
  String get minBeforePrayer;

  /// Skip button for onboarding
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// Maybe later button for onboarding
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybeLater;

  /// Back button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Get started button for onboarding
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Clear button label
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// First madhab description
  ///
  /// In en, this message translates to:
  /// **'Standard Asr time (shadow equals object)'**
  String get madhab0Desc;

  /// Second madhab description
  ///
  /// In en, this message translates to:
  /// **'Later Asr time (shadow equals twice object)'**
  String get madhab1Desc;

  /// Clear data confirmation message
  ///
  /// In en, this message translates to:
  /// **'This will delete all your tasks, prayers, and settings. This cannot be undone.'**
  String get clearDataMessage;

  /// Data cleared success message
  ///
  /// In en, this message translates to:
  /// **'All data cleared'**
  String get allDataCleared;

  /// Backup description
  ///
  /// In en, this message translates to:
  /// **'This will export your data to a JSON file that you can share or save.'**
  String get backupDescription;

  /// Backup failed error message
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get backupFailed;

  /// Restore failed error message
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get restoreFailed;

  /// Error reading file message
  ///
  /// In en, this message translates to:
  /// **'Error reading file'**
  String get errorReadingFile;

  /// Location detection error message
  ///
  /// In en, this message translates to:
  /// **'Could not detect location'**
  String get couldNotDetectLocation;

  /// Recommended label for suggestions
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// Qiyam hadith source
  ///
  /// In en, this message translates to:
  /// **'— Sahih al-Bukhari & Muslim'**
  String get qiyamSource;

  /// Completed indicator symbol
  ///
  /// In en, this message translates to:
  /// **'✓'**
  String get completed;

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Bookmark saved success message
  ///
  /// In en, this message translates to:
  /// **'Bookmark saved'**
  String get bookmarkSaved;

  /// Done reading button label
  ///
  /// In en, this message translates to:
  /// **'Done Reading'**
  String get doneReading;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Arabic language option (in Arabic)
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// Arabic language option (in English)
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabicEnglish;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
