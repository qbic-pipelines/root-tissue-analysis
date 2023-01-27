FROM  fiji/fiji:fiji-openjdk-8
USER root
RUN apt update
RUN apt install -y xvfb
RUN apt install libxrender1
RUN apt install -y libxtst6
RUN ls entrypoint.sh 
RUN chmod +x entrypoint.sh
RUN ImageJ-linux64 --headless --update add-update-site ImageScience http://sites.imagej.net/ImageScience/
RUN ImageJ-linux64 --headless --update update jars/imagescience.jar
RUN ImageJ-linux64 --headless --update update plugins/FeatureJ_.jar
COPY ratio_macro.ijm ./
ENTRYPOINT ["/entrypoint.sh"]