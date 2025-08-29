# https://emojipedia.org
# https://gist.github.com/rxaviers/7360908
Repository with projects especially focused on Computer Science and Natural Sciences.

![Alt text](resources/clean_architecture.jpg)

# 🧼 Microservicio en Python con Arquitectura Limpia

Este proyecto es una plantilla base para construir microservicios en Python siguiendo los principios de **Arquitectura Limpia**. Su objetivo es mantener la lógica de negocio aislada de tecnologías externas (frameworks, bases de datos, APIs), promoviendo un diseño desacoplado, testable y mantenible.

---

## 📚 Principios Fundamentales

- **Independencia de frameworks**: el dominio y los casos de uso no dependen de frameworks web, librerías ORM ni herramientas externas.
- **Separación de responsabilidades**: cada carpeta y módulo cumple una función específica.
- **Inversión de dependencias**: las capas externas dependen del dominio, nunca al revés.
- **Testabilidad**: se pueden probar casos de uso y lógica de negocio sin necesidad de ejecutar la infraestructura.

---
# 🐍 SCAFFOLDING FOR CLEAN ARCHITECTURE IN MICROSERVICES

```
📦jorge_cardona_project [project_directory]
┣ 📂 application [package]
┃ ┣ 📂 configuration [package]       ← Configuración de entorno (puertos, URIs, logging, settings)
┃ ┣ 📂 utils [package]               ← Funciones auxiliares generales
┃ ┣ 📂 domain [package]              ← Núcleo de negocio (arquitectura limpia)
┃ ┃ ┣ 📂 entities [package]          ← Modelos puros con @dataclass
┃ ┃ ┣ 📂 interfaces [package]        ← Contratos abstractos
┃ ┃ ┃ ┣ 📂 repositories [package]    ← Interfaces de persistencia (ej. UserRepository)
┃ ┃ ┃ ┗ 📂 business_logic [package]  ← Interfaces de lógica externa (ej. EmailSender)
┃ ┃ ┣ 📂 usecases [package]          ← Casos de uso del sistema
┃ ┃ ┣ 📂 services [package]          ← Servicios del dominio (reglas reutilizables)
┃ ┗ 📄 main.py [executable]          ← Punto de entrada (__main__)
┣ 📂 deployment [package]            ← Docker, Kubernetes y scripts de infraestructura
┣ 📂 logs [directory]                ← Archivos de log generados (no debe ser package)
┣ 📂 reports [directory]             ← Reportes de cobertura, calidad u otros artefactos
┣ 📂 requirements [package]          ← Organización de requirements por entorno (dev, prod, test)
┣ 📂 test [package]                  ← Pruebas unitarias y mocks
┃ ┣ 📂 usecases [package]
┃ ┣ 📂 mock [package]
┃ ┗ 📂 integration [package]
┣ 📄 README.md                       ← Documentación del proyecto
┣ ⚠️ .gitignore                      ← Exclusión de carpetas como `logs/`, `__pycache__/`, etc.
```

# PROJECT PACKAGES STRUCTURE
```
📦 jorge_cardona_project [project_directory]
┣ 📂 application [package]                                         ← Paquete principal del microservicio
┃ ┣ 📄 __init__.py                                                 ← Permite importar todo `application` como módulo raíz
┃ ┣ 🎄 main.py [__main__]                                          ← Punto de entrada. Orquesta la app.
┃ ┣ 📂 configuration [package]                                     ← Configuración general separada por dominio
┃ ┃ ┣ 📄 __init__.py                                               ← Expone todas las subconfiguraciones como módulo único
┃ ┃ ┣ 📂 rest [package]                                            ← Config de servidor HTTP/API
┃ ┃ ┃ ┣ 📄 __init__.py                                             ← Permite importar configuración del servidor REST
┃ ┃ ┃ ┗ 🏩 app_configuration.py
┃ ┃ ┣ 📂 environment [package]                                     ← Config por entorno
┃ ┃ ┃ ┣ 📄 __init__.py                                             ← Expone utilidades de entorno como módulo único
┃ ┃ ┃ ┗ 📡 environment_configuration.py
┃ ┃ ┣ 📂 database [package]                                        ← Configuración de conexión a base de datos
┃ ┃ ┃ ┣ 📄 __init__.py                                             ← Permite importar configuración DB como módulo
┃ ┃ ┃ ┗ 🔑 database_configuration.py
┃ ┃ ┣ 📂 log [package]                                             ← Configuración del logger
┃ ┃ ┃ ┣ 📄 __init__.py                                             ← Agrupa y expone la config de logs
┃ ┃ ┃ ┗ 📜 log_configuration.py
┃ ┃ ┣ 📂 cors [package]                                            ← Configuración de CORS
┃ ┃ ┃ ┣ 📄 __init__.py                                             ← Permite usar la configuración CORS desde `main.py`
┃ ┃ ┃ ┗ 🚧 cors_configuration.py
┃ ┃ ┣ 📂 swagger [package]                                         ← Configuración de documentación interactiva
┃ ┃ ┃ ┣ 📄 __init__.py                                             ← Habilita uso desde `configuration.swagger`
┃ ┃ ┃ ┗ 📪 swagger_configuration.py
┃ ┣ 📂 utils [package]                                             ← Helpers generales (fechas, formatos, etc.)
┃ ┃ ┣ 📄 __init__.py                                               ← Permite importar helpers directamente desde `utils`
┃ ┃ ┣ 🐍 script.py
┃ ┃ ┣ 🎰 file.yaml
┃ ┃ ┗ 📜 image.jpg                                                 ← ⚠️ Evitar binarios aquí
┃ ┣ 📂 domain [package]                                            ← Núcleo de la lógica de negocio (arquitectura limpia)
┃ ┃ ┣ 📄 __init__.py                                               ← Permite importar `entities`, `usecases`, `services`, etc.
┃ ┃ ┣ 📂 entities [package]                                        ← 📌 Modelos puros del dominio
┃ ┃ ┃ ┣ 📄 __init__.py                                             ← Expone entidades agrupadas
┃ ┃ ┃ ┣ 📂 entity_one [package]
┃ ┃ ┃ ┃ ┣ 📄 __init__.py                                           ← Permite importar entidad y schema 1
┃ ┃ ┃ ┃ ┣ 🐍 model_for_entity_ONE.py
┃ ┃ ┃ ┃ ┗ 💦 schema_for_entity_ONE.py
┃ ┃ ┃ ┣ 📂 entity_two [package]
┃ ┃ ┃ ┃ ┣ 📄 __init__.py                                           ← Permite importar entidad y schema 2
┃ ┃ ┃ ┃ ┣ 🐍 model_for_entity_TWO.py
┃ ┃ ┃ ┃ ┗ 💦 schema_for_entity_TWO.py
┃ ┃ ┃ ┣ 📂 entity_n [package]
┃ ┃ ┃ ┃ ┣ 📄 __init__.py                                           ← Permite importar entidad y schema N
┃ ┃ ┃ ┃ ┣ 🐍 model_for_entity_N.py
┃ ┃ ┃ ┃ ┗ 💦 schema_for_entity_N.py
┃ ┃ ┣ 📂 interfaces [package]                                      ← 📌 Contratos abstractos que el dominio necesita
┃ ┃ ┃ ┣ 📄 __init__.py                                             ← Exposición conjunta de `repositories` y `business_logic`
┃ ┃ ┃ ┣ 📂 repositories [package]                                  ← Interfaces de persistencia
┃ ┃ ┃ ┃ ┣ 📄 __init__.py                                           ← Expone métodos CRUD abstractos
┃ ┃ ┃ ┃ ┣ 🐟 database_method_model_Entity_ONE.py
┃ ┃ ┃ ┃ ┣ 🐟 database_method_model_Entity_TWO.py
┃ ┃ ┃ ┃ ┗ 🐟 database_method_model_Entity_N.py
┃ ┃ ┃ ┣ 📂 business_logic [package]                                ← Interfaces para servicios externos
┃ ┃ ┃ ┃ ┣ 📄 __init__.py                                           ← Permite importar lógica externa desacoplada
┃ ┃ ┃ ┃ ┣ 🐦 business_logic_method_model_Entity_ONE.py
┃ ┃ ┃ ┃ ┣ 🐦 business_logic_method_model_Entity_TWO.py
┃ ┃ ┃ ┃ ┗ 🐦 business_logic_method_model_Entity_N.py
┃ ┃ ┣ 📂 usecases [package]                                        ← 📌 Casos de uso que orquestan el negocio
┃ ┃ ┃ ┣ 📄 __init__.py                                             ← Expone todos los casos de uso desde un punto común
┃ ┃ ┃ ┣ 🎎 use_case_implementation_business_repository_logic_model_ONE.py
┃ ┃ ┃ ┣ 🎎 use_case_implementation_business_repository_logic_model_TWO.py
┃ ┃ ┃ ┗ 🎎 use_case_implementation_business_repository_logic_model_N.py
┃ ┃ ┣ 📂 services [package]                                        ← 📌 Lógica compartida entre casos de uso
┃ ┃ ┃ ┣ 📄 __init__.py                                             ← Importación de helpers reutilizables
┃ ┃ ┃ ┣ ✈️ services_use_case_implementation_model_ONE.py
┃ ┃ ┃ ┣ ✈️ services_use_case_implementation_model_TWO.py
┃ ┃ ┃ ┗ ✈️ services_use_case_implementation_model_N.py
┣ 📂 deployment [package]                                          ← Despliegue y empaquetado
┃ ┣ 📄 __init__.py                                                 ← Permite importar scripts de despliegue como módulo
┃ ┣ 🐳 Dockerfile
┃ ┗ 🎰 Manifest.yaml
┣ 📂 logs [directory]                                              ← Carpeta para logs generados
┃ ┣ 📝 app.log
┃ ┣ 📝 db.log
┃ ┗ 📂 archive [directory]
┃    ┗ 📝 app-2024-01-01.log
┣ 📂 reports [directory]                                           ← Reportes generados automáticamente
┃ ┣ 📄 coverage.html
┃ ┗ 📂 htmlcov [directory]
┃    ┗ 📜 main_py.html
┣ 📂 requirements [package]                                        ← Manejo separado de dependencias
┃ ┣ 📄 __init__.py                                                 ← Permite importar requirements como módulo si se usa dinámicamente
┃ ┣ 📄 base.txt
┃ ┣ 📄 dev.txt
┃ ┣ 📄 test.txt
┃ ┗ 📄 requirements.txt
┣ 📂 test [package]                                                ← Estructura de pruebas
┃ ┣ 📄 __init__.py                                                 ← Expone test como módulo para ejecución e importación
┃ ┣ 📂 test_case_one [package]
┃ ┃ ┣ 📄 __init__.py                                               ← Inicializa caso de prueba 1 como módulo
┃ ┃ ┣ 🍄 use_case_implementation_one.py
┃ ┃ ┗ 🍄 services_use_case_implementation_one.py
┃ ┣ 📂 test_case_two [package]
┃ ┃ ┣ 📄 __init__.py
┃ ┃ ┣ 🍄 use_case_implementation_two.py
┃ ┃ ┗ 🍄 services_use_case_implementation_two.py
┃ ┣ 📂 test_case_n [package]
┃ ┃ ┣ 📄 __init__.py
┃ ┃ ┣ 🍄 use_case_implementation_n.py
┃ ┃ ┗ 🍄 services_use_case_implementation_n.py
┣ 📜 README.md                                                    ← Documentación general del proyecto
┣ ⚠️ .gitignore                                                   ← Ignora `/logs/`, `__pycache__/`, `htmlcov/`, etc.
```

# Application
Este directorio encapsula todo el código fuente del microservicio. Implementa la arquitectura limpia dividiendo la aplicación en capas bien definidas: `configuration`, `logging`, `utils`, `domain`, y el punto de entrada (`main.py`).

| Parte del sistema                     | ¿Qué hace?                                                                                                                                                             |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`entities/model_for_entity_*.py`**  | ✅ Define la **estructura interna** de los datos. Son clases con `@dataclass` que representan tablas reales de la base de datos. Sin lógica ni validaciones.            |
| **`entities/schema_for_entity_*.py`** | ✅ Define los **esquemas de entrada y salida** que usa la API. Escritos con `pydantic`, validan datos de entrada y formatean la salida al cliente.                      |
| **`interfaces/`**                     | ✅ Declara **contratos abstractos** que el dominio necesita para acceder a datos (`repositories/`) o servicios externos (`business_logic/`). No contienen lógica.       |
| **`interfaces/repositories/`**        | ✅ Define interfaces para persistencia: `guardar()`, `buscar_por_id()`, `actualizar()`, etc. Sólo firmas de métodos. Sin implementación.                                |
| **`interfaces/business_logic/`**      | ✅ Define interfaces para lógica externa (email, autenticación, notificaciones, pagos, etc.). Declaración de métodos que otros deben implementar.                       |
| **`usecases/`**                       | ✅ Contiene la **lógica del negocio puro**. Cada clase representa un flujo funcional (crear, editar, eliminar) y **usa las interfaces** del dominio.                    |
|                                       | 🧠 Aquí también se **implementan los métodos definidos por las interfaces** y se escribe la lógica propia del negocio:                                                 |
|                                       | filtros, transformaciones, decisiones, validaciones del dominio, cálculos, restricciones de uso. No contiene lógica técnica ni externa.                                |
| **`services/`**                       | ✅ Define los **endpoints HTTP reales**. Aquí se reciben las peticiones, se validan usando schemas, se llama a los `usecases`, y se retorna la respuesta al cliente.    |
| **`main.py`**                         | ✅ Punto de entrada. Registra los endpoints desde `services/`, configura la aplicación y **conecta los usecases con sus dependencias reales**.                          |
| **`configuration/`**                  | ✅ Agrupa todas las configuraciones del sistema. Conexión a base de datos, variables de entorno, logging, CORS, Swagger, etc. Organizado en submódulos por contexto.    |
| **`utils/`**                          | ✅ Contiene funciones auxiliares reutilizables. Ej: manejo de fechas, normalización de strings, generadores de IDs, helpers sin lógica de negocio ni infraestructura.   |
| **`deployment/`**                     | ✅ Archivos necesarios para empaquetar y desplegar el microservicio. Incluye Dockerfile, manifest de Kubernetes, scripts, etc.                                          |
| **`requirements/`**                   | ✅ Lista de dependencias del proyecto divididas por entorno (`base.txt`, `dev.txt`, `test.txt`, `requirements.txt`). Para entornos reproducibles y mantenibles.         |
| **`test/`**                           | ✅ Contiene pruebas unitarias y de integración. Organizado por `usecases` y `services`. Usa mocks de interfaces para evitar conectarse a la base real en pruebas.       |
| **`logs/`**                           | ✅ Carpeta donde se escriben los archivos `.log` generados por la ejecución de la app. No contiene código ni se versiona. Ignorada por `.gitignore`.                    |
| **`reports/`**                        | ✅ Reportes generados automáticamente (ej. cobertura de código con `coverage.html`, análisis de calidad, performance, etc.). Carpeta ignorada del control de versiones. |


## 🧠 Dominio (`domain/`)

Contiene **todo el conocimiento del negocio** y debe permanecer libre de dependencias externas.

### 🔹 `entities/` — Modelos de Negocio Puros

¿Qué representan los modelos dentro de entities/?
> Los modelos en entities/ representan exactamente los campos de la base de datos,
con los mismos nombres y los mismos tipos de datos.

📌 Los modelos (model_for_entity_*.py) son clases que representan exactamente las tablas de la base de datos.

- Cada clase representa una tabla específica.
- Cada atributo de la clase corresponde a una columna de esa tabla, con el mismo nombre y tipo de dato.
- Se pueden implementar con @dataclass, lo que permite definir estructuras simples y ordenadas, sin métodos ni lógica adicional.
- No usan pydantic ni contienen validaciones, reglas de negocio o funciones.
- Su propósito es ser una descripción inmutable de los datos que existen en el dominio, usada por casos de uso, repositorios y servicios.

🧾 Ejemplo real 

🐍 Modelo en model_for_entity_producto.py
```python
from dataclasses import dataclass

@dataclass
class Producto:
    id: int
    nombre: str
    precio: float
```

🔁 Resultado: es una representación exacta de la tabla producto, pero escrita como clase en Python.

🎯 Tabla en base de datos:
```sql
CREATE TABLE producto (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    precio DECIMAL NOT NULL
);
```

### 🔹 `schemas/` — Validación y Serialización de Datos

- Modelos para entrada/salida de datos, usualmente desde/hacia la API.
- Usan `pydantic` para validación, conversión de tipos y documentación.
- Cada `entity` suele tener un `schema` correspondiente.

📄 `user_schema.py`:
```python
from pydantic import BaseModel, EmailStr

class UserCreateSchema(BaseModel):
    name: str
    email: EmailStr

class UserResponseSchema(BaseModel):
    user_id: int
    name: str
    email: EmailStr
```

# SCHEMAS

> Los `schemas` NO forman parte del núcleo del negocio, sino de la **interfaz con el exterior**.

¿Qué representa un `schema`?

> Un `schema` (ubicado en `schema_for_entity_*.py`) define la **forma, validación y estructura** de los datos que se reciben y devuelven por una API. 

* Un schema es una plantilla que define cómo deben ser los datos que entran o salen del sistema cuando alguien se conecta a tu API (por ejemplo, desde una aplicación web o móvil).

* Se usa para **validar la entrada** del usuario (por ejemplo, en un `POST` o `PUT`)
* Y para **formatear la salida** que se entrega como respuesta al cliente (por ejemplo, en un `GET` o `DELETE`)
* Están escritos con una librería llamada pydantic, que permite definir campos, tipos de datos, restricciones (como mínimo de caracteres, o que algo sea obligatorio).
* Se escribe con `pydantic.BaseModel`, y es el puente entre el mundo externo (API) y el dominio interno (`entity`)

* Es como qua la API diga:
    - 🔒 "Solo acepto datos si me los mandas con el nombre correcto, el tipo correcto y cumpliendo mis reglas."
    - 📦 "Y siempre responderé en este formato claro para que tú sepas cómo leerlo."

---

---

## 🧱 Ejemplo

### 🎯 Se tiene esta tabla de base de datos:

```sql
CREATE TABLE producto (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    precio DECIMAL NOT NULL
);
```

---

### 💦 Esquema para **recibir** un producto (POST):

```python
from pydantic import BaseModel, Field

class ProductoCreateSchema(BaseModel):
    nombre: str = Field(..., min_length=2)
    precio: float
```

Este esquema:

* **Exige** que venga un campo `nombre` con al menos 2 caracteres
* **Espera** que el `precio` sea un número (float)
* **Valida automáticamente** que esos datos sean correctos

✅ Si falta un campo, el schema **rechaza** la petición antes de que llegue al negocio.

---

### 🛫 Petición que pasaría la validación:

```json
{
  "nombre": "Laptop",
  "precio": 1299.99
}
```

---

### ❌ Petición que sería rechazada:

```json
{
  "precio": "barato"
}
```

❗ Porque `"barato"` no es un número, y `nombre` está ausente.

---

### 📦 Esquema para **responder** con un producto (GET):

```python
class ProductoResponseSchema(BaseModel):
    id: int
    nombre: str
    precio: float
```

Cuando un cliente hace `GET /productos/1`, la API usará este esquema para **garantizar** que responde así:

```json
{
  "id": 1,
  "nombre": "Laptop",
  "precio": 1299.99
}
```

Incluso si la base de datos tiene otros campos, el schema controla **lo que se muestra**.

---

### 🔥 ¿Qué gana el sistema con esto?

* 🔐 **Seguridad**: no entra basura ni datos incompletos
* 🧼 **Claridad**: las respuestas son limpias, ordenadas y fáciles de usar
* 🤝 **Compatibilidad**: otros equipos o sistemas pueden conectarse con confianza a tu API


Perfecto, Jorge. Aquí te dejo la descripción **completa, precisa y fácil de entender** para documentar correctamente la estructura de:

```
┃ ┃ ┣ 📂 interfaces [package]        ← Contratos abstractos
┃ ┃ ┃ ┣ 📂 repositories [package]    ← Interfaces de persistencia (ej. UserRepository)
┃ ┃ ┃ ┗ 📂 business_logic [package]  ← Interfaces de lógica externa (ej. EmailSender)
```

Incluye propósito, ejemplos y cómo se conectan al resto del sistema (usecases, adapters, etc.).

---

### 🔹 ¿Qué es `interfaces/`?

> Es un paquete que contiene **contratos abstractos**, también llamados **interfaces**.
> Define **qué necesita el dominio**, pero **no cómo se implementa**.

📌 En arquitectura limpia, el dominio (los `usecases`) **puede depender de interfaces**, pero **nunca de implementaciones concretas**.

---

## 📂 repositories/ — Interfaces de Persistencia

> Define **cómo espera el sistema interactuar con la base de datos**, pero **sin acoplarse a SQL, Mongo, ORM, etc.**
> Los repositories en el paquete interfaces/ son clases abstractas que definen métodos obligatorios, pero sin implementación.

> Su objetivo es establecer un contrato claro sobre cómo el sistema debe interactuar con la base de datos, sin acoplarse a ninguna tecnología específica.

* Los repositories en el paquete interfaces/ son solo clases abstractas con métodos definidos pero no implementados.
* Aquí se escriben clases abstractas como `ProductoRepository`, `UsuarioRepository`, etc.
* Estas clases definen **métodos obligatorios pero solo relacionado a interacciones con bases de datos**, como `guardar()`, `buscar_por_id()`, `listar_todos()`, pero no tienen implementación.
* Se usan en los `usecases`, donde se inyecta luego una implementación real (por ejemplo, un repositorio SQL o Mongo).

---

### 🧾 Ejemplo de repositories en `interfaces/repositories/`:

```python
# database_method_model_producto.py

from abc import ABC, abstractmethod
from domain.entities.entity_producto.model_for_entity_producto import Producto
from typing import List, Optional

class ProductoRepository(ABC):
    """Interfaz abstracta que define las operaciones permitidas sobre productos."""

    @abstractmethod
    def guardar(self, producto: Producto) -> Producto:
        """Guarda un nuevo producto y devuelve el producto con su ID asignado."""
        ...

    @abstractmethod
    def buscar_por_id(self, producto_id: int) -> Optional[Producto]:
        """Busca un producto por su ID."""
        ...

    @abstractmethod
    def listar(self) -> List[Producto]:
        """Devuelve una lista de todos los productos."""
        ...

    @abstractmethod
    def actualizar(self, producto: Producto) -> Producto:
        """Actualiza un producto existente."""
        ...

    @abstractmethod
    def eliminar(self, producto_id: int) -> None:
        """Elimina un producto por su ID."""
        ...
```

## 📂 business\_logic/ — Interfaces de Lógica Externa

> Define **cómo el sistema espera comunicarse con servicios externos** son clases abstractas que definen cómo el sistema espera comunicarse con servicios externos, como proveedores de email, SMS, autenticación, pagos, notificaciones, etc.

* Estas clases definen métodos obligatorios, pero no contienen implementación real.

* Sirven para describir el comportamiento esperado de un servicio externo, sin acoplar el sistema a una librería o proveedor específico.

* Se definen con abstractmethod, y se implementan más adelante en clases concretas como SendGridEmailSender, TwilioSMSSender, StripePaymentProcessor, etc.

* Los usecases dependen únicamente de estas interfaces, lo que permite sustituir o cambiar proveedores sin modificar la lógica del negocio.
---

### 🧾 Ejemplo de interfaz en `business_logic/`:

```python
# business_logic_method_model_usuario.py

from abc import ABC, abstractmethod

class EmailSender(ABC):

    @abstractmethod
    def enviar(self, destinatario: str, asunto: str, contenido: str) -> None:
        pass
```

Luego puedes tener una implementación real como:

```python
class SendGridEmailSender(EmailSender):
    def enviar(self, destinatario, asunto, contenido):
        # Llama a la API de SendGrid aquí
        ...
```

---

## 📦 ¿Cómo se usa en el flujo?

1. El `usecase` solo conoce la **interfaz** (`ProductoRepository`, `EmailSender`)
2. El `main.py` o el contenedor inyecta la **implementación real** (`ProductoRepositorySQL`, `SendGridEmailSender`)
3. El dominio sigue siendo limpio, desacoplado y fácil de testear

---

## 🧠 Ventajas clave

| Ventaja                      | Descripción                                                                 |
| ---------------------------- | --------------------------------------------------------------------------- |
| 🔄 Desacoplamiento total     | Puedes cambiar de base de datos o proveedor sin tocar la lógica del negocio |
| ✅ Testeabilidad total        | Puedes simular la interfaz fácilmente con un mock en pruebas                |
| 🔒 Independencia tecnológica | El dominio no depende de frameworks, librerías externas ni protocolos       |

---
## 📂 usecases/ — Casos de Uso del Negocio

> Contiene la **lógica de negocio central** del sistema. Cada clase representa una acción completa que responde a un requerimiento funcional (crear, editar, eliminar, notificar, listar, etc.).

Los `usecases` son los **núcleos ejecutables del dominio**, que **usan las interfaces declaradas** en `repositories/` o `business_logic/`, y **orquestan entidades y validaciones del negocio**.

---

### ✅ ¿Qué hacen exactamente los `usecases/`?
> Implementan la lógica de negocio completa para una acción del sistema (como crear, editar, eliminar, listar, notificar, etc.).
Cada clase en usecases/ representa un flujo funcional bien definido, que responde a una necesidad del negocio y usa las interfaces declaradas en interfaces/ para acceder a datos o servicios externos, pero implementa directamente en su interior toda la lógica que es propia del dominio.
Esto incluye, por ejemplo:

* Validaciones propias del negocio (que no son validaciones de tipo como en los schemas)

* Transformaciones de datos (ej. convertir estructuras, unir campos, aplicar formatos internos)

* Filtros, reglas, restricciones (ej. no permitir duplicados, no permitir ciertas combinaciones)

* Control del orden y condiciones de ejecución de acciones (ej. si se guarda, luego se notifica)

* Aunque los métodos que usa provienen de interfaces, la decisión de cuándo y cómo se llaman, en qué condiciones, con qué datos y en qué orden —esa es la responsabilidad exclusiva del usecase.

* Convertir estructuras.

* Validar consistencia lógica (ej. que no haya duplicados)

* Rechazar operaciones según reglas internas.

* No se conectan a base de datos ni a servicios externos directamente.

* Son independientes de frameworks, APIs, librerías y detalles de infraestructura.

* Son **totalmente testeables en aislamiento**, usando mocks.

* **Usan** las interfaces (`ProductoRepository`, `EmailSender`, etc.) sin conocer la implementación.
---

### 🧾 Ejemplo de un `usecase` en `usecases/`:

```python
# usecases/crear_producto.py

from domain.entities.entity_producto.model_for_entity_producto import Producto
from domain.interfaces.repositories.database_method_model_producto import ProductoRepository

class CrearProducto:
    def __init__(self, repo: ProductoRepository):
        self.repo = repo  # Interface inyectada

    def execute(self, nombre: str, precio: float) -> Producto:
        # ✅ Lógica de negocio: validación del dominio
        if len(nombre.strip()) < 3:
            raise ValueError("El nombre del producto es demasiado corto")

        if precio <= 0:
            raise ValueError("El precio debe ser mayor a cero")

        producto = Producto(id=0, nombre=nombre, precio=precio)

        # ✅ Llama a la interfaz (no conoce la implementación)
        return self.repo.guardar(producto)
```

---

### 🔁 Resultado

* El `usecase` decide **cuándo y cómo** se crea un producto.
* **No le importa si se guarda en PostgreSQL, Mongo o un archivo**.
* Si mañana cambias el motor de base de datos o el proveedor de email, **el `usecase` no se toca**.

---

# Configuration
Contains all configuration files for the Application

# Log
Save information about the application log.

# htmlcov
Save unit testing coverage information about the application code.

# Utils
Contains transversal resources for the application, that is not possible to include in other layers.

# Entities
is a package that contains modules, like Models and Schemas, the module it's a plain script, it contains only the class definition and no logic in the classes.
- **Models**: are modules that contain the fields from a table on the database and it is represented by a class.
- **Schemas**: these are modules that contain the fields Used to validate data we receive as well as to reformat the data that we want to send to the client/browser, so just contains the fields that we want to return in the request.

# Interfaces
are interfaces that contain only the methods that need to be implemented in the use cases one directory by class.
- **Repository**: Contains modules with methods that are needed to communicate with the database by class.
- **Business**: Contains modules with methods that are needed to process the information by class.

# Use Cases
is a package that contains modules, the module is a class that implements the methods from the package interfaces(Repository, Business) and defines the business logic by module.

# Services
is a package that contains modules, the module is a class that contains the API services by functionality or by class and use the UseCases classes.

# Web, Devices, DB, UI, External Interfaces
layer that communicates internal API services with API consumers.

# Deployment
Directory that contains the Dockerfile, k8s Manifest, and every file needed for the deployment.

# Requirements
Directory containing the requirements.txt with the definition of project dependencies.

# Test
Directory that contains the unit testing from the Use Cases and Services files.


📂 services/ — Capa de Presentación (Endpoints HTTP reales)
> La carpeta services/ define los endpoints reales del sistema, es decir, las funciones que procesan solicitudes HTTP (GET, POST, PUT, DELETE, etc.).
Esta capa actúa como el puente entre el mundo externo (cliente/API) y el núcleo del negocio (usecases/).

✅ ¿Qué hace un archivo en services/?
* administra las peticiones recibidas
* Valida la entrada usando un schema (pydantic)
* Llama al usecase correspondiente
* Recibe el resultado, lo formatea si es necesario
* Devuelve una respuesta estructurada al cliente, con el schema de salida

Ejemplo
```python
from fastapi import status
from configuration.rest.rest_api_configuration import clean_architecture

from usecases.usecase_products import ProductsUseCases as use_case
from usecases.usecase_products import Session, get_session, Depends, List
from usecases.usecase_products import get_schema, post_schema, put_schema, patch_schema

from configuration.end_points.products import SEARCH_ALL_OBJECTS, SEARCH_SPECIFIC_OBJECT, ADD_NEW_OBJECT, ADD_NEW_OBJECT_LIST
from configuration.end_points.products import BASE_PATH, UPDATE_OBJECT, PATCH_OBJECT, REMOVE_OBJECT

class ProductsServices:
            
    # retorna UNA LISTA DE OBJETOS con los campos que tenga el ESQUEMA DEL RESPONSE MODEL en este caso TODOS LOS CAMPOS
    @clean_architecture.get(BASE_PATH + "/", name=SEARCH_ALL_OBJECTS)
    def get_object_list(session: Session = Depends(get_session), offset: int = 0, limit: int = 100, page_number : int = 1, page_size : int = 10):
        """
        DESCRIPTION \\
        this service allows to RECOVERY A LIST of records from database
        """
        data = use_case().get_object_list(session=session, offset=offset, limit=limit)
        response = use_case().get_response_format(data, offset=offset, limit=limit, page_number=page_number, page_size=page_size)
        return response


    # retorna UN OBJETO con los campos que tenga el ESQUEMA DEL RESPONSE MODEL en este caso todos los campos EXCEPTO EL CAMPO ID
    @clean_architecture.get(BASE_PATH + "/{id}", name=SEARCH_SPECIFIC_OBJECT, tags=['products'], 
    responses={
        404: {"model": get_schema, "description": "The item was not found"},
        200: {
            "description": "User requested by ID",
            "content": {
                "application/json": {
                    "example": {"id": "bar", "value": "The bar tenders"}
                }
            },
        },
    }
                            )
    def get_object(id:int, session: Session = Depends(get_session)):
        """
        DESCRIPTION \\
        this service allows to RECOVERY specific the record from database
        """
        
        data = use_case().get_object(id=id, session=session)

        response = use_case().get_response_format(data=data)
        return response
    
    @clean_architecture.post(BASE_PATH + "/", name=ADD_NEW_OBJECT, status_code=status.HTTP_201_CREATED, tags=['products'])
    def add_object(entity:post_schema, session: Session = Depends(get_session)):
        """
        DESCRIPTION \\
        this service allows to CREATE a new the record of database
        """
        data = use_case().add_object(entity=entity, session=session)
        response = use_case().get_response_format(data=data)
        return response
    
    @clean_architecture.post(BASE_PATH + "/all", name=ADD_NEW_OBJECT_LIST, status_code=status.HTTP_201_CREATED, tags=['products'])
    def add_object_list(entity:List[post_schema], session: Session = Depends(get_session)):
        """
        DESCRIPTION \\
        this service allows to CREATE a LIST of new the record of database
        """
        data = use_case().add_object_list(entity=entity, session=session)
        response = use_case().get_response_format(data=data)
        return response
        
    @clean_architecture.put(BASE_PATH + "/{id}", name=UPDATE_OBJECT, tags=['products'])
    def update_object(id:int, entity:put_schema, session: Session = Depends(get_session)):
        """
        DESCRIPTION \\
        this service allows to UPDATE the record of database
        """
        return use_case().update_object(id=id, entity=entity, session=session)

    @clean_architecture.patch(BASE_PATH + "/{id}", name=PATCH_OBJECT, tags=['products'])
    def patch_object(id:int, entity:patch_schema, session: Session = Depends(get_session)):
        """
        DESCRIPTION \\
        this service allows to PATCH the record of database
        """
        return use_case().patch_object(id=id, entity=entity, session=session)
    
    # status_code=status.HTTP_204_NO_CONTENT, genera excepcion porque retorna mensaje
    @clean_architecture.delete(BASE_PATH + "/{id}",  name=REMOVE_OBJECT, tags=['products'])
    def delete_object(id:int, session: Session = Depends(get_session)):
        """
        DESCRIPTION \\
        this service allows to REMOVE the record of database
        """
        return use_case().delete_object(id=id, session=session)
```
---

## ⚙️ Infraestructura (`application/`)

Contiene todo lo relacionado con configuración, entrada al sistema, y conectores con tecnologías externas.

- `main.py`: punto de entrada del microservicio.
- `config.py`: define variables globales como rutas, puertos y claves.
- `logger.py`: inicializa logs con formato.
- `utils/`: funciones genéricas de utilidad para formateo, transformación, etc.

---

## 🧪 Pruebas (`test/`)

Diseñado para facilitar pruebas unitarias puras del dominio.

- `use_cases/`: pruebas de casos de uso con mocks de interfaces.
- `mock/`: implementaciones ficticias de interfaces para testeo.

📄 `mock_user_repository.py`:
```python
from domain.interfaces.user_repository import UserRepository
from domain.entities.user import User

class MockUserRepository(UserRepository):
    def save(self, user: User) -> User:
        return User(user_id=1, name=user.name, email=user.email)
```

---

## 🚢 Despliegue (`deployment/`)

- `Dockerfile`: define cómo construir la imagen Docker del microservicio.
- `manifest.yaml`: manifiesto de Kubernetes para orquestación.

---

## ▶️ Instalación

```bash
git clone https://github.com/JorgeCardona/python_microservice_scaffolding_clean_architecture.git
cd python_microservice_scaffolding_clean_architecture
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python application/main.py
```

---

## ✅ Pruebas

```bash
pytest test/
```

---

## 🔁 CI/CD con GitHub Actions

📄 `.github/workflows/ci.yml`:
```yaml
name: CI - Validación y Testeo

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      - run: pip install -r requirements.txt
      - run: pytest test/
```

---

## 📌 Próximos Pasos

- Añadir adaptadores reales (por ejemplo, SQL, Redis, HTTP).
- Crear endpoints FastAPI en `application/main.py`.
- Documentar la API con Swagger.
- Despliegue automatizado en Docker/Kubernetes.

---

## 👨‍💻 Autor

**Jorge Cardona Gallego**  
[https://github.com/JorgeCardona](https://github.com/JorgeCardona)