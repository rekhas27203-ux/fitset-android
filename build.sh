#!/bin/bash
set -e
export JAVA_HOME=/scratch/.local/lib/python3.12/site-packages/jdk4py/java-runtime
export PATH=$JAVA_HOME/bin:$PATH
SDK=/scratch/work/tools/sdk; BT=$SDK/build-tools/34.0.0; AJ=$SDK/platforms/android-34/android.jar
cd /scratch/work/app
rm -rf build/compiled build/gen build/classes build/dex build/*.apk
mkdir -p build/compiled build/gen build/classes build/dex
$BT/aapt2 compile --dir res -o build/compiled/res.zip
$BT/aapt2 link -o build/base.apk -I $AJ --manifest AndroidManifest.xml -A assets \
  --java build/gen --min-sdk-version 21 --target-sdk-version 34 build/compiled/res.zip
java -jar /scratch/work/tools/ecj.jar -source 1.8 -target 1.8 -nowarn -proc:none \
  -bootclasspath $AJ -classpath $AJ -d build/classes \
  build/gen/com/rekha/fitset/R.java src/com/rekha/fitset/MainActivity.java
java -Xmx512m -cp $BT/lib/d8.jar com.android.tools.r8.D8 --min-api 21 --lib $AJ --output build/dex \
  $(find build/classes -name "*.class")
python3 - <<'PY'
import zipfile, shutil, os
shutil.copy("/scratch/work/app/build/base.apk","/scratch/work/app/build/unsigned.apk")
z=zipfile.ZipFile("/scratch/work/app/build/unsigned.apk","a",zipfile.ZIP_DEFLATED)
z.write("/scratch/work/app/build/dex/classes.dex","classes.dex"); z.close()
PY
$BT/zipalign -f -p 4 build/unsigned.apk build/aligned.apk
if [ ! -f build/fitset.keystore ]; then
  keytool -genkeypair -keystore build/fitset.keystore -alias fitset -storepass fitset123 -keypass fitset123 \
    -dname "CN=FitSet, O=Rekha, C=IN" -keyalg RSA -keysize 2048 -validity 12000 2>/dev/null
fi
$BT/apksigner sign --ks build/fitset.keystore --ks-pass pass:fitset123 --key-pass pass:fitset123 \
  --v1-signing-enabled true --v2-signing-enabled true --out build/FitSet.apk build/aligned.apk 2>/dev/null
$BT/apksigner verify build/FitSet.apk && echo "SIGNATURE OK"
ls -la build/FitSet.apk
