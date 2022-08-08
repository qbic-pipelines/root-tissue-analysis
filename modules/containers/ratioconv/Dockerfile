FROM  fiji/fiji:fiji-openjdk-7

USER root
RUN apt update
RUN apt install -y xvfb
RUN fiji-linux64 --headless --update add-update-site ImageScience https://sites.imagej.net/ImageScience/
RUN fiji-linux64 --headless --update update jars/imagescience.jar
RUN fiji-linux64 --headless --update update plugins/FeatureJ_.jar

COPY ratio_macro.ijm /root/
