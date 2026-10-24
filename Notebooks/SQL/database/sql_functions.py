import sqlite3
import pandas as pd
import os

# 1. Función reutilizable para ejecutar SQL y retornar un DataFrame
def ejecutar_sql(query: str, db_path: str = "ecommerce_estudio.db") -> pd.DataFrame:
    """
    Ejecuta una consulta SQL en la base de datos SQLite especificada
    y devuelve los resultados formateados como un DataFrame de Pandas.
    """
    conn = sqlite3.connect(db_path)
    try:
        df = pd.read_sql_query(query, conn)
        return df
    finally:
        conn.close()

# 2. Función para inicializar la base de datos con los datos de prueba
def preparar_base_de_datos(sql_file_path: str = "schema.sql", db_path: str = "ecommerce_estudio.db"):
    """
    Lee un archivo .sql externo y lo ejecuta en la base de datos SQLite.
    """
    if not os.path.exists(sql_file_path):
        raise FileNotFoundError(f"El archivo {sql_file_path} no fue encontrado.")
    
    # Leer el archivo SQL
    with open(sql_file_path, "r", encoding="utf-8") as f:
        script_poblado = f.read()

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("PRAGMA foreign_keys = ON;")
    
    # Ejecutar todas las sentencias del script
    cursor.executescript(script_poblado)
    
    conn.commit()
    conn.close()
    print("Base de datos Generada, Correctamente a partir del archivo .sql")

def obtener_lista_tablas(db_path: str = "ecommerce_estudio.db") -> list[str]:
    """
    Consulta sqlite_master y devuelve una lista con los nombres de todas las tablas.
    """
    query = "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';"
    
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute(query)
    
    # Extraer el primer elemento de cada tupla en los resultados
    tablas = [row[0] for row in cursor.fetchall()]
    
    conn.close()
    return tablas