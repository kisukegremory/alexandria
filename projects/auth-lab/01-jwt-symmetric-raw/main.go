package main

import (
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// Idealmente uma variável de ambiente, Se o emissor e o validador não tiverem exatamente a mesma chave a validação falhará

type AlexandriaClaims struct {
	Username             string `json:"username"`
	Role                 string `json:"role"`
	jwt.RegisteredClaims        // -> contem iss, aud,....
}

func main() {
	var jwtKey = []byte("senku-secret-science-101")
	// Gerar um token de exemplo
	tokenString, err := generateToken("tavinho", "staff_engineer", jwtKey)
	if err != nil {
		fmt.Printf("Erro ao gerar o token %v\n", err)
	}
	// Podemos notar que o conteúdo dentro do jwt não é nada encriptografado, só é puramente assinado, então podemos ver se quem emitiu ele, tem a assinatura para dizer de quem era
	fmt.Printf("Esse é o token gerado, use o jwt.io para ver o conteúdo!: \n %v \n", tokenString)

	validateToken(tokenString, jwtKey)

	validateToken(tokenString, []byte("chave-errada"))

}

func generateToken(username, role string, jwtKey []byte) (string, error) {
	// Claims são as reividincações/afirmações, como quem sou, de quem fui enviado, quanto tempo essa declaração vence.... e dentro das declarações do jwt tem uma norma de campos base, como exp (expiresAt) iss (Issuer) quem emitiu, sub (subject) geralmente o dono do token, aud(audience) esse token só serve para essa aud/aplicação po rexemplo

	claims := &AlexandriaClaims{
		Username: username,
		Role:     role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(5 * time.Minute)),
			Issuer:    "alexandria-auth-system",
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		return "", err
	}

	return tokenString, nil

}

func validateToken(tokenString string, jwtKey []byte) {
	token, err := jwt.ParseWithClaims(
		tokenString,
		&AlexandriaClaims{},
		// Aqui verificamos se o método de assinatura é HMAC de fato, alem de que sistemas como o keycloak podem passar o header com ex "kid: "chave-nina" e ai antes disso você pode decidir qual chave utilizar, antes de passar o jwtKey diretamente
		func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("Método de assinatura inesperadas %v", token.Header["alg"])
			}

			return jwtKey, nil
		})

	if err != nil {
		fmt.Printf("Erro ao validar o token %v\n", err)
		return
	}

	if claims, ok := token.Claims.(*AlexandriaClaims); ok && token.Valid {
		fmt.Printf("Token válido! Bem-vindo %s com o cargo de %s\n", claims.Username, claims.Role)
	} else {
		fmt.Printf("Token parseado corretamente, mas claims inválidas\n")
	}

}
