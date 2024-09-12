# Build: docker build -f Dockerfile -t api4opt-sa .
# Run: docker run -it --name api4opt-sa-1 -p 8000:8000 api4opt-sa
# Exec: docker exec -it api4opt-sa-1 bash

# Build with variables(does not work yet): docker build $(sed 's/^/ --build-arg /g' variables_standalone.env | xargs) -t api4opt-sa .
# Run with variables: docker run --env-file=variables_standalone.env -it --name api4opt-sa-1 -p 8000:8000 api4opt-sa
# Run with file in image (COPY variables_standalone.env /root/variables.env): add this line in entrypoint.sh export $(cat variables.env | xargs)


FROM python:3.10-bullseye
LABEL AUTHOR "Gregorio Toscano <gtoscano@fastmail.com>"

# Environment Vars
ENV PYTHONUNBUFFERED=1
ENV MSU_CBPO_PATH=/opt/opt4cast
ENV AWS_ACCESS_KEY_ID=
ENV AWS_SECRET_ACCESS_KEY=
ENV AWS_REGION=us-east-1
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONIOENCODING=utf8
ENV LANG="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LC_CTYPE="en_US.UTF-8"
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/lib
ENV LD_RUN_PATH=/usr/local/lib:/usr/lib
ENV AMQP_USERNAME=guest
ENV AMQP_PASSWORD=guest
ENV MYSQL_DATABASE=mydb
ENV MYSQL_USER=myuser
ENV MYSQL_PASSWORD=32ghukj45ihhkj3425
ENV DB_USER=myuser
ENV DB_PORT=3306
ENV DB_PASSWD=32ghukj45ihhkj3425


# Required to install mysqlclient with Pip
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
RUN apt-get update && apt-get upgrade -y
RUN apt-get -y install apt-utils locales-all locales wget
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN mkdir -p /app /app/media /app/log /app/ /opt/opt4cast/output/parquet /app/data /opt/opt4cast/data /opt/opt4cast/output/nsga3

WORKDIR /app/
COPY . ./
COPY data/ /app/data/
COPY data/check.py /usr/local/bin

WORKDIR /app/data/
RUN wget https://www.dropbox.com/s/k74cctt8fgue9ko/dependencies.tar.gz && tar xvfz dependencies.tar.gz && rm dependencies.tar.gz
RUN tar xvfz ipopt.tar.gz && rm ipopt.tar.gz



WORKDIR /app/data/dependencies/
RUN wget -O apache-arrow-apt-source-latest-bullseye.deb https://apache.jfrog.io/artifactory/arrow/debian/apache-arrow-apt-source-latest-bullseye.deb
RUN dpkg -i apache-arrow-apt-source-latest-bullseye.deb
#COPY data/install.sh /tmp
#RUN chmod +x /tmp/install.sh
#RUN bash /tmp/install.sh
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get -y install libparquet-dev

RUN apt-get -y install gcc g++ gfortran cmake git patch pkg-config liblapack-dev libmetis-dev gawk build-essential cmake ninja-build bazel-bootstrap  rabbitmq-server librabbitmq-dev libboost-all-dev libboost-log-dev libfmt-dev nlohmann-json3-dev libhiredis0.14 libhiredis-dev libcurl4-openssl-dev libssl-dev uuid-dev zlib1g-dev libpulse-dev ca-certificates lsb-release protobuf-c-compiler  libprotobuf-dev libprotobuf-lite23 libprotobuf-c-dev libsnappy-dev zip unzip sudo awscli libarrow-dev libarrow-glib-dev libarrow-dataset-dev libarrow-dataset-glib-dev libparquet-dev libparquet-glib-dev default-libmysqlclient-dev python3-dev python3-pip python-is-python3 python3-geopandas  python3-psycopg2 default-libmysqlclient-dev systemctl libcjson1 libcjson-dev redis software-properties-common apt-transport-https gnupg2 librange-v3-dev

#COPY data/mysql.service /lib/systemd/system/

RUN systemctl enable rabbitmq-server &&  systemctl enable redis-server && rabbitmq-plugins enable rabbitmq_management 
#&& systemctl enable mysql
RUN pip install scikit-learn numpy uuid sqlalchemy pyarrow redis


# Must start: systemctl start mysqld


#WORKDIR /app/plot
#RUN gzip -d Chesapeake_Bay_Watershed_Model_Phase_6_Land_River_Segments.geojson.gz
#WORKDIR /app/data/
#RUN gzip -d eta.csv.gz

WORKDIR /app/
COPY ./data/eta.csv.gz /opt/opt4cast/data/
WORKDIR /opt/opt4cast/data/
RUN gzip -d eta.csv.gz

#COPY api api4opt core likes optimization playground plot settings static tags /app/
#COPY docker-compose.yml docker-entrypoint.sh wait-for-it.sh /app/
#COPY Pipfile Pipfile.lock requirements.txt /app/


# We use the --system flag so packages are installed into the system python
# and not into a virtualenv. Docker containers don't need virtual environments. 


#RUN chown -R www-data:www-data /home/www-data/web2py

## CREATE the output directories
RUN chown -R www-data.www-data /opt/opt4cast/output



# Copy the application files into the image


## CSVs config options
COPY data/csvs.tar.gz /opt/opt4cast/
WORKDIR /opt/opt4cast/
RUN tar xvfz csvs.tar.gz

RUN mkdir -p /tmp/aws-sdk-cpp /tmp/redis-plus-plus /tmp/crossguid /tmp/c-ares /tmp/SimpleAmqpClient /tmp/loki-cpp /tmp/curlpp 

## Install dependencies
WORKDIR /tmp/aws-sdk-cpp 
RUN cmake /app/data/dependencies/aws-sdk-cpp -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/usr/local/  -DBUILD_ONLY="s3" && make clean && make && make install

WORKDIR /tmp/redis-plus-plus 
RUN cmake -DREDIS_PLUS_PLUS_CXX_STANDARD=17 /app/data/dependencies/redis-plus-plus/ -DCMAKE_BUILD_TYPE=Release && make clean && make && make install

WORKDIR /tmp/crossguid 
RUN cmake /app/data/dependencies/crossguid -DCMAKE_BUILD_TYPE=Release && make clean && make && make install

WORKDIR /tmp/c-ares 
RUN cmake /app/data/dependencies/c-ares -DCMAKE_BUILD_TYPE=Release && make clean && make && make install

WORKDIR /tmp/SimpleAmqpClient
RUN cmake /app/data/dependencies/SimpleAmqpClient -DCMAKE_BUILD_TYPE=Release && make clean && make && make install

WORKDIR /tmp/loki-cpp
RUN cmake /app/data/dependencies/loki-cpp -DCMAKE_BUILD_TYPE=Release && make clean && make && make install

WORKDIR /tmp/curlpp
RUN cmake /app/data/dependencies/curlpp  && make clean && make && make install

WORKDIR /app/data/ipopt/ThirdParty-ASL
RUN ./configure && make clean && make && make install 

## Install COIN Operation Research Tools

WORKDIR /app/data/ipopt/ThirdParty-ASL
RUN ./configure && make clean && make && make install 


WORKDIR /app/data/ipopt/ThirdParty-HSL
RUN ./configure && make clean && make && make install 

WORKDIR /app/data/ipopt/ThirdParty-Mumps
RUN ./configure && make clean && make && make install 


WORKDIR /app/data/ipopt/Ipopt
RUN ./configure && make clean && make && make install 



WORKDIR /app/
RUN git clone https://github.com/gtoscano/CastEvaluation.git
RUN git clone https://github.com/gtoscano/alfred.git
RUN git clone https://github.com/gtoscano/MSUCast.git
RUN git clone https://github.com/gtoscano/run_base
RUN mkdir -p /app/CastEvaluation/build /app/alfred/build /app/MSUCast/build /app/run_base/build

WORKDIR /app/CastEvaluation/build
RUN cmake .. && make clean && make && make install 
#&& cd build && cmake .. && make clean && make && make install


#&& cd build && cmake .. && make clean && make && make install
WORKDIR /app/alfred/build
RUN cmake .. && make clean && make && make install


WORKDIR /app/MSUCast/build
RUN cmake .. && make clean && make && make install

WORKDIR /app/run_base/build
RUN cmake .. && make clean && make && make install

#&& cd build && cmake .. && make clean && make && make install


RUN rm -rf /app/data/dependencies/ /app/data/ipopt /tmp/aws-sdk-cpp /tmp/redis-plus-plus /tmp/crossguid /tmp/c-ares /tmp/SimpleAmqpClient /tmp/loki-cpp /tmp/curlpp 
#RUN chown -R www-data.www-data csvs

### Clean
## RUN rm csvs.tar.gz
#
#RUN rm /tmp/apache-arrow-apt-source-latest-bullseye.deb

WORKDIR /app

# Python 3 dependencies

#COPY api api4opt core likes optimization playground plot settings static tags /app/
#COPY docker-compose.yml docker-entrypoint.sh wait-for-it.sh /app/
#COPY Pipfile Pipfile.lock requirements.txt /app/

# Install pipenv
RUN pip install --upgrade pip 
RUN pip install pipenv

# We use the --system flag so packages are installed into the system python
# and not into a virtualenv. Docker containers don't need virtual environments. 
RUN pipenv install --system --deploy

#RUN chown -R www-data.www-data csvs

### Clean
## RUN rm csvs.tar.gz
#
#RUN rm /tmp/apache-arrow-apt-source-latest-bullseye.deb


COPY variables_standalone.env /root/variables.env

COPY run_once.sh /root/
COPY entrypoint_standalone.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose port 8000 on the container
EXPOSE 8000
ENTRYPOINT [ "entrypoint.sh" ]

