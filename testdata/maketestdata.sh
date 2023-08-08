#!/bin/bash

makedata ()
{
  METHOD=$1
  PASSWORDLENGTH=$2
  SALTLENGTH=$3
  ROUNDS=$4

  PASSWORD=$(openssl rand $PASSWORDLENGTH | base64 -w 0 | head -c $PASSWORDLENGTH)
  CMD="mkpasswd $PASSWORD -m $METHOD"

  if [ "x$SALTLENGTH" != "x0" ]
  then
    SALT=$(openssl rand $SALTLENGTH | base64 -w 0 | head -c $SALTLENGTH | sed 's/+/./g')
    CMD="$CMD -S $SALT"
  else
    SALT=""
  fi

  if [ "x$ROUNDS" != "x0" ]
  then
    CMD="$CMD -R $ROUNDS"
  else
    ROUNDS=""
  fi

  HASH=$($CMD)
  if [ "x$HASH" != "x" ]
  then
    echo "$METHOD;$SALT;$ROUNDS;$PASSWORD;$HASH;$CMD"
  else
    echo Failed: $CMD >&2
  fi
}

echo "METHOD;SALT;ROUNDS;PASSWORD;HASH;CMD"

for METHOD in sha-256 sha-512
do
  for PASSWORDLENGTH in {1..16} {17..300..56}
  do
    for SALTLENGTH in 0 {8..16}
    do
      for ROUNDS in 0 999 1000 5000 6666 99999
      do
    	makedata $METHOD $PASSWORDLENGTH $SALTLENGTH $ROUNDS
      done
    done
  done
done
