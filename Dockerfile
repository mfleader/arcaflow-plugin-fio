FROM quay.io/centos/centos:stream8 as poetry

RUN dnf -y module install python39 && dnf -y install python39 python39-pip
RUN dnf -y install fio-3.19-3.el8

WORKDIR /app
COPY poetry.lock /app/
COPY pyproject.toml /app/

RUN python3.9 -m pip install poetry \
 && python3.9 -m poetry config virtualenvs.create false \
 && python3.9 -m poetry install --without dev --no-root \
 && python3.9 -m poetry export -f requirements.txt --output requirements.txt --without-hashes

ENV package arcaflow_plugin_fio
COPY ${package}/ /app/${package}
COPY fixtures /app/fixtures
COPY tests /app/tests
ENV PYTHONPATH /app
RUN python3 tests/test_fio_plugin.py


FROM quay.io/centos/centos:stream8
ENV package arcaflow_plugin_fio

RUN dnf -y module install python39 && dnf -y install python39 python39-pip
RUN dnf -y install fio-3.19-3.el8

WORKDIR /app

COPY --from=poetry /app/requirements.txt /app/
COPY LICENSE /app/
COPY README.md /app/
COPY ${package}/ /app/${package}

RUN python3.9 -m pip install -r requirements.txt

WORKDIR /app/${package}

ENTRYPOINT ["python3.9", "fio_plugin.py"]
CMD []


LABEL org.opencontainers.image.source="https://github.com/arcalot/arcaflow-plugin-fio"
LABEL org.opencontainers.image.licenses="Apache-2.0+GPL-2.0-only"
LABEL org.opencontainers.image.vendor="Arcalot project"
LABEL org.opencontainers.image.authors="Arcalot contributors"
LABEL org.opencontainers.image.title="Fio Arcalot Plugin"
LABEL io.github.arcalot.arcaflow.plugin.version="0.1.1"
