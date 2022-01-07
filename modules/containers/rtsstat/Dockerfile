FROM python:3.8.1-alpine

# A few Utilities to able to install C based libraries such as numpy
RUN apk update
RUN apk add make automake gcc g++ git
RUN apt-get install -y procps wget

RUN pip install --upgrade pip setuptools wheel
# RUN pip install rtsstat

# CMD rtsstat
