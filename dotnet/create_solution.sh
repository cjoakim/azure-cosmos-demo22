#!/bin/bash

# Use the dotnet CLI to bootstrap a dotnet solution and project(s).
# Chris Joakim, Microsoft, August 2021

solution_name="Cosmos22"

echo ''
echo '=========='
echo 'removing any output files...'
rm -rf $solution_name

echo ''
echo '=========='
echo 'dotnet --version  (5.0.x is expected, as of August 2021)'
dotnet --version

echo ''
echo '=========='
echo 'creating the solution...'
dotnet new sln -o $solution_name
cd $solution_name

echo ''
echo '=========='
echo 'creating the core project...'
dotnet new console -o CosmosConsole22
cd     CosmosConsole22 
dotnet add package Microsoft.Azure.Cosmos
dotnet add package Azure.Storage.Blobs
dotnet add package CsvHelper
dotnet add package DocumentFormat.OpenXml 
dotnet add package Faker.Net
# dotnet add package Microsoft.EntityFrameworkCore.Cosmos
# dotnet add package Microsoft.EntityFrameworkCore.Sqlite
# dotnet add package Microsoft.Azure.DataLake.Store

cat    CosmosConsole22.csproj
dotnet restore
dotnet list package
dotnet build
dotnet run

# Project 'CosmosConsole22' has the following package references
#    [net5.0]:
#    Top-level Package             Requested   Resolved
#    > Azure.Storage.Blobs         12.9.1      12.9.1
#    > CsvHelper                   27.1.1      27.1.1
#    > DocumentFormat.OpenXml      2.13.0      2.13.0
#    > Faker.Net                   1.5.138     1.5.138
#    > Microsoft.Azure.Cosmos      3.20.1      3.20.1

cd ..

echo ''
echo '=========='
echo 'adding project(s) to solution...'

dotnet sln $solution_name.sln add CosmosConsole22/CosmosConsole22.csproj

echo ''
echo 'done'
