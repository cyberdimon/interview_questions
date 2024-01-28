docker-up:
	docker compose up -d

docker-down:
	docker compose down

docker-rebuild:
	docker compose down
	docker compose build
	docker compose up -d

check-php:
	docker compose exec php php -v

check-composer:
	docker compose exec php composer help

check-ini:
	docker compose exec php cat /usr/local/etc/php/php.ini