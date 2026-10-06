import 'package:flutter/material.dart';

/// Forwards the public Material localization contract to Flutter translations.
/// Calendar adapters override date operations and the numeric digit policy.
abstract class MaterialLocalizationsProxy extends MaterialLocalizations {
  MaterialLocalizationsProxy(this.translations);

  final MaterialLocalizations translations;

  String localizeDigits(String value);
  @override
  String get openAppDrawerTooltip => translations.openAppDrawerTooltip;

  @override
  String get backButtonTooltip => translations.backButtonTooltip;

  @override
  String get clearButtonTooltip => translations.clearButtonTooltip;

  @override
  String get closeButtonTooltip => translations.closeButtonTooltip;

  @override
  String get deleteButtonTooltip => translations.deleteButtonTooltip;

  @override
  String get moreButtonTooltip => translations.moreButtonTooltip;

  @override
  String get nextMonthTooltip => translations.nextMonthTooltip;

  @override
  String get previousMonthTooltip => translations.previousMonthTooltip;

  @override
  String get firstPageTooltip => translations.firstPageTooltip;

  @override
  String get lastPageTooltip => translations.lastPageTooltip;

  @override
  String get nextPageTooltip => translations.nextPageTooltip;

  @override
  String get previousPageTooltip => translations.previousPageTooltip;

  @override
  String get showMenuTooltip => translations.showMenuTooltip;

  @override
  String aboutListTileTitle(String applicationName) =>
      translations.aboutListTileTitle(applicationName);

  @override
  String get licensesPageTitle => translations.licensesPageTitle;

  @override
  String licensesPackageDetailText(int licenseCount) =>
      localizeDigits(translations.licensesPackageDetailText(licenseCount));

  @override
  String pageRowsInfoTitle(int firstRow, int lastRow, int rowCount,
          bool rowCountIsApproximate) =>
      localizeDigits(translations.pageRowsInfoTitle(
          firstRow, lastRow, rowCount, rowCountIsApproximate));

  @override
  String get rowsPerPageTitle => translations.rowsPerPageTitle;

  @override
  String tabLabel({required int tabIndex, required int tabCount}) =>
      localizeDigits(
          translations.tabLabel(tabIndex: tabIndex, tabCount: tabCount));

  @override
  String selectedRowCountTitle(int selectedRowCount) =>
      localizeDigits(translations.selectedRowCountTitle(selectedRowCount));

  @override
  String get cancelButtonLabel => translations.cancelButtonLabel;

  @override
  String get closeButtonLabel => translations.closeButtonLabel;

  @override
  String get continueButtonLabel => translations.continueButtonLabel;

  @override
  String get copyButtonLabel => translations.copyButtonLabel;

  @override
  String get cutButtonLabel => translations.cutButtonLabel;

  @override
  String get scanTextButtonLabel => translations.scanTextButtonLabel;

  @override
  String get okButtonLabel => translations.okButtonLabel;

  @override
  String get pasteButtonLabel => translations.pasteButtonLabel;

  @override
  String get selectAllButtonLabel => translations.selectAllButtonLabel;

  @override
  String get lookUpButtonLabel => translations.lookUpButtonLabel;

  @override
  String get searchWebButtonLabel => translations.searchWebButtonLabel;

  @override
  String get shareButtonLabel => translations.shareButtonLabel;

  @override
  String get viewLicensesButtonLabel => translations.viewLicensesButtonLabel;

  @override
  String get anteMeridiemAbbreviation => translations.anteMeridiemAbbreviation;

  @override
  String get postMeridiemAbbreviation => translations.postMeridiemAbbreviation;

  @override
  String get timePickerHourModeAnnouncement =>
      translations.timePickerHourModeAnnouncement;

  @override
  String get timePickerMinuteModeAnnouncement =>
      translations.timePickerMinuteModeAnnouncement;

  @override
  String get modalBarrierDismissLabel => translations.modalBarrierDismissLabel;

  @override
  String get menuDismissLabel => translations.menuDismissLabel;

  @override
  String get drawerLabel => translations.drawerLabel;

  @override
  String get popupMenuLabel => translations.popupMenuLabel;

  @override
  String get menuBarMenuLabel => translations.menuBarMenuLabel;

  @override
  String get dialogLabel => translations.dialogLabel;

  @override
  String get alertDialogLabel => translations.alertDialogLabel;

  @override
  String get searchFieldLabel => translations.searchFieldLabel;

  @override
  String get currentDateLabel => translations.currentDateLabel;

  @override
  String get selectedDateLabel => translations.selectedDateLabel;

  @override
  String get scrimLabel => translations.scrimLabel;

  @override
  String get bottomSheetLabel => translations.bottomSheetLabel;

  @override
  String scrimOnTapHint(String modalRouteContentName) =>
      translations.scrimOnTapHint(modalRouteContentName);

  @override
  TimeOfDayFormat timeOfDayFormat({bool alwaysUse24HourFormat = false}) =>
      translations.timeOfDayFormat(
          alwaysUse24HourFormat: alwaysUse24HourFormat);

  @override
  ScriptCategory get scriptCategory => translations.scriptCategory;

  @override
  String formatDecimal(int number) =>
      localizeDigits(translations.formatDecimal(number));

  @override
  String formatHour(TimeOfDay timeOfDay,
          {bool alwaysUse24HourFormat = false}) =>
      localizeDigits(translations.formatHour(timeOfDay,
          alwaysUse24HourFormat: alwaysUse24HourFormat));

  @override
  String formatMinute(TimeOfDay timeOfDay) =>
      localizeDigits(translations.formatMinute(timeOfDay));

  @override
  String formatTimeOfDay(TimeOfDay timeOfDay,
          {bool alwaysUse24HourFormat = false}) =>
      localizeDigits(translations.formatTimeOfDay(timeOfDay,
          alwaysUse24HourFormat: alwaysUse24HourFormat));

  @override
  String formatYear(DateTime date) => translations.formatYear(date);

  @override
  String formatCompactDate(DateTime date) =>
      translations.formatCompactDate(date);

  @override
  String formatShortDate(DateTime date) => translations.formatShortDate(date);

  @override
  String formatMediumDate(DateTime date) => translations.formatMediumDate(date);

  @override
  String formatFullDate(DateTime date) => translations.formatFullDate(date);

  @override
  String formatMonthYear(DateTime date) => translations.formatMonthYear(date);

  @override
  String formatShortMonthDay(DateTime date) =>
      translations.formatShortMonthDay(date);

  @override
  DateTime? parseCompactDate(String? inputString) =>
      translations.parseCompactDate(inputString);

  @override
  List<String> get narrowWeekdays => translations.narrowWeekdays;

  @override
  int get firstDayOfWeekIndex => translations.firstDayOfWeekIndex;

  @override
  String get dateSeparator => translations.dateSeparator;

  @override
  String get dateHelpText => translations.dateHelpText;

  @override
  String get selectYearSemanticsLabel => translations.selectYearSemanticsLabel;

  @override
  String get unspecifiedDate => translations.unspecifiedDate;

  @override
  String get unspecifiedDateRange => translations.unspecifiedDateRange;

  @override
  String get dateInputLabel => translations.dateInputLabel;

  @override
  String get dateRangeStartLabel => translations.dateRangeStartLabel;

  @override
  String get dateRangeEndLabel => translations.dateRangeEndLabel;

  @override
  String dateRangeStartDateSemanticLabel(String formattedDate) =>
      translations.dateRangeStartDateSemanticLabel(formattedDate);

  @override
  String dateRangeEndDateSemanticLabel(String formattedDate) =>
      translations.dateRangeEndDateSemanticLabel(formattedDate);

  @override
  String get invalidDateFormatLabel => translations.invalidDateFormatLabel;

  @override
  String get invalidDateRangeLabel => translations.invalidDateRangeLabel;

  @override
  String get dateOutOfRangeLabel => translations.dateOutOfRangeLabel;

  @override
  String get saveButtonLabel => translations.saveButtonLabel;

  @override
  String get datePickerHelpText => translations.datePickerHelpText;

  @override
  String get dateRangePickerHelpText => translations.dateRangePickerHelpText;

  @override
  String get calendarModeButtonLabel => translations.calendarModeButtonLabel;

  @override
  String get inputDateModeButtonLabel => translations.inputDateModeButtonLabel;

  @override
  String get timePickerDialHelpText => translations.timePickerDialHelpText;

  @override
  String get timePickerInputHelpText => translations.timePickerInputHelpText;

  @override
  String get timePickerHourLabel => translations.timePickerHourLabel;

  @override
  String get timePickerMinuteLabel => translations.timePickerMinuteLabel;

  @override
  String get invalidTimeLabel => translations.invalidTimeLabel;

  @override
  String get dialModeButtonLabel => translations.dialModeButtonLabel;

  @override
  String get inputTimeModeButtonLabel => translations.inputTimeModeButtonLabel;

  @override
  String get signedInLabel => translations.signedInLabel;

  @override
  String get hideAccountsLabel => translations.hideAccountsLabel;

  @override
  String get showAccountsLabel => translations.showAccountsLabel;

  @override
  // ignore: deprecated_member_use
  String get reorderItemToStart => translations.reorderItemToStart;

  @override
  // ignore: deprecated_member_use
  String get reorderItemToEnd => translations.reorderItemToEnd;

  @override
  // ignore: deprecated_member_use
  String get reorderItemUp => translations.reorderItemUp;

  @override
  // ignore: deprecated_member_use
  String get reorderItemDown => translations.reorderItemDown;

  @override
  // ignore: deprecated_member_use
  String get reorderItemLeft => translations.reorderItemLeft;

  @override
  // ignore: deprecated_member_use
  String get reorderItemRight => translations.reorderItemRight;

  @override
  String get expandedIconTapHint => translations.expandedIconTapHint;

  @override
  String get collapsedIconTapHint => translations.collapsedIconTapHint;

  @override
  String get expansionTileExpandedHint =>
      translations.expansionTileExpandedHint;

  @override
  String get expansionTileCollapsedHint =>
      translations.expansionTileCollapsedHint;

  @override
  String get expansionTileExpandedTapHint =>
      translations.expansionTileExpandedTapHint;

  @override
  String get expansionTileCollapsedTapHint =>
      translations.expansionTileCollapsedTapHint;

  @override
  String get expandedHint => translations.expandedHint;

  @override
  String get collapsedHint => translations.collapsedHint;

  @override
  String remainingTextFieldCharacterCount(int remaining) =>
      localizeDigits(translations.remainingTextFieldCharacterCount(remaining));

  @override
  String get refreshIndicatorSemanticLabel =>
      translations.refreshIndicatorSemanticLabel;

  @override
  String get keyboardKeyAlt => translations.keyboardKeyAlt;

  @override
  String get keyboardKeyAltGraph => translations.keyboardKeyAltGraph;

  @override
  String get keyboardKeyBackspace => translations.keyboardKeyBackspace;

  @override
  String get keyboardKeyCapsLock => translations.keyboardKeyCapsLock;

  @override
  String get keyboardKeyChannelDown => translations.keyboardKeyChannelDown;

  @override
  String get keyboardKeyChannelUp => translations.keyboardKeyChannelUp;

  @override
  String get keyboardKeyControl => translations.keyboardKeyControl;

  @override
  String get keyboardKeyDelete => translations.keyboardKeyDelete;

  @override
  String get keyboardKeyEject => translations.keyboardKeyEject;

  @override
  String get keyboardKeyEnd => translations.keyboardKeyEnd;

  @override
  String get keyboardKeyEscape => translations.keyboardKeyEscape;

  @override
  String get keyboardKeyFn => translations.keyboardKeyFn;

  @override
  String get keyboardKeyHome => translations.keyboardKeyHome;

  @override
  String get keyboardKeyInsert => translations.keyboardKeyInsert;

  @override
  String get keyboardKeyMeta => translations.keyboardKeyMeta;

  @override
  String get keyboardKeyMetaMacOs => translations.keyboardKeyMetaMacOs;

  @override
  String get keyboardKeyMetaWindows => translations.keyboardKeyMetaWindows;

  @override
  String get keyboardKeyNumLock => translations.keyboardKeyNumLock;

  @override
  String get keyboardKeyNumpad1 => translations.keyboardKeyNumpad1;

  @override
  String get keyboardKeyNumpad2 => translations.keyboardKeyNumpad2;

  @override
  String get keyboardKeyNumpad3 => translations.keyboardKeyNumpad3;

  @override
  String get keyboardKeyNumpad4 => translations.keyboardKeyNumpad4;

  @override
  String get keyboardKeyNumpad5 => translations.keyboardKeyNumpad5;

  @override
  String get keyboardKeyNumpad6 => translations.keyboardKeyNumpad6;

  @override
  String get keyboardKeyNumpad7 => translations.keyboardKeyNumpad7;

  @override
  String get keyboardKeyNumpad8 => translations.keyboardKeyNumpad8;

  @override
  String get keyboardKeyNumpad9 => translations.keyboardKeyNumpad9;

  @override
  String get keyboardKeyNumpad0 => translations.keyboardKeyNumpad0;

  @override
  String get keyboardKeyNumpadAdd => translations.keyboardKeyNumpadAdd;

  @override
  String get keyboardKeyNumpadComma => translations.keyboardKeyNumpadComma;

  @override
  String get keyboardKeyNumpadDecimal => translations.keyboardKeyNumpadDecimal;

  @override
  String get keyboardKeyNumpadDivide => translations.keyboardKeyNumpadDivide;

  @override
  String get keyboardKeyNumpadEnter => translations.keyboardKeyNumpadEnter;

  @override
  String get keyboardKeyNumpadEqual => translations.keyboardKeyNumpadEqual;

  @override
  String get keyboardKeyNumpadMultiply =>
      translations.keyboardKeyNumpadMultiply;

  @override
  String get keyboardKeyNumpadParenLeft =>
      translations.keyboardKeyNumpadParenLeft;

  @override
  String get keyboardKeyNumpadParenRight =>
      translations.keyboardKeyNumpadParenRight;

  @override
  String get keyboardKeyNumpadSubtract =>
      translations.keyboardKeyNumpadSubtract;

  @override
  String get keyboardKeyPageDown => translations.keyboardKeyPageDown;

  @override
  String get keyboardKeyPageUp => translations.keyboardKeyPageUp;

  @override
  String get keyboardKeyPower => translations.keyboardKeyPower;

  @override
  String get keyboardKeyPowerOff => translations.keyboardKeyPowerOff;

  @override
  String get keyboardKeyPrintScreen => translations.keyboardKeyPrintScreen;

  @override
  String get keyboardKeyScrollLock => translations.keyboardKeyScrollLock;

  @override
  String get keyboardKeySelect => translations.keyboardKeySelect;

  @override
  String get keyboardKeyShift => translations.keyboardKeyShift;

  @override
  String get keyboardKeySpace => translations.keyboardKeySpace;
}
