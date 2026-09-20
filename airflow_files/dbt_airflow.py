from airflow.decorators import dag
from airflow.operators.bash import BashOperator
from datetime import datetime
from time import sleep

# =========================
# VARIABLES REUTILIZABLES
# =========================
BASE_DIRECTORY = "/notebooks"
DBT_PROJECT_NAME = "dbt_poc"
DBT_DIRECTORY = f"{BASE_DIRECTORY}/{DBT_PROJECT_NAME}"
DBT_DOCS_PORT = 8081
DBT_DOCS_LOG = "/tmp/dbt_docs.log"


# ============================================================
# DAG 1 — DBT_FULL_PROCCESS
# ============================================================
@dag(
    schedule="0 5 * * *",
    max_active_runs=3,
    start_date=datetime(2021, 1, 1),
    catchup=False,
    tags=["DBT_FULL_PROCCESS"],
)
def dbt_run_full_dbt_configuration():

    def dbt_config():
        return f"""
        cd {BASE_DIRECTORY} &&
        echo -e "1\nhost.docker.internal\n5432\nadmin\n12345678\nspark\npublic\n1" | dbt init {DBT_PROJECT_NAME} || true
        """

    def change_directory_dbt_project():
        return f"cd {DBT_DIRECTORY} && pwd"

    def show_version():
        return "dbt -v"

    def test_connection():
        return f"cd {DBT_DIRECTORY} && dbt debug"

    def run_dbt():
        return f"cd {DBT_DIRECTORY} && dbt run"

    def generate_documentation():
        return f"cd {DBT_DIRECTORY} && dbt docs generate"

    def start_documentation_server():
        return f"""
        cd {DBT_DIRECTORY} &&
        echo "dbt docs server running at http://localhost:{DBT_DOCS_PORT}" &&
        nohup dbt docs serve --host 0.0.0.0 --port {DBT_DOCS_PORT} \
        > {DBT_DOCS_LOG} 2>&1 &
        """

    dbt_config_task = BashOperator(
        task_id="creates_the_dbt_configuration",
        bash_command=dbt_config(),
    )

    change_directory_task = BashOperator(
        task_id="change_directory_bash_task",
        bash_command=change_directory_dbt_project(),
    )

    show_version_task = BashOperator(
        task_id="show_version_bash_task",
        bash_command=show_version(),
    )

    test_connection_task = BashOperator(
        task_id="test_connection_bash_task",
        bash_command=test_connection(),
    )

    run_dbt_task = BashOperator(
        task_id="run_dbt_bash_task",
        bash_command=run_dbt(),
    )

    generate_documentation_task = BashOperator(
        task_id="generate_documentation_bash_task",
        bash_command=generate_documentation(),
    )

    start_documentation_server_task = BashOperator(
        task_id="start_documentation_server_bash_task",
        bash_command=start_documentation_server(),
    )

    (
        dbt_config_task
        >> change_directory_task
        >> show_version_task
        >> test_connection_task
        >> run_dbt_task
        >> generate_documentation_task
        >> start_documentation_server_task
    )


dag_dbt_run = dbt_run_full_dbt_configuration()


# ==========================================
# DAG 2 — DBT_START
# ==========================================
@dag(
    schedule="0 5 * * *",
    max_active_runs=3,
    start_date=datetime(2021, 1, 1),
    catchup=False,
    tags=["DBT_START"],
)
def dbt_run_documentation_server_start():

    def change_directory():
        return f"cd {DBT_DIRECTORY} && pwd"

    def show_version():
        return "dbt -v"

    def test_connection():
        return f"cd {DBT_DIRECTORY} && dbt debug"

    def run_dbt():
        return f"cd {DBT_DIRECTORY} && dbt run"

    def generate_documentation():
        return f"cd {DBT_DIRECTORY} && dbt docs generate"

    def start_documentation_server():
        return f"""
        cd {DBT_DIRECTORY} &&
        nohup dbt docs serve --host 0.0.0.0 --port {DBT_DOCS_PORT} \
        > {DBT_DOCS_LOG} 2>&1 &
        """

    change_directory_task = BashOperator(
        task_id="change_directory_bash_task",
        bash_command=change_directory(),
    )

    show_version_task = BashOperator(
        task_id="show_version_bash_task",
        bash_command=show_version(),
    )

    test_connection_task = BashOperator(
        task_id="test_connection_bash_task",
        bash_command=test_connection(),
    )

    run_dbt_task = BashOperator(
        task_id="run_dbt_bash_task",
        bash_command=run_dbt(),
    )

    generate_documentation_task = BashOperator(
        task_id="generate_documentation_bash_task",
        bash_command=generate_documentation(),
    )

    start_documentation_server_task = BashOperator(
        task_id="start_documentation_server_bash_task",
        bash_command=start_documentation_server(),
    )

    (
        change_directory_task
        >> show_version_task
        >> test_connection_task
        >> run_dbt_task
        >> generate_documentation_task
        >> start_documentation_server_task
    )


dag_dbt_run_start = dbt_run_documentation_server_start()


# ==========================================
# DAG 3 — DBT_STOP
# ==========================================
@dag(
    schedule="0 5 * * *",
    max_active_runs=3,
    start_date=datetime(2021, 1, 1),
    catchup=False,
    tags=["DBT_STOP"],
)
def dbt_documentation_server_stop():

    def stop_documentation_server():
        sleep(5)
        return 'pkill -f "dbt docs serve" || true'

    stop_documentation_server_task = BashOperator(
        task_id="stop_documentation_server_bash_task",
        bash_command=stop_documentation_server(),
    )

    stop_documentation_server_task


dag_stop_server = dbt_documentation_server_stop()