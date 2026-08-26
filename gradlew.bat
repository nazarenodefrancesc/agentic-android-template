@ECHO OFF
SET DIR=%~dp0
IF EXIST "%DIR%gradle\wrapper\gradle-wrapper.jar" (
  java -classpath "%DIR%gradle\wrapper\gradle-wrapper.jar" org.gradle.wrapper.GradleWrapperMain %*
  EXIT /B %ERRORLEVEL%
)
ECHO Gradle wrapper JAR is not present yet.
ECHO Run scripts\bootstrap-gradle.sh on the Linux build server once; the generated wrapper JAR stays local and Git-ignored.
EXIT /B 1
