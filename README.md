# EH_Charmenu

Gemeinsames Charakter-Menue fuer zwei Garry's-Mod-Server.

## Server 1 Metro

- 3 Charakterplaetze
- Name erstellen
- Geschlecht auswaehlen
- Model / Aussehen auswaehlen
- Skin einstellen
- Kleidung ueber Bodygroups veraendern
- Model-Vorschau im Menue
- Charakter wieder auswaehlen

## Server 2 Stadt / DarkRP

- dieselben Charaktere laden
- gespeicherte Kleidung laden
- zusaetzlich Jobdaten
- Rang speichern
- Job-Kleidung setzen
- Job-Ausruestung geben

## Wichtig

Fuer echte Synchronisierung zwischen Server 1 und Server 2 brauchst du MySQL oder MariaDB.
SQLite ist nur fuer Tests auf einem einzelnen Server gedacht.

## Installation

Diesen Ordner auf beide Server hochladen:

```txt
garrysmod/addons/EH_Charmenu/
```

Danach Server neu starten.

## Server-ID einstellen

Datei:

```txt
lua/eh_charmenu/sh_config.lua
```

Auf Server 1 Metro:

```lua
EHChar.Config.ServerID = "metro"
```

Auf Server 2 Stadt / DarkRP:

```lua
EHChar.Config.ServerID = "stadt"
```

## Workshop-Modelpacks

EH_Charmenu kann automatisch alle PlayerModels nutzen, die durch Workshop-Addons registriert werden.

Dafuer ist in der Config aktiv:

```lua
EHChar.Config.UseAllRegisteredPlayerModels = true
```

Damit koennen z.B. diese Addons im Menue erscheinen, wenn sie installiert sind:

- RP Models BIG Pack
- Enhanced PlayerModel Selector
- andere PlayerModel-/Clothing-Packs

Wichtig: Die Addon-Dateien selbst werden nicht in EH_Charmenu kopiert. Die Workshop-Addons muessen weiterhin auf Server und Client vorhanden sein.

## Datenbank

In `sh_config.lua` kannst du MySQL aktivieren:

```lua
EHChar.Config.Database.UseMySQL = true
```

Beide Server muessen dann dieselbe Datenbank verwenden.

## Befehle

Chat:

```txt
/chars
```

Konsole:

```txt
eh_chars
```

## Kleidung bearbeiten

Im Menue gibt es jetzt bei jedem Slot den Button:

```txt
Kleidung / Aussehen bearbeiten
```

Dort kannst du:

- Model / Grundkoerper auswaehlen
- Skin / Variante einstellen
- Bodygroups per Schieberegler veraendern
- eine Model-Vorschau sehen
- die Kleidung speichern

Die Bodygroup-Regler werden automatisch aus dem gewaehlten Model erzeugt.
Wenn ein Model keine Kleidungsteile anzeigt, hat dieses Model keine Bodygroups.

## Hinweis zu Kleidung

Das Menue speichert aktuell:

- Model
- Skin
- Bodygroups

Beide Server muessen dieselben Player-Models und Clothing-Addons haben.
Sonst kann Server 2 die gespeicherte Kleidung nicht richtig laden.

Fuer ein spaeteres Premium-System kann man noch einbauen:

- Kleider-Shop
- Haare / Bart
- Jacken / Hosen / Schuhe als Items
- Admin-Freigabe fuer Fraktionskleidung
- Speichern von Outfits
- Kleidung nur fuer bestimmte Jobs
