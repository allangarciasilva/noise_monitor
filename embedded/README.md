# Embarcado

Lembre-se de abrir a pasta atual:

```shell
cd ./embedded # A partir da raiz do repositório
```

Copie para o contexto atual os arquivos necessários:

```shell
rm -rf .env proto
cp ../proto proto -r
cp ../config.env .env
```

## Instalação do Ambiente

Para essa parte, foi disponibilizado uma configuração de imagem que instala todas as dependências necessárias pelo PlatformIO. Com isso, pode-se conectar a ESP32 via USB e, em um terminal dentro do container, compilar e enviar a aplicação. Para isso, faça:

```shell
# Constrói a imagem e abre um terminal dentro do container
docker compose build platformio
docker compose run --rm -it platformio bash
```

Já nesse terminal, você pode verificar se a ESP está corretamente detectada utilizando o comando:

```shell
pio device list
```

Por fim, pode-se compilar o programa, enviá-lo para ESP e, caso desejado, abrir o monitor serial.

```shell
# Compila o Protobuf e algumas outras configurações
sh ./scripts/prebuild.sh

# Compila o programa e envia para a ESP
pio run -e real_hardware -t upload

# Abre o monitor serial
pio device monitor --baud 115200
```
