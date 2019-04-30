FROM mcr.microsoft.com/dotnet/core/aspnet:2.2

ADD app/out/ app/

ENTRYPOINT ["dotnet", "app/app.dll"]
