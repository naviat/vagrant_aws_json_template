#!/bin/bash -       
#description  :Provision script for starting the morecast-api on vagrant, starts all needed services
#author       :rsalzer
#date         :20151015
#=======================================================================================================================

########################################################################################################################
################################################# lets get se party started ############################################
########################################################################################################################
killall python
killall uwsgi
service nginx restart
/bin/bash /usr/share/vagrant/startup/start_morecast_api.sh &
/bin/bash /usr/share/vagrant/startup/start_dataserver.sh &
/bin/bash /usr/share/vagrant/startup/start_timezone_api.sh &
