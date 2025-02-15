# Setup
- Do ansible
- Upload favicon
```sh
scp priv/static/images/favicon.png deploy@server.com:/var/www/favicon.ico
```


# Troubleshooting
### Anything obvious in these?
```sh
sudo systemctl status durandal
sudo journalctl -u durandal -xn | less
```

### Is the Durandal binary in place?
```sh
stat /apps/durandal/bin
```

### Database
```sh
# Does it exist?
psql -U durandal_prod

# Do you have the right connection credentials?
psql -U durandal_prod -h durandal4x.com -W
```

# Check the logs
```sh
cat /var/log/durandal/info.log
```

# Start it manually
```sh
sudo systemctl stop durandal

```
