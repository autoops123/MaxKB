FROM python:3.11.9-slim

WORKDIR /opt/project
COPY pyproject.toml /opt/project

RUN python3 -m venv /opt/py3 && \
    pip install poetry --break-system-packages && \
    poetry config virtualenvs.in-project true && \
    poetry config virtualenvs.create false && \
    . /opt/py3/bin/activate && \
    poetry install

ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/py3/bin"
EXPOSE 8080
CMD ["python3"]









