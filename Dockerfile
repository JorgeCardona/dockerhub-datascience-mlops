# docker build --tag jorgecardona/datascience-mlops:3.14.7 .
# docker run -d --name mlops-new -p 8888:8888 -p 4040:4040 -p 5006:5006 -p 3000:3000 -p 8081:8081 -p 8082:8082 -p 8083:8083 -p 9091:9091 -p 9092:9092 -p 9093:9093 -p 9094:9094 --restart always jorgecardona/datascience-mlops:3.14.7

FROM jorgecardona/datascience-mlops-kernels:latest

LABEL maintainer="Jorge Cardona"


###############################################################
############# INSTALACION DE PAQUETES PARA PYTHON #############
###############################################################

RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade pip setuptools wheel

# --- MACHINE LEARNING, DEEP LEARNING Y NLP ---
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade \
    scikit-learn \
    torch \
    torchvision \
    torchaudio \
    keras \
    opencv-python \
    spacy \
    transformers \
    datasets \
    accelerate

# --- IA GENERATIVA, AGENTES Y LANGCHAIN ---
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade \
    langchain \
    langchain-community \
    langgraph \
    openai \
    langchain-openai \
    google-genai \
    google-api-python-client \
    langchain-google-genai
    
# --- WEB SCRAPING Y EXTRACCIÓN DE DATOS ---
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade \
    beautifulsoup4 \
    scrapy \
    httpx \
    requests \
    requests-html \
    selenium \
    playwright \
    newspaper3k \
    lxml \
    html5lib \
    feedparser \
    && playwright install --with-deps chromium

# --- CIBERSEGURIDAD, HACKING ÉTICO Y ANÁLISIS RED ---
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade \
    scapy \
    python-nmap \
    impacket \
    paramiko \
    cryptography \
    pwntools \
    shodan \
    censys \
    volatility3 \
    mitmproxy \
    requests-toolbelt

# --- CONECTORES DE BASES DE DATOS Y STREAMING ---
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade \
    mysql-connector-python \
    psycopg2-binary \
    pymongo \
    redis \
    sqlalchemy \
    confluent-kafka

# --- MANIPULACIÓN DE DATOS, ARCHIVOS Y LECTORES ---
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade \
    pandas \
    polars \
    tables \
    openpyxl \
    pyarrow \
    faker

# --- VISUALIZACIÓN DE DATOS Y DIAGRAMAS ---
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade \
    matplotlib \
    seaborn \
    plotly \
    bokeh \
    panel \
    itables \
    diagrams

# --- BATCH, PROCESAMIENTO DISTRIBUIDO Y BIG DATA ---
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade \
    pyspark \
    delta-spark \
    delta-sharing 

RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade \
    dask \
    dask-labextension \
    apache-beam[interactive] \
    duckdb

# --- ORQUESTACIÓN, MLOps Y PRUEBAS ---
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade \
    dbt-core \
    dbt-postgres \
    mlflow \
    papermill \
    apache-airflow

RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade \
    selenium \
    pytest \
    pytest-cov \
    pytest-bdd \
    pytest-selenium \
    behave \
    locust 
    
# --- ENTORNO Y EXTENSIONES DE JUPYTERLAB ---
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade \
    jupyterlab-git \
    jupyterlab_code_formatter \
    jupyterlab-indent-guides

# --- CALIDAD DE CÓDIGO Y FORMATO ---
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade \
    black \
    isort \
    ruff

# --- SERVICIOS WEB, APIS REST Y MICROSERVICIOS ---
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade \
    fastapi \
    uvicorn[standard] \
    gunicorn \
    httpx \
    pydantic

# --- GESTIÓN DE CONFIGURACIÓN Y VARIABLES DE ENTORNO ---
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade \
    python-dotenv \
    pydantic-settings \
    python-decouple \
    environs \
    dynaconf \
    pyyaml \
    tomli
###############################################################
################ UTILIDADES PARA EL CONTENEDOR ################
###############################################################

RUN apt-get update && apt-get install -y --no-install-recommends \
    graphviz \
    sudo \
    vim \
    htop \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

###############################################################
################### CONFIGURACION DE INICIO ###################
###############################################################

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--LabApp.token=''"]
