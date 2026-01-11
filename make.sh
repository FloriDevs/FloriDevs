#!/bin/bash

# 1. Frage nach der Java-Datei
read -p "Wie heißt die Java-Datei (z.B. Main.java)? " JAVA_FILE

# Prüfen ob Datei existiert
if [ ! -f "$JAVA_FILE" ]; then
    echo "Fehler: Datei '$JAVA_FILE' wurde nicht gefunden!"
    exit 1
fi

# Basisname extrahieren (z.B. Main aus Main.java)
CLASS_NAME=$(basename "$JAVA_FILE" .java)

# 2. Ordner 'building' erstellen und vorbereiten
echo "Bereite Ordner 'building' vor..."
mkdir -p building
cp "$JAVA_FILE" building/
cd building

# 3. Kompilieren und JAR erstellen
echo "Kompiliere..."
javac "$JAVA_FILE"

if [ $? -ne 0 ]; then
    echo "Kompilierung fehlgeschlagen!"
    exit 1
fi

echo "Erstelle JAR-Datei..."
echo "Main-Class: $CLASS_NAME" > manifest.txt
jar cmf manifest.txt "${CLASS_NAME}.jar" *.class

# 4. Frage nach dem Terminal-Befehl
read -p "Welchen Befehl willst du im Terminal eingeben, um das Programm zu starten? " CMD_NAME

# Vorbereitung für jpackage (JAR muss in einem Unterordner sein)
mkdir -p input_dir
mv "${CLASS_NAME}.jar" input_dir/

# 5. Erstellen des DEB-Pakets
echo "Erstelle .deb Paket..."
jpackage \
  --input input_dir \
  --dest ../output \
  --name "$CMD_NAME" \
  --main-jar "${CLASS_NAME}.jar" \
  --main-class "$CLASS_NAME" \
  --type deb \
  --app-version "1.0" \
  --description "Installiert als $CMD_NAME"

# Aufräumen im building ordner
cd ..
echo "------------------------------------------------"
echo "ERFOLG!"
echo "Das Paket wurde im Ordner 'output' erstellt."
echo "Installiere es mit: sudo apt install ./output/${CMD_NAME}_1.0_amd64.deb"
echo "Danach kannst du einfach '$CMD_NAME' in dein Terminal tippen."
