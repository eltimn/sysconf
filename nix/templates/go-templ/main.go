package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

const DefaultDatabaseTimeout = 5 * time.Second

func main() {
	// setup logging
	logLevel, logHandler := logging.Configure(os.Getenv("LOG_LEVEL"), os.Getenv("LOG_HANDLER"))
	slog.Info("Configured logging", slog.String("level", logLevel), slog.String("handler", logHandler))

	// grab some env vars
	listenIp := util.GetEnv("WEB_IP", "0.0.0.0")
	listenPort := util.GetEnv("WEB_PORT", "8080")
	isSecure := util.GetEnv("WEB_SECURE", "false")
	dbUrl := util.GetEnv("DB_URL", "http://127.0.0.1:5000")
	assetsPath := util.GetEnv("ASSETS_PATH", "./dist/assets")

	listenAddress := listenIp + ":" + listenPort

	// create router
	router := router.NewRouter(router.WithErrorHandler(handleHttpError))

	router.Get("/error", func(rw http.ResponseWriter, req *http.Request) error {
		return fmt.Errorf("this is only a test error")
	})

	// Handles the home page and all non-matches
	router.ServeMux.Handle("/", homeHandler())

	// start server
	server := &http.Server{
		Addr:    listenAddress,
		Handler: router.ServeMux,
	}

	slog.Info("Server starting", "listen", listenAddress)

	// https://dev.to/mokiat/proper-http-shutdown-in-go-3fji
	go func() {
		if err := server.ListenAndServe(); !errors.Is(err, http.ErrServerClosed) {
			slog.Error("HTTP server error", errs.ErrAttr(err))
			os.Exit(1)
		}
		slog.Info("Stopped serving new connections.")
	}()

	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
	<-sigChan

	shutdownCtx, shutdownRelease := context.WithTimeout(context.Background(), 10*time.Second)
	defer shutdownRelease()

	exitCode := 0
	if err := server.Shutdown(shutdownCtx); err != nil {
		slog.Error("HTTP shutdown error", errs.ErrAttr(err))
		exitCode = 1
	}
	if err := database.Close(); err != nil {
		slog.Error("Error closing database", errs.ErrAttr(err))
		exitCode = 1
	}
	slog.Info("Graceful shutdown complete.")
	os.Exit(exitCode)
}

// This is written as a regular http.HandlerFunc so it can be used as a catch-all route to handle 404s.
func homeHandler() http.Handler {
	next := http.HandlerFunc(func(rw http.ResponseWriter, req *http.Request) {
		slog.Debug("URL", slog.String("url", req.URL.Path))
		if req.URL.Path != "/" || req.Method != http.MethodGet {
			handleHttpError(rw, req, errs.NotFoundError)
			return
		}

		err := Home().Render(req.Context(), rw)
		if err != nil {
			handleHttpError(rw, req, err)
			return
		}
	})

	return mid(next)
}
