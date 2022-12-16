#!/bin/bash

#######################
# Setting
#######################
PROJECT_PASS='path/to/project'
PROJECT_NAME='project-name'
DEPLOY_PASS='path/to/www/root'

DO_BACKUP=true

#######################
# Verify npm and vue-cli
#######################
npm -v &> /dev/null
if [ $? -ne 0 ] ; then
    echo 'npm is not installed...'
    exit 1
fi

vue --version &> /dev/null
if [ $? -ne 0 ] ; then
    echo 'vue-cli is not installed...'
    exit 1
fi

#######################
# Verify paths
#######################
PROJECT_DIR="$PROJECT_PASS/$PROJECT_NAME"

if [ ! -e "$PROJECT_DIR" ]; then
    echo "'$PROJECT_DIR' (project directory) is not exists..."
    exit 1
fi

if [ ! -e "$DEPLOY_PASS" ]; then
    echo "'$DEPLOY_PASS' (www root directory) is not exists..."
    exit 1
fi

#######################
# Build specified vue project
#######################
DIST_PATH="$PROJECT_DIR/dist"

# Do backup if a backup flag is turned on.
if [ "$DO_BACKUP" -a -e "$DIST_PATH" ]; then
    BACKUP_PASS="$PROJECT_DIR/dist_backup/"`date '+%Y%m%d%H%M%S'`
    echo "Backup current scripts to '$BACKUP_PASS' ..."

    mkdir -p $BACKUP_PASS
    rsync -a -r $DIST_PATH $BACKUP_PASS --exclude="$BACKUP_PASS"
    echo "Backup has done !!"
fi

rm -rf $DIST_PATH/*

# Build
cd $PROJECT_DIR
npm run build

if [ $? -ne 0 ] ; then
    echo 'Build failed...'
    exit 1
fi

#######################
# Deploy
#######################
echo "Deploy is in progress ..."
cp -r $DIST_PATH/* $DEPLOY_PASS
echo "Deploy has done !!"

#######################
# Restart NGINX
#######################
echo "Restarting NGINX ..."
systemctl restart nginx
echo "Restart has done !!"

echo "Finished !!"
