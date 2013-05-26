#!/bin/bash
set -e
set -x

yum -y update
yum -y install openldap-servers openldap-clients openssh-server passwd

cat << EOF > /etc/openldap/slapd.conf
pidfile     /var/run/openldap/slapd.pid
argsfile    /var/run/openldap/slapd.args
EOF
rm -rf /etc/openldap/slapd.d/*
slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d

cat << EOF > /etc/openldap/slapd.d/cn=config/olcDatabase\={1}monitor.ldif
dn: olcDatabase={1}monitor
objectClass: olcDatabaseConfig
olcDatabase: {1}monitor
olcAccess: {1}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by * break
olcAddContentAcl: FALSE
olcLastMod: TRUE
olcMaxDerefDepth: 15
olcReadOnly: FALSE
olcMonitoring: FALSE
structuralObjectClass: olcDatabaseConfig
creatorsName: cn=config
modifiersName: cn=config
EOF

chown -R ldap /etc/openldap/slapd.d
chmod -R 700 /etc/openldap/slapd.d

ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ""
ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ""
echo root:123456 | chpasswd

cat << EOF > /run.sh
#!/bin/bash
service slapd restart
/usr/sbin/sshd -D
EOF
chmod +x /run.sh

