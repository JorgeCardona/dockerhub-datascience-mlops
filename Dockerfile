# docker build --tag jorgecardona/datascience-mlops:latest .
# docker run -d --name jorgecardona-datascience-mlops -p 8888:8888 -p 4040:4040 -p 5006:5006 -p 3000:3000 -p 8081:8081 -p 8082:8082 -p 8083:8083 -p 9091:9091 -p 9092:9092 -p 9093:9093 -p 9094:9094 --restart always jorgecardona/datascience-mlops:latest

# Base image python:3.11.10, python:3.12.7
# Base image python:3.11.13, python:3.12.10
FROM python:3.12.7

# etiqueta creador de la imagen
LABEL maintainer="Jorge Cardona"

###############################################################
############ INSTALACION DE LENGUAJES EN LA IMAGEN ############
###############################################################

# INSTALA Java
RUN curl -O https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb && \
    apt install -y ./jdk-21_linux-x64_bin.deb && \
    rm jdk-21_linux-x64_bin.deb && \
    export JAVA_HOME=/usr/lib/jvm/jdk-21-oracle-x64 && \
    export PATH=$PATH:$JAVA_HOME/bin

# Download and install Scala
ARG VERSION_SCALA=2.13.16
ARG VERSION_SCALA_KERNEL=scala-${VERSION_SCALA}
RUN curl -O https://downloads.lightbend.com/scala/${VERSION_SCALA}/${VERSION_SCALA_KERNEL}.tgz && \
    tar -xzf ${VERSION_SCALA_KERNEL}.tgz && \
    mv ${VERSION_SCALA_KERNEL} /usr/local/share/scala && \
    ln -s /usr/local/share/scala/bin/scala /usr/local/bin/scala && \
    ln -s /usr/local/share/scala/bin/scalac /usr/local/bin/scalac && \
    rm ${VERSION_SCALA_KERNEL}.tgz

# INSTALA lenguaje R
RUN apt-get update && apt-get install -y r-base

# INSTALA NODEJS y NPM
RUN apt-get install nodejs npm -y

# Instalar Go
RUN apt-get update && apt-get install -y golang

# INSTALA Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    /root/.cargo/bin/rustup component add rust-src

# INSTALA Julia
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-1.10.4-linux-x86_64.tar.gz && \
    tar -xvzf julia-1.10.4-linux-x86_64.tar.gz && \
    mv julia-1.10.4 /opt/julia && \
    ln -s /opt/julia/bin/julia /usr/local/bin/julia && \
    rm julia-1.10.4-linux-x86_64.tar.gz

# Install Jenkins	
RUN apt-get update && \
    apt-get install -y wget && \
    wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian/jenkins.io-2023.key && \
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null && \
    apt-get update && \
    apt-get install -y jenkins && \
    sed -i 's/HTTP_PORT=8080/HTTP_PORT=8083/g' /etc/default/jenkins
	
# Install Kafka
ARG VERSION_KAFKA_KERNEL=3.9.1
ARG VERSION_KAFKA=kafka_2.13-3.9.1
ARG KAFKA_HOME=/usr/local/kafka

RUN wget https://archive.apache.org/dist/kafka/${VERSION_KAFKA_KERNEL}/${VERSION_KAFKA}.tgz && \
    tar xvf ${VERSION_KAFKA}.tgz && \
    mv ${VERSION_KAFKA} ${KAFKA_HOME} && \
    ln -s ${KAFKA_HOME} /kafka && \
	mkdir -p ${KAFKA_HOME}/data/logs && \
	mkdir -p ${KAFKA_HOME}/data/zookeeper && \
    rm ${VERSION_KAFKA}.tgz

###############################################################
############ INSTALACION DE KERNELS EN JUPYTER LAB ############
###############################################################

# Instala JupyterLab
RUN pip install --no-cache-dir -i https://pypi.org/simple jupyterlab

# Instala el kernel de R
RUN echo "install.packages(c('IRkernel'), repos='http://cran.rstudio.com/', dependencies=TRUE)"  > /tmp/packages.R && Rscript /tmp/packages.R
RUN echo 'IRkernel::installspec()' > /tmp/temp.R && Rscript /tmp/temp.R

# Instala el kernel de C++
RUN pip install --no-cache-dir -i https://pypi.org/simple jupyter-cpp-kernel

# Instala el kernel de go
RUN go install github.com/gopherdata/gophernotes@v0.7.5 && \
    mkdir -p ~/.local/share/jupyter/kernels/gophernotes && \
    cd ~/.local/share/jupyter/kernels/gophernotes && \
    cp "$(go env GOPATH)"/pkg/mod/github.com/gopherdata/gophernotes@v0.7.5/kernel/*  "." && \
    chmod +w ./kernel.json && \
    sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" < kernel.json.in > kernel.json
	
ARG VERSION_JAVA_KERNEL=1.3.0
# Instala el kernel de Java
RUN wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-${VERSION_JAVA_KERNEL}.zip && \
    unzip ijava-${VERSION_JAVA_KERNEL}.zip && \
    python3 install.py --sys-prefix && \
    rm ijava-${VERSION_JAVA_KERNEL}.zip
	
# Instala el kernel de Kotlin
RUN pip install --no-cache-dir -i https://pypi.org/simple kotlin-jupyter-kernel	

# Instala el kernel de Scala
# https://almond.sh/docs/quick-start-install
# 1. Descargar el lanzador `cs` para Linux x86_64
# Descargar Coursier (cs) y prepararlo
RUN curl -fLo coursier.gz https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz \
    && gunzip coursier.gz \
    && chmod +x coursier

# Instalar Almond con coursier
RUN ./coursier launch --fork almond -- --install

# Limpiar
RUN rm -f coursier

# Instala el kernel de Nodejs-JavaScript
RUN npm install -g ijavascript 
RUN ijsinstall # jernel javaScript

# Instalar Kernel Rust
RUN /root/.cargo/bin/cargo install --locked evcxr_jupyter && \
    /root/.cargo/bin/evcxr_jupyter --install

# Instalar Kernel Julia
RUN julia -e 'using Pkg; Pkg.add("IJulia")'

# Renombrar el Kernel de python
RUN python -m ipykernel install --name python3 --display-name "Python - ML - Data Science" --user

###############################################################
################ UTILIDADES PARA EL CONTENEDOR ################
###############################################################

# Instalar Graphviz para visualización de gráficos y generación de diagramas
RUN apt install graphviz -y
RUN apt install -y sudo
RUN apt install -y vim

###############################################################
############# INSTALACION DE PAQUETES PARA PYTHON #############
###############################################################

# Set the working directory
WORKDIR /notebooks

RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade pip
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade jupyterlab-git
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade scikit-learn
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade tensorflow
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade keras
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade opencv-python
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade spacy

RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade mysql-connector-python
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade psycopg2
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade pymongo
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade confluent-kafka

RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade pytest
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade locust
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade itables
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade faker
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade panel
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade seaborn
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade bokeh
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade diagrams
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade dask
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade dask-labextension
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade duckdb

RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade pandas
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade polars
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade apache-beam[interactive]
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade dbt-core
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade dbt-postgres
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade pyxtension
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade pyspark
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade delta-spark
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade delta-sharing
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade mlflow
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade papermill
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade lxml
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade tables
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade openpyxl
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade jupyterlab-spreadsheet
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade pandas-dataset-handler
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade notebook-orchestration-and-execution-manager
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade jupyter-collaboration-ui
# RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade apache-airflow
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade "apache-airflow==2.11.0"

RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade jupyterlab_code_formatter
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade jupyterlab-indent-guides
#RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade jupyterlab-lsp
#RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade python-language-server

RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade black
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade isort
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade ruff
#RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade autopep8
#RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade yapf
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade sos-notebook
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade jupyterlab-sos

# Instala SoS y la extensión para JupyterLab
RUN python -m sos_notebook.install

#RUN pip install pycodestyle
###############################################################
################## CONFIGURACIONES FINALES ####################
###############################################################

# Establece la variable de entorno HOME
ENV HOME=/root
ENV DBT_PROFILES_DIR=/root/.dbt

# Establece las variables de entorno necesarias para PySpark y Delta
# ENV PYSPARK_SUBMIT_ARGS="--packages io.delta:delta-core_2.12:2.4.0 --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog pyspark-shell"

# Crea el directorio para dbt
RUN mkdir -p /root/.dbt

# Start Airflow when the container launches
# avoid loading all DAG examples
ENV AIRFLOW__CORE__LOAD_EXAMPLES=False 
RUN airflow db init
RUN airflow users create --role Admin --username admin --email mldatascience@jorgecardona.com --firstname admin --lastname airflow --password 12345678
#RUN rm /usr/local/lib/python3.12/site-packages/airflow/example_dags/example_branch_operator_decorator.py
#RUN rm /usr/local/lib/python3.12/site-packages/airflow/example_dags/example_branch_operator.py
RUN mkdir -p /root/airflow/dags
COPY /airflow_files/dbt_airflow.py /root/airflow/dags
COPY /kafka_files/*.properties /usr/local/kafka/config
COPY /jars/*.jar /usr/local/spark/jars/
COPY /jars_scala_2.13/*.jar /usr/local/spark/jars/

# copia los .jar para delta lake
# tar -czf /notebooks/cache.tar.gz -C /root .ivy2
RUN mkdir -p /root/.ivy2.5.2
COPY delta_spark/ivy2.5.2/ /root/.ivy2.5.2/

# copia la configuracion del notebook personalizada
COPY NotebookConfig/tracker.jupyterlab-settings /root/.jupyter/lab/user-settings/@jupyterlab/notebook-extension/tracker.jupyterlab-settings
COPY NotebookConfig/panel.jupyterlab-settings /root/.jupyter/lab/user-settings/@jupyterlab/notebook-extension/panel.jupyterlab-settings
COPY NotebookConfig/manager.jupyterlab-settings /root/.jupyter/lab/user-settings/@jupyterlab/completer-extension/manager.jupyterlab-settings
COPY NotebookConfig/plugin.jupyterlab-settings /root/.jupyter/lab/user-settings/@jupyterlab/cell-toolbar-extension/plugin.jupyterlab-settings
COPY NotebookConfig/kernels/sos/kernel.json /usr/local/share/jupyter/kernels/sos/kernel.json

# Elimina kernels de C++ que estan con otras versiones, solo se deja el de C++20
RUN jupyter kernelspec remove -f cpp03 || true && \
    jupyter kernelspec remove -f cpp11 || true && \
    jupyter kernelspec remove -f cpp14 || true && \
    jupyter kernelspec remove -f cpp17 || true && \
    jupyter kernelspec remove -f cpp23 || true && \
    jupyter kernelspec remove -f cpp98 || true

# Start JupyterLab when the container launches
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--LabApp.token=''"]

# Limpiar paquetes innecesarios
RUN apt update 
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# copiar una imagen paar subirla al dockerhub
#docker tag python:3.12.3 jorgecardona/python:3.12.3
#docker push jorgecardona/python:3.12.3