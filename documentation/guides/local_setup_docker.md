# Local docker setup
Install [Docker](https://www.docker.com/)

## Clone repo
```bash
git clone git@github.com:durandal4x/durandal-server.git
cd durandal-server
```

## Fontawesome
The site makes use of [FontAwesome](https://fontawesome.com/) so if you are using the site you'll need to download the free version and do the following.

#### Using a script (free version)
```sh
# Download and unzip
wget --output-document fa.zip https://use.fontawesome.com/releases/v6.7.2/fontawesome-free-6.7.2-web.zip
unzip fa.zip

# Folders we need
mkdir -p priv/static/css
mkdir -p priv/static/webfonts

# Move things around
mv fontawesome-free-6.7.2-web/css/all.min.css priv/static/css/fontawesome.css
mv fontawesome-free-6.7.2-web/webfonts/* priv/static/webfonts

# Cleanup
rm -rf fontawesome-free-6.7.2-web
rm fa.zip
```

#### Manually
Note: Ensure you download the Web version, not the desktop version.
```bash
fontawesome/css/all.css -> priv/static/css/fontawesome.css
fontawesome/webfonts -> priv/static/webfonts
```

## Now make it run
```sh
docker compose up --build
# Now visit http://localhost:4000
```


## TODO:
- Create admin account on spinup
- How to get the remote console?
