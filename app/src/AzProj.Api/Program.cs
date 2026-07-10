var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => Results.Ok("ok"));
app.MapGet("/healthz", () => Results.Ok("healthy"));

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
        value
    });
});

app.Run("http://0.0.0.0:8080");