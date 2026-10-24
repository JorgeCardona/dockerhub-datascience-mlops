import sqlite3
import json
import random
from datetime import datetime, timedelta

DB_PATH = "ecommerce_estudio.db"

# Listas de apoyo para datos realistas
PAGES_VISITED = ["/home", "/product_detail", "/cart", "/checkout", "/search", "/profile"]
EVENT_TYPES = ["page_view", "add_to_cart", "checkout_init", "search", "click_banner"]
COUNTRIES = ["ES", "MX", "CO", "AR", "CL", "PE"]
PAYMENT_METHODS = ["credit_card", "paypal", "bank_transfer", "debit_card"]
ORDER_STATUSES = ["completed", "completed", "completed", "pending", "cancelled", "refunded"]
THEMES = ["dark", "light"]
TAGS_POOL = ["vip", "frequent", "newbie", "tech_lover", "gamer", "casual"]

FIRST_NAMES = ["Carlos", "Ana", "Miguel", "Laura", "Sofia", "Javier", "Elena", "Diego", "Lucia", "Mateo"]
LAST_NAMES = ["Gomez", "Rodriguez", "Lopez", "Perez", "Martinez", "Sanchez", "Fernandez", "Gonzalez"]

def entrenar_y_poblar_todo(n_muestras_usuario: int = 100, db_path: str = DB_PATH):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("PRAGMA foreign_keys = ON;")

    print(f"\nGenerando {n_muestras_usuario} usuarios sintéticos e interacciones de forma instantánea...")

    # Obtener catálogo de productos existente
    cursor.execute("SELECT product_id, price FROM products")
    productos_db = cursor.fetchall()
    if not productos_db:
        productos_db = [(101, 49.99), (102, 19.99), (103, 89.99)]

    usuarios_creados = 0
    ordenes_creadas = 0
    eventos_creados = 0

    cursor.execute("BEGIN TRANSACTION;")

    for idx in range(1, n_muestras_usuario + 1):
        # 1. Generar USUARIO
        nombre = f"{random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}"
        email = f"user_syn_{idx}_{random.randint(1000, 9999)}@estudio.com"
        pais = random.choice(COUNTRIES)
        dias_antiguedad = random.randint(1, 365)
        fecha_registro = (datetime.now() - timedelta(days=dias_antiguedad)).strftime("%Y-%m-%d %H:%M:%S")

        profile_json = json.dumps({
            "age": random.randint(18, 65),
            "preferences": {"theme": random.choice(THEMES), "notifications": random.choice([True, False])},
            "tags": random.sample(TAGS_POOL, k=random.randint(1, 3))
        })

        cursor.execute("""
            INSERT INTO users (full_name, email, country, signup_date, profile_data)
            VALUES (?, ?, ?, ?, ?)
        """, (nombre, email, pais, fecha_registro, profile_json))
        
        user_id = cursor.lastrowid
        usuarios_creados += 1

        # 2. Generar ÓRDENES (Entre 0 y 3 órdenes por usuario)
        num_ordenes = random.choices([0, 1, 2, 3], weights=[0.2, 0.5, 0.2, 0.1])[0]
        for _ in range(num_ordenes):
            estado = random.choice(ORDER_STATUSES)
            metodo = random.choice(PAYMENT_METHODS)
            fecha_orden = (datetime.now() - timedelta(days=random.randint(0, dias_antiguedad))).strftime("%Y-%m-%d %H:%M:%S")

            cursor.execute("""
                INSERT INTO orders (user_id, order_date, status, payment_method)
                VALUES (?, ?, ?, ?)
            """, (user_id, fecha_orden, estado, metodo))
            
            order_id = cursor.lastrowid
            ordenes_creadas += 1

            # Generar ítems por orden (1 a 3 ítems)
            items_compra = random.sample(productos_db, k=random.randint(1, min(3, len(productos_db))))
            for prod_id, precio in items_compra:
                cantidad = random.randint(1, 3)
                descuento = random.choice([0.0, 0.0, 0.0, 5.0, 10.0])
                cursor.execute("""
                    INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
                    VALUES (?, ?, ?, ?, ?)
                """, (order_id, prod_id, cantidad, precio, descuento))

        # 3. Generar EVENT_LOGS (Entre 1 y 5 eventos por usuario)
        num_eventos = random.randint(1, 5)
        for _ in range(num_eventos):
            tipo_evento = random.choice(EVENT_TYPES)
            fecha_evento = (datetime.now() - timedelta(days=random.randint(0, dias_antiguedad))).strftime("%Y-%m-%d %H:%M:%S")
            
            event_meta = json.dumps({
                "page": random.choice(PAGES_VISITED),
                "session_time_sec": random.randint(5, 600),
                "device": random.choice(["mobile", "desktop", "tablet"])
            })

            cursor.execute("""
                INSERT INTO event_logs (user_id, event_type, event_timestamp, metadata)
                VALUES (?, ?, ?, ?)
            """, (user_id, tipo_evento, fecha_evento, event_meta))
            eventos_creados += 1

    conn.commit()
    conn.close()

    print("\n==========================================")
    print("      POBLADO RELACIONAL COMPLETADO       ")
    print("==========================================")
    print(f"✔ Usuarios creados: {usuarios_creados}")
    print(f"✔ Órdenes creadas:  {ordenes_creadas}")
    print(f"✔ Eventos creados:  {eventos_creados}")
    print("==========================================\n")

if __name__ == "__main__":
    entrenar_y_poblar_todo(n_muestras_usuario=100)