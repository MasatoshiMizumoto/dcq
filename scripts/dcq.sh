#!bin/bash

dcq() {
  local name
  if [ -z "$1" ]; then
    echo """
Name:
  dcq - Docker Compose Quick

Usage:
  dcq <command> <app_name>

Commands:
  l | list      list all apps
  c | create    create Dockerfile/docker-compose.yml/any directories
  u | up        docker-compose up with detach
  s | shell     attach shel
  d | down      docker-compose down
    """
    return 1
  fi

  case $1 in
  # list
    "l" | "list")
      ls -1r $(ghq list -p dcq)/docker-compose-* | xargs -I{} basename "{}" | sed 's/docker-compose-//' | cut -d '.' -f 1
    ;;
  # create
    "c" | "create")
      if [ -z "$2" ]; then
        echo """
Usage:
  dcq c <app_name>
"""
      else
        mkdir $(ghq list -p dcq)/contexts/$2
        mkdir $(ghq list -p dcq)/volumes/$2
        touch $(ghq list -p dcq)/contexts/$2/Dockerfile-$2
        touch $(ghq list -p dcq)/docker-compose-$2.yml
        yml_template=$(
cat <<EOS
# This is sample docker-compose.yml

version: "3.9"
services:
  ${2}-front:
    build:
      context: ./contexts/${2}
      dockerfile: Dockerfile-${2}
    tty: true
    image: ${2}
    container_name: ${2}
    volumes:
      - ./volumes/${2}/app-dir:/app-dir
EOS
)
        echo "${yml_template}" > $(ghq list -p dcq)/docker-compose-$2.yml

        echo """
Create finish.

Please modify 'Dockerfile-$2' and 'docker-compose-$2.yml'.
"""
      fi
      ;;
  # up
    "u" | "up")
      if [ "$2" ]; then
        name=$2
      else
        name=$(ls -1r $(ghq list -p dcq)/docker-compose-* | xargs -I{} basename "{}" | sed 's/docker-compose-//' | cut -d '.' -f 1 | fzf)
      fi

      if  [ $? = 0 ]; then
        docker-compose -f $(ghq list -p dcq)/docker-compose-$name.yml up -d --build
      fi
      ;;
  # shell
    "s" | "shell")
      if [ "$2" ]; then
        name=$2
      else
        name=$(ls -1r $(ghq list -p dcq)/docker-compose-* | xargs -I{} basename "{}" | sed 's/docker-compose-//' | cut -d '.' -f 1 | fzf)
      fi

      if  [ $? = 0 ]; then
        docker exec -it $name bash
      fi
    ;;
  # down
    "d" | "down")
      if [ "$2" ]; then
        name=$2
      else
        name=$(ls -1r $(ghq list -p dcq)/docker-compose-* | xargs -I{} basename "{}" | sed 's/docker-compose-//' | cut -d '.' -f 1 | fzf)
      fi

      if  [ $? = 0 ]; then
        docker-compose -f $(ghq list -p dcq)/docker-compose-$name.yml down
      fi
    ;;
  esac
}
