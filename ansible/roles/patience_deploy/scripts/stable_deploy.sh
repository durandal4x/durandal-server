# Setup folders
echo "Starting release"

# Remove previous release
rm -rf /tmp/durandal_release
mkdir -p /tmp/durandal_release
cd /tmp/durandal_release

echo "Decompressing"
tar mxfz /home/deploy/releases/durandal_stable.tar.gz

echo "Backup existing"
rm -rf /apps/durandal_backup
mv /apps/durandal /apps/durandal_backup

echo "Stopping service"
/apps/durandal_backup/bin/durandal stop

echo "Remove existing binary"
sudo rm -rf /apps/durandal

echo "Relocate binary"
cp -r /tmp/durandal_release/opt/build/_build/prod/rel/durandal /apps

echo "Rotate logs"
rm /var/log/durandal/error_old.log
rm /var/log/durandal/info_old.log

cp /var/log/durandal/error.log /var/log/durandal/error_old.log
cp /var/log/durandal/info.log /var/log/durandal/info_old.log

echo "Clear logs"
> /var/log/durandal/error.log
> /var/log/durandal/info.log

# Settings and vars
sudo chmod o+rw /apps/durandal/releases/0.0.1/env.sh
cat /apps/durandal.vars >> /apps/durandal/releases/0.0.1/env.sh

# Reset permissions
sudo chown -R deploy:deploy /apps/durandal
sudo chown -R deploy:deploy /var/log/durandal

echo "Starting service"
sudo systemctl restart durandal.service
