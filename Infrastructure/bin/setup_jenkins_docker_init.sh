# Backup existing registries.conf to /etc/containers/registries.conf.yyyyMMddHHMM
echo "Backup existing registries.conf to /etc/containers/registries.conf.yyyyMMddHHMM"
cp /etc/containers/registries.conf /etc/containers/registries.conf.$(date +%Y%m%d%H%M)
cd /home/$1
command cp -fr registries.conf /etc/containers/

echo "Enabling Docker and Starting Docker service"
systemctl enable docker
systemctl start docker

echo "Docker services started..."
