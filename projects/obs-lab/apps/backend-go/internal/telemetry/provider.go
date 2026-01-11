package telemetry

import (
	"context"
	"log/slog"
	"os"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetricgrpc"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/propagation"
	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.37.0"
)

const (
	serviceName    = "credit-service-go"
	serviceVersion = "0.1.0"
	enviroment     = "local-lab"
)

func newResource(ctx context.Context) (*resource.Resource, error) {
	return resource.New(ctx,
		resource.WithAttributes(
			semconv.ServiceName(serviceName),
			semconv.ServiceVersion(serviceVersion),
			semconv.DeploymentEnvironmentName(enviroment),
		))
}

func getCollectorURL() string {
	url := os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT")
	if url == "" {
		url = "localhost:4317" // fallback
	}
	return url
}

func InitTracer() func(context.Context) error {
	ctx := context.Background()

	collectorURL := getCollectorURL()
	// criar o exporter
	exporter, err := otlptracegrpc.New(ctx,
		otlptracegrpc.WithEndpoint(collectorURL),
		otlptracegrpc.WithInsecure(),
	)
	if err != nil {
		slog.Error("Error on creating trace exporter")
		panic(err)
	}

	res, err := newResource(ctx)
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

func InitMeter() func(context.Context) error {
	ctx := context.Background()

	collectorURL := getCollectorURL()
	exporter, err := otlpmetricgrpc.New(
		ctx,
		otlpmetricgrpc.WithEndpoint(collectorURL),
		otlpmetricgrpc.WithInsecure(),
	)
	if err != nil {
		slog.Error("Erro ao criar exporter para as metricas")
		panic(err)
	}

	res, err := newResource(ctx)
	if err != nil {
		slog.Error("Erro ao criar resource para as metricas")
		panic(err)
	}

	mp := sdkmetric.NewMeterProvider(
		sdkmetric.WithResource(res),
		sdkmetric.WithReader(
			sdkmetric.NewPeriodicReader(
				exporter,
				sdkmetric.WithInterval(3*time.Second), // envia métricas para o collector a cada 3s
			),
		),
	)

	otel.SetMeterProvider(mp)

	return mp.Shutdown

}
