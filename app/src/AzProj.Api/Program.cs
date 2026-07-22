var builder = WebApplication.CreateBuilder(args);

builder.Logging.ClearProviders();
builder.Logging.AddConsole();

var app = builder.Build();

var version = Environment.GetEnvironmentVariable("APP_VERSION") ?? "local";
var podName = Environment.GetEnvironmentVariable("HOSTNAME") ?? "unknown";
var environmentName = Environment.GetEnvironmentVariable("APP_ENVIRONMENT") ?? "local";
var marketplaceName = Environment.GetEnvironmentVariable("MARKETPLACE_NAME") ?? "Cloud-Native Marketplace";

app.Use(async (context, next) =>
{
    var logger = context.RequestServices.GetRequiredService<ILoggerFactory>()
        .CreateLogger("RequestLog");

    logger.LogInformation(
        "HTTP {Method} {Path} from {RemoteIp} on pod {PodName} version {Version}",
        context.Request.Method,
        context.Request.Path,
        context.Connection.RemoteIpAddress,
        podName,
        version);

    await next();

    logger.LogInformation(
        "HTTP {Method} {Path} responded {StatusCode} on pod {PodName} version {Version}",
        context.Request.Method,
        context.Request.Path,
        context.Response.StatusCode,
        podName,
        version);
});

app.MapGet("/", () => Results.Ok("ok"));

app.MapGet("/healthz", () => Results.Ok("healthy"));

app.MapGet("/version", () => Results.Ok(new
{
    app = "azproj-api",
    version,
    podName,
    timestampUtc = DateTime.UtcNow
}));

app.MapGet("/cpu", () =>
{
    var end = DateTime.UtcNow.AddSeconds(2);
    var value = 0.0;

    while (DateTime.UtcNow < end)
    {
        value += Math.Sqrt(Random.Shared.NextDouble());
    }

    return Results.Ok(new
    {
        status = "cpu load generated",
        value,
        podName,
        version
    });
});

app.MapGet("/config", () => Results.Ok(new
{
    app = "azproj-api",
    environment = environmentName,
    marketplace = marketplaceName,
    version,
    podName,
    timestampUtc = DateTime.UtcNow
}));

app.MapGet("/secret-status", () =>
{
    var secretPath = "/mnt/secrets-store/marketplace-connection";
    var exists = File.Exists(secretPath);

    return Results.Ok(new
    {
        app = "azproj-api",
        secretName = "marketplace-connection",
        mounted = exists,
        valueExposed = false,
        podName,
        version,
        timestampUtc = DateTime.UtcNow
    });
});

app.Run("http://0.0.0.0:8080");