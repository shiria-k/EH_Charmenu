# EH_Charmenu

Gemeinsames Charakter-Menue fuer zwei Garry's-Mod-Server.

## Server 1 Metro

- 3 Charakterplaetze
- Name erstellen
- Geschlecht auswaehlen
- Model / Aussehen auswaehlen
- Skin einstellen
- Bodygroups speichern
- Charakter wieder auswaehlen

## Server 2 Stadt / DarkRP

- dieselben Charaktere laden
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

## Hinweis zu Kleidung

Diese Basis speichert Model, Skin und Bodygroups.
Ein richtiges Kleidungssystem mit Shop, Vorschau, Haaren, Bart, Jacken, Hosen und Items muss spaeter als Erweiterung eingebaut werden.
Beide Server muessen dieselben Model- und Kleidungs-Addons haben, sonst laden Charaktere falsch.
