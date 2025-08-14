

```bash
sudo apt install golang-go
go version # checa a versão
```



# Configuração do workspace (desnecessário com a chegada do go mod)
```bash
mkdir -p ~/go # workspace golang
```

Adicione no .bashrc:
```bash
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```