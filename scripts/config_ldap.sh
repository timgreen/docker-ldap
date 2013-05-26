#!/bin/bash

BASE_DIR="$(dirname "$0")"
cd "$BASE_DIR"

. ldap_config

modify_slapd_conf() {
  cp -f $BASE_DIR/../slapd.conf.tpl /etc/openldap/slapd.conf
  sed -i "s/suffix_placeholder/suffix $LDAP_BASE_DN/" /etc/openldap/slapd.conf
  sed -i "s/rootdn_placeholder/rootdn $LDAP_ROOT_DN/" /etc/openldap/slapd.conf
  sed -i "s|rootpw_placeholder|rootpw $ROOT_PW|" /etc/openldap/slapd.conf
  rm -rf /etc/openldap/slapd.d/*
}

start_slapd() {
  slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d

  rm -fr /var/lib/ldap/*
  cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
  chown ldap:ldap /var/lib/ldap/DB_CONFIG
  chown -R ldap:ldap /var/lib/ldap/
  chown -R ldap:ldap /etc/openldap/slapd.d
  chmod -R 700 /etc/openldap/slapd.d

  service slapd restart
}

init_tree() {
  TMP_FILE=$(mktemp)

  cat > $TMP_FILE << EOF
dn: $LDAP_BASE_DN
dc: $LDAP_DC
description: LDAP root
objectClass: dcObject
objectClass: organization
o: $LDAP_O

dn: $LDAP_PEOPLE_DN
objectClass: organizationalUnit
ou: $LDAP_PEOPLE_NAME

dn: $LDAP_GROUP_DN
objectClass: organizationalUnit
ou: $LDAP_GROUP_NAME
EOF

  ldapadd -h $LDAP_HOST -x -W -D "$LDAP_ROOT_DN" -f $TMP_FILE
  rm -f $TMP_FILE
}

modify_slapd_conf
start_slapd
init_tree
