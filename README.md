
# gateway-hivemq-ce

## Build Docker Image

    docker build -t gateway-hivemq-ce .
## Run as Daemon
To execute this image, simply run the following command:

    docker run --restart always --name gateway-hivemq-ce -d --ulimit nofile=500000:500000 -p 8883:8883 -p 8443:8443 allxon/gateway-hivemq-ce:latest
To replace the default keystore/truststore you can mount the file path of `hivemq.jks` to volume `/opt/hivemq/certs` when running the container:

    docker run --restart always --name gateway-hivemq-ce -d --ulimit nofile=500000:500000 -v /path/to/jks:/opt/hivemq/certs -p 8883:8883 -p 8443:8443 allxon/gateway-hivemq-ce:latest
To change the default Java heap size you can set the environment variable `JAVA_OPTS` when running the container:

    docker run --restart always --name gateway-hivemq-ce -d -e JAVA_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseNUMA -XX:+ExitOnOutOfMemoryError -Xms512M -Xmx1024M" --ulimit nofile=500000:500000 -p 8883:8883 -p 8443:8443 allxon/gateway-hivemq-ce:latest

## Generate Client Certificate
To create the client certificate PEM files `client.pem` and `client.key`:

    openssl req -nodes -x509 -newkey rsa:2048 -keyout client.key -out client.pem -days 12000

## Create Server Keystore
To create the server keystore `hivemq.jks`, simply run the following command:

NOTE: The first question about the first and last name is the so-called common name. This common name should match the server address.


    keytool -genkey -keyalg RSA -alias hivemq -keystore hivemq.jks -storepass hivemq -validity 12000 -keysize 2048
    What is your first and last name?
      [Unknown]:  hivemq.local
    What is the name of your organizational unit?
      [Unknown]:  hivemq
    What is the name of your organization?
      [Unknown]:  hivemq
    What is the name of your City or Locality?
      [Unknown]:  Landshut
    What is the name of your State or Province?
      [Unknown]:  Bavaria
    What is the two-letter country code for this unit?
      [Unknown]:  DE
    Is CN=hivemq.local, OU=hivemq, O=hivemq, L=Landshut, ST=Bavaria, C=DE correct?
      [no]:  yes

    Generating 2,048 bit RSA key pair and self-signed certificate (SHA256withRSA) with a validity of 12,000 days
      for: CN=hivemq.local, OU=hivemq, O=hivemq, L=Landshut, ST=Bavaria, C=DE

To export the server certificate PEM file `hivemq.pem` from the keystore:

    keytool -exportcert -alias hivemq -keystore hivemq.jks -rfc -file hivemq.pem
    Enter keystore password:
    Certificate stored in file <hivemq.pem>

## Create Server Truststore
To import the client certificate to truststore `hivemq-trust-store.jks`:

    openssl x509 -outform der -in client.pem -out client.crt
    keytool -import -file client.crt -alias client -keystore hivemq-trust-store.jks -storepass hivemq

## Connect to MQTT Broker
Map the IP address of the broker to hostname `hivemq.local` in `/etc/hosts`

    echo "127.0.0.1 hivemq.local" >> /etc/hosts
Test connect with MQTT protocol via port 8883

    docker run -v /path/to/certs:/tmp --network host hivemq/mqtt-cli sub -V 3 -t topic -q 1 -h hivemq.local -p 8883 -i client --cafile=/tmp/hivemq.pem --client-cert=/tmp/client.pem --key=/tmp/client.key -d

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

    docker run -v /path/to/certs:/tmp --network host hivemq/mqtt-cli sub -V 3 -ws -ws:path="/mqtt" -t topic -q 1 -h hivemq.local -p 8443 -i client --cafile=/tmp/hivemq.pem --client-cert=/tmp/client.pem --key=/tmp/client.key -d

    Restriction request problem information was set but is unused in MQTT Version MQTT_3_1_1
    Client 'client@hivemq.local' sending CONNECT
        MqttConnect{keepAlive=60, cleanSession=true, restrictions=MqttConnectRestrictions{receiveMaximum=65535, sendMaximum=65535, maximumPacketSize=268435460, sendMaximumPacketSize=268435460, topicAliasMaximum=0, sendTopicAliasMaximum=16, requestProblemInformation=true, requestResponseInformation=false}}
    Client 'client@hivemq.local' received CONNACK
        MqttConnAck{returnCode=SUCCESS, sessionPresent=false}
    Client 'client@hivemq.local' sending SUBSCRIBE
        MqttSubscribe{subscriptions=[MqttSubscription{topicFilter=topic, qos=AT_LEAST_ONCE}]}
    Client 'client@hivemq.local' received SUBACK
        MqttSubAck{returnCodes=[SUCCESS_MAXIMUM_QOS_1]}