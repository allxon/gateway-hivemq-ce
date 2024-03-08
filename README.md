
# gateway-hivemq-ce

## Build Docker Image

    docker build -t gateway-hivemq-ce .
## Run as Daemon
To execute this image, simply run the following command:

    docker run --restart always --name gateway-hivemq-ce -d --ulimit nofile=500000:500000 -p 8883:8883 -p 8443:8443 allxon/gateway-hivemq-ce:latest
To replace the default keystore/truststore you can mount the file path of hivemq.jks to volume `/opt/hivemq/certs` when running the container:

    docker run --restart always --name gateway-hivemq-ce -d --ulimit nofile=500000:500000 -v /path/to/jks:/opt/hivemq/certs -p 8883:8883 -p 8443:8443 allxon/gateway-hivemq-ce:latest
To change the default Java heap size you can set the environment variable `JAVA_OPTS` when running the container:

    docker run --restart always --name gateway-hivemq-ce -d -e JAVA_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseNUMA -XX:+ExitOnOutOfMemoryError -Xms512M -Xmx1024M" --ulimit nofile=500000:500000 -p 8883:8883 -p 8443:8443 allxon/gateway-hivemq-ce:latest

## Connect to MQTT Broker
Map the IP address of the broker to hostname `hivemq.local` in `/etc/hosts`

    echo "127.0.0.1 hivemq.local" >> /etc/hosts
Test connect with MQTT protocol via port 8883

    docker run -v /path/to/certs:/tmp --network host hivemq/mqtt-cli sub -V 3 -t topic -q 1 -h hivemq.local -p 8883 -i client --cafile=/tmp/hivemq.pem --client-cert=/tmp/hivemq.pem --key=/tmp/hivemq.key -d

    Restriction request problem information was set but is unused in MQTT Version MQTT_3_1_1
    Client 'client@hivemq.local' sending CONNECT
        MqttConnect{keepAlive=60, cleanSession=true, restrictions=MqttConnectRestrictions{receiveMaximum=65535, sendMaximum=65535, maximumPacketSize=268435460, sendMaximumPacketSize=268435460, topicAliasMaximum=0, sendTopicAliasMaximum=16, requestProblemInformation=true, requestResponseInformation=false}}
    Client 'client@hivemq.local' received CONNACK
        MqttConnAck{returnCode=SUCCESS, sessionPresent=false}
    Client 'client@hivemq.local' sending SUBSCRIBE
        MqttSubscribe{subscriptions=[MqttSubscription{topicFilter=topic, qos=AT_LEAST_ONCE}]}
    Client 'client@hivemq.local' received SUBACK
        MqttSubAck{returnCodes=[SUCCESS_MAXIMUM_QOS_1]}

Test connect with Websocket protocol via port 8443

    docker run -v /path/to/certs:/tmp --network host hivemq/mqtt-cli sub -V 3 -ws -ws:path="/mqtt" -t topic -q 1 -h hivemq.local -p 8443 -i client --cafile=/tmp/hivemq.pem --client-cert=/tmp/hivemq.pem --key=/tmp/hivemq.key -d

    Restriction request problem information was set but is unused in MQTT Version MQTT_3_1_1
    Client 'client@hivemq.local' sending CONNECT
        MqttConnect{keepAlive=60, cleanSession=true, restrictions=MqttConnectRestrictions{receiveMaximum=65535, sendMaximum=65535, maximumPacketSize=268435460, sendMaximumPacketSize=268435460, topicAliasMaximum=0, sendTopicAliasMaximum=16, requestProblemInformation=true, requestResponseInformation=false}}
    Client 'client@hivemq.local' received CONNACK
        MqttConnAck{returnCode=SUCCESS, sessionPresent=false}
    Client 'client@hivemq.local' sending SUBSCRIBE
        MqttSubscribe{subscriptions=[MqttSubscription{topicFilter=topic, qos=AT_LEAST_ONCE}]}
    Client 'client@hivemq.local' received SUBACK
        MqttSubAck{returnCodes=[SUCCESS_MAXIMUM_QOS_1]}