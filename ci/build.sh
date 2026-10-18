#!/usr/bin/env bash
# Fabrica el APK (para instalar directo) y el AAB (para Google Play) de Control de Gastos y Bancos.
# Necesita el secreto KS_PASS (clave de la llave de firma) configurado en GitHub.
set -euo pipefail
ROOT="$PWD"; APPID="com.controlgastos.ve"; APPNAME="Control de Gastos"
test -n "${KS_PASS:-}" || { echo "::error::Falta el secreto KS_PASS (Settings > Secrets and variables > Actions)"; exit 1; }
openssl enc -d -aes-256-cbc -pbkdf2 -in "$ROOT/firma.jks.enc" -out "$ROOT/firma.jks" -pass pass:"$KS_PASS"
(yes | "${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null 2>&1) || true
rm -rf build && mkdir build && cd build
npm init -y >/dev/null
npm i @capacitor/core@7 @capacitor/cli@7 @capacitor/android@7 @capacitor/filesystem@7 @capacitor/share@7 --no-audit --no-fund
mkdir www && cp "$ROOT/app/index.html" www/index.html
cat > capacitor.config.json <<JSON
{"appId":"$APPID","appName":"$APPNAME","webDir":"www","backgroundColor":"#0b1a33","server":{"androidScheme":"https"}}
JSON
npx cap add android
npx cap sync android
A=android/app/src/main
JAVADIR="$A/java/$(echo $APPID | tr . /)"
sed "s/__PKG__/$APPID/g" "$ROOT/ci/PrintHtmlPlugin.java.tpl" > "$JAVADIR/PrintHtmlPlugin.java"
sed "s/__PKG__/$APPID/g" "$ROOT/ci/MainActivity.java.tpl" > "$JAVADIR/MainActivity.java"
python3 - <<PY
import re
p="$A/AndroidManifest.xml"; s=open(p).read()
s=s.replace('android:allowBackup="true"','android:allowBackup="false"')
s=s.replace('<uses-permission android:name="android.permission.INTERNET" />','<uses-permission android:name="android.permission.INTERNET" />\n    <uses-permission android:name="android.permission.CAMERA" />\n    <uses-feature android:name="android.hardware.camera" android:required="false" />')
assert 'CAMERA' in s; open(p,"w").write(s)
p="android/app/build.gradle"; s=open(p).read()
s=re.sub(r'versionCode \d+','versionCode $((1000 + RUN_NUMBER))',s); s=re.sub(r'versionName "[^"]*"','versionName "2.3.${RUN_NUMBER}"',s)
open(p,"w").write(s)
PY
pip install --quiet pillow
python3 - <<PY
import os,shutil
os.makedirs("$ROOT/_ic/icons",exist_ok=True)
for f in ["icon-512.png","maskable-512.png"]: shutil.copy("$ROOT/icons/"+f,"$ROOT/_ic/icons/"+f)
PY
python3 "$ROOT/ci/make_icons.py" "$A/res" "$ROOT/_ic"
cd android && chmod +x gradlew && ./gradlew assembleRelease bundleRelease --no-daemon --stacktrace
cd "$ROOT/build"
BT=$(ls -d "$ANDROID_HOME"/build-tools/* | sort -V | tail -1)
"$BT/zipalign" -p -f 4 android/app/build/outputs/apk/release/app-release-unsigned.apk aligned.apk
"$BT/apksigner" sign --ks "$ROOT/firma.jks" --ks-pass pass:"$KS_PASS" --key-pass pass:"$KS_PASS" --ks-key-alias gastos --out "$ROOT/Control_de_Gastos.apk" aligned.apk
"$BT/apksigner" verify "$ROOT/Control_de_Gastos.apk" && echo "APK firmado OK"
cp android/app/build/outputs/bundle/release/app-release.aab "$ROOT/Control_de_Gastos_PlayStore.aab"
jarsigner -keystore "$ROOT/firma.jks" -storepass "$KS_PASS" -keypass "$KS_PASS" -sigalg SHA256withRSA -digestalg SHA-256 "$ROOT/Control_de_Gastos_PlayStore.aab" gastos
echo "AAB firmado OK"
rm -f "$ROOT/firma.jks"
