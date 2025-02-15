# Local docker setup
Install [Docker](https://www.docker.com/)

## Clone repo
```bash
git clone git@github.com:durandal4x/durandal-server.git
cd durandal-server
```

## Fontawesome
The site makes use of [FontAwesome](https://fontawesome.com/) so if you are using the site you'll need to download the free version and do the following.

Note: Ensure you download the Web version, not the desktop version.
```bash
fontawesome/css/all.css -> priv/static/css/fontawesome.css
fontawesome/webfonts -> priv/static/webfonts
```
If you have a pro copy then you will also want to do the following:
```sh

```

## Now make it run
```sh
docker compose up --build
# Now visit http://localhost:4000
```