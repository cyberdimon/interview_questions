# #6 Docker Compose Configuration

There is a configuration of services in docker-compose.yml that requires modification. The tasks are as follows:

- Add a service to this file where a PHP application will run.
- Override the database service to MySQL 8 without changing the current file.
- Combine all services into one network.
- Port settings and the configuration of the Nginx service default.conf should be modifiable externally.

Original docker-compose:
```yaml
version: '3'
services:
  nginx:
    image: nginx:alpine
    container_name: app-nginx
    ports:
      - "8090:8090"
      - "443:443"
    volumes:
      - ./:/var/www

  db:
    platform: linux/x86_64
    image: mysql:5.6.47
    container_name: app-db
    ports:
      - "3306:3306"
    volumes:
      - ./etc/infrastructure/mysql/my.cnf:/etc/mysql/my.cnf
      - ./etc/database/base.sql:/docker-entrypoint-initdb.d/base.sql

```

## Solution

Look files in this dir.  
Create /storage/mysql dir for mysql data storage.