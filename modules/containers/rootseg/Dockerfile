FROM python:3.8.12-slim-bullseye

# A few Utilities to able to install C based libraries such as numpy
RUN apt update
RUN apt-get install -y procps wget
RUN pip install --upgrade pip setuptools wheel
RUN pip install rts-package=1.1.12

CMD rts_package
