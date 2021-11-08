#!/bin/sh

# update-findingaids.sh -T 'awsparamstore://{PARAM_NAME}?region={REGION}&credentials=session'
# update-findingaids.sh -T 'constant://?val={TOKEN}'

SOURCES=`which wof-findingaid-sources`
POPULATE=`which wof-findingaid-populate`
RUNTIMEVAR=`which runtimevar`

GIT=`which git`
DATE=`which date`
BC=`which bc`

OFFSET=86400	# 24 hours
GITHUB_USER="whosonfirst-bot"

CUSTOM_REPOS=""
TOKEN_URI=""
USAGE=""

while getopts "O:R:T:U:h" opt; do
    case "$opt" in
        h) 
	    USAGE=1
	    ;;
	O)
	    OFFSET=$OPTARG
	    ;;	
	R)
	    CUSTOM_REPOS=$OPTARG
	    ;;
	T)
	    TOKEN_URI=$OPTARG
	    ;;
	U)
	    GITHUB_USER=$OPTARG
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

echo "Update finding aids"

echo "Retrieve GitHub acccess token"

GITHUB_TOKEN=`${RUNTIMEVAR} "${TOKEN_URI}"`

if [ "${GITHUB_TOKEN}" = "" ]
then
    echo "Missing GitHub access token"
    exit 1
fi

echo "Fetch repositories"

NOW=`${DATE} '+%s'`
SINCE=$((${NOW} - ${OFFSET}))

if [ "${CUSTOM_REPOS}" = "" ]
then
    echo "Fetch repos updated since ${SINCE} (offset ${OFFSET} seconds since now)"
    REPOS=`${SOURCES} -provider-uri "github://whosonfirst-data?prefix=whosonfirst-data-&exclude=whosonfirst-data-venue-&updated_since=${SINCE}"`    
else
    echo "Update custom repos ${CUSTOM_REPOS}"

    for REPO in ${CUSTOM_REPOS}
    do
	REPOS="${REPOS} https://github.com/whosonfirst-data/${REPO}.git"
    done
fi

if [ "${REPOS}" = "" ]
then
    echo "No repos to update, exiting"
    exit
fi

echo "Clone whosonfirst-data/whosonfirst-findingaids as ${GITHUB_USER}"
${GIT} clone --depth 1 https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/whosonfirst-data/whosonfirst-findingaids.git /usr/local/data/whosonfirst-findingaid

for REPO in ${REPOS}
do
    NAME=`basename ${REPO} | sed 's/\.git//g'`
    echo "Update finding aid for ${NAME}"
    
    PRODUCER_URI="csv://?archive=/usr/local/data/whosonfirst-findingaid/data/${NAME}.tar.gz"
    
    time ${POPULATE} -iterator-uri git:///tmp -producer-uri ${PRODUCER_URI} ${REPO}
done

NAMES=""

for REPO in ${REPOS}
do
    NAME=`basename ${REPO} | sed 's/\.git//g'`
    NAMES="${NAMES} ${NAME}"
done

echo "Commit changes"

cd /usr/local/data/whosonfirst-findingaid
git pull origin main
git add data
git commit -m "update finding aids for ${NAMES}" data
git push origin main
