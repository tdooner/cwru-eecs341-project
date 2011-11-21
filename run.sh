#!/usr/bin/env bash
# This script will be a bit more intelligent about how to run the server:
#   If it's running on sharemat.ch, we'll be in PRODUCTION
#   Otherwise, we'll be in DEVELOPMENT
#   Unless you pass in an argument to the script like:
#      ./run.sh production
#
# Depending on mode, either shotgun or thin will be run (shotgun for
#  development, naturally.)

if [[ -z $1 ]]; then
    RACK_ENV='development'
else
    RACK_ENV=`echo $1 | tr '[A-Z]' '[a-z]'` # Lowercase the human input
fi

# If we're running on the real thing, let's run in production mode.
HOSTNAME=`hostname`
if [[ $HOSTNAME == "main.tdooner.com" ]]; then
    RACK_ENV='production'
fi

export $RACK_ENV

if [[ $RACK_ENV == 'development' ]]; then 
    echo "Running server in ${RACK_ENV} environment..."
    bundle exec shotgun -o 0.0.0.0 -p 4567 -E $RACK_ENV -s thin ./config.ru
fi
if [[ $RACK_ENV == 'production' ]]; then 
    echo "Running server in ${RACK_ENV} environment..."
    bundle exec thin start -a 0.0.0.0 -p 4567 -e $RACK_ENV -R ./config.ru
fi

