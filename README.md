# 📘 README — Déploiement Flask + Gunicorn + Nginx avec Ansible

## 🎯 Objectif du projet

Ce projet montre comment **automatiser le déploiement d’une application Python Flask** en production à l’aide d’**Ansible**. L’application est servie par **Gunicorn** (serveur WSGI) derrière **Nginx** (reverse proxy), avec un **service systemd** pour la supervision.

L’ensemble du déploiement est **idempotent**, **reproductible**, et **CI/CD ready**.

---

## ⚙️ Stack technique

| Composant                 | Description                             |
| ------------------------- | --------------------------------------- |
| **OS cible**              | Ubuntu 22.04 / 24.04 (adaptable Debian) |
| **Serveur web**           | Nginx (port 80)                         |
| **Serveur d’application** | Gunicorn (port interne 8000)            |
| **Framework web**         | Flask (Python 3)                        |
| **Supervision**           | systemd                                 |
| **Automatisation**        | Ansible                                 |

---

## 🧩 Architecture

```
[Client] ─▶ Nginx (port 80)
             │
             ▼
        Gunicorn (port 8000)
             │
             ▼
         Flask App
```

---

## 🗂️ Structure du projet

```
ansible-flask-gunicorn-nginx/
├─ ansible.cfg
├─ inventory.ini
├─ group_vars/web.yml
├─ playbooks/
│  ├─ site.yml
│  └─ check.yml
├─ roles/
│  ├─ common/
│  ├─ python/
│  ├─ flask_app/
│  ├─ gunicorn/
│  └─ nginx/
└─ Makefile
```

---

## 🚀 Déploiement rapide

### 1️⃣ Configuration de base

Modifie `inventory.ini` pour y placer l’adresse IP et l’utilisateur SSH de ton serveur :

```ini
[web]
node01 ansible_host=192.168.56.21 ansible_user=vagrant
```

Assure-toi d’avoir un accès SSH fonctionnel depuis ta machine de contrôle.

### 2️⃣ Exécuter le déploiement

```bash
make ping     # Vérifie la connexion Ansible
make setup    # Déploie l’ensemble (common, python, app, gunicorn, nginx)
```

Pour mettre à jour uniquement l’application :

```bash
make deploy
```

### 3️⃣ Vérification

```bash
curl -I http://<IP>
curl http://<IP>/healthz
```

Résultat attendu : `{ "status": "ok" }`

---

## 🧠 Fonctionnement des rôles

### 🧱 `common`

Installe les dépendances système, crée l’utilisateur applicatif et le répertoire `/opt/myflaskapp`.

### 🐍 `python`

Installe Python, pip, venv, et crée un environnement virtuel isolé.

### 💡 `flask_app`

Copie les sources de l’application Flask, installe les dépendances `requirements.txt` dans le venv et notifie le redémarrage du service.

### 🔥 `gunicorn`

Crée un service systemd gérant Gunicorn, le démarre et vérifie sa santé via `/healthz`.

### 🌐 `nginx`

Installe Nginx, crée un fichier de configuration proxy_pass vers Gunicorn, et recharge le service.

---

## 🧰 Commandes Makefile

| Commande            | Description                                       |
| ------------------- | ------------------------------------------------- |
| `make ping`         | Teste la connectivité Ansible                     |
| `make setup`        | Installation complète initiale                    |
| `make deploy`       | Redéploiement applicatif (app + gunicorn + nginx) |
| `make check`        | Vérifie la santé de l’application                 |
| `make nginx-reload` | Recharge manuellement Nginx                       |

---

## 🧪 Tests & Validation

* Accède à `http://<IP>` → la page HTML doit s’afficher.
* `/healthz` retourne `{"status":"ok"}`.
* Vérifie les services :

```bash
systemctl status nginx
systemctl status myflaskapp
```

---

## 🔐 (Option) HTTPS & Sécurité

* Activer **UFW** :

```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
```

* Ajouter un rôle `letsencrypt` pour Certbot et activer HTTPS.
* Forcer le `server_name` dans `group_vars/web.yml` pour ton domaine.

---

## 🧰 Intégration CI/CD

Pour automatiser les déploiements via GitLab CI ou GitHub Actions :

* Ajouter les jobs :

  * `ansible-lint`
  * `yamllint`
  * Déploiement Ansible sur environnement staging/prod

---

## ❗ Dépannage rapide

| Problème                | Commande utile                         |
| ----------------------- | -------------------------------------- |
| Gunicorn ne démarre pas | `journalctl -u myflaskapp -f`          |
| Erreur Nginx            | `nginx -t && systemctl reload nginx`   |
| Mauvais droits          | `chown -R flask:flask /opt/myflaskapp` |
| Health check échoue     | `curl http://127.0.0.1:8000/healthz`   |

---

## 📸 Résultats attendus

* Page d’accueil Flask visible sur IP publique
* Service Gunicorn actif (`systemctl is-active myflaskapp` → `active`)
* `nginx` en écoute sur le port 80

---

## 📜 Licence

Projet libre à usage personnel, pédagogique ou professionnel.
