para alterar o apontamento de um módulo para um outro lugar dá pra usar:
`go mod edit -replace example.com/greetings=../greetings`


# Para instalar o módulo
- abra no módulo que quer instalar
- pegue o output do `go list -f '{{.Target}}'`
- ele te dará algo do tipo /home/gustavo/go/bin/hello
- cole esse export prévio ao hello no .bashrc, ex: `export PATH=$PATH:/home/gustavo/go/bin`
- restarte o shell ou source no bashrc
- agora só ir na pasta do módulo e rodar go install e voilá!! agora está global na sua máquina
