# build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY src/AzProj.Api/AzProj.Api.csproj src/AzProj.Api/
RUN dotnet restore src/AzProj.Api/AzProj.Api.csproj
COPY src/ src/
RUN dotnet publish src/AzProj.Api/AzProj.Api.csproj -c Release -o /out /p:UseAppHost=false

# run
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /out .
ENV ASPNETCORE_URLS=http://0.0.0.0:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "AzProj.Api.dll"]
