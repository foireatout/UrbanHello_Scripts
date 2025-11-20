# UrbanHello REMI – Command Manager for Jeedom

Ce dépôt contient un **gestionnaire Bash (`urbanhello_manager.sh`)** permettant de piloter un réveil **UrbanHello REMI** via l’API non documentée d’UrbanHello.

Le script utilise un **backend Python (`urbanhello_api.py`)**, dédié aux appels API, tandis que **le manager Bash** offre une interface simple à utiliser dans **Jeedom (virtuel, scénario, script)**.

---

# Principe général

1. **Le script Bash** est utilisé directement dans Jeedom.  
2. **Le script Python** est responsable des appels HTTPS à l’API UrbanHello.  
3. Le manager Bash :
   - stocke et réutilise le `sessionToken`,
   - fournit des commandes simplifiées,
   - permet une intégration propre dans Jeedom.

---

# Fonctionnalités disponibles

Toutes les fonctions ci-dessous sont fournies par **`urbanhello_manager.sh`**.

## Gestion du compte

### `account [attribute]`
Affiche les informations du compte UrbanHello.

---

## Informations REMI

### `remi REMI_ID`
Affiche toutes les infos du réveil.

### `get_temp REMI_ID`
Retourne la température du REMI.

---

## Son & Musique

### `play_music REMI_ID fichier.mp3`
Joue un fichier MP3 déjà présent sur le REMI.  
L’API reçoit : `musicPath = "<file>:play"`

### `stop_music REMI_ID`
Stoppe la musique en cours.  
L’API reçoit : `musicPath = "pause:0"`

### `set_volume REMI_ID volume`
Définit le volume entre **0 et 100**.

---

## Lumière

### `set_luminosity REMI_ID niveau`
Ajuste la luminosité de 0 à 100.

---

## Visage du REMI

### `face REMI_ID`
Affiche le nom du visage actuel.

### `face REMI_ID faceName`
Change le visage (awakeFace, sleepyFace, semiAwakeFace, blankFace).

### `facenum REMI_ID`
Retourne un numéro correspondant au visage actuel :
- 1 = awakeFace  
- 2 = sleepyFace  
- 3 = semiAwakeFace  
- 4 = blankFace  

---

## Alarmes

### `get_alarms REMI_ID`
Liste les alarmes du réveil.

### `set_alarm REMI_ID index field value`
Modifie une alarme existante.  
Exemples :
- changer l’heure → `set_alarm X 0 hour 7`
- activer/désactiver → `set_alarm X 0 enabled true`

---

# Fichiers

- **urbanhello_manager.sh**  
  Interface principale, à appeler depuis Jeedom.

- **urbanhello_api.py**  
  Gère l’intégralité des appels HTTPS à l’API UrbanHello.

---

# Installation

1. Pour Jeedom, créer le dossier /var/www/html/plugins/script/data/urbanhello et placez le deux fichiers dedans.
2. Modifiez le fichier urbanhello_manager.sh et remplacez:
   - USERNAME= l'adresse mail de votre compte UrbanHello
   - PASSWORD= Votre mot de passe UrbanHello
3. Pour Jeedom, utilisez le plugin "script" de Jeedom pour appeler les commandes
