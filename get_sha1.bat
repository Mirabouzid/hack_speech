@echo off
echo ========================================
echo   Obtention du SHA-1 pour Google Sign-In
echo ========================================
echo.

echo Methode 1: Keytool (Recommande)
echo --------------------------------
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android | findstr SHA1

echo.
echo.
echo Methode 2: Gradle
echo -----------------
cd android
call gradlew signingReport
cd ..

echo.
echo ========================================
echo Copier le SHA-1 affiche ci-dessus
echo et l'ajouter dans Google Cloud Console
echo ========================================
pause
