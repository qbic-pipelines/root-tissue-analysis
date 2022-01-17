FROM quay.io/biocontainers/python:3.8.3

RUN pip install --upgrade pip setuptools wheel
COPY requirements.txt ./
RUN pip install --requirement requirements.txt
COPY reporting.ipynb ./
