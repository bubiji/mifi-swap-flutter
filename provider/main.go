package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/MixinNetwork/bot-api-go-client"
	"github.com/ilyakaznacheev/cleanenv"
	"net/http"
)

type ConfigDatabase struct {
	Host          string `yaml:"host" env:"HOST" env-default:":8090"`
	AppHost       string `yaml:"app_host" env:"APP_HOST" env-default:"https://api.mixin.one"`
	AppId         string `yaml:"app_id" env:"APP_ID" env-default:""`
	AppSecret     string `yaml:"app_secret" env:"APP_SECRET" env-default:""`
	AppSessionId  string `yaml:"app_session_id" env:"APP_SESSION_ID" env-default:""`
	AppPrivateKey string `yaml:"app_private_key" env:"APP_PRIVATE_KEY" env-default:""`
}

var cfg ConfigDatabase

func oauth(w http.ResponseWriter, req *http.Request) {
	req.ParseForm()
	code := req.Form.Get("code")
	ctx := context.Background()
	accessToken, scope, _, err := bot.OAuthGetAccessToken(ctx, cfg.AppId, cfg.AppSecret, code, "", "")

	w.Header().Set("Content-Type", "application/json")
	if err != nil {
		fmt.Fprintf(w, "%v", err)
		return
	}
	fmt.Fprintf(w, `{"access_token": "%s", "scope": "%s"}`, accessToken, scope)
}

func createUser(w http.ResponseWriter, req *http.Request) {
	req.ParseForm()
	fullName := req.Form.Get("full_name")
	sessionSecret := req.Form.Get("session_secret")
	fmt.Printf("FullName: %s\n", fullName)
	fmt.Printf("SessionSecret: %s\n", sessionSecret)
	ctx := context.Background()
	user, err := bot.CreateUser(ctx, sessionSecret, fullName, cfg.AppId, cfg.AppSessionId, cfg.AppPrivateKey)

	w.Header().Set("Content-Type", "application/json")

	if err != nil {
		fmt.Printf("Error: %v\n", err)
		fmt.Fprintf(w, "%v", err)
		return
	}
	json.NewEncoder(w).Encode(user)
}

func main() {
	err := cleanenv.ReadConfig("config.yml", &cfg)
	if err != nil {
		panic(err)
	}
	fmt.Printf("HOST: %s\n", cfg.Host)
	fmt.Printf("APP_HOST: %s\n", cfg.AppHost)
	fmt.Printf("APP_ID: %s\n", cfg.AppId)
	fmt.Printf("APP_SESSION_ID: %s\n", cfg.AppSecret)

	http.HandleFunc("/oauth/token", oauth)
	http.HandleFunc("/users", createUser)
	http.ListenAndServe(cfg.Host, nil)
}
