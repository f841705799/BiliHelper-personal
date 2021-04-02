FROM php:alpine

MAINTAINER zsnmwy <szlszl35622@gmail.com>

ENV USER_NAME='' \
    USER_PASSWORD='' \
    CONIFG_PATH='/app/conf/user.conf' \
    Green="\\033[32m" \
    Red="\\033[31m" \
    GreenBG="\\033[42;37m" \
    RedBG="\\033[41;37m" \
    Font="\\033[0m" \
    Green_font_prefix="\\033[32m" \
    Green_background_prefix="\\033[42;37m" \
    Font_color_suffix="\\033[0m" \
    Info="${Green}[信息]${Font}" \
    OK="${Green}[OK]${Font}" \
    Error="${Red}[错误]${Font}"

WORKDIR /app

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN docker-php-ext-install sockets

RUN apk add --no-cache git && \
    git clone https://github.com.cnpmjs.org/lkeme/BiliHelper-personal.git --depth=1 /app && \
    php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php composer.phar install && \
    rm -r /var/cache/apk && \
    rm -r /usr/share/man

ENTRYPOINT echo -e "\n ======== \n ${Info} ${GreenBG} 正使用 git pull 同步项目 ${Font} \n ======== \n" && \
    git pull && \
    echo -e "\n ======== \n ${Info} ${GreenBG} 安装/更新 项目运行依赖 ${Font} \n ======== \n" && \
    php composer.phar install && \
    echo -e "\n \n \n \n" && \
    if [[ -f ${CONIFG_PATH} ]]; then echo -e "\n ======== \n ${GreenBG} 正在使用外部配置文件 ${Font} \n ======== \n" && php index.php ; else echo -e "${OK} ${GreenBG} 正在使用传入的环境变量进行用户配置。\n 如果需要配置更多选择项，请通过挂载配置文件来传入。具体参考项目中的README。\n https://github.com/lkeme/BiliHelper-personal.git ${Font} \n ======== \n " && cp /app/conf/user.conf.example /app/conf/user.conf && sed -i ''"$(cat /app/conf/user.conf -n | grep "APP_USER=" | awk '{print $1}')"'c '"$(echo "APP_USER=${USER_NAME}")"'' ${CONIFG_PATH} && sed -i ''"$(cat /app/conf/user.conf -n | grep "APP_PASS=" | awk '{print $1}')"'c '"$(echo "APP_PASS=${USER_PASSWORD}")"'' ${CONIFG_PATH} && php index.php; fi
