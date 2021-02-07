ARG ONEC_VERSION
FROM demoncat/onec:full-${ONEC_VERSION} as onec-full

ARG OSCRIPT_VERSION

RUN set -xe \
    && apt-get update \
    && apt-get install -y mono-complete mono-devel \
    && wget https://oscript.io/downloads/latest/x64/onescript-engine_${OSCRIPT_VERSION}_all.deb -O oscript.deb \
    && dpkg -i oscript.deb \
    && rm oscript.deb 

COPY src/ /app

RUN cd /app \
    && opm install -l

FROM evilbeaver/oscript-web:dev
COPY --from=onec-full /opt/1C/v8.3/x86_64 /opt/1C/v8.3/x86_64
COPY --from=onec-full /app /app

# Временное решение, до закрытия - https://github.com/EvilBeaver/OneScript.Web/pull/82
ENTRYPOINT ["/var/osp.net/artifact/core/linux-x64/OneScript.WebHost"]