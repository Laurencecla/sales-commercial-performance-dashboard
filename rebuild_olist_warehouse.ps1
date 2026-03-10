$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FULL RESET + REBUILD: OLIST WAREHOUSE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# -----------------------------
# Config
# -----------------------------
$ContainerName = "olist_postgres"
$DbUser = "olist_user"
$DbName = "olist"

# -----------------------------
# Helper functions
# -----------------------------
function Run-SqlFileRaw {
    param(
        [string]$FilePath
    )

    Write-Host "`nRunning SQL file via stdin: $FilePath" -ForegroundColor Yellow
    Get-Content $FilePath -Raw | docker exec -i $ContainerName psql -v ON_ERROR_STOP=1 -U $DbUser -d $DbName

    if ($LASTEXITCODE -ne 0) {
        throw "SQL execution failed for file: ${FilePath}"
    }
}

function Copy-And-RunSqlFile {
    param(
        [string]$LocalFile,
        [string]$ContainerFile
    )

    Write-Host "`nCopying SQL file to container: $LocalFile -> $ContainerFile" -ForegroundColor Yellow
    docker cp $LocalFile "${ContainerName}:${ContainerFile}"

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to copy SQL file into container: ${LocalFile}"
    }

    Write-Host "Executing SQL file inside container: $ContainerFile" -ForegroundColor Yellow
    docker exec -i $ContainerName psql -v ON_ERROR_STOP=1 -U $DbUser -d $DbName -f $ContainerFile

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to execute SQL file in container: ${ContainerFile}"
    }
}

function Run-PythonScript {
    param(
        [string]$ScriptPath
    )

    Write-Host "`nRunning Python script: $ScriptPath" -ForegroundColor Yellow
    python $ScriptPath

    if ($LASTEXITCODE -ne 0) {
        throw "Python script failed: ${ScriptPath}"
    }
}

# -----------------------------
# Basic file checks
# -----------------------------
$RequiredFiles = @(
    ".\sql\01_create_schemas.sql",
    ".\sql\02_create_raw_tables.sql",
    ".\sql\03_staging_tables.sql",
    ".\sql\04_dimension_tables.sql",
    ".\sql\05_fact_sales.sql",
    ".\sql\06_views.sql",
    ".\sql\07_data_quality_checks.sql",
    ".\python\ingest_olist.py",
    ".\python\generate_date_dim.py",
    ".\data\raw\olist_orders_dataset.csv",
    ".\data\raw\olist_order_items_dataset.csv",
    ".\data\raw\olist_order_payments_dataset.csv",
    ".\data\raw\olist_customers_dataset.csv",
    ".\data\raw\olist_products_dataset.csv",
    ".\data\raw\product_category_name_translation.csv",
    ".\docker-compose.yml",
    ".\requirements.txt"
)

Write-Host "`nChecking required files..." -ForegroundColor Green
foreach ($file in $RequiredFiles) {
    if (-not (Test-Path $file)) {
        throw "Required file not found: ${file}"
    }
}
Write-Host "All required files found." -ForegroundColor Green

# -----------------------------
# Step 1: Full reset
# -----------------------------
Write-Host "`n[1/10] Stopping containers and removing volume..." -ForegroundColor Green
docker compose down -v
if ($LASTEXITCODE -ne 0) {
    throw "docker compose down -v failed"
}

Write-Host "`n[2/10] Starting fresh PostgreSQL container..." -ForegroundColor Green
docker compose up -d
if ($LASTEXITCODE -ne 0) {
    throw "docker compose up -d failed"
}

Write-Host "`nWaiting for PostgreSQL container to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# -----------------------------
# Step 2: Create schemas + raw tables
# -----------------------------
Write-Host "`n[3/10] Creating schemas..." -ForegroundColor Green
Run-SqlFileRaw ".\sql\01_create_schemas.sql"

Write-Host "`n[4/10] Creating raw tables..." -ForegroundColor Green
Run-SqlFileRaw ".\sql\02_create_raw_tables.sql"

# -----------------------------
# Step 3: Ingest raw data
# -----------------------------
Write-Host "`n[5/10] Loading CSV files into raw schema..." -ForegroundColor Green
Run-PythonScript ".\python\ingest_olist.py"

# -----------------------------
# Step 4: Build staging + date dimension
# -----------------------------
Write-Host "`n[6/10] Building staging layer..." -ForegroundColor Green
Run-SqlFileRaw ".\sql\03_staging_tables.sql"

Write-Host "`n[7/10] Building date dimension..." -ForegroundColor Green
Run-PythonScript ".\python\generate_date_dim.py"

# -----------------------------
# Step 5: Build mart dimensions + fact
# -----------------------------
Write-Host "`n[8/10] Building dimension tables..." -ForegroundColor Green
Copy-And-RunSqlFile ".\sql\04_dimension_tables.sql" "/tmp/04_dimension_tables.sql"

Write-Host "`n[9/10] Building fact table..." -ForegroundColor Green
Copy-And-RunSqlFile ".\sql\05_fact_sales.sql" "/tmp/05_fact_sales.sql"

# -----------------------------
# Step 6: Views + checks
# -----------------------------
Write-Host "`n[10/10] Building reporting views..." -ForegroundColor Green
Run-SqlFileRaw ".\sql\06_views.sql"

Write-Host "`nRunning data quality checks..." -ForegroundColor Green
Run-SqlFileRaw ".\sql\07_data_quality_checks.sql"

# -----------------------------
# Final row count summary
# -----------------------------
Write-Host "`nFinal mart row counts..." -ForegroundColor Cyan
docker exec -i $ContainerName psql -U $DbUser -d $DbName -c "
SELECT 'fact_sales'  AS table_name, COUNT(*) AS row_count FROM mart.fact_sales
UNION ALL
SELECT 'dim_product' AS table_name, COUNT(*) AS row_count FROM mart.dim_product
UNION ALL
SELECT 'dim_customer' AS table_name, COUNT(*) AS row_count FROM mart.dim_customer
UNION ALL
SELECT 'dim_region'  AS table_name, COUNT(*) AS row_count FROM mart.dim_region
UNION ALL
SELECT 'dim_segment' AS table_name, COUNT(*) AS row_count FROM mart.dim_segment
UNION ALL
SELECT 'dim_date'    AS table_name, COUNT(*) AS row_count FROM mart.dim_date
ORDER BY table_name;
"

if ($LASTEXITCODE -ne 0) {
    throw "Final row count query failed"
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "REBUILD COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan