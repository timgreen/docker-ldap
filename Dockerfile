FROM centos
MAINTAINER Tim Green "iamtimgreen@gmail.com"
RUN curl https://raw.github.com/timgreen/docker-ldap/master/setup_ldap_centos.sh > /dev/shm/setup_ldap_centos.sh
RUN /bin/bash /dev/shm/setup_ldap_centos.sh
EXPOSE 636
EXPOSE 22
CMD ["/run.sh"]
