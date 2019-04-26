#!/sh
pyrit -r $1 analyze
pyrit -r $1 -o clean_$1 strip
pyrit -i $WORDLIST import_passwords
pyrit eval
pyrit batch
pyrit -r clean_$1 attack_db
