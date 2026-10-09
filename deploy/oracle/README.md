# Despliegue del backend de Galingo en Oracle Cloud (Always Free)

VM ARM (Ampere A1) gratuita para siempre: hasta 4 vCPU / 24 GB RAM.
El modelo ASR se descarga solo desde Hugging Face al primer arranque.

## 1. Crear la cuenta
- Regístrate en https://signup.cloud.oracle.com (pide tarjeta para verificar, pero
  los recursos *Always Free* no cobran).
- Elige una **región** cercana (p. ej. Madrid / Frankfurt).

## 2. Crear la VM (Always Free)
- Menú → **Compute → Instances → Create instance**.
- **Image**: Ubuntu 24.04.
- **Shape**: *Ampere / Arm* → `VM.Standard.A1.Flex` con **4 OCPU / 24 GB RAM**
  (entra en Always Free).
- **Networking**: crea/usa una VCN; asigna **IP pública**.
- **SSH keys**: descarga la clave privada (`ssh-key-....key`).

## 3. Abrir el puerto 8000
Dos sitios (si falta uno, no llega la conexión):

1. **VCN → Security Lists → Default → Add Ingress Rule**
   - Source `0.0.0.0/0`, IP Protocol `TCP`, Destination Port `8000`.
2. **Dentro de la VM** (Ubuntu trae reglas iptables):
   ```bash
   sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 8000 -j ACCEPT
   sudo netfilter-persistent save
   ```

## 4. Instalar y arrancar el backend
```bash
# Conéctate
ssh -i ssh-key-....key ubuntu@<IP_PUBLICA>

# Docker
sudo apt-get update && sudo apt-get install -y docker.io docker-compose-v2 git
sudo usermod -aG docker $USER && newgrp docker

# Código
git clone https://github.com/Retselfernandez/Galingo.git
cd Galingo

# Arrancar (descarga el modelo la primera vez: ~1-2 min)
docker compose -f deploy/oracle/docker-compose.yml up -d --build

# Ver logs
docker compose -f deploy/oracle/docker-compose.yml logs -f
```

## 5. Probar
```bash
curl http://<IP_PUBLICA>:8000/api/v1/metricas
curl -F "audio=@test.mp3" -F "target=Ola, bos días!" http://<IP_PUBLICA>:8000/api/v1/voz/avaliar
```

URL definitiva: `http://<IP_PUBLICA>:8000`

## Notas
- **Sin HTTPS**: la app usa `android:usesCleartextTraffic="true"` para la beta.
  Si más adelante quieres HTTPS, añade un dominio + Caddy con Let's Encrypt en la VM.
- **Persistencia**: el modelo y la BD SQLite viven en volúmenes Docker (`models`, `data`).
- **Reinicio**: `restart: unless-stopped` mantiene la API viva tras reiniciar la VM.
- Para datos de telemetría más sólidos, cambia `DATABASE_URL` a un Postgres (Neon/Supabase).
