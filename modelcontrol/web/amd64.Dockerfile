FROM mcr.microsoft.com/dotnet/core/aspnet:2.2

ADD /app/bin/Release/netcoreapp2.2/publish/ /app/

ENTRYPOINT ["dotnet", "app/app.dll"]
