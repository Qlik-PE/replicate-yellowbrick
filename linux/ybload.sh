#! /bin/bash

debug="false"  

#loader="psql"
loader="ybload"

# JAVA_HOME is required by ybload. 
if [[ -z "$JAVA_HOME" ]]
then
   echo "JAVA_HOME was not set. Setting a default." 1>&2 
   export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.322.b06-1.el7_9.x86_64/jre"
fi

if [[ "$1" == "-V" ]]
then
    echo "ybload.sh - map arguments from Replicate to Yellowbrick 'ybload'"
    ${loader} --version
    exit 0
fi


if [ "${debug}" == "true" ]
then
   echo "args: $*"
fi

ARGS=( "$@" )
# 
if [ "${debug}" == "true" ]
then
   total=${#ARGS[*]}
   for (( i=0; i<$(( total )); i++ ))
   do 
       echo  "$i : ${ARGS[$i]} "
   done
fi

IFS=' '
read -ra META <<< "${ARGS[1]}"
FQTN=${META[1]}
eval SCHEMA="${FQTN%\.*}"
eval TABLE="${FQTN#*\.}"
eval FILENAME="${META[3]}"
URI="${ARGS[2]}"

if [ "${debug}" == "true" ]
then
   echo "schema=|$SCHEMA|"
   echo "table=|$TABLE|"
   echo "filename=|$FILENAME|"
   echo "uri=|$URI|"
fi

IFS='?'
read -ra FIELDS <<< "$URI"

QUERY_PARMS=${FIELDS[1]}
URL=${FIELDS[0]}

IFS=':'
read -ra FIELDS <<< "$URL"
HOST=${FIELDS[1]}
HOST=${HOST#//@}
PORT=${FIELDS[2]}

IFS='&'
read -ra PARMS <<< "$QUERY_PARMS"

for parm in "${PARMS[@]}"
do
   case $parm in
      dbname=*)
         DATABASE=${parm#*=}
         ;;
      user=*)
         USERNAME=${parm#*=}
         ;;
       *)
         ;;
   esac
done


if [ "${debug}" == "true" ]
then
   echo "host=$HOST"
   echo "port=$PORT"
   echo "database=$DATABASE"
   echo "username=$USERNAME"
fi


case $loader in
   psql)
      echo "loader is 'psql'"
      psql -c "\\copy \"${SCHEMA}\".\"${TABLE}\" from '${FILENAME}' \
            WITH DELIMITER ',' CSV NULL 'attNULL' ESCAPE '\\' " "${URI}"
      ;;
   ybload)
      echo "loader is 'ybload'"
      export YBPASSWORD=${PGPASSWORD}

      ybload -h "${HOST}" -p "${PORT}" -U "${USERNAME}" -d "${DATABASE}" \
        --format CSV --escape-char "\\" \
        -t "\"${SCHEMA}\".\"${TABLE}\"" \
        --nullmarker "attNULL" "${FILENAME}"
      ;;
   *)
      echo "ybload.sh: invalid loader specified '$loader'" 1>&2
      exit 1
      ;;
esac



