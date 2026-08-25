<#
.SYNOPSIS
    CodeAlpha Task 2 - Jenkins Remoting Helper Script (PowerShell)
#>

param (
    [Parameter(Position=0)]
    [ValidateSet("build", "start", "stop", "restart", "status", "nodes", "logs-controller", "logs-agent", "trigger-job", "clean", "help")]
    [string]$Action = "help"
)

function Show-Help {
    Write-Host "`n=== CodeAlpha Jenkins Remoting Cluster Helper ===" -ForegroundColor Cyan
    Write-Host "Usage: .\manage.ps1 [action]`n" -ForegroundColor Yellow
    Write-Host "Available Actions:"
    Write-Host "  build           - Build Controller & Agent Docker images"
    Write-Host "  start           - Start Jenkins Controller and Agent cluster"
    Write-Host "  stop            - Stop the Jenkins cluster"
    Write-Host "  restart         - Restart the cluster"
    Write-Host "  status          - Show status of Jenkins containers"
    Write-Host "  nodes           - Check Jenkins Nodes in UI / logs"
    Write-Host "  logs-controller - Stream Jenkins Controller logs"
    Write-Host "  logs-agent      - Stream Jenkins Agent logs"
    Write-Host "  trigger-job     - Trigger the distributed build job via CLI/API"
    Write-Host "  clean           - Remove containers, images, and volumes"
    Write-Host "=================================================`n"
}

switch ($Action) {
    "build" {
        Write-Host "--> Building Jenkins Controller & SSH Agent Images..." -ForegroundColor Cyan
        docker compose build
    }
    "start" {
        Write-Host "--> Starting Jenkins Distributed Cluster..." -ForegroundColor Green
        docker compose up -d
        Write-Host "`n--> Jenkins is booting up!" -ForegroundColor Yellow
        Write-Host "--> Web UI will be available at: http://localhost:8082" -ForegroundColor Cyan
        Write-Host "--> Login Credentials: Username = admin | Password = admin" -ForegroundColor Green
    }
    "stop" {
        Write-Host "--> Stopping Jenkins Cluster..." -ForegroundColor Yellow
        docker compose stop
    }
    "restart" {
        Write-Host "--> Restarting Jenkins Cluster..." -ForegroundColor Cyan
        docker compose restart
    }
    "status" {
        Write-Host "`n--> Jenkins Containers Status:" -ForegroundColor Cyan
        docker ps -a --filter "name=jenkins"
    }
    "nodes" {
        Write-Host "`n--> Jenkins Nodes Page:" -ForegroundColor Cyan
        Write-Host "Visit http://localhost:8082/manage/computer/ to inspect connected agent nodes." -ForegroundColor Yellow
    }
    "logs-controller" {
        docker compose logs -f jenkins-controller
    }
    "logs-agent" {
        docker compose logs -f jenkins-agent
    }
    "trigger-job" {
        Write-Host "--> Triggering distributed build job..." -ForegroundColor Cyan
        try {
            $cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("admin:admin"))
            $authHeader = @{ Authorization = "Basic $cred" }
            $crumb = Invoke-RestMethod -Uri "http://localhost:8082/crumbIssuer/api/json" -Headers $authHeader -SessionVariable sess
            $headers = @{
                Authorization = "Basic $cred"
                $crumb.crumbRequestField = $crumb.crumb
            }
            $res = Invoke-WebRequest -Uri "http://localhost:8082/job/CodeAlpha-Distributed-Build-Job/build" -Method Post -Headers $headers -WebSession $sess -UseBasicParsing
            Write-Host "Job Triggered Successfully! (HTTP $($res.StatusCode))" -ForegroundColor Green
            Write-Host "Check live progress at: http://localhost:8082/job/CodeAlpha-Distributed-Build-Job/" -ForegroundColor Yellow
        } catch {
            Write-Host "Failed to trigger job: $_" -ForegroundColor Red
        }
    }
    "clean" {
        Write-Host "--> Cleaning up Jenkins containers..." -ForegroundColor Yellow
        docker compose down --rmi local --volumes --remove-orphans
        Write-Host "--> Cleaned successfully." -ForegroundColor Green
    }
    Default {
        Show-Help
    }
}
