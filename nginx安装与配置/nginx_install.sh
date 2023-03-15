#!/bin/bash
#编译安装Nginx
nginx_install(){
#创建软件运行用户
groupadd -r nginx
useradd -r -g nginx nginx
#安装依赖
yum -y install gcc gcc-c++ pcre-devel zlib-devel openssl-devel
#编译安装
cd /root/soft
tar xvf nginx-1.22.1.tar.gz
cd nginx-1.22.1
./configure --prefix=/usr/local/nginx-1.22.1 --with-stream --with-stream_ssl_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_realip_module --with-http_sub_module --with-http_ssl_module --with-http_flv_module --with-http_mp4_module --with-pcre --user=nginx --group=nginx && make && make install
# 创建软连接
ln -s /usr/local/nginx-1.22.1 /usr/local/nginx
# 添加环境变量
echo "PATH=/usr/local/nginx/sbin:$PATH" >> ~/.bash_profile
source ~/.bash_profile
# 创建存放虚拟主机配置
mkdir /usr/local/nginx/vhosts

# add nginx log file logreotate configure
cat > /etc/logrotate.d/nginx <<EOF
/usr/local/nginx/logs/*.log {
    create 0664 nginx root
    daily
    rotate 10
    missingok
    notifempty
    compress
    sharedscripts
    postrotate
        /bin/kill -USR1 `cat /usr/local/nginx/logs/nginx.pid 2>/dev/null` 2>/dev/null || true
    endscript
}
EOF

# 创建nignx.service
cat > /usr/lib/systemd/system/nginx.service <<EOF
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
LimitNOFILE=65535
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

systemctl enable nginx

cat > /etc/sysctl.d/nginx.conf <<EOF
kernel.pid_max = 65535
vm.panic_on_oom = 0
fs.inotify.max_user_watches = 89100
fs.file-max = 52706963
fs.nr_open = 52706963
net.netfilter.nf_conntrack_max = 2310720
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_max_orphans = 327680
net.ipv4.tcp_orphan_retries = 3
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_max_syn_backlog = 262144
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 65535
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
net.core.rmem_default = 8388608
net.core.wmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_mem = 10240 87380 6291456
net.ipv4.tcp_rmem = 10240 87380 6291456
net.ipv4.tcp_wmem = 10240 87380 6291456
net.ipv4.ip_local_port_range = 1024   65530
net.nf_conntrack_max = 2097152
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 15
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 30
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 30
net.netfilter.nf_conntrack_tcp_timeout_established = 1200
EOF

sysctl -p /etc/sysctl.d/nginx.conf

cat > /etc/security/limits.conf <<EOF
* hard nofile 655360
* soft nofile 131072
* soft nproc 655350
* hard nproc 655350
* soft memlock unlimited
* hard memlock unlimited
EOF

}


#脚本开始时间
start_time=`date +%s`
#执行的脚本代码
nginx_install
#脚本结束时间
end_time=`date +%s`
#脚本执行花费时间
const_time=$((end_time-start_time))
echo 'Take time is: '$const_time's'
