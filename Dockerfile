FROM maven:3-eclipse-temurin-21 AS builder

WORKDIR /app

COPY . .

RUN mvn clean package -DskipTests \
    && cp target/oci-helper-*.jar /app/oci-helper.jar

FROM eclipse-temurin:21-jre-jammy AS base-with-tools

ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    TZ=Asia/Shanghai

RUN apt update && \
    apt install -y --no-install-recommends openssh-client lsof curl locales && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /home/ocihelper/.ssh && \
    echo "Host *\n  HostKeyAlgorithms +ssh-rsa\n  PubkeyAcceptedKeyTypes +ssh-rsa" > /home/ocihelper/.ssh/config && \
    chmod 700 /home/ocihelper/.ssh && chmod 600 /home/ocihelper/.ssh/config && \
    locale-gen zh_CN.UTF-8 && \
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

FROM base-with-tools

ENV OCI_HELPER_VERSION=3.5.0

# 安全修复：创建非 root 用户运行应用
RUN groupadd -r ocihelper && useradd -r -g ocihelper -m -d /home/ocihelper -s /bin/bash ocihelper

WORKDIR /app/oci-helper

COPY --from=builder /app/oci-helper.jar .

# 确保目录权限正确
RUN chown -R ocihelper:ocihelper /app/oci-helper && \
    mkdir -p /var/log && touch /var/log/oci-helper.log && \
    chown ocihelper:ocihelper /var/log/oci-helper.log

EXPOSE 8818

CMD exec java \
    --add-opens java.base/java.net=ALL-UNNAMED \
    --add-opens java.base/sun.net.www.protocol.https=ALL-UNNAMED \
    -jar oci-helper.jar | tee -a /var/log/oci-helper.log

# 切换到非 root 用户
USER ocihelper
