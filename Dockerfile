FROM alpine:3 AS extensions
WORKDIR /extensions
ADD https://www.hivemq.com/releases/extensions/hivemq-deny-wildcard-extension-4.1.2.zip .
ADD https://www.hivemq.com/releases/extensions/hivemq-mqtt-message-log-extension-1.1.3.zip .
RUN apk add --no-cache -U unzip
RUN unzip hivemq-deny-wildcard-extension-4.1.2.zip
RUN unzip hivemq-mqtt-message-log-extension-1.1.3.zip

FROM hivemq/hivemq-ce:2024.3
COPY --from=extensions /extensions/hivemq-deny-wildcard-extension /opt/hivemq/extensions/hivemq-deny-wildcard-extension
COPY --from=extensions /extensions/hivemq-mqtt-message-log-extension /opt/hivemq/extensions/hivemq-mqtt-message-log-extension
COPY --chown=hivemq:hivemq conf/* /opt/hivemq/conf/
COPY --chown=hivemq:hivemq certs/* /opt/hivemq/certs/

ENV JAVA_OPTS "-XX:+UnlockExperimentalVMOptions -XX:+UseNUMA -Xmx512M -Xms512M -XX:+ExitOnOutOfMemoryError"

VOLUME /opt/hivemq/certs

EXPOSE 8883/tcp
EXPOSE 8443/tcp
