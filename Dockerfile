FROM golang:alpine AS builder

# 安装所需的软件包
RUN apk update && apk add --no-cache git

# 克隆NEXTTRACE源代码并编译
WORKDIR /build
RUN git clone https://github.com/nxtrace/Ntrace-core.git . && \
    go clean -modcache && \
    go mod download && \
    go build -o nexttrace .

FROM ubuntu:22.04

ENV TEST_HOST 0.0.0.0

# 安装所需的软件包
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 安装Python依赖包
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# 从构建阶段复制NEXTTRACE二进制文件到最终镜像
COPY --from=builder /build/nexttrace /usr/local/bin/nexttrace
RUN chmod +x /usr/local/bin/nexttrace

# 复制应用程序文件
COPY app.py /app/app.py

# 复制templates和assets文件夹
COPY templates /app/templates
COPY assets /app/assets

# 设置工作目录
WORKDIR /app

EXPOSE 35000

CMD ["python3", "-u", "app.py"]
