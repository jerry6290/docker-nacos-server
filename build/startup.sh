#!/bin/sh
set -x
export CUSTOM_SEARCH_LOCATIONS=file:${BASE_DIR}/conf/
export CUSTOM_SEARCH_NAMES="application,custom"

#===========================================================================================
# JVM Configuration
#===========================================================================================
if [[ "${MODE}" == "standalone" ]]; then
    JAVA_OPT="${JAVA_OPT} -Xms512m -Xmx512m -Xmn256m"
    JAVA_OPT="${JAVA_OPT} -Dnacos.standalone=true"
else
  JAVA_OPT="${JAVA_OPT} -server -Xms${JVM_XMS} -Xmx${JVM_XMX} -Xmn${JVM_XMN} -XX:MetaspaceSize=${JVM_MS} -XX:MaxMetaspaceSize=${JVM_MMS}"
  if [[ "${NACOS_DEBUG}" == "y" ]]; then
    JAVA_OPT="${JAVA_OPT} -Xdebug -Xrunjdwp:transport=dt_socket,address=9555,server=y,suspend=n"
  fi
  JAVA_OPT="${JAVA_OPT} -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${BASE_DIR}/logs/java_heapdump.hprof"
  JAVA_OPT="${JAVA_OPT} -XX:-UseLargePages"
fi

#===========================================================================================
# Setting system properties
#===========================================================================================
# set  mode that Nacos Server function of split
if [[ "${FUNCTION_MODE}" == "config" ]]; then
    JAVA_OPT="${JAVA_OPT} -Dnacos.functionMode=config"
elif [[ "${FUNCTION_MODE}" == "naming" ]]; then
    JAVA_OPT="${JAVA_OPT} -Dnacos.functionMode=naming"
fi
# set nacos server ip
if [[ ! -z "${NACOS_SERVER_IP}" ]]; then
    JAVA_OPT="${JAVA_OPT} -Dnacos.server.ip=${NACOS_SERVER_IP}"
fi

if [[ ! -z "${USE_ONLY_SITE_INTERFACES}" ]]; then
    JAVA_OPT="${JAVA_OPT} -Dnacos.inetutils.use-only-site-local-interfaces=${USE_ONLY_SITE_INTERFACES}"
fi

if [[ ! -z "${PREFERRED_NETWORKS}" ]]; then
    JAVA_OPT="${JAVA_OPT} -Dnacos.inetutils.preferred-networks=${PREFERRED_NETWORKS}"
fi

if [[ ! -z "${IGNORED_INTERFACES}" ]]; then
    JAVA_OPT="${JAVA_OPT} -Dnacos.inetutils.ignored-interfaces=${IGNORED_INTERFACES}"
fi

if [[ "${PREFER_HOST_MODE}" == "hostname" ]]; then
    JAVA_OPT="${JAVA_OPT} -Dnacos.preferHostnameOverIp=true"
fi


JAVA_OPT="${JAVA_OPT} -Dnacos.home=${BASE_DIR}"
JAVA_OPT="${JAVA_OPT} -jar ${BASE_DIR}/target/nacos-server.jar"
JAVA_OPT="${JAVA_OPT} ${JAVA_OPT_EXT}"
JAVA_OPT="${JAVA_OPT} --spring.config.location=${CUSTOM_SEARCH_LOCATIONS}"
JAVA_OPT="${JAVA_OPT} --spring.config.name=${CUSTOM_SEARCH_NAMES}"
JAVA_OPT="${JAVA_OPT} --logging.config=${BASE_DIR}/conf/nacos-logback.xml"
JAVA_OPT="${JAVA_OPT} --server.max-http-header-size=524288"

echo "nacos is starting,you can check the ${BASE_DIR}/logs/start.out"
echo "$JAVA ${JAVA_OPT}" > ${BASE_DIR}/logs/start.out 2>&1 &
nohup $JAVA ${JAVA_OPT} > ${BASE_DIR}/logs/start.out 2>&1 < /dev/null
