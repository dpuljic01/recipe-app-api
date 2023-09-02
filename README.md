## Recipe API

Recipe API: Django & DRF


### Helpful commands
- `docker build .` - builds an image based on `Dockerfile` in current directory
- `docker-compose build` - builds an image based on `docker-compose.yml` file in current directory
- `docker-compose run --rm app sh -c "django-admin startproject app ."` - create new django project inside current directory
- `docker-compose up` - starts services defined in `docker-compose` file
- `docker-compose down` - clear containers
- `docker-compose run --rm app sh -c "python manage.py wait_for_db"` - custom management command to check if DB is available
- `docker volume ls` - list all volumes on our system
- `docker volume rm <name-of-volume>` - removes volume