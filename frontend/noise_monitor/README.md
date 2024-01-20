# Flutter

Lembre-se de abrir a pasta atual:

```shell
cd ./frontend/noise_monitor # A partir da raiz do repositório
```

Para essa parte, foi disponibilizado uma configuração de imagem que instala todas as dependências necessárias pelo Flutter, incluindo o Android SDK, e compila a aplicação. Com isso, pode-se conectar um smartphone Android via USB e, em um terminal dentro do container, enviar a aplicação. 

> **Atenção:** É necessário a opção de **Depuração USB** do Android esteja ativada. O tutorial oficial para ativação pode ser encontrado [aqui](https://developer.android.com/studio/debug/dev-options?hl=pt-br). Em alguns dispositivos, a opção **Número da versão** pode estar sob o nome de **Número de compilação**.

Para compilar e abrir o terminal, faça:

```shell
# Copia os arquivos do Protobuf para a pasta atual e configura o $API_HOST e as portas
sh ./scripts/setup.sh

# Constrói a imagem (compilando o aplicativo)
docker compose build flutter

# Abre um terminal dentro do container
docker compose run --rm -it flutter bash
```

> **Atenção:** o processo de *build* da imagem pode ser demorado e requisitar uma quantidade considerável de memória.
 
## Instalação usando o ADB

No terminal aberto dentro do container, você pode verificar se o smartphone está corretamente detectada utilizando o comando:

```shell
adb devices
```

> Caso não tenha sido listado nenhum disposivo, além de verificar que o Android está com a Depuração USB ativa, caso você tenha o ADB instalado na sua máquina host, pode ser necessário desativá-lo. Para isso, utilize o comando: `adb kill-server` (pode ser necessário executar mais de uma vez).

Por fim, para enviar o programa para o smartphone, pode-se utilizar:

```shell
flutter install
```

A aplicação deve, então, ter sido instalada com o nome de `noise_monitor`.

## Obtenção do APK

Outra forma de instalar o aplicativo no celular é utilizando o APK que foi compilado durante a construção da imagem e instalar manualmente no aparelho.

O APK compilado encontra-se no caminho `/home/developer/app/release.apk` do container e pode ser obtido por meio de:

```shell
# No terminal do host, inicia o container em modo detached
docker compose up -d flutter

# Copia o arquivo do container para a máquina host, em ./noise_monitor.apk
docker compose cp flutter:/home/developer/app/release.apk ./noise_monitor.apk

# Mata o container
docker compose down flutter
```

Uma vez obtido o APK (agora em `./noise_monitor.apk`), pode-se movê-lo para o smartphone e instalá-lo normalmente.