FROM python:3.10

RUN apt-get update && apt-get upgrade -y
RUN apt-get install dumb-init -y

COPY pip-pinned-requirements.txt .
RUN export MAKEFLAGS="-j$(nproc)" && pip install -r pip-pinned-requirements.txt

COPY app.py .

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD [ "flask", "run", "--host=0.0.0.0" ]
