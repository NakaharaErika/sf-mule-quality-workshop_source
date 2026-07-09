param(
    [string]$ComposeFile = "mysql\docker-compose.yml"
)

$ErrorActionPreference = "Stop"
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$composePath = Join-Path $repoRoot $ComposeFile

Write-Host "Resetting workshop_db data by re-running schema and seed SQL."
Write-Host "This script does not remove Docker containers or volumes."

docker compose -f $composePath exec -T workshop-mysql sh -c "mysql --default-character-set=utf8mb4 -u`$MYSQL_USER -p`$MYSQL_PASSWORD `$MYSQL_DATABASE < /docker-entrypoint-initdb.d/01-schema.sql"

docker compose -f $composePath exec -T workshop-mysql sh -c "mysql --default-character-set=utf8mb4 -u`$MYSQL_USER -p`$MYSQL_PASSWORD `$MYSQL_DATABASE -e 'TRUNCATE TABLE service_request;'"

docker compose -f $composePath exec -T workshop-mysql sh -c "mysql --default-character-set=utf8mb4 -u`$MYSQL_USER -p`$MYSQL_PASSWORD `$MYSQL_DATABASE < /docker-entrypoint-initdb.d/02-seed.sql"

Write-Host "Database reset completed."
