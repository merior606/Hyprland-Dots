#!/bin/bash

# ==============================================================================
# CONFIGURACIÓN AUTOMÁTICA DE RED Y UNIDAD DE RED UPV
# ==============================================================================
# Este script configura:
# 1. Conexión WiFi UPVNET (WPA-EAP)
# 2. Conexión VPN UPV (Cisco VPNC)
# 3. Credenciales SMB y automontaje de la unidad personal (W:) en /home/usuario_local/W
# ==============================================================================

# Asegurarse de que el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Por favor, ejecuta este script como root."
  echo "Ejemplo: sudo $0 <usuario_upv> <contraseña> <usuario_local_linux>"
  exit 1
fi

# Verificar que se han introducido exactamente tres argumentos
if [ "$#" -ne 3 ]; then
  echo "Uso: $0 <usuario_upv> <contraseña> <usuario_local_linux>"
  exit 1
fi

USUARIO_UPV="$1"
CONTRASENA="$2"
USUARIO_LOCAL="$3"

# Comprobar si el usuario local existe en el sistema
if ! id "$USUARIO_LOCAL" &>/dev/null; then
  echo "Error: El usuario local '$USUARIO_LOCAL' no existe en este sistema."
  exit 1
fi

# Obtener datos del usuario local dinámicamente
PRIMERA_LETRA="${USUARIO_UPV:0:1}"
LOCAL_UID=$(id -u "$USUARIO_LOCAL")
LOCAL_GID=$(id -g "$USUARIO_LOCAL")
HOME_LOCAL=$(getent passwd "$USUARIO_LOCAL" | cut -d: -f6)
PUNTO_MONTAJE="${HOME_LOCAL}/W"

echo ">> Instalando paquetes necesarios a través de pacman..."
pacman -S --needed networkmanager networkmanager-vpnc vpnc cifs-utils

echo ">> Creando archivo /etc/NetworkManager/system-connections/UPVNET.nmconnection... "
cat <<EOF > /etc/NetworkManager/system-connections/UPVNET.nmconnection
[connection]
id=UPVNET
uuid=459fc165-d548-4d9c-90b5-5f96a7a120e8
type=wifi
autoconnect=true

[wifi]
ssid=UPVNET
mode=infrastructure

[wifi-security]
key-mgmt=wpa-eap

[802-1x]
eap=peap;
identity=${USUARIO_UPV}@alumno.upv.es
anonymous-identity=
password=${CONTRASENA}
phase2-auth=mschapv2
ca-cert=/etc/ssl/certs/USERTrust_ECC_Certification_Authority.pem
domain-suffix-match=radius.upv.es

[ipv4]
method=auto

[ipv6]
method=auto
EOF

echo ">> Creando archivo /etc/NetworkManager/system-connections/VPN-UPV.nmconnection..."
cat <<EOF > /etc/NetworkManager/system-connections/VPN-UPV.nmconnection
[connection]
id=VPN-UPV
uuid=baec232c-38fd-4ee3-8a30-79e9d7965e63
type=vpn
autoconnect=false
permissions=

[vpn]
service-type=org.freedesktop.NetworkManager.vpnc
IPSec gateway=vpn.upv.es
IPSec ID=soloupv
IPSec secret-flags=0
Xauth username=${USUARIO_UPV}@alumno.upv.es
Xauth password-flags=0
NAT Traversal Mode=natt
IKE DH Group=dh2
Perfect Forward Secrecy=server
Vendor=cisco

[vpn-secrets]
IPSec secret=upvnet
Xauth password=${CONTRASENA}

[ipv4]
method=auto

[ipv6]
method=auto
addr-gen-mode=stable-privacy

[proxy]
EOF

echo ">> Ajustando permisos y propietarios de NetworkManager..."
chmod 600 /etc/NetworkManager/system-connections/UPVNET.nmconnection
chmod 600 /etc/NetworkManager/system-connections/VPN-UPV.nmconnection
chown root:root /etc/NetworkManager/system-connections/UPVNET.nmconnection
chown root:root /etc/NetworkManager/system-connections/VPN-UPV.nmconnection

# Recargar NetworkManager
nmcli connection reload

echo ">> Creando archivo de credenciales SMB en /root/.smbcredentials..."
cat <<EOF > /root/.smbcredentials
username=${USUARIO_UPV}
password=${CONTRASENA}
EOF

chmod 600 /root/.smbcredentials
chown root:root /root/.smbcredentials

echo ">> Preparando punto de montaje local en ${PUNTO_MONTAJE}..."
mkdir -p "${PUNTO_MONTAJE}"
chown "${LOCAL_UID}:${LOCAL_GID}" "${PUNTO_MONTAJE}"

echo ">> Añadiendo la entrada a /etc/fstab..."
# Evitamos duplicados básicos comprobando si ya existe el punto de montaje en fstab
if grep -q "${PUNTO_MONTAJE}" /etc/fstab; then
  echo "La entrada para ${PUNTO_MONTAJE} ya parece existir en /etc/fstab. Omitiendo."
else
  echo "" >> /etc/fstab
  echo "# Montar unidad W para el usuario ${USUARIO_UPV}" >> /etc/fstab
  echo "//nasupv/alumnos/${PRIMERA_LETRA}/${USUARIO_UPV}   ${PUNTO_MONTAJE}   cifs   credentials=/root/.smbcredentials,uid=${LOCAL_UID},gid=${LOCAL_GID},noauto,x-systemd.automount,_netdev,noserverino   0  0" >> /etc/fstab
  
  # Recargar los demonios de systemd para que reconozca el x-systemd.automount nuevo
  systemctl daemon-reload
fi

echo ">> ¡Configuración finalizada con éxito!"