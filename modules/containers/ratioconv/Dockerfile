FROM  fiji/fiji:fiji-openjdk-8
USER root
RUN apt update
RUN apt install -y xvfb
USER fiji
RUN ImageJ-linux64 --headless --update add-update-site ImageScience https://sites.imagej.net/ImageScience/
RUN ImageJ-linux64 --headless --update update jars/imagescience.jar
RUN ImageJ-linux64 --headless --update update plugins/FeatureJ_.jar
COPY ratio_macro.ijm ./
