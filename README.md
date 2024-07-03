# ynh_dev_dockerized
Dockerized yuonohost with tailscale and current installation script

# Build
    docker build -t yunohost .

# Run 
    podman run -d --name yunohost -p 8080:80 -p 4443:443 --cap-add NET_RAW debian-yunohost
