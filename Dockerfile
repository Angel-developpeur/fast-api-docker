FROM python:3.11-alpine

# Directorio de la app
WORKDIR /app

# Configuración de usuario demo
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN addgroup -g ${GROUP_ID} demo \
 && adduser -D demo -u ${USER_ID} -g demo -G demo -s /bin/sh

# 1. Copiamos PRIMERO solo los requerimientos
COPY requirements.txt /app/requirements.txt

# 2. Instalamos dependencias actualizando herramientas de construcción
RUN apk add --no-cache --virtual .build-deps gcc libc-dev make \
    && pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt \
    && apk del .build-deps gcc libc-dev make

# 3. Copiamos el resto del código y damos permisos al usuario demo
COPY --chown=demo:demo . /app/

USER demo

# Entrypoint (Asegúrate de que la ruta app.main:app sea correcta según tu carpeta)
CMD ["uvicorn", "app.main:app", "--proxy-headers", "--host", "0.0.0.0", "--port", "8080"]