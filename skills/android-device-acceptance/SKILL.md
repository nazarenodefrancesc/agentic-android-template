# Skill: android-device-acceptance

## Purpose

Convert a QA APK into evidence from the human's physical Android device.

## Procedure

1. Identify the exact APK by build number and Git SHA.
2. Give the human only the minimal acceptance scenario(s) that automation cannot prove.
3. Record PASS/FAIL and device notes in the task evidence report.
4. On FAIL, keep/reopen the task as `IN_PROGRESS` and capture reproduction steps.
5. On PASS, permit `COMPLETE` only if all other task gates are also green.
