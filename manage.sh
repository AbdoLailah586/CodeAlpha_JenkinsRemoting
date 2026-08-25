#!/usr/bin/env bash
ACTION="${1:-help}"

case "$ACTION" in
    build)
        echo "--> Building Jenkins Controller & Agent Images..."
        docker compose build
        ;;
    start)
        echo "--> Starting Jenkins Cluster..."
        docker compose up -d
        echo "--> Web UI at: http://localhost:8082 (admin/admin)"
        ;;
    stop)
        docker compose stop
        ;;
    restart)
        docker compose restart
        ;;
    status)
        docker ps -a --filter "name=jenkins"
        ;;
    logs-controller)
        docker compose logs -f jenkins-controller
        ;;
    logs-agent)
        docker compose logs -f jenkins-agent
        ;;
    trigger-job)
        CRUMB=$(curl -u admin:admin -s "http://localhost:8082/crumbIssuer/api/json" | grep -o '"crumb":"[^"]*' | cut -d'"' -f4)
        CRUMB_FIELD=$(curl -u admin:admin -s "http://localhost:8082/crumbIssuer/api/json" | grep -o '"crumbRequestField":"[^"]*' | cut -d'"' -f4)
        curl -X POST -u admin:admin -H "${CRUMB_FIELD}:${CRUMB}" http://localhost:8082/job/CodeAlpha-Distributed-Build-Job/build
        echo "--> Triggered job! Check at http://localhost:8082/job/CodeAlpha-Distributed-Build-Job/"
        ;;
    clean)
        docker compose down --rmi local --volumes --remove-orphans
        ;;
    *)
        echo "Usage: ./manage.sh {build|start|stop|restart|status|logs-controller|logs-agent|trigger-job|clean}"
        ;;
esac
