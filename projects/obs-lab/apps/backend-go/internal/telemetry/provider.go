package telemetry

import (
	"context"
	"log/slog"
	"os"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.37.0"
)

func InitTracer() func(context.Context) error {
	ctx := context.Background()

	collectorURL := os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT")
	if collectorURL == "" {
		collectorURL = "localhost:4317" // fallback
	}

	// criar o exporter
	exporter, err := otlptracegrpc.New(ctx,
		otlptracegrpc.WithEndpoint(collectorURL),
		otlptracegrpc.WithInsecure(),
	)
	if err != nil {
		slog.Error("Error on creating trace exporter")
		panic(err)
	}

	res, err := resource.New(ctx,
		resource.WithAttributes(
			semconv.ServiceName("credit-service-go"),
			semconv.DeploymentEnvironmentName("local-lab"),
		))
	if err != nil {
		slog.Error("Error on creating resource for trace")
		panic(err)
	}

	// configurar o trace provider p/agrupar e enviar em batch
	tp := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter),
		sdktrace.WithResource(res),
	)

	// Registra como global!
	otel.SetTracerProvider(tp)
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
		propagation.TraceContext{}, // w3c trace context
		propagation.Baggage{},      // metadados extras
	))

	return tp.Shutdown

}
