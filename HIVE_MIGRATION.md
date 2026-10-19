# Hive migration

This commit migrates local persistence from SharedPreferences to Hive (appBox). It also includes a migration step: on first run, if SharedPreferences had stored points/tasks/badges, they will be copied into Hive and a flag `migrated_to_hive` will be set in SharedPreferences to avoid repeated migration.

Why Hive?
- More robust local storage
- Easier to extend (objects/lists/maps)
- Faster for larger data

How it works:
- appBox keys used:
  - 'points' -> int
  - 'badges' -> List<String>
  - 'task_<id>_completed' -> bool

If you need to revert the migration, delete the `migrated_to_hive` key from SharedPreferences or clear app data.
