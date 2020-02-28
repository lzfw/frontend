# Font end HTTP proxy

The front end reverse web proxy is a container instantiating the [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) image.

## GitLab CI/CD

Changes to GitLab can be applied by manually starting jobs. Always make sure you have SSH access for a roll-back.

### Apply a change

Start the "run" task.

### Update jwilder/nginx

Start the "upgrade" task. This fetches the newest image from Docker Hub and re-starts the proxy if required with all configuration changes applied.

### Roll-Back

TODO

## Usage as reverse proxy, HTTPS termination, HTTP Auth

When in doubt, refer to the [official documentation](https://github.com/jwilder/nginx-proxy).

### Purpose
HTTPS Termination, HTTP Auth, Reverse Proxy (distribute incoming requests to the correct containers running in the same network).
 
### Configuration
The frontend proxy container creates its configuration from meta data from all running Docker containers automatically. The following Docker container environment variables are important: `VIRTUAL_HOST`, `LETSENCRYPT_HOST`, and `LETSENCRYPT_EMAIL`
If a container should be reachable under the host name goethe.leopoldina.org, `VIRTUAL_HOST` and `LETSENCRYPT_HOST` must be set to goethe.leopoldina.org
Set `LETSENCRYPT_EMAIL` to the lzfw one; this eMail address will be contacted by LetsEncrypt in case of issues or expiring certificates.
Additionally, the EXPOSE entries are used to find the port the container offers its web service under.

### Additional configuration
Additional vHost configurations, passwords, and server config can be added in the proxy's volumes. Root privileges on the server are required though.

#### `/var/lib/docker/volumes/frontend-proxy_conf/_data`

```conf
map $status $accessdenied {
    401  1;
    default 0;
}

geo $external {
    default        1;

    5.35.251.220    0;
    2a01:488:67:1000:523:fbdc:0:1   0;

    127.0.0.1      0;
# We can not trust these IPs as long as IPv6 is enabled on host
# and disabled in Docker because Docker does IPv4 to IPv6 NAT.
#    172.16.0.0/12  0;
#    192.168.0.0/16 0;
#    10.0.0.0/8     0;

    ::1            0;
#    fd00::/8       0;
}


log_format fail2ban '$time_local $remote_addr - $remote_user '
                    'tt-tt $status "$request" $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';

log_format gelf_json escape=json '{ "timestamp": "$time_iso8601", '
         '"remote_addr": "$remote_addr", '
         '"connection": "$connection", '
         '"connection_requests": $connection_requests, '
         '"pipe": "$pipe", '
         '"body_bytes_sent": $body_bytes_sent, '
         '"request_length": $request_length, '
         '"request_time": $request_time, '
         '"response_status": $status, '
         '"request": "$request", '
         '"request_method": "$request_method", '
         '"host": "$host", '
         '"upstream_cache_status": "$upstream_cache_status", '
         '"upstream_addr": "$upstream_addr", '
#         '"http_x_forwarded_for": "$http_x_forwarded_for", '
         '"http_referrer": "$http_referer", '
         '"http_user_agent": "$http_user_agent", '
         '"http_version": "$server_protocol", '
         '"remote_user": "$remote_user", '
#         '"http_x_forwarded_proto": "$http_x_forwarded_proto", '
         '"upstream_response_time": "$upstream_response_time", '
         '"nginx_access": true }';

log_format syslog_json escape=json '{ "timestamp": "$time_iso8601", '
	'"remote_addr": "$remote_addr", '
	'"body_bytes_sent": $body_bytes_sent, '
    '"request_length": $request_length, '
	'"request_time": $request_time, '
	'"response_status": $status, '
	'"request": "$request", '
	'"request_method": "$request_method", '
	'"host": "$host", '
	'"upstream_cache_status": "$upstream_cache_status", '
	'"upstream_addr": "$upstream_addr", '
	'"http_referrer": "$http_referer", '
	'"http_user_agent": "$http_user_agent", '
	'"http_version": "$server_protocol", '
    '"remote_user": "$remote_user", '
	'"nginx_access": true }';

access_log /var/log/nginx/ext/accessdenied.log fail2ban if=$accessdenied;
```

## Headers

The following HTTP headers are calculated by the frontend server and passed to the upstream containers: `Host`, `Upgrade`, `Connection`, `X-Real-IP`, `X-Forwarded-For`, `X-Forwarded-Proto`, `X-Forwarded-Ssl`, `X-Forwarded-Port`

### Examples
* https://github.com/lzfw/sammlungsraeume (minimal)
* https://github.com/lzfw/ns-medical-victims-docker (features containers that are not reachable from the outside world)

## Docker Network

The Frontend Server's Docker Compose configuration adds a network named `global-proxy-network`. All containers that should be accessible from outside the server itself on port 80 or 443 must be part of that network.
 
Examples of how to become part of the network:
* https://github.com/lzfw/sammlungsraeume/blob/9ea217c9e633ac5b79236614ed63a9b735e44765/docker-compose.yaml#L13,L19

# FAQ

- Q: Do we have to hard code the proxie's internal IP?
- A. We must not, as long as the entire network is not hardcoded. Otherwise services may fail to start with "address already in use" error.


