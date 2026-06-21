# EH_Charmenu

Gemeinsames Charakter-Menue fuer zwei Garry's-Mod-Server mit gemeinsamer SQL-Datenbank.

## Funktionen

- 3 Charakterplaetze pro Spieler
- Name erstellen
- Geschlecht auswaehlen
- PlayerModel auswaehlen
- Skin einstellen
- Kleidung ueber Bodygroups speichern
- Model-Vorschau im Menue
- Charakter auf mehreren Servern nutzen
- DarkRP-Jobdaten optional speichern

## Ordnerstruktur

Der Addon-Ordner muss so liegen:

```txt
garrysmod/addons/EH_Charmenu/
├─ addon.json
├─ lua/
│  ├─ autorun/
│  │  └─ eh_charmenu_loader.lua
│  └─ eh_charmenu/
│     ├─ sh_config.lua
│     ├─ sv_config.lua
│     ├─ sv_database.lua
│     ├─ sv_resources.lua
│     ├─ sv_version.lua
│     ├─ sv_core.lua
│     └─ cl_menu.lua
```

## Installation auf Pterodactyl

1. Repository als ZIP herunterladen.
2. Alten Ordner `EH_Charmenu` loeschen.
3. Neuen Ordner nach `garrysmod/addons/EH_Charmenu/` hochladen.
4. SQL-Daten in `lua/eh_charmenu/sv_config.lua` eintragen.
5. Server komplett neu starten.

## SQL einrichten

SQL-Daten kommen nur hier rein:

```txt
lua/eh_charmenu/sv_config.lua
```

Beispiel:

```lua
EHChar.Config.Database = {
    UseMySQL = true,
    Host = "DEINE_SQL_IP_ODER_HOST",
    Port = 3306,
    Database = "DEINE_DATENBANK",
    Username = "DEIN_SQL_USER",
    Password = "DEIN_SQL_PASSWORT",
    AutoReconnect = true,
    ReconnectDelay = 10,
    StrictMySQL = true
}
```

Wichtig: Bei externer Datenbank nicht `127.0.0.1` oder `localhost` nutzen. Nimm die echte Datenbank-IP oder den Hostnamen.

Der MySQL-User muss externe Verbindungen vom GMod-Server erlauben.

## Benötigtes Modul

Fuer MySQL braucht Garry's Mod das Modul `mysqloo`.

Wenn im Log steht:

```txt
mysqloo konnte nicht geladen werden
```

muss `mysqloo` nach `garrysmod/lua/bin/` installiert und der Server neu gestartet werden.

## Erwarteter Server-Log

Nach einem erfolgreichen Start sollte im Log stehen:

```txt
[EH_Charmenu] Loader gestartet | Version 0.1.4
[EH_Charmenu] Geladen: eh_charmenu/sh_config.lua
[EH_Charmenu] Geladen: eh_charmenu/sv_config.lua
[EH_Charmenu] Geladen: eh_charmenu/sv_database.lua
[EH_Charmenu] Server-Dateien geladen
[EHChar SQL] Verbinde zu MySQL:
[EHChar SQL] MySQL verbunden.
```

## Server-ID einstellen

Datei:

```txt
lua/eh_charmenu/sh_config.lua
```

Metro-Server:

```lua
EHChar.Config.ServerID = "metro"
```

Stadt-/DarkRP-Server:

```lua
EHChar.Config.ServerID = "stadt"
```

Beide Server muessen dieselbe SQL-Datenbank nutzen, wenn die Charaktere synchron sein sollen.

## Steam Workshop vorbereiten

Dieses Addon ist fuer gmpublisher/gmad vorbereitet.

Wichtig fuer Workshop:

- `addon.json` muss im Hauptordner liegen.
- Der Ordner muss direkt `lua/` enthalten.
- Keine echten SQL-Passwoerter in das Workshop-Addon packen.
- SQL-Daten nach Installation auf dem Server in `sv_config.lua` eintragen.

Mit gmpublisher:

1. Addon-Ordner `EH_Charmenu` auswaehlen.
2. Titel: `EH Charmenu`
3. Typ: `ServerContent`
4. Tags: `roleplay`, `fun`
5. Veröffentlichen oder aktualisieren.

## Befehle

Chat:

```txt
/chars
!chars
/char
```

Konsole:

```txt
eh_chars
```

Debug:

```txt
eh_char_debug
```

## Datenbanktabellen

Das Addon erstellt automatisch:

```txt
eh_characters
eh_character_jobs
eh_charmenu_meta
```

`eh_charmenu_meta` speichert die installierte Version und ob im Repo eine neuere Version gefunden wurde.
