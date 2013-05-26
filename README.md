## Quick Setup LDAP Service

    container_id=$(docker run -d timgreen/ldap:latest)
    container_ip=$(docker inspect $container_id | jshon -e NetworkSettings -e IpAddress -u)
    ssh root@$container_ip # default password is '123456', please change it
    # cd /dev/shm/scripts/
    # # edit ldap_config
    # ./config_ldap.sh
    # exit
