#!/bin/sh

# update-findingaids.sh -T 'awsparamstore://{PARAM_NAME}?region={REGION}&credentials=session'
# update-findingaids.sh -T 'constant://?val={TOKEN}'

SOURCES=`which wof-findingaid-sources`
POPULATE=`which wof-findingaid-populate`
RUNTIMEVAR=`which runtimevar`

GIT=`which git`
DATE=`which date`
BC=`which bc`

NOW=`${DATE} '+%s'`
SINCE=$((${NOW} - 86400))	# 24 hours

GITHUB_USER="whosonfirst-data"

TOKEN_URI=""
USAGE=""

while getopts "T:h" opt; do
    case "$opt" in
        h) 
	    USAGE=1
	    ;;	
	T)
	    TOKEN_URI=$OPTARG
	    ;;
	:   )
	    echo "WHAT WHAT WHAT"
	    ;;
    esac
done

if [ "${USAGE}" = "1" ]
then
    echo "usage: update.sh"
    echo "options:"
    echo "...please write me"
    exit 0
fi

GITHUB_TOKEN=`${RUNTIMEVAR} "${TOKEN_URI}"`

if [ "${GITHUB_TOKEN}" = "" ]
then
    echo "Missing GitHub access token"
    exit 1
fi

REPOS=`${SOURCES} -provider-uri "github://whosonfirst-data?prefix=whosonfirst-data-&exclude=whosonfirst-data-venue-&updated_since=${SINCE}"`

if [ "${REPOS}" = "" ]
then
    exit
fi

${GIT} clone https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/whosonfirst-data/whosonfirst-findingaids.git /usr/local/data/whosonfirst-findingaid

for REPO in ${REPOS}
do
    NAME=`basename ${REPO} | sed 's/\.git//g'`
    echo "Update finding aid for ${NAME}"
    
    PRODUCER_URI="csv://?archive=/usr/local/data/whosonfirst-findingaid/data/${NAME}.db"
    
    time ${POPULATE} -iterator-uri git:///tmp -producer-uri ${PRODUCER_URI} ${REPO}
done

NAMES=""

for REPO in ${REPOS}
do
    NAME=`basename ${REPO} | sed 's/\.git//g'`
    NAMES="${NAMES} ${NAME}"
done

cd /usr/local/data/whosonfirst-findingaid
git add data
git commit -m "update finding aids for ${NAMES}"
git push origin main
