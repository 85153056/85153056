# 85153056
red = ' \ 033 [0; 31m '
绿色= ' \ 033 [0; 32米'
黄色= ' \ 033 [0; 33米'
plain = ' \ 033 [0m '

os = ' ossystem '
密码= ' kexuesw.com '
port = ' 1024 '
libsodium_file = “ libsodium-1.0.16 ”
libsodium_url = “ https://github.com/jedisct1/libsodium/releases/download/1.0.16/libsodium-1.0.16.tar.gz ”

fly_dir = “ $（ cd  ” $（ dirname “ $ {BASH_SOURCE [0]} ” ） “  &&  pwd  ） ”

kernel_ubuntu_url = “ http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.10.2/linux-image-4.10.2-041002-generic_4.10.2-041002.201703120131_amd64.deb ”
kernel_ubuntu_file = “ linux-image-4.10.2-041002-generic_4.10.2-041002.201703120131_amd64.deb ”

usage（）{
        cat $ fly_dir / sshelp
}

DIR = ` PWD `

wrong_para_prompt（）{
    echo -e “ [ $ {red}错误$ {plain} ]参数输入错误！$ 1 ”
}

install_ss（）{
        如果 [[ “ $＃”  -lt 1]]
        然后
          wrong_para_prompt “请输入至少一个参数作为密码”
          返回 1
        科幻
        密码= $ 1
        如果 [[ “ $＃”-  ge 2]]
        然后
          端口= $ 2
        科幻
        如果 [[ $ port  -le 0 ||  $ port  -gt 65535]]
        然后
          wrong_para_prompt “端口号输入格式错误，请输入1到65535 ”
          出口 1
        科幻
        check_os
        check_dependency
        download_files
        ps -ef | grep -v grep | grep -i “ ssserver ”  > / dev / null 2>＆1
        如果 [ $？ -eq 0] ;  然后
                ssserver -c /etc/shadowsocks.json -d stop
        科幻
        generate_config $ password  $ port
        如果 [ $ {os}  ==  ' centos ' ]
        然后
                firewall_set
        科幻
        安装
        清理
}

uninstall_ss（）{
        读 -p “确定要卸载ss吗？（y / n）：”选项
        [ -z  $ {option} ] && option = “ n ”
        如果 [ “ $ {option} ”  ==  “ y ” ] || [ “ $ {option} ”  ==  “ Y ” ]
        然后
                ps -ef | grep -v grep | grep -i “ ssserver ”  > / dev / null 2>＆1
                如果 [ $？ -eq 0] ;  然后
                        ssserver -c /etc/shadowsocks.json -d stop
                科幻
                案例 $ os  in
                        ' ubuntu ' | ' debian '）
                                update-rc.d -f ss-fly删除
                                ;;
                        ' centos '）
                                chkconfig --del ss-fly
                                ;;
                ESAC
                rm -f /etc/shadowsocks.json
                rm -f /var/run/shadowsocks.pid
                rm -f /var/log/shadowsocks.log
                如果 [ -f /usr/local/shadowsocks_install.log] ;  然后
                        cat /usr/local/shadowsocks_install.log | xargs rm -rf
                科幻
                回声 “ ss卸载成功！”
        其他
                回声
                回声 “卸载取消”
        科幻
}

install_bbr（）{
	[[ -d  “ / proc / vz ” ]] &&  echo -e “ [ $ {red}错误$ {plain} ]你的系统是OpenVZ架构的，不支持开启BBR。”  &&  exit 1
	check_os
	check_bbr_status
	如果 [ $？ -eq 0]
	然后
		echo -e “ [ $ {green}提示$ {plain} ] TCP BBR加速已经开启成功。”
		退出 0
	科幻
	check_kernel_version
	如果 [ $？ -eq 0]
	然后
		echo -e “ [ $ {green}提示$ {plain} ]你的系统版本高于4.9，直接开启BBR加速。”
		sysctl_config
		echo -e “ [ $ {green}提示$ {plain} ] TCP BBR加速开启成功”
		退出 0
	科幻
	    
	如果 [[x “ $ {os} ”  == x “ centos ” ]] ;  然后
        	install_elrepo
        	yum --enablerepo = elrepo-kernel -y安装kernel-ml kernel-ml-devel
        	如果 [ $？ -ne 0] ;  然后
            		echo -e “ [ $ {red}错误$ {plain} ]安装内核失败，请自行检查。”
            		出口 1
        	科幻
    	elif [[x “ $ {os} ”  == x “ debian ”  ||）x “ $ {os} ”  == x “ ubuntu ” ]] ;  然后
        	[[ ！！ -e  “ / usr / bin / wget ” ]] && apt-get -y update && apt-get -y install wget
        	＃ get_latest_version
        	＃ [$？-ne 0] && echo -e“[$ {red}错误$ {plain}]获取最新内核版本失败，请检查网络”&& exit 1
       		 ＃ wget的-C-T3 -T60 -O $ {deb_kernel_name} $ {} deb_kernel_url
        	＃if [$？-ne 0]; 然后
            	＃ 	回波-e “[$ {红色}错误$ {平原}]下载$ {deb_kernel_name}失败，请自行检查”。
            	＃ 	出口1
       		＃网络
        	＃ dpkg -i来$ {} deb_kernel_name
        	＃ RM -fv $ {} deb_kernel_name
		wget $ {kernel_ubuntu_url}
		如果 [ $？ -ne 0]
		然后
			echo -e “ [ $ {red}错误$ {plain} ]下载内核失败，请自行检查。”
			出口 1
		科幻
		dpkg -i $ {kernel_ubuntu_file}
    	其他
       	 	回声 -e “ [ $ {红色}错误$ {平原} ]脚本不支持该操作系统，请修改系统为的CentOS /于Debian / Ubuntu。 ”
        	出口 1
    	科幻

    	install_config挂载
    	sysctl_config
    	reboot_os
}

install_ssr（）{
	wget  - 无检查证书https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocksR.sh
	chmod + x shadowsocksR.sh
	./shadowsocksR.sh 2>＆1  | tee shadowsocksR.log
}

check_os_（）{
        源 / etc / os-release
	本地 os_tmp = $（ echo $ ID  | tr [AZ] [az] ）
        事例 $ os_tmp  中
                Ubuntu的| debian的）
                os = ' ubuntu '
                ;;
                CentOS的）
                os = ' centos '
                ;;
                *）
                echo -e “ [ $ {red}错误$ {plain} ]本脚本暂时只支持Centos / Ubuntu / Debian系统，如需用本本本，请先修改你的系统类型”
                出口 1
                ;;
        ESAC
}

check_os（）{
    如果 [[ -f / etc / redhat-release]] ;  然后
        os = “ centos ”
    elif cat / etc / issue | grep -Eqi “ debian ” ;  然后
        os = “ debian ”
    elif cat / etc / issue | grep -Eqi “ ubuntu ” ;  然后
        os = “ ubuntu ”
    elif cat / etc / issue | grep -Eqi “ centos | red hat | redhat ” ;  然后
        os = “ centos ”
    elif cat / proc / version | grep -Eqi “ debian ” ;  然后
        os = “ debian ”
    elif cat / proc / version | grep -Eqi “ ubuntu ” ;  然后
        os = “ ubuntu ”
    elif cat / proc / version | grep -Eqi “ centos | red hat | redhat ” ;  然后
        os = “ centos ”
    科幻
}

check_bbr_status（）{
    local param = $（ sysctl net.ipv4.tcp_available_congestion_control | awk ' {print $ 3} '）
    if [[x “ $ {param} ”  == x “ bbr ” ]] ;  然后
        返回 0
    其他
        返回 1
    科幻
}

version_ge（）{
    测试 “ $（ echo ” $ @ “  | tr ”  “  ” \ n “  | sort -rV | head -n 1 ） ” == “ $ 1 ”
}

check_kernel_version（）{
    本地 kernel_version = $（ uname -r | cut -d- -f1 ）
    如果 version_ge $ {kernel_version} 4.9 ;  然后
        返回 0
    其他
        返回 1
    科幻
}

sysctl_config（）{
    sed -i '/ net.core.default_qdisc/d '/ etc/ sysctl.conf
    sed -i '/ net.ipv4.tcp_congestion_control/d '/ etc/ sysctl.conf
    echo  “ net.core.default_qdisc = fq ”  >> /etc/sysctl.conf
    echo  “ net.ipv4.tcp_congestion_control = bbr ”  >> /etc/sysctl.conf
    sysctl -p > / dev / null 2>＆1
}

install_elrepo（）{
    如果 centosversion 5 ;  然后
        echo -e “ [ $ {red}错误$ {plain} ]脚本不支持CentOS 5. ”
        出口 1
    科幻

    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

    如果 centosversion 6 ;  然后
        rpm -Uvh http://www.elrepo.org/elrepo-release-6-8.el6.elrepo.noarch.rpm
    elif centosversion 7 ;  然后
        rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
    科幻

    如果 [ ！ -f /etc/yum.repos.d/elrepo.repo] ;  然后
        echo -e “ [ $ {red}错误$ {plain} ]安装elrepo失败，请自行检查。”
        出口 1
    科幻
}

get_latest_version（）{

    latest_version = $（ wget -qO- http://kernel.ubuntu.com/~kernel-ppa/mainline/ | awk -F ' \“v '  ' /  v [ 4-9 ] ./{print $ 2} ' | cut -d / -f1 | grep -v  -   | sort -V | tail -1 ）

    [ -z  $ {latest_version} ] &&  返回 1

    如果 [[ ` getconf WORD_BIT `  ==  “ 32 ”  &&  ` getconf LONG_BIT `  ==  “ 64 ” ] ;  然后
        deb_name = $（ wget -qO- http://kernel.ubuntu.com/~kernel-ppa/mainline/v $ {latest_version} / | grep “ linux-image ”  | grep “ generic ”  | awk -F ' \“ > '  '/ amd64.deb/{print $ 2} '  | cut -d ' < '- f1 | head -1 ）
        deb_kernel_url = “ http://kernel.ubuntu.com/~kernel-ppa/mainline/v $ {latest_version} / $ {deb_name} ”
        deb_kernel_name = “ linux-image- $ {latest_version} -amd64.deb ”
    其他
        deb_name = $（ wget -qO- http://kernel.ubuntu.com/~kernel-ppa/mainline/v $ {latest_version} / | grep “ linux-image ”  | grep “ generic ”  | awk -F ' \“ > '  '/ i386.deb/{print $ 2} '  | cut -d ' < '- f1 | head -1 ）
        deb_kernel_url = “ http://kernel.ubuntu.com/~kernel-ppa/mainline/v $ {latest_version} / $ {deb_name} ”
        deb_kernel_name = “ linux-image- $ {latest_version} -i386.deb ”
    科幻

    [ ！ -z  $ {deb_name} ] &&  return 0 ||  返回 1
}

get_opsy（）{
    [ -f / etc / redhat-release] && awk ' {print（$ 1，$ 3〜/ ^ [0-9] /？$ 3：$ 4）} ' / etc / redhat-release &&  return
    [ -f / etc / os-release] && awk -F ' [=“] '  ' / PRETTY_NAME / {print $ 3，$ 4，$ 5} ' / etc / os-release &&  return
    [ -f / etc / lsb-release] && awk -F ' [=“] + '  ' / DESCRIPTION / {print $ 2} ' / etc / lsb-release &&  return
}

opsy = $（ get_opsy ）
arch = $（ uname -m ）
lbit = $（ getconf LONG_BIT ）
kern = $（ uname -r ）

check_dependency（）{
        案例 $ os  in
                ' ubuntu ' | ' debian '）
                apt-get -y更新
                apt-get -y安装python python-dev python-setuptools openssl libssl-dev curl wget unzip gcc automake autoconf make libtool
                ;;
                ' centos '）
                yum install -y python python-devel python-setuptools openssl openssl-devel curl wget unzip gcc automake autoconf make libtool
        ESAC
}

install_config（）{
    如果 [[x “ $ {os} ”  == x “ centos ” ]] ;  然后
        如果 centosversion 6 ;  然后
            如果 [ ！ -f  “ /boot/grub/grub.conf ” ] ;  然后
                echo -e “ [ $ {red}错误$ {plain} ]没有找到/boot/grub/grub.conf文件。”
                出口 1
            科幻
            SED -i ' S / ^默认=。* /默认= 0 /克' /boot/grub/grub.conf文件
        elif centosversion 7 ;  然后
            如果 [ ！ -f  “ /boot/grub2/grub.cfg ” ] ;  然后
                echo -e “ [ $ {red}错误$ {plain} ]没有找到/boot/grub2/grub.cfg文件。”
                出口 1
            科幻
            grub2-set-default 0
        科幻
    elif [[x “ $ {os} ”  == x “ debian ”  ||）x “ $ {os} ”  == x “ ubuntu ” ]] ;  然后
        / usr / sbin目录/更新，蛴螬
    科幻
}

reboot_os（）{
    回声
    echo -e “ [ $ {green}提示$ {plain} ]系统需要重启BBR才能生效。”
    read -p “是否立马重启[y / n] ” is_reboot
    如果 [[ $ {is_reboot}  ==  “ y ”  ||） $ {is_reboot}  ==  “ Y ” ]] ;  然后
        重启
    其他
        echo -e “ [ $ {green}提示$ {plain} ]取消重启。其自行执行reboot命令。”
        退出 0
    科幻
}

download_files（）{
        如果 ！wget  - 无检查证书-O $ {libsodium_file} .tar.gz $ {libsodium_url}
        然后
                echo -e “ [ $ {red}错误$ {plain} ]下载$ {libsodium_file} .tar.gz失败！”
                出口 1
        科幻
        如果 ！wget  - 无检查证书-O shadowsocks-master.zip https://github.com/shadowsocks/shadowsocks/archive/master.zip
        然后
                echo -e “ [ $ {red}错误$ {plain} ] shadowsocks安装包文件下载失败！”
                出口 1
        科幻
}

generate_config（）{
    cat > /etc/shadowsocks.json << - EOF
{
    “服务器”： “0.0.0.0”，
    “SERVER_PORT”：$ 2，
    “local_address”： “127.0.0.1”，
    “LOCAL_PORT”：1080，
    “密码”： “$ 1”，
    “超时”：300，
    “方法”： “AES-256-CFB”，
    “fast_open”：假的
}
EOF
}

firewall_set（）{
    echo -e “ [ $ {green}信息$ {plain} ]正在设置防火墙... ”
    如果 centosversion 6 ;  然后
        /etc/init.d/iptables status > / dev / null 2>＆1
        如果 [ $？ -eq 0] ;  然后
            iptables -L -n | grep -i $ {port}  > / dev / null 2>＆1
            如果 [ $？ -ne 0] ;  然后
                iptables -I INPUT -m状态 - 状态新-m tcp -p tcp --dport $ {端口} -j ACCEPT
                iptables -I INPUT -m状态 - 状态新-m udp -p udp --dport $ {端口} -j ACCEPT
                /etc/init.d/iptables保存
                /etc/init.d/iptables重启
            其他
                echo -e “ [ $ {green}信息$ {plain} ] port $ {port}已经开放。”
            科幻
        其他
            echo -e “ [ $ {yellow}警告$ {plain} ]防火墙（iptables）好像已经停止或没有安装，如有需要请手动关闭防火墙。”
        科幻
    elif centosversion 7 ;  然后
        systemctl status firewalld > / dev / null 2>＆1
        如果 [ $？ -eq 0] ;  然后
            firewall-cmd --permanent --zone = public --add-port = $ {port} / tcp
            firewall-cmd --permanent --zone = public --add-port = $ {port} / udp
            firewall-cmd --reload
        其他
            echo -e “ [ $ {yellow}警告$ {plain} ]防火墙（iptables）好像已经停止或没有安装，如有需要请手动关闭防火墙。”
        科幻
    科幻
    echo -e “ [ $ {green}信息$ {plain} ]防火墙设置成功。”
}

centosversion（）{
    如果 [ $ {os}  ==  ' centos ' ]
    然后
        本地代码= $ 1
        本地版本= “ $（ getversion ） ”
        本地 main_ver = $ {version %%。* }
        如果 [ “ $ main_ver ”  ==  “ $ code ” ] ;  然后
            返回 0
        其他
            返回 1
        科幻
    其他
        返回 1
    科幻
}

getversion（）{
    如果 [[ -s / etc / redhat-release]] ;  然后
        grep -oE   “ [0-9。] + ” / etc / redhat-release
    其他
        grep -oE   “ [0-9。] + ” / etc / issue
    科幻
}

install（）{
        如果 [ ！ -f /usr/lib/libsodium.a]
        然后 
                cd  $ {DIR}
                tar zxf $ {libsodium_file} .tar.gz
                cd  $ {libsodium_file}
                ./configure --prefix = / usr && make && make install
                如果 [ $？ -ne 0]
                然后 
                        echo -e “ [ $ {red}错误$ {plain} ] libsodium安装失败！”
                        清理
                出口 1  
                科幻
        科幻      
        LDCONFIG
        
        cd  $ {DIR}
        解压缩-q shadowsocks-master.zip
        如果 [ $？ -ne 0]
        然后 
                echo -e “ [ $ {red}错误$ {plain} ]解压缩失败，请检查unzip命令”
                清理
                出口 1
        科幻      
        cd  $ {DIR} / shadowsocks-master
        python setup.py install  - 记录/usr/local/shadowsocks_install.log
        如果 [ -f / usr / bin / ssserver] || [ -f / usr / local / bin / ssserver]
        然后 
                cp $ fly_dir / ss-fly /etc/init.d/
                chmod + x /etc/init.d/ss-fly
                案例 $ os  in
                        ' ubuntu ' | ' debian '）
                                update-rc.d ss-fly默认值
                                ;;
                        ' centos '）
                                chkconfig --add ss-fly
                                chkconfig ss-fly
                                ;;
                ESAC            
                ssserver -c /etc/shadowsocks.json -d start
        其他    
                echo -e “ [ $ {red}错误$ {plain} ] ss服务器安装失败，请联系QQ85153056（https://www.kexuesw.com）”
                清理
                出口 1
        科幻      
        echo -e “ [ $ {green}成功$ {plain} ]安装成功尽情冲浪！”
        echo -e “你的服务器地址（IP）：\ 033 [41; 37m $（ get_ip ） \ 033 [0m ”
        echo -e “你的密码：\ 033 [41; 37m $ {password} \ 033 [0m ”
        echo -e “你的端口：\ 033 [41; 37m $ {port} \ 033 [0m ”
        echo -e “你的加密方式：\ 033 [41; 37m aes-256-cfb \ 033 [0m ”
        echo -e “欢迎访问www.kexuesw.com：\ 033 [41; 37m https://www.kexuesw.com \ 033 [0m ”                   
}

清理（）{
        cd  $ {DIR}
        rm -rf shadowsocks-master.zip shadowsocks-master $ {libsodium_file} .tar.gz $ {libsodium_file}
}

get_ip（）{
    local IP = $（ ip addr | egrep -o ' [0-9] {1,3} \。[0-9] {1,3} \。[0-9] {1,3} \。[0 -9] {1,3} '  | egrep -v “ ^ 192 \ .168 | ^ 172 \ .1 [6-9] \。| ^ 172 \ .2 [0-9] \。| ^ 172 \。 3 [0-2] \。| ^ 10 \。| ^ 127 \。| ^ 255 \。| ^ 0 \。“  | head -n 1 ）
    [ -z  $ {IP} ] && IP = $（ wget -qO- -t1 -T2 ipv4.icanhazip.com ）
    [ -z  $ {IP} ] && IP = $（ wget -qO- -t1 -T2 ipinfo.io/ip ）
    [ ！ -z  $ {IP} ] &&  echo  $ {IP}  ||  回声
}

if [ “ $＃”-  eq 0] ;  然后
	用法
	退出 0
科幻

案例 $ 1  中
	-h | h | help）
		用法
		退出 0 ;
		;;
	-v | v | version）
		回声 ' SS1.0版，二零一八年五月十日，版权（C）2018 www.kexuesw.com '
		退出 0 ;
		;;
ESAC

如果 [ “ $ EUID ”  -ne 0] ;  然后
	echo -e “ [ $ {red}错误$ {plain} ]必需以root身份运行，请使用sudo命令”
	出口 1 ;
科幻

案例 $ 1  中
	-i | i | install）
        	install_ss $ 2  $ 3
		;;
        -bbr）
        	install_bbr
                ;;
        -ssr）
        	install_ssr
                ;;
	-卸载 ）
		uninstall_ss
		;;
	*）
		用法
		;;
ESAC
