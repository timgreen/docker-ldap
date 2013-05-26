#!/bin/bash
set -e
set -x

yum -y update
yum -y install openldap-servers openldap-clients openssh-server passwd

curl https://raw.github.com/timgreen/docker-ldap/master/slapd.conf.tpl > /dev/shm/slapd.conf.tpl
mkdir -p /dev/shm/scripts/
curl https://raw.github.com/timgreen/docker-ldap/master/scripts/config_ldap.sh > /dev/shm/scripts/config_ldap.sh
chmod +x /dev/shm/scripts/config_ldap.sh
curl https://raw.github.com/timgreen/docker-ldap/master/scripts/ldap_config > /dev/shm/scripts/ldap_config

ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ""
ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ""
echo root:123456 | chpasswd

cat > /run.sh << EOF
#!/bin/bash
[ -r /var/lib/ldap/DB_CONFIG ] && service slapd restart || echo "Edit /dev/shm/ldap_config & run /dev/shm/config_ldap.sh to setup."
/usr/sbin/sshd -D
EOF
chmod +x /run.sh
