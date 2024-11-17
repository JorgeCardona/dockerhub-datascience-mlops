# dockerhub-datascience-mlops

Jorge Cardona

-------------------  -------------------------------------------
<a href="https://www.linkedin.com/in/jorgecardona1" target="_blank"><img src="https://content.linkedin.com/content/dam/me/business/en-us/amp/brand-site/v2/bg/LI-Bug.svg.original.svg" width="80" height="80"></a>
<a href="https://www.youtube.com/jorgeCardona1" target="_blank"><img src="https://i1.wp.com/www.siempreviajero.com/wp-content/uploads/2017/03/logo-youtube-png.png" width="80" height="80"></a>
<a href="https://www.hackerrank.com/jorgecardona" target="_blank"><img src="https://d29fhpw069ctt2.cloudfront.net/icon/image/38712/preview.svg" width="80" height="80"></a>
<a href="https://hub.docker.com/u/jorgecardona" target="_blank"><img src="https://raw.githubusercontent.com/docker-library/docs/c350af05d3fac7b5c3f6327ac82fe4d990d8729c/docker/logo.png" width="80" height="80"></a>
<a href="https://pypi.org/user/jorgecardona/" target="_blank"><img src="https://raw.githubusercontent.com/JorgeCardona/PipPackageInstaller/main/imagenes/PyPI.png" width="80" height="80"></a>
<a href="https://jorgecardona.github.io/portfolio/" target="_blank"><img src="https://raw.githubusercontent.com/JorgeCardona/PipPackageInstaller/refs/heads/main/imagenes/github.svg" width="80" height="80"></a>
-------------------     ----------------------------

# Available Kernels, Languages And Packages
<img src="https://raw.githubusercontent.com/JorgeCardona/recursos/main/docker_hub/data_science_3.11.7.png"/>

# ❎ In a python cell run the following code to check the version of each installed language ❎
```python
%%bash
echo "C++ Version" && g++ --version && echo
echo "Go Version" && go version && echo
echo "Java Version" && java -version && echo
echo "NodeJs Version" && node -v && echo
echo "Kotlin Version" && kotlin -version && echo
echo "Python Version" && python --version && echo
echo "R Version" && R --version && echo
echo "Rust Version" && rustc --version && echo
echo "Scala Version" && scala -version && echo
echo "Julia Version" && julia -version && echo
```

# ⚠️ For this image, it is **not necessary to use the token** to access the notebooks ⚠️
# How to run the image.

#  TEMPORAL CONTAINER
## 🔥If you want to just test the image and do not keep the container when you finish running the container use the next command🔥:
#### ``` docker run --name jorgecardona-datascience-mlops --rm -p 8888:8888 -p 4040:4040 -p 5006:5006 -p 3000:3000 -p 8081:8081 -p 8082:8082 -p 8083:8083  -p 9091:9091 -p 9092:9092 -p 9093:9093 -p 9094:9094 jorgecardona/datascience-mlops:main```

# PERSISTENT CONTAINER
## 💦If you want to keep the container, save the notebooks, and continue working on this container use the next command:💦
#### ``` docker run --name jorgecardona-datascience-mlops -p 8888:8888 -p 4040:4040 -p 5006:5006 -p 3000:3000 -p 8081:8081 -p 8082:8082 -p 8083:8083  -p 9091:9091 -p 9092:9092 -p 9093:9093 -p 9094:9094 --restart always jorgecardona/datascience-mlops:main```

#  ACCESS TO JUPYTER LAB AND SPARK UI 
##  🐱 access to JUPYTERLAB ```http://localhost:8888```  <a href=" http://localhost:8888" target="_blank">CLICK HERE </a> 🐱
## 🐶access to sparkUI with pySpark  ```http://localhost:4040```  <a href=" http://localhost:4040" target="_blank">CLICK HERE </a>🐶

# 🌀To run Spark for Scala, on the terminal execute ```spark-shell``` command to start it.🌀
<img src="https://github.com/JorgeCardona/recursos/blob/main/docker_hub/running_spark.png?raw=true"/>

## 🐍access to sparkUI Running directly Apache Spark ```http://localhost:4040```  <a href=" http://localhost:4040" target="_blank">CLICK HERE </a>🐍
<img src="https://github.com/JorgeCardona/recursos/blob/main/docker_hub/spark_ui.png?raw=true"/>

# EXAMPLES BY LANGUAGE
| Language   | Example                                                                                     |
|-----------|---------------------------------------------------------------------------------------------|
| C++       |#include &lt;iostream&gt;<br>int calculateSquare(int number) {<br>&nbsp;&nbsp;&nbsp;&nbsp;return number * number;<br>}<br>int main() {<br>&nbsp;&nbsp;&nbsp;&nbsp;// Print "Hello, C++!"<br>&nbsp;&nbsp;&nbsp;&nbsp;std::cout << "Hello, C++!" << std::endl;<br>&nbsp;&nbsp;&nbsp;&nbsp;// Use the function to calculate the square of 5<br>&nbsp;&nbsp;&nbsp;&nbsp;int result = calculateSquare(5);<br>&nbsp;&nbsp;&nbsp;&nbsp;// Print the result<br>&nbsp;&nbsp;&nbsp;&nbsp;std::cout << "The square of 5 is: " << result << std::endl;<br>&nbsp;&nbsp;&nbsp;&nbsp;return 0;<br>}<br>|
| Go        | package main<br><br>import "fmt"<br><br>func main() {<br>&nbsp;&nbsp;&nbsp;&nbsp;fmt.Println("Hello, Go!")<br><br>&nbsp;&nbsp;&nbsp;&nbsp;// Define a function to calculate the square of a number<br>&nbsp;&nbsp;&nbsp;&nbsp;calculateSquare := func(number int) int {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return number * number<br>&nbsp;&nbsp;&nbsp;&nbsp;}<br><br>&nbsp;&nbsp;&nbsp;&nbsp;// Use the function to calculate the square of 5<br>&nbsp;&nbsp;&nbsp;&nbsp;result := calculateSquare(5)<br>&nbsp;&nbsp;&nbsp;&nbsp;fmt.Println("Square of 5:", result)<br>}<br>main() |
| Java      | public class Main {<br>&nbsp;&nbsp;&nbsp;&nbsp;public static void greeting() {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println("Hello, Java!");<br>&nbsp;&nbsp;&nbsp;&nbsp;}<br>}<br>Main.greeting(); |
| Julia     | print("Hello Julia!\n")<br><br># Define a function to calculate the square of a number<br>function square(number::Int) <br>&nbsp;&nbsp;&nbsp;&nbsp;return number * number<br>end<br><br># Use the function to calculate the square of 5<br>num = 5<br><br># Print the result<br>println("The square of ", num, " is ", square(num))<br> |
| Node.js   | const http = require('http');<br><br>// Create the server<br>const server = http.createServer((req, res) => {<br>&nbsp;&nbsp;&nbsp;&nbsp;// Configure the server response<br>&nbsp;&nbsp;&nbsp;&nbsp;res.statusCode = 200;<br>&nbsp;&nbsp;&nbsp;&nbsp;res.setHeader('Content-Type', 'text/plain');<br>&nbsp;&nbsp;&nbsp;&nbsp;res.end('Hello, from JupyterLab Container!');<br>});<br><br>// Define the port on which the server will run<br>const port = 3000;<br><br>// Start the server<br>server.listen(port, () => {<br>&nbsp;&nbsp;&nbsp;&nbsp;console.log('Node.js server is running at http://localhost:' + port + '/');<br>});<br> |
| Kotlin    | fun main() {<br>&nbsp;&nbsp;&nbsp;&nbsp;// Print "Hello, Kotlin!"<br>&nbsp;&nbsp;&nbsp;&nbsp;println("Hello, Kotlin!")<br><br>&nbsp;&nbsp;&nbsp;&nbsp;// Define a function to calculate the square of a number<br>&nbsp;&nbsp;&nbsp;&nbsp;fun calculateSquare(number: Int): Int {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return number * number<br>&nbsp;&nbsp;&nbsp;&nbsp;}<br><br>&nbsp;&nbsp;&nbsp;&nbsp;// Use the function to calculate the square of 5<br>&nbsp;&nbsp;&nbsp;&nbsp;val result = calculateSquare(5)<br>&nbsp;&nbsp;&nbsp;&nbsp;println("Square of 5: \$result")<br>}<br>main() |
| R         | # Print "Hello, R!"<br>cat("Hello, R!\n")<br><br># Define a function to calculate the square of a number<br>calculateSquare <- function(number) {<br>&nbsp;&nbsp;&nbsp;&nbsp;return (number * number)<br>}<br><br># Use the function to calculate the square of 5<br>result <- calculateSquare(5)<br>cat("Square of 5: ", result, "\n")<br> |
| Rust      | fn main() {<br>&nbsp;&nbsp;&nbsp;&nbsp;// Print "Hello, Rust!"<br>&nbsp;&nbsp;&nbsp;&nbsp;println!("Hello, Rust!");<br><br>&nbsp;&nbsp;&nbsp;&nbsp;// Define a function to calculate the square of a number<br>&nbsp;&nbsp;&nbsp;&nbsp;fn calculate_square(number: i32) -> i32 {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return number * number;<br>&nbsp;&nbsp;&nbsp;&nbsp;}<br><br>&nbsp;&nbsp;&nbsp;&nbsp;// Use the function to calculate the square of 5<br>&nbsp;&nbsp;&nbsp;&nbsp;let result = calculate_square(5);<br>&nbsp;&nbsp;&nbsp;&nbsp;println!("Square of 5: {}", result);<br>}<br>main() |
| Scala     | println("Hello, Scala!")<br><br>// Define a function to calculate the square of a number<br>def calculateSquare(number: Int): Int = {<br>&nbsp;&nbsp;&nbsp;&nbsp;number * number<br>}<br><br>// Use the function to calculate the square of 5<br>val result = calculateSquare(5)<br><br>// Print the result<br>println("The square of 5 is: " + result)<br> |


# Relevant Packages & Installed Apps
| Package | Version |Port|
|---------|--------|-----|
| Apache Spark UI| 3.4.3| 4040|
| Node.js     | 18.13.0|3000   |
| Kafka       | 3.6.1| 9091-9094|
| Panel| 1.3.8 |5006|
| jupyterlab | 4.0.16 | 8888|
| dbt-docs server| 1.7.4|8081|
| apache-airflow| 2.8.0| 8082 |
| jenkins| 2.440.2 | 8083|
| pyspark | 3.4.3 | 4040|
| confluent-kafka | 2.3.0| 
| jupyterlab-git | 0.50.0 |
| pandas | 2.2.2 |
| apache-beam[interactive] | 2.55.1 |
| dask | 2024.1.0 |
| duckdb| 0.9.2 |
| scikit-learn|  1.4.0| 
| OpenCV Python|  4.9.0.80| 
| Spacy|  3.7.2| 
| NLTK|  3.8.1| 
| bokeh |  3.3.4 | 
| seaborn|  0.13.2 | 
| dbt-core| 1.7.4|
| mysql-connector-python | 8.3.0|
| psycopg2 | 2.9.9 |
| pymongo | 4.6.1 |
| Faker | 22.5.1 |
| itables | 1.6.3 |
| pytest| 8.0.0 |
| diagrams| 0.23.4 |
| jupyterlab_code_formatter| 2.2.1 |
| black| 24.1.2 |
| isort| 5.13.2 |
| autopep8| 2.1.0 |
| yapf| 0.40.2 |
| pycodestyle| 2.11.1 |
| jupyterlab-indent-guides| 0.1.0 |
| jupyterlab-lsp| 5.1.0 |
| python-language-server| 0.36.2 |
| AnsiColorPrinter|  0.0.2| 
| Pyxtension| 1.16.10| 
| delta-spark | 2.4.0| 
| mlflow | 2.17.2| 

# EXAMPLES OF INSTALLED PACKAGES
## 🐳 ```Test Basic Packages Notebook GUIDE```  <a href="https://github.com/JorgeCardona/recursos/blob/main/Notebooks/Test%20Basic%20Functions%20and%20Packages.ipynb" target="_blank">CLICK HERE </a>🐳

## You can use the following examples for testing, just copy and paste the following code to test each package.
| Package          | Description                                                 | Advantages                                                     | Disadvantages                                                 | Example                                                                                                                                                                                                                                                                                 |
|------------------|-------------------------------------------------------------|----------------------------------------------------------------|---------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Itables          | tabular data manipulation in Python.                        | SQL-like syntax for querying.                                 | May be less efficient for advanced operations compared to specialized libraries. | # **to enable itables**<br>from itables import init_notebook_mode<br>init_notebook_mode(all_interactive=True)                                                                                                                                                                          |
| Pyspark          | distributed processing with Apache Spark                     | - Distributed and scalable processing                        | - Complex configuration and management                          | from pyspark.sql import SparkSession<br><br># Create a SparkSession<br>spark = SparkSession.builder.appName("JorgeCardonaSpark").getOrCreate()<br><br># Perform a simple DataFrame operation<br>data = [('Nathalie', 0), ('Ana', 3), ('Diana', 7), ('Lucia', 10), ('Tatiana', 13), ('Angela', 17), ('Cecilia', 25), ('Alice', 31), ('Kristin', 35), ('Carolina', 37), ('Lina', 39), ('Marcela', 40), ('Maria', 42)]<br><br># Create a Dataframe<br>df = spark.createDataFrame(data, ["Name", "Age"])<br>df.show() <br>spark.stop() |
| Pandas           | data manipulation and analysis                             | - Efficient data manipulation and analysis functions         | - Limitations in handling large volumes of data                | import pandas as pd<br><br>data = {<br>&nbsp;&nbsp;&nbsp;&nbsp;'Name': ["Nathalie", "Ana", "Diana", "Lucia", "Tatiana", "Angela", "Cecilia", "Alice", "Kristin", "Carolina", "Lina", "Marcela", "Maria"],<br>&nbsp;&nbsp;&nbsp;&nbsp;'Age': [0, 3, 7, 10, 13, 17, 25, 31, 35, 37, 39, 40, 42]<br>}<br>df = pd.DataFrame(data)<br>df |
| Apache-beam      | Programming model for data processing                       | - High-level abstraction for data processing                 | - Requires knowledge of parallel programming                   | import apache_beam as beam<br><br>def regular_case_function(element):<br>&nbsp;&nbsp;&nbsp;&nbsp;return element.lower()<br><br>def to_uppercase_function(element):<br>&nbsp;&nbsp;&nbsp;&nbsp;return element.upper()<br><br>def calculate_length_function(element):<br>&nbsp;&nbsp;&nbsp;&nbsp;return len(element)<br><br>def calculate_square_function(element):<br>&nbsp;&nbsp;&nbsp;&nbsp;return element ** 2<br><br># Create a pipeline<br>with beam.Pipeline() as pipeline:<br>&nbsp;&nbsp;&nbsp;&nbsp;# Prepare a list of names to be processed<br>&nbsp;&nbsp;&nbsp;&nbsp;names_list = ["Nathalie", "Ana", "Diana", "Lucia", "Tatiana", "Angela", "Cecilia", "Alice", "Kristin", "Carolina", "Lina", "Marcela", "Maria"]<br><br>&nbsp;&nbsp;&nbsp;&nbsp;# Create a PCollection with the given data<br>&nbsp;&nbsp;&nbsp;&nbsp;data = pipeline \| beam.Create(names_list)<br><br>&nbsp;&nbsp;&nbsp;&nbsp;# Apply transformation functions to the data<br>&nbsp;&nbsp;&nbsp;&nbsp;regular_case_data = data \| beam.Map(regular_case_function)  # Transform to lowercase<br>&nbsp;&nbsp;&nbsp;&nbsp;uppercase_data = data \| beam.Map(to_uppercase_function)  # Transform to uppercase<br>&nbsp;&nbsp;&nbsp;&nbsp;length_data = data \| beam.Map(calculate_length_function)  # Apply transformation to calculate the length of each name<br>&nbsp;&nbsp;&nbsp;&nbsp;square_data = length_data \| beam.Map(calculate_square_function)  # Apply transformation to calculate the square<br><br>&nbsp;&nbsp;&nbsp;&nbsp;# Print the results of each transformation<br>&nbsp;&nbsp;&nbsp;&nbsp;length_data \| "Show_Length" >> beam.Map(print)  # Print length results<br>&nbsp;&nbsp;&nbsp;&nbsp;regular_case_data \| "Show_Lowercase" >> beam.Map(print)  # Print lowercase results<br>&nbsp;&nbsp;&nbsp;&nbsp;uppercase_data \| "Show_Uppercase" >> beam.Map(print)  # Print uppercase results<br>&nbsp;&nbsp;&nbsp;&nbsp;square_data \| "Show_Square" >> beam.Map(print)  # Print square results <br>&nbsp;&nbsp;&nbsp;&nbsp;combined_data = (length_data, regular_case_data, uppercase_data, square_data) \| beam.Flatten() <br>&nbsp;&nbsp;&nbsp;&nbsp;combined_data \| "Show_All" >> beam.Map(print)|
| Faker            | Generating simulated data                                   | - Easy generation of simulated data                          | - Not suitable for production environments                     | `from faker import Faker`<br>`fake = Faker()`<br>`name = fake.name()`<br>`print(name)` |
| Panel            | Creating interactive dashboards and apps                    | - Powerful dashboard and app creation capabilities           | - Requires learning the Panel library                          | import panel as pn<br><br>def model(n=5):<br>&nbsp;&nbsp;&nbsp;&nbsp;return "⭐"*n<br><br>pn.extension()<br><br>slider = pn.widgets.IntSlider(value=5, start=1, end=5)<br><br>interactive_model = pn.bind(model, n=slider)<br><br>layout = pn.Column(slider, interactive_model)<br><br>app = pn.serve(layout, port=5006, show=True)<br><br> #app.stop() <br><br> # ✨ Panel UI APP ```http://localhost:5006```  <a href=" http://localhost:5006" target="_blank">CLICK HERE </a>✨|
| Seaborn          | Data visualization library based on Matplotlib              | - Easy syntax for creating attractive statistical graphics   | - May not be as customizable as Matplotlib                    | import seaborn as sns<br>import matplotlib.pyplot as plt<br><br># Load the "tips" dataset from Seaborn<br>tips = sns.load_dataset("tips")<br><br># Create a scatter plot with Matplotlib<br>plt.figure(figsize=(10, 7))<br>plt.scatter(x='total_bill', y='tip', data=tips, alpha=0.7)<br>plt.title('Scatter Plot of Total Bill vs Tip')<br>plt.xlabel('Total Bill')<br>plt.ylabel('Tip')<br>plt.show()|
| Bokeh            | Interactive visualization library                           | - Interactive and web-ready visualizations                   | - Learning curve for advanced features                        | from bokeh.plotting import figure, show<br>from bokeh.io import output_notebook<br>import seaborn as sns<br><br># Load the "tips" dataset from Seaborn<br>tips = sns.load_dataset("tips")<br><br># Enable output in the notebook<br>output_notebook()<br><br># Create a scatter plot using Bokeh with custom size<br>p = figure(<br>&nbsp;&nbsp;&nbsp;&nbsp;title="Scatter Plot of Total Bill vs Tip",<br>&nbsp;&nbsp;&nbsp;&nbsp;x_axis_label='Total Bill',<br>&nbsp;&nbsp;&nbsp;&nbsp;y_axis_label='Tip',<br>&nbsp;&nbsp;&nbsp;&nbsp;width=900,  # adjust as needed<br>&nbsp;&nbsp;&nbsp;&nbsp;height=500  # adjust as needed<br>)<br><br># Add the data to the plot<br>p.circle(x='total_bill', y='tip', source=tips, size=8, color="navy", alpha=0.5)<br><br># Show the plot in the notebook<br>show(p)|
| Package Diagrams | Drawing package diagrams                                    | - Provides a simple and intuitive way to create package diagrams | - Limited customization options                                | <br>from diagrams import Diagram <br>from diagrams.aws.compute import EC2 <br>from diagrams.aws.database import RDS <br>from diagrams.aws.network import ELB <br><br>with Diagram("Grouped Workers", show=False, direction="TB"): <br>&nbsp;&nbsp;&nbsp;&nbsp;ELB("lb") >> [ <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;EC2("worker1"),<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;EC2("worker2"),<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;EC2("worker3"),<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;EC2("worker4"),<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;EC2("worker5")<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;] >> RDS("events") <br>|
| AnsiColorPrinter | A Python package for printing text in various ANSI colors.                                | Easy-to-use functions for colorizing text.      | Limited functionality compared to others.       | <br>import AnsiColorPrinter as acp<br><br># Print red text<br>print(acp.red("Hello, World!"))<br><br># Print bold blue text<br>print(acp.blue("Welcome!", formats=["bold"]))<br><br># Print bold red multiple formats<br>print(acp.cyan("Multi Formats", formats=['underlined', 'bold', 'reverse'])) |
| Pyxtension   | A Python package providing extended functionality and tools.   | Simplifies common data manipulation tasks.                    | May have a learning curve for beginners.                     | `from pyxtension.streams import stream`<br><br>`data = [{'name': 'Alice', 'age': 28, 'gender': 'F'},{'name': 'Bob', 'age': 23, 'gender': 'M'},{'name': 'Charlie', 'age': 35, 'gender': 'M'},{'name': 'David', 'age': 22, 'gender': 'M'},{'name': 'Eve', 'age': 30, 'gender': 'F'},{'name': 'Frank', 'age': 26, 'gender': 'M'},{'name': 'Grace', 'age': 29, 'gender': 'F'},{'name': 'Hank', 'age': 31, 'gender': 'M'},{'name': 'Ivy', 'age': 24, 'gender': 'F'},{'name': 'Jack', 'age': 27, 'gender': 'M'}]`<br><br>`print(stream(data).filter(lambda person: person['age'] > 25).map(lambda person: person['name']).toList())`<br>`print(stream(data).map(lambda person: person['age']).toList())`<br>`print(stream(data).map(lambda person: person['age']).mean())`<br>`print(stream(data).min(lambda person: person['age'])['name'])`<br>`print(stream(data).map(lambda person: {'name': person['name'].upper(), 'age': person['age'], 'gender': person['gender']}).toList())`<br>`print(stream(data).map(lambda person: person['name']).join(", "))`<br>`print(stream(data).sorted(key=lambda person: person['age']).toList())`<br>`print(stream(data).map(lambda person: person['age']).sum())`<br>`print(len(stream(data).filter(lambda person: person['age'] > 30).toList()))`<br>`print(dict(stream(data).map(lambda person: (person['name'], person['age'])).toList()))`<br>`print(stream(data).filter(lambda person: person['age'] > 25).filter(lambda person: 'c' in person['name'].lower()).map(lambda person: person['gender']).reduce(lambda acc, gender: {**acc, gender: acc.get(gender, 0) + 1}, {}))` |

### ADDED SUPPORT TO CONNECT SPARK FOR EXTRACTION DATA FROM MySQL, MongoDB, AND PostgreSQL
# PING to databases MySQL, MongoDB, PostgreSQL
# USE TEMPORAL DOCKER IMAGES FOR TESTING,  delete  *--rm* on docker command to do persistent databases

# DOCKER FOR PostgreSQL
##  `docker run --name jorgecardona-postgres --rm -e POSTGRES_DB=spark -e POSTGRES_PASSWORD=12345678 -e POSTGRES_USER=admin -d -p 5432:5432 postgres:15.4`

# DOCKER FOR MySQL
##  `docker run --name jorgecardona-mysql --rm -e MYSQL_DATABASE=spark -e MYSQL_PASSWORD=12345678 -e MYSQL_USER=admin -e MYSQL_ROOT_PASSWORD=root -d -p 3306:3306 mysql:8.4.0`

# DOCKER FOR SQL SERVER
`user: sa`
`pass: Admin@123`

###  `docker run --name jorgecardona-sqlserver -d --rm -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Admin@123" -e "MSSQL_DATA_DIR=/var/opt/mssql/data" -e "MSSQL_PID=Developer" -e "MSSQL_TCP_PORT=1433" -p 1433:1433 --hostname jorgecardona-sqlserver mcr.microsoft.com/mssql/server:2022-latest`

# DOCKER FOR MongoDB
###  `docker run --name jorgecardona-mongodb --rm -d -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=12345678 mongodb/mongodb-community-server:6.0.7-ubuntu2204-20230812T065949Z`

# STRING CONNECTION FOR SPECIFIC MONGO DB HOST
# `mongodb://admin:12345678@localhost:27017` 

# STRING CONNECTION FOR LOCAL DOCKER MONGO DB
# `mongodb://admin:12345678@host.docker.internal:27017`

# DBT EXAMPLE CONFIGURATION
```
dbt init dbt_poc
Enter a number: 1
host (hostname for the instance): host.docker.internal
port [5432]: 5432
user (dev username): admin
pass (dev password): 12345678
dbname (default database that dbt will build objects in): spark
schema (default schema that dbt will build objects in): public
threads (1 or more) [1]: 1
```

# DBT TESTING
```
cd  dbt_poc
dbt debug # test connection
dbt run # creates the tables
dbt docs generate # generates documentation
dbt docs serve --port 8081
```
## 🌀 dbt_poc DOCUMENTATION <a href="http://localhost:8081" target="_blank">CLICK HERE</a> 🌀

# AIRFLOW TESTING
```
airflow scheduler
airflow webserver -p 8082
user : admin
pass: 12345678
```
## 💠 Airflow Interface <a href="http://localhost:8082" target="_blank">CLICK HERE</a>💠

# Jenkins TESTING
```
service jenkins start
user : admin
pass: 12345678
```
## 💠 Jenkins Interface <a href="http://localhost:8083" target="_blank">CLICK HERE</a>💠

## 💠 Apache Nifi Interface <a href="https://localhost:8443/nifi/login" target="_blank">CLICK HERE</a>💠
```
# check user and password in the docker logs
docker run --name jorgecardona-nifi -p 8443:8443 -d -e NIFI_WEB_HTTPS_PORT='8443' jorgecardona/nifi:2.0.0-M4
```

# KAFKA TESTING, RUN ZOOKEEPER, START BROKERS, LIST BROKERS, KAFKA SPARK STREAMING AND BATCH
## 🐳 ```Spark-Kafka Notebook GUIDE```  <a href="https://github.com/JorgeCardona/recursos/blob/main/docker_hub/jupyterlab_multilanguages_dockerfile/Spark-Kafka-Confluence-Batch-Streaming-MlLib.ipynb" target="_blank">CLICK HERE </a>🐳

## 🐳 ```Testing Connections```  <a href="https://github.com/JorgeCardona/recursos/blob/main/docker_hub/jupyterlab_multilanguages_dockerfile/Test%20Connections%20Updated.ipynb" target="_blank">CLICK HERE </a>🐳

## 🐳 ```Testing Packages```  <a href="https://github.com/JorgeCardona/recursos/blob/main/docker_hub/jupyterlab_multilanguages_dockerfile/Test%20Packages%20Updated.ipynb" target="_blank">CLICK HERE </a>🐳

## 🐳 ```DBT Examples```  <a href="https://github.com/JorgeCardona/recursos/tree/main/DBT" target="_blank">CLICK HERE </a>🐳

## 🐳 ```Execution Plan And Partitioning Example Postgresql```  <a href="https://github.com/JorgeCardona/recursos/blob/main/datasets/README.md" target="_blank">CLICK HERE </a>🐳

## 🐳 ```How to Publish Packages in PyPi```  <a href="https://github.com/JorgeCardona/PipPackageInstaller" target="_blank">CLICK HERE </a>🐳