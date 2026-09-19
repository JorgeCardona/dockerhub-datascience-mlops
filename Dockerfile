<<<<<<< HEAD
# docker build --tag jorgecardona/datascience-mlops-new:latest .
# docker build --tag jorgecardona/datascience-mlops:3.13.8 .
# docker build --cache-from jorgecardona/datascience-mlops-new:latest --tag jorgecardona/datascience-mlops-new:latest .
# docker run -d --name jorgecardona-datascience-mlops -p 8888:8888 -p 4040:4040 -p 5006:5006 -p 3000:3000 -p 8081:8081 -p 8082:8082 -p 8083:8083 -p 9091:9091 -p 9092:9092 -p 9093:9093 -p 9094:9094 --restart always jorgecardona/datascience-mlops:latest
# docker run -d --name mlops-new -p 8888:8888 -p 4040:4040 -p 5006:5006 -p 3000:3000 -p 8081:8081 -p 8082:8082 -p 8083:8083 -p 9091:9091 -p 9092:9092 -p 9093:9093 -p 9094:9094 --restart always jorgecardona/datascience-mlops-new:latest
# Base image python:3.11.10, python:3.12.7
# Base image python:3.11.13, python:3.12.10
FROM python:3.14.7
=======
# docker build --tag jorgecardona/datascience-mlops:3.14.7 .
# docker run -d --name mlops-new -p 8888:8888 -p 4040:4040 -p 5006:5006 -p 3000:3000 -p 8081:8081 -p 8082:8082 -p 8083:8083 -p 9091:9091 -p 9092:9092 -p 9093:9093 -p 9094:9094 --restart always jorgecardona/datascience-mlops:3.14.7

FROM jorgecardona/datascience-mlops-kernels:latest
>>>>>>> 25cce5aad1a47fda7ecfa0b89c9300ff879650e5

LABEL maintainer="Jorge Cardona"

<<<<<<< HEAD
###############################################################
############ INSTALACION DE LENGUAJES EN LA IMAGEN ############
###############################################################

# ==========================================
# 1. JAVA (JDK 25 - Fix de variables y limpieza)
# ==========================================
ARG JDK_VERSION=25
ARG JDK_BUILD=latest
ENV JAVA_HOME=/usr/lib/jvm/jdk-${JDK_VERSION}-oracle-x64
ENV PATH=$JAVA_HOME/bin:$PATH

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates \
    && curl -fL https://download.oracle.com/java/${JDK_VERSION}/${JDK_BUILD}/jdk-${JDK_VERSION}_linux-x64_bin.deb -o jdk.deb \
    && apt-get install -y ./jdk.deb \
    && rm jdk.deb \
    && rm -rf /var/lib/apt/lists/*

# ==========================================
# 2. SCALA (URL corregida desde GitHub Releases)
# ==========================================
ARG VERSION_SCALA=2.13.18
ARG VERSION_SCALA_KERNEL=scala-${VERSION_SCALA}

RUN curl -fL https://github.com/scala/scala/releases/download/v${VERSION_SCALA}/${VERSION_SCALA_KERNEL}.tgz -o scala.tgz \
    && tar -xzf scala.tgz \
    && mv ${VERSION_SCALA_KERNEL} /usr/local/share/scala \
    && ln -s /usr/local/share/scala/bin/scala /usr/local/bin/scala \
    && ln -s /usr/local/share/scala/bin/scalac /usr/local/bin/scalac \
    && rm scala.tgz

# ==========================================
# 3. LENGUAJE R (Versión exacta fijada)
# ==========================================
ARG R_VERSION=4.5.0-3

RUN apt-get update && apt-get install -y --no-install-recommends \
    r-base-core=${R_VERSION} \
    && rm -rf /var/lib/apt/lists/*

# ==========================================
# 4. GO (Versión exacta fijada)
# ==========================================
ARG GO_VERSION=1.27.1
ENV PATH=/usr/local/go/bin:$PATH

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates \
    && curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o go.tar.gz \
    && tar -xzf go.tar.gz -C /usr/local \
    && rm go.tar.gz \
    && rm -rf /var/lib/apt/lists/*

# ==========================================
# 5. RUST (Versión exacta fijada)
# ==========================================
ARG RUST_VERSION=1.98.1
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates build-essential \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION} --no-modify-path \
    && rustup component add rust-src \
    && rm -rf /var/lib/apt/lists/*

# ==========================================
# 6. JULIA (Versión exacta fijada)
# ==========================================
ARG JULIA_VERSION_MAJOR=1.13
ARG JULIA_VERSION_FULL=1.13.0

RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates \
    && wget https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION_MAJOR}/julia-${JULIA_VERSION_FULL}-linux-x86_64.tar.gz -O julia.tar.gz \
    && tar -xzf julia.tar.gz \
    && mv julia-${JULIA_VERSION_FULL} /opt/julia \
    && ln -s /opt/julia/bin/julia /usr/local/bin/julia \
    && rm julia.tar.gz \
    && rm -rf /var/lib/apt/lists/*

# ==========================================
# 7. NODE.JS Y NPM (Versión exacta fijada)
# ==========================================
ARG NODE_VERSION=v20.19.2

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates \
    && curl -fsSL https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.gz -o node.tar.gz \
    && tar -xzf node.tar.gz -C /usr/local --strip-components=1 \
    && rm node.tar.gz \
    && rm -rf /var/lib/apt/lists/*
	
###############################################################
############ INSTALACION DE KERNELS EN JUPYTER LAB ############
###############################################################

# 1. Instalar JupyterLab base e ipykernel
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade jupyterlab
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade ipykernel

# 2. Kernel de R (Configuración global)
RUN Rscript -e "install.packages('IRkernel', repos='http://cran.rstudio.com/')" \
    && Rscript -e "IRkernel::installspec(user = FALSE)"

# 3. Kernel de C++
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade jupyter-cpp-kernel
# Elimina kernels de C++ que estan con otras versiones, solo se deja el de C++20
RUN jupyter kernelspec remove -f cpp03 || true && \
    jupyter kernelspec remove -f cpp11 || true && \
    jupyter kernelspec remove -f cpp14 || true && \
    jupyter kernelspec remove -f cpp17 || true && \
    jupyter kernelspec remove -f cpp23 || true && \
    jupyter kernelspec remove -f cpp98 || true

# 4. Kernel de Go (Gophernotes global)
RUN go install github.com/gopherdata/gophernotes@v0.7.5 \
    && mkdir -p /usr/local/share/jupyter/kernels/gophernotes \
    && cd /usr/local/share/jupyter/kernels/gophernotes \
    && cp "$(go env GOPATH)"/pkg/mod/github.com/gopherdata/gophernotes@v0.7.5/kernel/* "." \
    && chmod +w ./kernel.json \
    && sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" < kernel.json.in > kernel.json

# 5. Kernel de Java (IJava)
ARG VERSION_JAVA_KERNEL=1.3.0
RUN curl -fLo ijava.zip https://github.com/SpencerPark/IJava/releases/download/v${VERSION_JAVA_KERNEL}/ijava-${VERSION_JAVA_KERNEL}.zip \
    && unzip ijava.zip -d /tmp/ijava \
    && python3 /tmp/ijava/install.py --sys-prefix \
    && rm -rf ijava.zip /tmp/ijava

# 6. Kernel de Kotlin
RUN pip install --no-cache-dir kotlin-jupyter-kernel

# 7. KERNEL DE SCALA (Almond Fix)
ARG ALMOND_SCALA_VERSION=2.13.18
ARG ALMOND_VERSION=0.14.5

# a. Descargar Coursier
RUN curl -fLo cs.gz https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz \
    && gzip -d cs.gz \
    && mv cs /usr/local/bin/cs \
    && chmod +x /usr/local/bin/cs

# b. Generar el instalador de Almond e instalar el kernel globalmente
RUN cs bootstrap \
    --scala ${ALMOND_SCALA_VERSION} \
    almond:${ALMOND_VERSION} \
    --output /tmp/almond \
    && /tmp/almond --install --global \
    && rm -f /tmp/almond /usr/local/bin/cs

# 8. Kernel de Rust (Evcxr)
RUN cargo install --locked evcxr_jupyter \
    && evcxr_jupyter --install

# 9. Kernel de Julia (IJulia global)
ENV JULIA_DEPOT_PATH=/usr/local/share/julia
RUN julia -e 'using Pkg; Pkg.add("IJulia")'

# 10. Kernel de JS / TS con Deno (Nativo y moderno)
RUN curl -fsSL https://deno.land/install.sh | sh
ENV DENO_INSTALL="/root/.deno"
ENV PATH="$DENO_INSTALL/bin:$PATH"

RUN deno jupyter --install
RUN npm install -g ijavascript 
RUN ijsinstall # kernel javaScript

# 11. Instala SoS y la extensión para JupyterLab
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade sos-notebook
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade jupyterlab-sos
RUN python -m sos_notebook.install

# 12. Instala el kernel de Bash para Jupyter
RUN pip install --no-cache-dir -i https://pypi.org/simple --upgrade bash_kernel
RUN python -m bash_kernel.install

# 13. Kernel de Ruby (IRuby)
ARG IRUBY_VERSION=0.8.3

RUN apt-get update && apt-get install -y --no-install-recommends \
        ruby \
        ruby-dev \
        libczmq-dev \
        build-essential \
    && gem install iruby -v "${IRUBY_VERSION}" --no-document \
    && iruby register --force \
    && rm -rf /var/lib/apt/lists/*

# 14. KERNEL DE MATLAB / OCTAVE
ARG OCTAVE_VERSION="9.4.0*"
ARG OCTAVE_KERNEL_VERSION="1.1.1"

RUN apt-get update && apt-get install -y --no-install-recommends \
        octave=${OCTAVE_VERSION} \
        octave-control \
        octave-image \
        octave-io \
        octave-signal \
        gnuplot \
        ghostscript \
        fonts-freefont-otf \
        fontconfig \
        curl \
    && fc-cache -f \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir octave_kernel=="${OCTAVE_KERNEL_VERSION}"

RUN KERNEL_DIR="$(jupyter kernelspec list | grep -E '^\s*octave\s+' | awk '{print $2}')" && \
    if [ -n "$KERNEL_DIR" ]; then \
        curl -fsSL https://upload.wikimedia.org/wikipedia/commons/2/21/Matlab_Logo.png -o "${KERNEL_DIR}/logo-64x64.png"; \
    fi
    
# 15. KERNEL DE ELIXIR (Con logo e interfaz oficial)
RUN apt-get update && apt-get install -y --no-install-recommends \
        elixir \
        curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# a. Crear el runner wrapper
RUN mkdir -p /usr/local/share/elixir_kernel \
    && cat <<'EOF' > /usr/local/share/elixir_kernel/kernel.py
import subprocess
import sys
from ipykernel.kernelbase import Kernel

class ElixirNativeKernel(Kernel):
    implementation = 'Elixir'
    implementation_version = '1.0'
    language = 'elixir'
    language_info = {
        'name': 'elixir',
        'mimetype': 'text/x-elixir',
        'file_extension': '.exs'
    }
    banner = "Elixir Runner Kernel"

    def do_execute(self, code, silent, store_history=True, user_expressions=None, allow_stdin=False):
        if not code.strip():
            return {'status': 'ok', 'execution_count': self.execution_count, 'payload': [], 'user_expressions': {}}

        try:
            process = subprocess.run(
                ['elixir', '-e', code],
                capture_output=True,
                text=True,
                check=False
            )

            if not silent:
                if process.stdout:
                    self.send_response(self.iopub_socket, 'stream', {'name': 'stdout', 'text': process.stdout})
                if process.stderr:
                    self.send_response(self.iopub_socket, 'stream', {'name': 'stderr', 'text': process.stderr})

            status = 'ok' if process.returncode == 0 else 'error'
            return {'status': status, 'execution_count': self.execution_count, 'payload': [], 'user_expressions': {}}

        except Exception as e:
            if not silent:
                self.send_response(self.iopub_socket, 'stream', {'name': 'stderr', 'text': str(e)})
            return {'status': 'error', 'execution_count': self.execution_count, 'ename': type(e).__name__, 'evalue': str(e), 'traceback': []}

if __name__ == '__main__':
    from ipykernel.kernelapp import IPKernelApp
    IPKernelApp.launch_instance(kernel_class=ElixirNativeKernel)
EOF

# b. Registrar el kernel en JupyterLab
RUN mkdir -p /usr/local/share/jupyter/kernels/elixir \
    && cat <<'EOF' > /usr/local/share/jupyter/kernels/elixir/kernel.json
{
  "argv": [
    "python3",
    "/usr/local/share/elixir_kernel/kernel.py",
    "-f",
    "{connection_file}"
  ],
  "display_name": "Elixir",
  "language": "elixir"
}
EOF

# c. Descargar los logos oficiales originales de IElixir
RUN curl -fsSL https://raw.githubusercontent.com/pprzetacznik/IElixir/master/resources/logo-64x64.png -o /usr/local/share/jupyter/kernels/elixir/logo-64x64.png \
    && curl -fsSL https://raw.githubusercontent.com/pprzetacznik/IElixir/master/resources/logo-32x32.png -o /usr/local/share/jupyter/kernels/elixir/logo-32x32.png

# 15. Personalización del Kernel predeterminado de Python
RUN python -m ipykernel install --sys-prefix --name python3 --display-name "Python - ML - Data Science"
RUN sed -i 's/"display_name": ".*"/"display_name": "SoS - Multi-language Notebook"/' /usr/local/share/jupyter/kernels/sos/kernel.json
RUN sed -i 's/"display_name": ".*"/"display_name": "Ruby"/' /root/.local/share/jupyter/kernels/ruby3/kernel.json
RUN OCTAVE_PATH=$(jupyter kernelspec list --json | grep -o '"/[^"]*octave"' | head -n 1 | tr -d '"') && sed -i 's/"display_name": ".*"/"display_name": "MATLAB \/ Octave"/' "${OCTAVE_PATH}/kernel.json"

# 16. Deshabilitar la extensión de consola de JupyterLab para mejorar el rendimiento
RUN jupyter labextension disable @jupyterlab/console-extension

###############################################################
############# DEFINICION DE DIRECTORIO DE TRABAJO #############
###############################################################

# Set the working directory
WORKDIR /notebooks

###############################################################
############ LIMPIEZA FINAL Y ARRANQUE #######################
###############################################################

# Limpiar paquetes temporales innecesarios para reducir peso de la imagen
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Arrancar JupyterLab al iniciar el contenedor
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--LabApp.token=''"]
=======

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
>>>>>>> 25cce5aad1a47fda7ecfa0b89c9300ff879650e5
