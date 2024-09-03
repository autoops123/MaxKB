FROM 1panel/maxkb:v1.4.0 AS stage-build


FROM python:3.11-slim-bookworm

ARG DOCKER_IMAGE_TAG=dev \
    BUILD_AT \
    GITHUB_COMMIT

ENV MAXKB_VERSION="${DOCKER_IMAGE_TAG} (build at ${BUILD_AT}, commit: ${GITHUB_COMMIT})" \
    MAXKB_CONFIG_TYPE=ENV \
    MAXKB_DB_NAME=maxkb \
    MAXKB_DB_HOST=127.0.0.1 \
    MAXKB_DB_PORT=5432  \
    MAXKB_DB_USER=root \
    MAXKB_DB_PASSWORD=Password123@postgres \
    MAXKB_EMBEDDING_MODEL_NAME=/opt/maxkb/model/embedding/shibing624_text2vec-base-chinese \
    MAXKB_EMBEDDING_MODEL_PATH=/opt/maxkb/model/embedding

WORKDIR /opt/maxkb/app



COPY --from=stage-build /opt/maxkb /opt/maxkb
#COPY --from=stage-build /opt/py3 /opt/py3
#COPY --from=stage-build /opt/maxkb/app/model /opt/maxkb/model

RUN python3 -m venv /opt/py3 && \
    pip install poetry --break-system-packages && \
    poetry config virtualenvs.create false && \
    . /opt/py3/bin/activate

RUN rm -rf /opt/maxkb/app/apps && \
    rm -rf /opt/maxkb/app/installer

COPY apps /opt/maxkb/app/apps
COPY installer /opt/maxkb/app/installer


ENV LANG=en_US.UTF-8
ENV PATH=/opt/py3/bin:$PATH

ENV POSTGRES_USER=root
ENV POSTGRES_PASSWORD=Password123@postgres

RUN chmod 777 /opt/maxkb/app/installer/run-maxkb.sh && \
    cp -r /opt/maxkb/model/base/hub /opt/maxkb/model/tokenizer && \
    cp -f /opt/maxkb/app/installer/run-maxkb.sh /usr/bin/run-maxkb.sh && \
    cp -f /opt/maxkb/app/installer/init.sql /docker-entrypoint-initdb.d

EXPOSE 8080

ENTRYPOINT ["bash", "-c"]
CMD [ "/opt/maxkb/app/installer/run-maxkb.sh" ]








