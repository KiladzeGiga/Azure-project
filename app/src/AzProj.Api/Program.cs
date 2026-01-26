var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => Results.Ok("ok"));
app.MapGet("/healthz", () => Results.Ok("healthy"));

app.Run("http://0.0.0.0:8080");
