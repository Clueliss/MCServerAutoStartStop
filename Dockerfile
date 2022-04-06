FROM rustlang/rust:nightly-bullseye-slim AS builder
WORKDIR /usr/src/systemd-query-rest
COPY systemd-query-rest ./
RUN cargo build --release


FROM jrei/systemd-debian:11

EXPOSE 25565/tcp
EXPOSE 25565/udp
EXPOSE 8000/tcp

VOLUME ["/opt/mcserv", "/sys/fs/cgroup", "/tmp", "/run"]

RUN apt-get update && apt-get install openjdk-17-jre-headless -y

COPY scripts/* /usr/local/bin/
COPY systemd-units/* /etc/systemd/system/
COPY --from=builder /usr/src/systemd-query-rest/deploy/* /etc/systemd/system/
COPY --from=builder /usr/src/systemd-query-rest/target/release/systemd-query-rest /usr/local/bin/systemd-query-rest

RUN chmod +x /usr/local/bin/mcserv-* && chmod +x /usr/local/bin/systemd-query-rest

RUN systemctl enable mcserv.socket && systemctl enable systemd-query-rest.service
