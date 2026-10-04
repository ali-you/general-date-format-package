/// Legacy internal initialization hook. Locale data is now loaded lazily by
/// GeneralDateFormat, so callers no longer need an explicit initialization step.
@Deprecated('GeneralDateFormat loads its calendar data lazily.')
void loadDateIntlDataIfNotLoaded() {}
