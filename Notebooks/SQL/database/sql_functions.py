import sqlite3
import pandas as pd
import os
import pprint

# 1. Función reutilizable para ejecutar SQL y retornar un DataFrame
def ejecutar_sql(query: str, db_path: str = "ecommerce.db") -> pd.DataFrame:
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
def preparar_base_de_datos(sql_file_path: str = "schema.sql", db_path: str = "ecommerce.db"):
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

def obtener_lista_tablas(db_path: str = "ecommerce.db") -> list[str]:
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

def obtener_columnas_tabla(nombre_tabla: str, db_path: str = "ecommerce.db") -> pd.DataFrame:
    """
    Consulta la estructura de una tabla específica utilizando PRAGMA table_info
    y devuelve un DataFrame con el ID, nombre, tipo de dato, nulidad y clave primaria.
    """
    query = f"PRAGMA table_info({nombre_tabla});"
    return ejecutar_sql(query, db_path)

def mostrar_esquema_tablas(db_path: str = "ecommerce.db", como_diccionario: bool = False):
    """
    Muestra el esquema de la base de datos.
    - Si como_diccionario=False: Imprime un listado limpio por consola en formato de texto.
    - Si como_diccionario=True: Imprime y devuelve el esquema estructurado como un diccionario de Python.
    """
    tablas = obtener_lista_tablas(db_path)
    
    if como_diccionario:
        esquema_dict = {}
        for tabla in tablas:
            df_cols = obtener_columnas_tabla(tabla, db_path)
            columnas_info = {}
            for _, row in df_cols.iterrows():
                tipo = row['type']
                if row['pk'] > 0:
                    tipo += " (PK)"
                if row['notnull'] == 1:
                    tipo += " [NOT NULL]"
                columnas_info[row['name']] = tipo
            esquema_dict[tabla] = columnas_info
        
        pprint.pprint(esquema_dict)
        return esquema_dict
    else:
        for tabla in tablas:
            print(f"\n📂 Tabla: {tabla.upper()}")
            print("-" * 40)
            df_cols = obtener_columnas_tabla(tabla, db_path)
            for _, row in df_cols.iterrows():
                pk_str = " (PK)" if row['pk'] > 0 else ""
                nn_str = " [NOT NULL]" if row['notnull'] == 1 else ""
                print(f"  • {row['name']} : {row['type']}{pk_str}{nn_str}")


import json


def obtener_esquema_como_dataframe(
    db_path: str = "ecommerce.db", como_json: bool = False
) -> pd.DataFrame:
  """Devuelve un DataFrame de Pandas con todo el esquema de la base de datos.

  Configura Pandas para evitar cualquier tipo de truncamiento.
  - Si como_json=False: Columnas -> tabla, columna, tipo
  - Si como_json=True: Columnas -> tabla, columnas (en formato JSON)
  """
  # Configurar pandas para que no se trunque la salida
  pd.set_option("display.max_rows", None)
  pd.set_option("display.max_columns", None)
  pd.set_option("display.max_colwidth", None)
  pd.set_option("display.width", 1000)

  tablas = obtener_lista_tablas(db_path)
  registros = []

  for tabla in tablas:
    df_cols = obtener_columnas_tabla(tabla, db_path)

    if como_json:
      columnas_info = {}
      for _, row in df_cols.iterrows():
        tipo = row["type"]
        if row["pk"] > 0:
          tipo += " (PK)"
        if row["notnull"] == 1:
          tipo += " [NOT NULL]"
        columnas_info[row["name"]] = tipo

      registros.append({
          "tabla": tabla,
          "columnas": json.dumps(columnas_info, ensure_ascii=False),
      })
    else:
      for _, row in df_cols.iterrows():
        tipo = row["type"]
        if row["pk"] > 0:
          tipo += " (PK)"
        if row["notnull"] == 1:
          tipo += " [NOT NULL]"

        registros.append({"tabla": tabla, "columna": row["name"], "tipo": tipo})

  return pd.DataFrame(registros)