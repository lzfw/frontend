# Font end HTTP proxy

The front end reverse web proxy is a container instantiating the [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) image.

## GitLab CI/CD

Changes to GitLab can be applied by manually starting jobs. Always make sure you have SSH access for a roll-back.

### Apply a change

Start the "run" task.

### Update jwilder/nginx

Start the "upgrade" task. This fetches the newest image from docker hub and re-starts the proxy if required with all configuration changes applied.

### Roll-Back

TODO

## Usage as reverse proxy, HTTPS termination, HTTP Auth

When in doubt, refer to the [official documentation](https://github.com/jwilder/nginx-proxy).

### Purpose
HTTPS Termination, HTTP Auth, Reverse Proxy (distribute incoming requests to the correct containers running in the same network).
 
### Configuration
The creates its configuration from meta data from all running Docker containers automatically. The following Docker container environment variables are important: `VIRTUAL_HOST`, `LETSENCRYPT_HOST`, and `LETSENCRYPT_EMAIL`
If a container should be reachable under the host name goethe.leopoldina.org, `VIRTUAL_HOST` and `LETSENCRYPT_HOST` must be set to goethe.leopoldina.org
Set `LETSENCRYPT_EMAIL` to the lzfw one; this eMail address will be contacted by LetsEncrypt in case of issues or expiring certificates.
Additionally, the EXPOSE entries are used to find the port the container offers its web service under.

### Additional configuration
Additional vHost configurations, passwords, and server config can be added in the proxy's volumes. Root privileges on the server are required though.
 
### Examples
* https://github.com/lzfw/sammlungsraeume (minimal)
* https://github.com/lzfw/ns-medical-victims-docker (features containers that are not reachable from the outside world)

## Docker Network

The Frontend Server's Docker Compose configuration adds a network named `global-proxy-network`. All containers that should be accessible from outside the the server itself on port 80 or 443 must be part of that network.
 
Examples of how to become part of the network:
* https://github.com/lzfw/sammlungsraeume/blob/9ea217c9e633ac5b79236614ed63a9b735e44765/docker-compose.yaml#L13,L19




