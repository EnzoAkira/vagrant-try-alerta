#!/bin/sh -ex

wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
apt-get -y update
apt-get -y upgrade
apt-get -y install default-jre
update-ca-certificates -f

apt-get -y install elasticsearch kibana logstash

echo "-Xms512m" >> /etc/elasticsearch/jvm.options
echo "-Xmx512m" >> /etc/elasticsearch/jvm.options

systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service

systemctl enable kibana.service
systemctl start kibana.service

wget -qO /etc/logstash/conf.d/logstash.conf https://raw.githubusercontent.com/alerta/kibana-alerta/master/logstash.conf
systemctl enable logstash.service
systemctl start logstash.service

cat >>/etc/alertad.conf << EOF
PLUGINS = ['reject','logstash']
LOGSTASH_HOST = 'localhost'
LOGSTASH_PORT = 1514
EOF

apachectl restart
