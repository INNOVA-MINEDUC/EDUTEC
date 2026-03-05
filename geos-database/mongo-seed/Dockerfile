FROM mongo:4.2.12

COPY database/guia_edutec /guia_edutec
CMD mongorestore --host=$MONGO_IP --db=$MONGO_DB -u $MONGO_USER -p $MONGO_PASSWORD --authenticationMechanism SCRAM-SHA-256 /guia_edutec --gzip