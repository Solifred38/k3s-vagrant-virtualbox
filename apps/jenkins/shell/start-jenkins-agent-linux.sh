curl -sO http://192.168.10.200:8080/jnlpJars/agent.jar
java -jar agent.jar -url http://192.168.10.200:8080/ -secret 5c5e6872a497a821d700373dce1398e9416374d6a6b3d3244157c544ff79e62f -name "agent linux" -webSocket -workDir "/tmp/jenkins" &
echo "agent linux démarré"
