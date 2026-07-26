using Microsoft.Data.SqlClient;
var builder = WebApplication.CreateBuilder(args);

builder.Logging.ClearProviders();
builder.Logging.AddConsole();

var app = builder.Build();

var version = Environment.GetEnvironmentVariable("APP_VERSION") ?? "local";
var podName = Environment.GetEnvironmentVariable("HOSTNAME") ?? "unknown";
var environmentName = Environment.GetEnvironmentVariable("APP_ENVIRONMENT") ?? "local";
var marketplaceName = Environment.GetEnvironmentVariable("MARKETPLACE_NAME") ?? "Cloud-Native Marketplace";
var dbConnectionPath = "/mnt/secrets-store/marketplace-db-connection";

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

app.MapGet("/db-status", async () =>
{
    var configured = File.Exists(dbConnectionPath);

    if (!configured)
    {
        return Results.Ok(new
        {
            app = "azproj-api",
            databaseConfigured = false,
            canConnect = false,
            valueExposed = false,
            podName,
            version,
            timestampUtc = DateTime.UtcNow
        });
    }

    try
    {
        var connectionString = await File.ReadAllTextAsync(dbConnectionPath);
        await EnsureProductsTableAsync(connectionString);

        return Results.Ok(new
        {
            app = "azproj-api",
            databaseConfigured = true,
            canConnect = true,
            valueExposed = false,
            podName,
            version,
            timestampUtc = DateTime.UtcNow
        });
    }
    catch (Exception ex)
    {
        app.Logger.LogError(ex, "Database status check failed");

        return Results.Problem(
            title: "Database status check failed",
            detail: ex.Message,
            statusCode: 500);
    }
});

app.MapPost("/products", async (ProductCreateRequest request) =>
{
    if (!File.Exists(dbConnectionPath))
    {
        return Results.Problem(
            title: "Database connection is not configured",
            statusCode: 500);
    }

    var connectionString = await File.ReadAllTextAsync(dbConnectionPath);
    await EnsureProductsTableAsync(connectionString);

    await using var connection = new SqlConnection(connectionString);
    await connection.OpenAsync();

    await using var command = connection.CreateCommand();
    command.CommandText = """
        INSERT INTO Products (Name, Price, CreatedUtc)
        OUTPUT INSERTED.Id
        VALUES (@name, @price, SYSUTCDATETIME());
        """;

    command.Parameters.AddWithValue("@name", request.Name);
    command.Parameters.AddWithValue("@price", request.Price);

    var id = (int)await command.ExecuteScalarAsync();

    return Results.Created($"/products/{id}", new
    {
        id,
        request.Name,
        request.Price,
        podName,
        version,
        timestampUtc = DateTime.UtcNow
    });
});

app.MapGet("/products", async () =>
{
    if (!File.Exists(dbConnectionPath))
    {
        return Results.Problem(
            title: "Database connection is not configured",
            statusCode: 500);
    }

    var connectionString = await File.ReadAllTextAsync(dbConnectionPath);
    await EnsureProductsTableAsync(connectionString);

    var products = new List<object>();

    await using var connection = new SqlConnection(connectionString);
    await connection.OpenAsync();

    await using var command = connection.CreateCommand();
    command.CommandText = """
        SELECT TOP 50 Id, Name, Price, CreatedUtc
        FROM Products
        ORDER BY Id DESC;
        """;

    await using var reader = await command.ExecuteReaderAsync();

    while (await reader.ReadAsync())
    {
        products.Add(new
        {
            id = reader.GetInt32(0),
            name = reader.GetString(1),
            price = reader.GetDecimal(2),
            createdUtc = reader.GetDateTime(3)
        });
    }

    return Results.Ok(products);
});

static async Task EnsureProductsTableAsync(string connectionString)
{
    await using var connection = new SqlConnection(connectionString);
    await connection.OpenAsync();

    await using var command = connection.CreateCommand();
    command.CommandText = """
        IF OBJECT_ID('dbo.Products', 'U') IS NULL
        BEGIN
            CREATE TABLE dbo.Products
            (
                Id INT IDENTITY(1,1) PRIMARY KEY,
                Name NVARCHAR(200) NOT NULL,
                Price DECIMAL(18,2) NOT NULL,
                CreatedUtc DATETIME2 NOT NULL
            );
        END
        """;

    await command.ExecuteNonQueryAsync();
}

app.Run("http://0.0.0.0:8080");

record ProductCreateRequest(string Name, decimal Price);