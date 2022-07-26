### Описание действий
  +  Terraform
1. Подготовить инфраструктуру на базе облачного провайдера YandexCloud, с помощью Terraform (настроить все id, пароли, ключи, зарезервировать ip либо раскомментировать в main.tf блок с созданием внешнего ip и привязку к ноде с reverse proxy ) Выбрать workspace (stage или prod)   
  +  Ansible.   
1. Предварительно настроить все переменные в defaults каждой роли (пароли, domain_name), проверить доступность хостов 
2. Запустить плейбук revproxy.yml для настройки Nginx Reverse Proxy. Роль настроит iptables и nat для возможности другим инстансам выходить в интернет через этот сервер, настроит Nginx, сгенерит сертификаты letsencrypt для всех доменов/поддоменов, настроит все upstreams
3. Запустить плейбук mysql.yml для настройки кластера Mysql. Роль настроит кластер MySQL для дальнейшей установки Wordpress.
6. Запустить плейбук wordpress.yml для установки Wordpress. (Зайти в панель Wordpress поменять пароль ) 
7. Запустить плейбук gitlab.yml для установки и подготовки среды для Gitlab CE. 
8. Запустить плейбук sshrunner.yml для установки ssh сертификатов для работы runner и подключения к веб серверу для деплоя (wordpress), создаст пользователя gitlab-runner для установки, подключений и регистрации runner.
9.  Запустить плейбук runner.yml для установки и подготовки среды для Gitlab Runner. 
10. Зайти в gitlab ce , поменять пароль, создать пользователя, группу, проект и Получить регистрационный токен для этого проекта и runner
11. Зарегистрировать runner на сервере с установленным runner (можно это сделать автоматически с помощью роли, но есть некоторые проблемы вытащить регистрационные токены для конретного проекта , пароли ,создать через api пользователя и получить api токены и тд. это отдельная тема и думаю не хватит времени выделленного на решение задач по диплому) (ниже пример команд для регисрации)
12. Настроить pipeline (ниже пример .gitlab-ci.yml file)
13. Запустить плейбук monitoring.yml для настройки мониторинга инфраструктуры с помощью стека: Prometheus, Alert Manager и Grafana. Роль усатновит на все инстансы nodeexporter (кроме самого сервера мониторинга, там уже есть nodeexporter).


Регистрация runner:    
``` sudo gitlab-runner register --url http://gitlab.ldevops.ru/ --registration-token $REGISTRATION_TOKEN ```    

пример .gitlab-ci.yml file (поменять путь до проекта, путь до папки на веб сервере куда будет копироваться / обновляться код и свой домен):     
```
stages:          # List of stages for jobs, and their order of execution
  - deploy
deploy-job:      # This job runs in the deploy stage.
  stage: deploy  # It only runs when *both* jobs in the test stage complete successfully.
  script:
    - echo "Deploying application..."
    - rsync -avzu --no-perms --no-owner --no-group --exclude ".git*" --exclude ".gitlab-ci.yml" ~/builds/y6Pybxpp/0/wordpress1/wordpress/* /var/www/yourdomain.ru/test
    - echo "Application successfully deployed."
 ```   
Для копирования кода в необходимую папку на вебсервере используется rsync так как позволяет отслеживать и копировать только изменённый файлы, сжимать и тд.     
